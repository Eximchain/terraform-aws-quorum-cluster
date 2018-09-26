package softwareupgrade

import (
	"bytes"
	"errors"
	"fmt"
	"io"
	"io/ioutil"
	"os"
	"path"
	"strings"
	"sync"
	"time"

	"golang.org/x/crypto/ssh"
)

// The SSHConfig-related functions rely on the presence of pkill and pgrep on the target system
// pgrep and pkill is assumed to be located in the environmental PATH

type (
	// SSHConfig is used to carry the username, privatekey and the host to connect to.
	SSHConfig struct {
		user              string
		sudo              string
		privateKey        string
		HostIPOrAddr      string
		RemoteOS          string
		session           *ssh.Session
		client            *ssh.Client
		autoOpenSession   bool
		parsedKey         ssh.Signer
		keepAliveDuration time.Duration
		maxRetries        int
		sleepBtwRetries   int64
	}

	// ResProcessStatus provides the status
	ResProcessStatus struct {
		Exists bool
		err    error
	}
)

var (
	sshConfigCache map[string]*SSHConfig
	sshTimeout     time.Duration
)

// EnsureSSHConfigCache initializes the sshConfigCache so it can be used to cache SSHConfig
func EnsureSSHConfigCache() {
	if sshConfigCache == nil {
		sshConfigCache = make(map[string]*SSHConfig)
	}
}

// ClearSSHConfigCache closes the SSH session and client connection in the sshConfigCache
func ClearSSHConfigCache() {
	if sshConfigCache != nil {
		for k, v := range sshConfigCache {
			v.Close()
			v.Clear()
			delete(sshConfigCache, k)
		}
	}
}

// MakeSudo enables Sudo on Copy, CreateDirectory, and ChangeFileOwnership and Run
func (c *SSHConfig) MakeSudo() (result *SSHConfig) {
	c.sudo = "sudo "
	return c
}

// ClearSudo removes Sudo from Copy, CreateDirectory, ChangeFileOwnership and Run
func (c *SSHConfig) ClearSudo() (result *SSHConfig) {
	c.sudo = ""
	return c
}

// SetMaxRetries sets the max. no. of retries on connection failure
func (c *SSHConfig) SetMaxRetries(retries int) (result *SSHConfig) {
	c.maxRetries = retries
	result = c
	return
}

// SetSleepBtwRetries sets the max. no. of sleep between connection retries
func (c *SSHConfig) SetSleepBtwRetries(sleepMS int64) (result *SSHConfig) {
	c.sleepBtwRetries = sleepMS
	result = c
	return
}

// NewSSHConfig initializes a SSHConfig structure for executing a Run or Copy* command.
func NewSSHConfig(user, KeyFilename, HostIPOrAddr string) (result *SSHConfig) {
	if expandedKeyFilename, err := Expand(KeyFilename); err == nil {
		KeyFilename = expandedKeyFilename
	}
	mapName := HostIPOrAddr + user + KeyFilename

	EnsureSSHConfigCache() // guard against forgetful devs!
	result = sshConfigCache[mapName]
	if result != nil {
		return
	}

	privateKey := []byte{}
	var err error
	privateKey, err = ReadDataFromFile(KeyFilename)
	result = &SSHConfig{
		user:              user,
		HostIPOrAddr:      HostIPOrAddr,
		keepAliveDuration: 5 * time.Second,
		maxRetries:        3,
		sleepBtwRetries:   15,
	}
	if err == nil {
		result.privateKey = string(privateKey)
	}
	result.EnableAutoOpen()
	sshConfigCache[mapName] = result
	return
}

func NewSSHConfigKeyBytes(user string, KeyBytes []byte, HostIPOrAddr string) (result *SSHConfig) {
	mapName := HostIPOrAddr + user

	EnsureSSHConfigCache() // guard against forgetful devs!
	result = sshConfigCache[mapName]
	if result != nil {
		return
	}

	privateKey := []byte{}
	var err error
	privateKey = KeyBytes
	result = &SSHConfig{
		user:              user,
		HostIPOrAddr:      HostIPOrAddr,
		keepAliveDuration: 5 * time.Second,
		maxRetries:        3,
		sleepBtwRetries:   15,
	}
	if err == nil {
		result.privateKey = string(privateKey)
	}
	result.EnableAutoOpen()
	sshConfigCache[mapName] = result
	return
}

// Clear clears the privateKey, user and host stored in the configuration.
func (sshConfig *SSHConfig) Clear() {
	sshConfig.privateKey = ""
	sshConfig.user = ""
	sshConfig.HostIPOrAddr = ""
}

// SetKeepAlive sets the duration to send a keep-alive message on a SSH connection
func (sshConfig *SSHConfig) SetKeepAlive(t time.Duration) {
	sshConfig.keepAliveDuration = t
}

