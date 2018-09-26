package softwareupgrade

import (
	"fmt"
	"io/ioutil"
	"net"
	"os/exec"
	"runtime"
	"testing"
	"time"
)

func defaultSSHConfig() *SSHConfig {
	return NewSSHConfig("$USER", "~/Downloads/nodes/localhost", "localhost")
}

func Test_Run(t *testing.T) {
	sshConfig := defaultSSHConfig()
	result, err := sshConfig.Run("ls -al /")
	if err == nil {
		fmt.Println(result)
	} else {
		t.Fatalf("Error: %v", err)
	}
}

func TestSshConfig_remoteKill(t *testing.T) {
	var (
		cmd *exec.Cmd
		err error
	)
	switch runtime.GOOS { // assumes remote OS runs the same OS as the runtime OS
	case "darwin":
		{
			cmd = exec.Command("/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal")
		}
	default:
		{
			t.Fatal("Platform code not defined!")
		}
	}
	if cmd != nil {
		err = cmd.Start()
		time.Sleep(1 * time.Second)
	}
	sshConfig := defaultSSHConfig()
	result, err := sshConfig.Signal("Terminal", "int")
	if err == nil {
		fmt.Println(result)
	} else {
		t.Fatalf("Error: %v", err)
	}
}

func TestSshConfig_Interrupt(t *testing.T) {
	var (
		cmd *exec.Cmd
		err error
	)
	sshConfig := defaultSSHConfig()
	if !sshConfig.ProcessStatus("geth").Exists {
		switch os := runtime.GOOS; os {
		case "darwin":
			{
				cmd = exec.Command("~/Downloads/nodes/geth", "--syncmode fast")
			}
		case "linux":
			{

			}
		default:
			{
				t.Fatal("Platform code not defined!")
			}
		}
		if cmd != nil {
			err = cmd.Start()
			time.Sleep(1 * time.Second)
		}
	}
	result, err := sshConfig.Interrupt("geth")
	if err == nil {
		fmt.Println(result)
	} else {
		t.Fatalf("Error: %v", err)
	}
}

func TestSSHConfig_ProcessExists(t *testing.T) {
	// The below is working. Due to being run automatically by the auto-test, it's commented out.
	// sshConfig := defaultSSHConfig()
	// result := sshConfig.ProcessStatus("vault")
	// if result.err != nil {
	// 	t.Fatal("ProcessExists failed!")
	// }
	// fmt.Printf("Vault exists: %v", result.Exists)
}

func TestSSHConfig_Close(t *testing.T) {
	sshConfig := NewSSHConfig("ubuntu", "~/.ssh/quorum", "ec2-52-201-244-132.compute-1.amazonaws.com")
	sshConfig.OpenSession()
	if sshConfig.session == nil || sshConfig.client == nil {
		t.Fatal("Either client or session is not opened successfully!")
	}
	sshConfig.Close()
	if sshConfig.session != nil || sshConfig.client != nil {
		t.Fatal("Failed to close either client or session successfully!")
	}
}

func TestSSHConfig_CopyLocalFileToRemotePath(t *testing.T) {
	sshConfig := NewSSHConfig("ubuntu", "~/.ssh/quorum", "ec2-52-201-244-132.compute-1.amazonaws.com")
	sshConfig.CopyLocalFileToRemoteFile("~/Documents/GitHub/SoftwareUpgrade/src/SoftwareUpgrade/sshSession_test.go",
		"/tmp/sshSession_test.go", "0644")
	sshConfig.CopyLocalFileToRemoteFile("~/Documents/GitHub/SoftwareUpgrade/src/SoftwareUpgrade/sshSession.go",
		"/tmp/sshSession.go", "0644")
}

func TestSSHConfig_DirectoryExists(t *testing.T) {
	sshConfig := NewSSHConfig("ubuntu", "~/.ssh/quorum", "18.232.179.208")

	tempDir, err := ioutil.TempDir("", "")
	if err == nil {
		result, err := sshConfig.DirectoryExists(tempDir) // this probably doesn't exist
		if err == nil {
			if !result {
				t.Fatalf("Directory %s shouldn't exist but does", tempDir)
			}
		}
	}

	result, err := sshConfig.DirectoryExists("/tmp") // this should exist on every Linux system
	if !result || err != nil {
		t.Fatal("DirectoryExists failed.")
	}

	sshConfig = NewSSHConfig("ubuntu", "~/.ssh/quorum", "invalid-host-unresolvable")
	result, err = sshConfig.DirectoryExists("/tmp") // this should exist on every Linux system, however, invalid-host-unresolvable shouldn't be resolvable.
	if err == nil {
		t.Fatal("DirectoryExists failed.")
	}

}

func TestSSHConfig_FileExists(t *testing.T) {
	sshConfig := NewSSHConfig("ubuntu", "~/.ssh/quorum", "18.232.179.208")
	result, err := sshConfig.FileExists("/vmlinuz") // this should exist on every Linux system
	if !result || err != nil {
		t.Fatal("FileExists failed.")
	}

	sshConfig = NewSSHConfig("ubuntu", "~/.ssh/quorum", "invalid-host-unresolvable")
	result, err = sshConfig.FileExists("/vmlinuz") // this should exist on every Linux system, however, invalid-host-unresolvable shouldn't be resolvable.
	if err == nil {
		t.Fatal("FileExists failed.")
	}

}

func TestSSHConfig_Connect(t *testing.T) {
	sshConfig := NewSSHConfig("ubuntu", "~/.ssh/quorum", "invalid-host-unresolvable")
	err := sshConfig.Connect()
	if err == nil {
		t.Fatal("Connect should fail to connect, but did not returned any error.")
	}
	if _, ok := err.(*net.OpError).Err.(*net.DNSError); !ok {
		t.Fatal("Connect should encounter a DNS error but didn't.")
	}
}

func TestSSHConfig_GetOS(t *testing.T) {
	sshConfig := NewSSHConfig("ubuntu", "~/.ssh/quorum", "18.232.179.208")
	if sshConfig.GetOS() == "" {
		t.Fatal("Unable to get expected result from GetOS")
	}
	sshConfig.Run("uname")
}
