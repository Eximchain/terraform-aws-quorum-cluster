package softwareupgrade

import (
	"encoding/json"
	"errors"
	"fmt"
	"time"
)

type (
	// CopyInfo contains the local and remote filenames for a transfer
	CopyInfo struct {
		LocalFilename  string `json:"LocalFilename"`
		RemoteFilename string `json:"RemoteFilename"`
	}

	// SSHInfo contains the SSH cert and the username to be used for a SSH connection
	SSHInfo struct {
		SSHCert     string `json:"ssh_cert"`
		SSHUserName string `json:"ssh_username"`
		SSHTimeout  string `json:"ssh_timeout"`
	}

	// RollbackStruct contains the necessary information in order to rollback a particular
	// software to its previous state
	RollbackStruct struct {
		DestFilePath string
	}

	// RollbackSession contains the information required to rollback an upgrade/add session
	RollbackSession struct {
		SessionSuffix string             `json:"SessionSuffix"`
		RollbackInfo  *FailedUpgradeInfo `json:"RollbackInfo"`
		Mode          string             `json:"Mode"`
	}

	// UpgradeStruct contains the information necessary to add/upgrade a particular software
	// on a node
	UpgradeStruct struct {
		SourceFilePath string `json:"Local_Filename"`  // local file path
		DestFilePath   string `json:"Remote_Filename"` // remote file path
		UserGroup      string `json:"UserGroup"`       // specifies user:group ownership
		Permissions    string `json:"Permissions"`     // permissions of the newly copied file
		VerifyCopy     string `json:"VerifyCopy"`      // command to run to verify copy is successful
		RollbackPath   string `json:"RollbackPath"`    // internal rollback
		BackupStrategy string `json:"BackupStrategy"`  // either copy or move
	}

	// UpgradeInfo contains the information necessary to start and stop a particular software on a node
	UpgradeInfo struct {
		PostUpgrade []string `json:"postupgrade"`
		PreUpgrade  []string `json:"preupgrade"`
		StartCmd    string   `json:"start"`
		StopCmd     string   `json:"stop"`

		// The key string is actually integer, and the order of the
		// copy will be numeric order.
		Copy map[string]UpgradeStruct `json:"Copy"`
		Exec []string                 `json:"Exec"`
	}

	// FailedUpgradeInfo records the name of nodes together with the software it failed to upgrade.
	FailedUpgradeInfo struct {
		FailedNodeSoftware map[string][]string `json:"NodeSoftware"`
	}

	// NodeInfoContainer contains the information necessary to connect to a particular node and its upgrade information
	NodeInfoContainer struct {
		UpgradeInfo
		SSHInfo
	}

	// NodeUpgradeConfig specifies the upgrade configuration for each node,
	// if the node is not specified
	NodeUpgradeConfig struct {
		NodeUpgradeInfo map[string]UpgradeInfo
	}

	// Duration contains the delay to sleep between upgrades
	Duration struct {
		time.Duration
	}

	// UpgradeConfig contains the configuration for upgrading nodes
	UpgradeConfig struct {
		Common struct {
			SSHInfo                           // This specifies the general and common SSL configuration for common nodes
			SoftwareGroup map[string][]string `json:"software_group"` // This specifies the software type that's possible to run on a node, the start and stop command, the command used to upgrade the software
			GroupPause    Duration            `json:"group_pause_after_upgrade"`
		} `json:"common"`
		Nodes    map[string]NodeInfoContainer `json:"nodes"`    // This is a map with the key as the DNS hostnames of each node that participates in the network
		Software map[string]UpgradeInfo       `json:"software"` // this defines each individual piece of software
		// This specifies the combination of software on each node.
		// So, say, vault and quorum is one group 1.
		// blockmetrics, cloudwatchmetrics, constellation is group 2.
		// So node1 and node3 runs group 1.
		// node2 and node4 runs group 2.
		// node5, node6, node7 runs group 3.
		SoftwareGroupNodes map[string][]string `json:"groupnodes"`
	}
)