// Close closes both the session and the connection to the client.
func (sshConfig *SSHConfig) Close() {
	sshConfig.CloseSession()
	sshConfig.CloseClient()
}

// CloseClient closes the client that was opened implicitly during OpenSession.
func (sshConfig *SSHConfig) CloseClient() {
	if sshConfig.client != nil {
		sshConfig.client.Close()
		sshConfig.client = nil
	}
}

// CloseSession closes the session that was opened using OpenSession
func (sshConfig *SSHConfig) CloseSession() {
	if sshConfig.session != nil {
		sshConfig.session.Close()
		sshConfig.session = nil
	}
}

func (sshConfig *SSHConfig) internalConnect() (err error) {
	clientConfig, err := sshConfig.getClientConfig()
	if err != nil {
		return err
	}

	sshConfig.CloseSession()

	if sshConfig.client == nil {
		sshConfig.client, err = ssh.Dial("tcp", sshConfig.HostIPOrAddr+":22", clientConfig)
		if err != nil {
			return err
		}

		// this sends keepalive packets every 5 seconds(configurable) so that the client doesn't timeout
		// there's no useful response from these, so abort if there's an error
		go func(client *ssh.Client) {
			t := time.NewTicker(sshConfig.keepAliveDuration)
			defer t.Stop()
			for {
				<-t.C
				_, _, err1 := client.Conn.SendRequest("keepalive@golang.org", true, nil)
				if err1 != nil {
					err = err1
					return
				}
			}
		}(sshConfig.client)
	}

	sshConfig.session, err = sshConfig.client.NewSession()
	return err
}

// Connect connects to the given host specified in the configuration
func (sshConfig *SSHConfig) Connect() (err error) {
breakRetry:
	for retries := 0; retries < sshConfig.maxRetries; retries++ {
		err = sshConfig.internalConnect()
		if err == nil {
			break breakRetry
		}
		time.Sleep(time.Duration(sshConfig.sleepBtwRetries) * time.Millisecond)
	}
	return
}

// Copy copies the contents of the specified io.Reader to the given remote location.
// Requires a session to be opened already, unless autoOpenSession is set in the SSHConfig, in which case, Copy connects to the specified host given in the SSHConfig.
// permissions is a string, like 0644, or 0700, etc.
func (sshConfig *SSHConfig) Copy(reader io.Reader, remotePath string, permissions string, size int64) (err error) {
	if sshConfig.session == nil {
		if !sshConfig.autoOpenSession {
			panic("No SSH session opened.")
		}
		if err1 := sshConfig.Connect(); err1 != nil {
			return err1
		}
	}
	if len(permissions) != 4 {
		return errors.New("permissions need to be 4 characters")
	}

	filename := path.Base(remotePath)
	if filename == "" {
		return errors.New("Remote filename is empty")
	}

	directory := path.Dir(remotePath)

	var (
		wg           sync.WaitGroup
		writtenCount int64
	)
	wg.Add(1)
	go func() {
		defer wg.Done()
		var w io.WriteCloser
		w, err = sshConfig.session.StdinPipe()
		if err != nil {
			return
		}
		defer w.Close()
		fmt.Fprintln(w, "C"+permissions, size, filename)
		writtenCount, err = io.Copy(w, reader)
		if err != nil {
			return
		}
		if writtenCount != size {
			// some error here
			msg := fmt.Sprintf("Copied size: %d not equal to file size: %d", writtenCount, size)
			err = errors.New(msg)
		}
		fmt.Fprintln(w, "\x00")  // Send 0 byte to indicate EOF
		sshConfig.CloseSession() // A session only accepts one call to Run/Shell, etc, so close the session
	}()

	cmd := fmt.Sprintf("%s/usr/bin/scp -t %s", sshConfig.sudo, directory)
	sshConfig.session.Run(cmd)
	wg.Wait() // waits for the coroutine to complete
	return
}

// CopyBytesToFile copies the contents of the given []byte to the specified remotePath
func (sshConfig *SSHConfig) CopyBytesToFile(contentBytes []byte, remotePath string, permissions string) (err error) {
	byteReader := bytes.NewReader(contentBytes)
	err = sshConfig.Copy(byteReader, remotePath, permissions, int64(len(contentBytes)))
	return
}

// CopyBytesToFileAndVerify copies the contents of the given []byte to the specified remotePath, and verifies that it's on the remote side
func (sshConfig *SSHConfig) CopyBytesToFileAndVerify(contentBytes []byte, remotePath string, permissions string) (err error) {
	err = sshConfig.CopyBytesToFile(contentBytes, remotePath, permissions)
	if err == nil {
		if contents, err1 := sshConfig.ReadBytesFromFile(remotePath); err1 == nil {
			result := bytes.Compare(contents, contentBytes)
			if result != 0 {
				err = errors.New("File did not transfer successfully")
				return
			}
		}
	}
	return
}

