package softwareupgrade

import (
	"strings"
	"time"
)

var (
	backupSuffix string
)

func init() {
	t := time.Now()
	backupSuffix = strings.Replace(t.Format(time.RFC3339), ":", "-", -1)
}

// GetBackupSuffix returns the backup suffix
func GetBackupSuffix() string {
	return backupSuffix
}