var (
	sourceFilesVerificationInfo map[string]string
)

// MarshalJSON marshals the duration into JSON format
func (d Duration) MarshalJSON() ([]byte, error) {
	return json.Marshal(d.String())
}

// UnmarshalJSON unmarshals the JSON into native Go structure
func (d *Duration) UnmarshalJSON(b []byte) error {
	var v interface{}
	if err := json.Unmarshal(b, &v); err != nil {
		return err
	}
	switch value := v.(type) {
	case float64:
		d.Duration = time.Duration(value)
		return nil
	case string:
		var err error
		d.Duration, err = time.ParseDuration(value)
		if err != nil {
			return err
		}
		return nil
	default:
		return errors.New("invalid duration")
	}
}

// RunAdd adds the given files specified in the nodeInfo to the target node specified in the sshConfig
func (nodeInfo *NodeInfoContainer) RunAdd(sshConfig *SSHConfig) (err error) {
	var msg string
	if len(nodeInfo.Copy) > 0 {
		for i := 0; i < len(nodeInfo.Copy)+1; i++ {
			index := IntToStr(i)
			upgradeStruct := nodeInfo.Copy[index]
			if (UpgradeStruct{}) == upgradeStruct { // skip empty struct, or empty source
				continue
			}
			err = sshConfig.CopyLocalFileToRemoteFile(
				upgradeStruct.SourceFilePath,
				upgradeStruct.DestFilePath, upgradeStruct.Permissions)
			if err != nil {
				if msg == "" {
					msg = fmt.Sprintf("%v", err)
				} else {
					msg = fmt.Sprintf("%s\n%v", msg, err)
				}
			} else {
				if upgradeStruct.UserGroup != "" {
					// if fileOwner has been retrieved, change the file ownership to the previous
					err = sshConfig.changeFileOwnership(upgradeStruct.DestFilePath, upgradeStruct.UserGroup)
					if err != nil {
						msg = fmt.Sprintf("%s\n%v", msg, err)
					}
				}
			}
		}
	}
	if msg != "" {
		err = errors.New(msg)
	}
	return
}

// RunDeleteAdd deletes the specified files in the nodeInfo on the target nodes specified in the sshConfig
func (nodeInfo *NodeInfoContainer) RunDeleteAdd(sshConfig *SSHConfig) (err error) {
	return nodeInfo.RunDeleteRollback(sshConfig, "")
}

// RunDeleteRollback deletes the rollback for a particular node
func (nodeInfo *NodeInfoContainer) RunDeleteRollback(sshConfig *SSHConfig, rollbackSuffix string) (err error) {
	var msg string
	if len(nodeInfo.Copy) > 0 {
		for i := 0; i < len(nodeInfo.Copy)+1; i++ {
			index := IntToStr(i)
			upgradeStruct := nodeInfo.Copy[index]
			if (UpgradeStruct{}) == upgradeStruct { // skip empty struct, or empty source
				continue
			}
			if cmd := nodeInfo.StopCmd; cmd != "" {
				_, err := sshConfig.Run(cmd)
				if err != nil {
					if msg == "" {
						msg = fmt.Sprintf("%v", err)
					} else {
						msg = fmt.Sprintf("%s\n%v", msg, err)
					}
				}
			}
			rollbackName := upgradeStruct.DestFilePath + rollbackSuffix
			cmd := fmt.Sprintf("sudo rm %s", rollbackName)
			_, err = sshConfig.Run(cmd)
		}
	}
	if msg != "" {
		err = errors.New(msg)
	}
	return
}

