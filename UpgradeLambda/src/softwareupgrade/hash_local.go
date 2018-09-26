package softwareupgrade

import (
	"crypto/md5"
	"io"
	"log"
	"os"
)

type (
	// LocalHostHasher ...
	LocalHostHasher struct {
	}

	// Hasher specifies the functions required to be implemented for a stricture
	// to be compatible to the Hasher interface
	Hasher interface {
		Md5sum(path string) (result string, err error)
		Sha256sum(path string) (result string, err error)
	}
)

// NewLocalHostHasher returns an empty structure which implicitly implements Hasher interface
func NewLocalHostHasher() (result *LocalHostHasher) {
	return &LocalHostHasher{}
}

// Sha256sum calculates the SHA256 hash for a specified path
func (hasher *LocalHostHasher) Sha256sum(path string) (result string, err error) {
	return localSHA256(path)
}

// Md5sum calculates the MD5 hash for a specified path
func (hasher *LocalHostHasher) Md5sum(path string) (result string, err error) {
	f, err := os.Open(path)
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()

	h := md5.New()
	_, err = io.Copy(h, f)
	result = string(h.Sum(nil))
	return
}