// CopyFile copies the contents of an io.Reader to a remote location, the length is determined by reading the io.Reader until EOF is reached.
// if the file length is known in advance, use "Copy" instead.
func (sshConfig *SSHConfig) CopyFile(fileReader io.Reader, remotePath string, permissions string) error {
	contentBytes, _ := ioutil.ReadAll(fileReader)
	return sshConfig.CopyBytesToFile(contentBytes, remotePath, permissions)
}

// CopyFromFile copies the contents of an os.File to a remote location, it will get the length of the file by looking it up from the filesystem.
func (sshConfig *SSHConfig) CopyFromFile(file os.File, remotePath string, permissions string) error {
	stat, err := file.Stat()
	if err == nil {
		err = sshConfig.Copy(&file, remotePath, permissions, stat.Size())
	}
	return err
}

// CopyLocalFileToRemoteFile copies the given local filename to the remote filename with the given permissions
// localFilename must be the filename of a local file and remoteFilename must be the remote filename, not a directory.
func (sshConfig *SSHConfig) CopyLocalFileToRemoteFile(localFilename, remoteFilename, permissions string) error {
	if expandedLocalFilename, err := Expand(localFilename); err == nil {
		localFilename = expandedLocalFilename
	} else {
		return err
	}
	file, err := os.Open(localFilename)
	if err != nil {
		return err
	}
	defer file.Close()
	err = sshConfig.CopyFromFile(*file, remoteFilename, permissions)
	return err
}

// CreateDirectory creates the specified directory on the host specified in the given SSHConfig
func (sshConfig *SSHConfig) CreateDirectory(path string) (err error) {
	cmd := fmt.Sprintf("%smkdir -p %s", sshConfig.sudo, path)
	_, err = sshConfig.Run(cmd)
	return
}

// Destroy closes the connection to the client and clears the privatKey, user and host stored in the configuration.
func (sshConfig *SSHConfig) Destroy() {
	sshConfig.Close()
	sshConfig.Clear()
}

// DirectoryExists verifies that the given path exists on the host specified in the given SSHConfig
// Might not be able to deal with symlink as a directory.
func (sshConfig *SSHConfig) DirectoryExists(path string) (result bool, err error) {

	// stat returns "No such file or directory" if the file/dir doesn't exist
	// otherwise, it returns some file system related information about the file/dir
	cmd := fmt.Sprintf("stat %s", path)
	cmdResult, err := sshConfig.Run(cmd)
	if err == nil {
		result = !strings.Contains(cmdResult, "No such file or directory") // DO NOT LOCALIZE
	}
	return
}

// DisableAutoOpen sets the autoOpenSession flag to false so tat sessions are not automatically opened.
func (sshConfig *SSHConfig) DisableAutoOpen() {
	sshConfig.autoOpenSession = false
}

// EnableAutoOpen sets the autoOpenSession flag to true so that sessions are automatically opened.
func (sshConfig *SSHConfig) EnableAutoOpen() {
	sshConfig.autoOpenSession = true
}

// FileExists verifies that the given file exists on the host specified in the given SSHConfig
// Able to handle symlink. Tested.
func (sshConfig *SSHConfig) FileExists(file string) (result bool, err error) {
	return sshConfig.DirectoryExists(file)
}

func (sshConfig *SSHConfig) getClientConfig() (*ssh.ClientConfig, error) {
	var key ssh.Signer
	if sshConfig.parsedKey == nil {
		var err error
		key, err = ssh.ParsePrivateKey([]byte(sshConfig.privateKey))
		if err != nil {
			return nil, err
		}
		sshConfig.parsedKey = key
	} else {
		key = sshConfig.parsedKey
	}
	// Authentication
	config := &ssh.ClientConfig{
		User: sshConfig.user,
		Auth: []ssh.AuthMethod{
			ssh.PublicKeys(key),
		},
		HostKeyCallback: ssh.InsecureIgnoreHostKey(),
	}
	if sshTimeout != 0 {
		config.Timeout = sshTimeout
	}
	return config, nil
}

// GetOS returns the OS that is running on the host specified in the given SSHConfig
func (sshConfig *SSHConfig) GetOS() string {
	if sshConfig.RemoteOS == "" {
		temp, err := sshConfig.Run("uname") // Works only on macOS / Linux systems
		if err != nil {
			return ""
		}
		temp = strings.Replace(temp, "\n", "", -1)
		sshConfig.RemoteOS = strings.ToLower(temp)
	}
	return sshConfig.RemoteOS
}

// getFileOwnership returns the user and group of the specified filename like so:
// user:group
func (sshConfig *SSHConfig) getFileOwnership(filename string) (owner string, err error) {
	cmd := fmt.Sprintf("stat --printf=%%U:%%G %s", filename)
	owner, err = sshConfig.Run(cmd)
	return
}