// RunRollback runs the rollback for a particular node
func (nodeInfo *NodeInfoContainer) RunRollback(sshConfig *SSHConfig, rollbackSuffix string) (err error) {
	if len(nodeInfo.Copy) > 0 {
		for i := 0; i < len(nodeInfo.Copy)+1; i++ {
			index := IntToStr(i)
			upgradeStruct := nodeInfo.Copy[index]
			if (UpgradeStruct{}) == upgradeStruct || upgradeStruct.SourceFilePath == "" { // skip empty struct, or empty source
				continue
			}
			if upgradeStruct.UserGroup == "" {
				if upgradeStruct.UserGroup, err = sshConfig.getFileOwnership(upgradeStruct.DestFilePath); err != nil {
					DebugLog.Printf("Unable to get owner for %s, error: %v\n", upgradeStruct.DestFilePath, err)
				}
			}
			PreUpgradeCmds := nodeInfo.PreUpgrade
			if len(PreUpgradeCmds) > 0 {
				DebugLog.Println("Running Pre-Rollback commands...")
				for i := range PreUpgradeCmds {
					cmd := PreUpgradeCmds[i]
					msg := fmt.Sprintf(`Pre-Rollback command %d: "%s"`, i, cmd)
					DebugLog.Println(msg)
					cmdOutput, err := sshConfig.Run(cmd)
					msg = fmt.Sprintf(`%d output: "%s", error: "%v"`, i, cmdOutput, err)
					DebugLog.Println(msg)
				}
			}
			rollbackName := upgradeStruct.DestFilePath + rollbackSuffix
			cmd := fmt.Sprintf("sudo mv %s %s", rollbackName, upgradeStruct.DestFilePath)
			_, err = sshConfig.Run(cmd)
			if err == nil {
				if upgradeStruct.UserGroup != "" {
					// if fileOwner has been retrieved, change the file ownership to the previous
					err = sshConfig.changeFileOwnership(upgradeStruct.DestFilePath, upgradeStruct.UserGroup)
					if err != nil {
						DebugLog.Printf("Unable to set owner for %s, error: %v\n", upgradeStruct.DestFilePath, err)
					}
				}
			}
			PostUpgradeCmds := nodeInfo.PostUpgrade
			if len(PostUpgradeCmds) > 0 {
				DebugLog.Println("Running Post-Rollback commands...")
				for i := range PostUpgradeCmds {
					cmd := PostUpgradeCmds[i]
					msg := fmt.Sprintf(`Post-Rollback command %d: "%s"`, i, cmd)
					DebugLog.Println(msg)
					cmdOutput, err := sshConfig.Run(cmd)
					msg = fmt.Sprintf(`%d output: "%s", error: "%v"`, i, cmdOutput, err)
					DebugLog.Println(msg)
				}
			}
		}
	}
	return
}

