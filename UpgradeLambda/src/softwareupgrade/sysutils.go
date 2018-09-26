package softwareupgrade

import (
	"bytes"
	"log"
	"os"
	"os/exec"
	"os/user"
	"path/filepath"
	"runtime"
	"strconv"
	"strings"
)

// IntToStr converts an integer to a string
func IntToStr(value int) string {
	return strconv.Itoa(value)
}

// Expand expands the ~ in the given path to the home directory
func Expand(path string) (string, error) {
	if len(path) == 0 || path[0] != '~' {
		return path, nil
	}

	usr, err := user.Current()
	if err != nil {
		return "", err
	}
	result := filepath.Join(usr.HomeDir, path[1:])
	return result, nil
}

// FileExists checks if the given filename exists
func FileExists(filename string) bool {
	if expandedFilename, err := Expand(filename); err == nil {
		filename = expandedFilename
	}
	if _, err := os.Stat(filename); err != nil {
		if os.IsNotExist(err) {
			return false
		}
	}
	return true
}

//
func localSHA256(filename string) (result string, err error) {
	var (
		app string
		cmd *exec.Cmd
	)
	if expandedFilename, err := Expand(filename); err == nil {
		filename = expandedFilename
	}
	switch runtime.GOOS {
	case "darwin":
		{
			app, err = exec.LookPath("shasum")
			if err != nil {
				return
			}
			cmd = exec.Command(app, "-a", "256", filename)
		}
	case "linux":
		{
			app := "sha256sum"
			cmd = exec.Command(app, filename)
		}
	}
	var b bytes.Buffer
	cmd.Stdout = &b // get output
	err = cmd.Run()
	if err != nil {
		log.Printf("Error %v", err)
		return
	}
	runResult1 := b.String()
	runResult2 := strings.Split(runResult1, " ")
	result = runResult2[0]
	return
}
