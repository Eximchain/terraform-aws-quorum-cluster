package softwareupgrade

import (
	"io/ioutil"
	"os"
	"testing"
)

func TestSHA256(t *testing.T) {
	tempdir, err := ioutil.TempDir("", "")
	if err == nil {
		defer os.Remove(tempdir)
		tempfile, err := ioutil.TempFile(tempdir, "")
		if err == nil {
			defer os.Remove(tempfile.Name())
			data := []byte("Hello World")
			SaveDataToFile(tempfile.Name(), data)
			sha256, err := localSHA256(tempfile.Name())
			if err == nil {
				if sha256 != "a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e" {
					t.Fatal("localSHA256 failed!")
				}
			} else {
				t.Fatal("Unable to get SHA256 for temp file")
			}
		} else {
			t.Fatal("Unable to create temp file")
		}
	} else {
		t.Fatal("Unable to create temp dir")
	}
}