// RunUpgrade runs the upgrade for a particular node
func (nodeInfo *NodeInfoContainer) RunUpgrade(sshConfig *SSHConfig) (err error) {
	// Support i := 0 or i := 1 by checking for empty struct
	var msg string
	if len(nodeInfo.Copy) > 0 {
		for i := 0; i < len(nodeInfo.Copy)+1; i++ {
			index := IntToStr(i)
			upgradeStruct := nodeInfo.Copy[index]
			if (UpgradeStruct{}) == upgradeStruct || upgradeStruct.SourceFilePath == "" { // skip empty struct, or empty source
				continue
			}
			var (
				sourceHash, destHash string
			)
			if upgradeStruct.VerifyCopy != "" {
				localHasher := NewLocalHostHasher()
				switch upgradeStruct.VerifyCopy {
				case "md5":
					{
						sourceHash, err = localHasher.Md5sum(upgradeStruct.SourceFilePath)
					}
				case "sha256":
					{
						sourceHash, err = localHasher.Sha256sum(upgradeStruct.SourceFilePath)
					}
				}
			}
			if upgradeStruct.Permissions == "" {
				upgradeStruct.Permissions, err = sshConfig.getFilePermissions(upgradeStruct.DestFilePath)
			}
			if upgradeStruct.UserGroup == "" {
				if upgradeStruct.UserGroup, err = sshConfig.getFileOwnership(upgradeStruct.DestFilePath); err != nil {
					DebugLog.Printf("Unable to get owner for %s, error: %v\n", upgradeStruct.DestFilePath, err)
				}
			}
			if upgradeStruct.BackupStrategy != "" {
				var cmd, backupName string
				backupName = upgradeStruct.DestFilePath + backupSuffix
				switch upgradeStruct.BackupStrategy {
				case "copy":
					{
						cmd = fmt.Sprintf("sudo cp %s %s", upgradeStruct.DestFilePath, backupName)
					}
				case "move":
					{
						cmd = fmt.Sprintf("sudo mv %s %s", upgradeStruct.DestFilePath, backupName)
					}
				}
				backupResult, err := sshConfig.Run(cmd)
				if err != nil {
					msg = fmt.Sprintf("%sFailed to implement backup strategy for node: %v software: %s\n", msg, err, backupResult)
				}
			}
			PreUpgradeCmds := nodeInfo.PreUpgrade
			if len(PreUpgradeCmds) > 0 {
				DebugLog.Println("Running Pre-Upgrade commands...")
				for i := range PreUpgradeCmds {
					cmd := PreUpgradeCmds[i]
					msg := fmt.Sprintf(`Pre-Upgrade command %d: "%s"`, i, cmd)
					DebugLog.Println(msg)
					cmdOutput, err := sshConfig.Run(cmd)
					msg = fmt.Sprintf(`%d output: "%s", error: "%v"`, i, cmdOutput, err)
					DebugLog.Println(msg)
				}
			}
			err = sshConfig.CopyLocalFileToRemoteFile(
				upgradeStruct.SourceFilePath,
				upgradeStruct.DestFilePath, upgradeStruct.Permissions)
			if err != nil {
				msg = fmt.Sprintf("%sError encountered during file transfer in RunUpgrade: %v\n", msg, err)
			} else if upgradeStruct.VerifyCopy != "" {
				switch upgradeStruct.VerifyCopy {
				case "md5":
					{
						destHash, err = sshConfig.Md5sum(upgradeStruct.DestFilePath)
					}
				case "sha256":
					{
						destHash, err = sshConfig.Sha256sum(upgradeStruct.DestFilePath)
					}
				}
				// file transfer successful since the hash is the same
				if destHash != "" && sourceHash != "" && sourceHash == destHash {
					if upgradeStruct.UserGroup != "" {
						// if fileOwner has been retrieved, change the file ownership to the previous
						err = sshConfig.changeFileOwnership(upgradeStruct.DestFilePath, upgradeStruct.UserGroup)
					}
					if err == nil {
						DebugLog.Println("Upgrade successful!")
					}
				} else {
					msg = fmt.Sprintf("%sUpgrade failed for %s\n", msg, upgradeStruct.DestFilePath)
				}
			}
			PostUpgradeCmds := nodeInfo.PostUpgrade
			if len(PostUpgradeCmds) > 0 {
				DebugLog.Println("Running Post-Upgrade commands...")
				for i := range PostUpgradeCmds {
					cmd := PostUpgradeCmds[i]
					msg := fmt.Sprintf(`Post-Upgrade command %d: "%s"`, i, cmd)
					DebugLog.Println(msg)
					cmdOutput, err := sshConfig.Run(cmd)
					msg = fmt.Sprintf(`%d output: "%s", error: "%v"`, i, cmdOutput, err)
					DebugLog.Println(msg)
				}
			}
		}
		if msg != "" {
			err = errors.New(msg)
		}
	}
	if err == nil && len(nodeInfo.Exec) > 0 {
		for index := range nodeInfo.Exec {
			cmd := nodeInfo.Exec[index]
			cmdResult, err := sshConfig.Run(cmd)
			if err == nil {
				DebugLog.Printf(`Exec: "%s", Result: "%s", \n`, cmd, cmdResult)
			} else {
				DebugLog.Printf(`Exec: "%s", Result: "%v"`, cmd, err)
			}
		}
	}
	return
}

// GetGroupNames gets the groups specified in the config
func (config *UpgradeConfig) GetGroupNames() (result []string) {
	for groupKey := range config.SoftwareGroupNodes {
		result = append(result, groupKey)
	}
	return
}