func (sshConfig *SSHConfig) getFilePermissions(filename string) (permissions string, err error) {
	cmd := fmt.Sprintf("stat -c%%04a %s", filename)
	permissions, err = sshConfig.Run(cmd)
	return
}

func (sshConfig *SSHConfig) changeFileOwnership(filename, owner string) (err error) {
	cmd := fmt.Sprintf("%schown %s %s", sshConfig.sudo, owner, filename)
	_, err = sshConfig.Run(cmd)
	return
}

// InteractiveSession must always be followed by a deferred call to sshConfig.Destroy() or
// sshConfig.Close()
func (sshConfig *SSHConfig) InteractiveSession() {
	sshConfig.OpenSession()
}

func (sshConfig *SSHConfig) internalExists(invert, funcName, path string) (result bool, err error) {
	const expectedResult string = "Yes"
	pathExistsCmd := fmt.Sprintf(`[ %s -%s %s ] && echo -n "%s"`, invert, funcName, path, expectedResult)
	runResult, err := sshConfig.Run(pathExistsCmd)
	if err == nil {
		result = strings.Contains(runResult, expectedResult)
		return
	}
	result = false
	return
}

func (sshConfig *SSHConfig) internalSum(app, path string) (result string, err error) {
	command := fmt.Sprintf("%s %s", app, path)
	runResult, err := sshConfig.Run(command)
	if err != nil {
		return
	}
	splitStrings := strings.Split(runResult, " ")
	result = splitStrings[0]
	return
}

// Interrupt sends the interrupt signal to the given processName running on the host in the given SSHConfig
func (sshConfig *SSHConfig) Interrupt(processName string) (result string, err error) {
	result, err = sshConfig.Signal(processName, CInt)
	return
}

// Md5sum calculates the MD5 for the given path on the host specified in the given SSHConfig
func (sshConfig *SSHConfig) Md5sum(path string) (result string, err error) {
	return sshConfig.internalSum("md5sum", path)
}

// OpenSession opens a SSH session to the host specified in the given SSHConfig
func (sshConfig *SSHConfig) OpenSession() (*ssh.Session, *ssh.Client, error) {
	err := sshConfig.Connect()
	if err != nil {
		return nil, nil, err
	}
	return sshConfig.session, sshConfig.client, nil
}

// ProcessStatus detects if a process is running in the environment specified in the SSHConfig.
func (sshConfig *SSHConfig) ProcessStatus(processName string) *ResProcessStatus {
	cmd := fmt.Sprintf("pgrep -l %s", processName)
	runResult, err := sshConfig.Run(cmd)
	Result := &ResProcessStatus{}
	if err == nil {
		Result.Exists = runResult != ""
	} else {
		Result.err = err
	}
	return Result
}

// ReadsBytesFromFile reads the contents of a file.
func (sshConfig *SSHConfig) ReadBytesFromFile(remotePath string) (result []byte, err error) {
	cmd := fmt.Sprintf("cat %s", remotePath)
	result, err = sshConfig.rawRun(cmd)
	return
}

// Run runs a command on the given SSH environment, usage: output, err := Run("ls")
// Automatically closes the client and session
func (sshConfig *SSHConfig) rawRun(cmd string) ([]byte, error) {
	session, _, err := sshConfig.OpenSession()
	if err != nil {
		return []byte{}, err
	}

	// sshConfig.client = nil // remove copy of the client
	// defer client.Close()

	sshConfig.session = nil // remove copy of the session
	defer session.Close()

	var b bytes.Buffer
	session.Stdout = &b // get output
	err = session.Run(cmd)
	return b.Bytes(), err
}

// Run runs a command on the given SSH environment, usage: output, err := Run("ls")
// Automatically closes the client and session
func (sshConfig *SSHConfig) Run(cmd string) (string, error) {
	b, err1 := sshConfig.rawRun(cmd)
	return string(b), err1
}

// Sha256sum calculates the SHA256 for the given path on the host specified in the given SSHConfig
func (sshConfig *SSHConfig) Sha256sum(path string) (result string, err error) {
	return sshConfig.internalSum("sha256sum", path)
}

// Signal sends the specified signal to the given processName…
func (sshConfig *SSHConfig) Signal(processName, signal string) (result string, err error) {
	command := fmt.Sprintf("%s -%s %s", CPKill, signal, processName)
	result, err = sshConfig.Run(command)
	return
}

// Sum calculates the checksum of any given file on the host specified in the given SSHConfig
func (sshConfig *SSHConfig) Sum(path string) (result string, err error) {
	return sshConfig.internalSum("sum", path)
}

// SetSSHTimeout sets the global SSH timeout, which will be picked up by when NewSSHConfig is called.
func SetSSHTimeout(t time.Duration) {
	sshTimeout = t
}