// GetGroupNodes gets the nodes belonging to the spcified group
func (config *UpgradeConfig) GetGroupNodes(groupName string) (result []string) {
	result = config.SoftwareGroupNodes[groupName]
	return
}

// GetGroupSoftware gets the software belonging to the specified group
func (config *UpgradeConfig) GetGroupSoftware(groupName string) (result []string) {
	result = config.Common.SoftwareGroup[groupName]
	return
}

// GetNodeCount retrieves the number of nodes that are defined under all software groups
func (config *UpgradeConfig) GetNodeCount() (result int) {
	for _, softwareGroupNode := range config.SoftwareGroupNodes {
		result += len(softwareGroupNode)
	}
	return
}

// VerifyFilesExist verifies that all the SourceFiles specified exists. If this is true, error is nil.
// If any of the files specified in the SourceFilePath does not exist, an error msg for each file that doesn't exist is returned.
func (config *UpgradeConfig) VerifyFilesExist() (err error) {
	var msg string

	// build a cache for SourceFile sum
	if sourceFilesVerificationInfo == nil {
		sourceFilesVerificationInfo = make(map[string]string)
	}

	for softwareKey, softwareInfo := range config.Software {
		for _, fileInfo := range softwareInfo.Copy {
			if !FileExists(fileInfo.SourceFilePath) {
				msg = fmt.Sprintf("%sFile does not exist in %s: %v\n", msg, softwareKey, fileInfo.SourceFilePath)
			} else {
				fileInfo := sourceFilesVerificationInfo[fileInfo.SourceFilePath]
				if fileInfo == "" {
				}
			}
		}
	}
	if msg != "" {
		err = errors.New(msg)
	}
	return
}

// GetNodes return the DNS names of all the nodes in the configuration
func (config *UpgradeConfig) GetNodes() (result []string) {
	for _, groupNodesList := range config.SoftwareGroupNodes {
		for _, nodeDNS := range groupNodesList {
			result = append(result, nodeDNS)
		}
	}
	return
}

// GetNodeUpgradeInfo gets the specific upgrade information for a particular node's software.
func (config *UpgradeConfig) GetNodeUpgradeInfo(node, software string) (result *NodeInfoContainer) {
	result = &NodeInfoContainer{}
	nodeInfo := config.Nodes[node]
	if len(nodeInfo.PostUpgrade) > 0 {
		result.PostUpgrade = nodeInfo.PostUpgrade
	} else {
		result.PostUpgrade = config.Software[software].PostUpgrade
	}
	if len(nodeInfo.PreUpgrade) > 0 {
		result.PreUpgrade = nodeInfo.PreUpgrade
	} else {
		result.PreUpgrade = config.Software[software].PreUpgrade
	}
	if nodeInfo.StartCmd != "" {
		result.StartCmd = nodeInfo.StartCmd
	} else {
		result.StartCmd = config.Software[software].StartCmd
	}
	if nodeInfo.StopCmd != "" {
		result.StopCmd = nodeInfo.StopCmd
	} else {
		result.StopCmd = config.Software[software].StopCmd
	}
	if nodeInfo.SSHUserName != "" {
		result.SSHUserName = nodeInfo.SSHUserName
	} else {
		result.SSHUserName = config.Common.SSHUserName
	}
	if nodeInfo.SSHCert != "" {
		result.SSHCert = nodeInfo.SSHCert
	} else {
		result.SSHCert = config.Common.SSHCert
	}
	if len(nodeInfo.Copy) > 0 {
		result.Copy = nodeInfo.Copy
		result.Exec = nodeInfo.Exec
	} else {
		result.Copy = config.Software[software].Copy
		result.Exec = config.Software[software].Exec
	}

	// assign backup strategy as copy if it is not speficied.
	// also assign transfer verification
	for k := range result.Copy {
		if result.Copy[k].BackupStrategy == "" {
			temp := result.Copy[k]
			temp.BackupStrategy = "copy"
			temp.VerifyCopy = "sha256"
			result.Copy[k] = temp
		}
	}

	if (len(result.Copy) == 0) || (len(result.PreUpgrade) == 0) || (len(result.PostUpgrade) == 0) ||
		(result.SSHCert == "") || (result.SSHUserName == "") || (result.StartCmd == "") || (result.StopCmd == "") {
		// panic(fmt.Sprintf("One of the fields is empty! %+v", result))
	}
	return
}

// NewFailedUpgradeInfo creates a structure necessary to contain failed upgrades
func NewFailedUpgradeInfo() *FailedUpgradeInfo {
	result := &FailedUpgradeInfo{}
	result.FailedNodeSoftware = make(map[string][]string)
	return result
}

// Clear clears the mapping
func (failedUpgradeInfo *FailedUpgradeInfo) Clear() {
	failedUpgradeInfo.FailedNodeSoftware = nil
}

// GetNodeSoftwareCount gets the number of failed upgrades for a particular node
func (failedUpgradeInfo *FailedUpgradeInfo) GetNodeSoftwareCount(node string) int {
	return len(failedUpgradeInfo.FailedNodeSoftware[node])
}

// GetCount returns the total number of values currently available
func (failedUpgradeInfo *FailedUpgradeInfo) GetCount() (totalCount int) {
	for k := range failedUpgradeInfo.FailedNodeSoftware {
		totalCount += len(failedUpgradeInfo.FailedNodeSoftware[k])
	}
	return
}

// AddNodeSoftware adds the node and software to the failed upgrades
func (failedUpgradeInfo *FailedUpgradeInfo) AddNodeSoftware(node, software string) {
	if failedUpgradeInfo == nil {
		panic("Iniatialize failedUpgradeInfo first!")
	}
	// Do not allow duplicates
	if failedUpgradeInfo.ExistsNodeSoftware(node, software) {
		return
	}
	softwares := failedUpgradeInfo.FailedNodeSoftware[node]
	softwares = append(softwares, software)
	failedUpgradeInfo.FailedNodeSoftware[node] = softwares
}

// Empty returns true if failedUpgradeInfo's FailedNodeSoftware does not have any keys
func (failedUpgradeInfo *FailedUpgradeInfo) Empty() (empty bool) {
	empty = len(failedUpgradeInfo.FailedNodeSoftware) == 0
	return
}

// ExistsNodeSoftware returns true if a particular software for a nade exists in the failed upgrade info
func (failedUpgradeInfo *FailedUpgradeInfo) ExistsNodeSoftware(node, software string) (result bool) {
	if failedUpgradeInfo == nil || failedUpgradeInfo.FailedNodeSoftware == nil {
		return false
	}
	softwares := failedUpgradeInfo.FailedNodeSoftware[node]
	for i := range softwares {
		if softwares[i] == software {
			return true
		}
	}
	return false
}

// RemoveNodeSoftware removes a software from a node
func (failedUpgradeInfo *FailedUpgradeInfo) RemoveNodeSoftware(node, software string) {
	softwares := failedUpgradeInfo.FailedNodeSoftware[node]
	for i, v := range softwares {
		if v == software {
			// removes the key since there's only 1 match.
			if len(softwares) == 1 {
				delete(failedUpgradeInfo.FailedNodeSoftware, node)
				return
			}
			softwares = append(softwares[:i], softwares[i+1:]...)
			// breaks once a match is found. assumes no duplicates
			break
		}
	}
	failedUpgradeInfo.FailedNodeSoftware[node] = softwares
}

// FindNode returns the software for a node
func (failedUpgradeInfo *FailedUpgradeInfo) FindNode(node string) []string {
	return failedUpgradeInfo.FailedNodeSoftware[node]
}

// NewRollbackSession creates a new RollbackSession
func NewRollbackSession(aSessionSuffix string) (result *RollbackSession) {
	result = &RollbackSession{
		aSessionSuffix,
		NewFailedUpgradeInfo(), ""}
	return
}
