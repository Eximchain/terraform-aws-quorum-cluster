package softwareupgrade

import (
	"testing"
)

var (
	failedUpgradeInfo *FailedUpgradeInfo
)

func init() {
	failedUpgradeInfo = NewFailedUpgradeInfo()
	failedUpgradeInfo.AddNodeSoftware("node1", "soft1")
	failedUpgradeInfo.AddNodeSoftware("node1", "soft2")
	failedUpgradeInfo.AddNodeSoftware("node1", "soft3")
	failedUpgradeInfo.AddNodeSoftware("node1", "soft4")
	failedUpgradeInfo.RemoveNodeSoftware("node1", "soft3")
	if count := failedUpgradeInfo.GetNodeSoftwareCount("node1"); count != 3 {
		DebugLog.Printf("Node count should be 3, but is: %d\n", count)
	}
}

func TestFailedUpgradeInfo_RemoveNodeSoftware(t *testing.T) {
	failedUpgradeInfo = NewFailedUpgradeInfo()
	if count := failedUpgradeInfo.GetNodeSoftwareCount("node1"); count != 0 {
		t.Fatalf("Node count should be 0, but is: %d", count)
	}
	failedUpgradeInfo.AddNodeSoftware("node1", "s1")
	if count := failedUpgradeInfo.GetNodeSoftwareCount("node1"); count != 1 {
		t.Fatalf("Node count should be 1, but is: %d", count)
	}
	failedUpgradeInfo.RemoveNodeSoftware("node1", "s1")
	if count := failedUpgradeInfo.GetNodeSoftwareCount("node1"); count != 0 {
		t.Fatalf("Node count should be 0, but is: %d", count)
	}
}

func TestFailedUpgradeInfo_AddNodeSoftware(t *testing.T) {
	failedUpgradeInfo = NewFailedUpgradeInfo()
	failedUpgradeInfo.AddNodeSoftware("node1", "s1")
	if count := failedUpgradeInfo.GetNodeSoftwareCount("node1"); count != 1 {
		t.Fatalf("Node count shoud be 1, but is: %d", count)
	}

	failedUpgradeInfo.AddNodeSoftware("node1", "s1")
	if count := failedUpgradeInfo.GetCount(); count != 1 {
		t.Fatal("AddNodeSoftware isn't handling duplicates")
	}

}

func TestFailedUpgradeInfo_Empty(t *testing.T) {
	failedUpgradeInfo := NewFailedUpgradeInfo()
	if !failedUpgradeInfo.Empty() {
		t.Fatal("failedUpgradeInfo should be empty!")
	}

	failedUpgradeInfo.AddNodeSoftware("node1", "hey")
	if failedUpgradeInfo.Empty() {
		t.Fatal("failedUpgradeInfo shouldn't be empty!")
	}

	failedUpgradeInfo.RemoveNodeSoftware("node1", "hey")
	if !failedUpgradeInfo.Empty() {
		t.Fatal("failedUpgradeInfo should be empty!")
	}
}

func TestFailedUpgradeInfo_GetCount(t *testing.T) {
	failedUpgradeInfo := NewFailedUpgradeInfo()
	if failedUpgradeInfo.GetCount() != 0 {
		t.Fatalf("%s %d", CGetCountShouldReturn, 0)
	}

	failedUpgradeInfo.AddNodeSoftware("node1", "s1")
	if failedUpgradeInfo.GetCount() != 1 {
		t.Fatalf("%s %d", CGetCountShouldReturn, 1)
	}

	failedUpgradeInfo.AddNodeSoftware("node1", "s1") // check if duplicates are handled
	if failedUpgradeInfo.GetCount() != 1 {
		t.Fatalf("%s %d", CGetCountShouldReturn, 2)
	}

	failedUpgradeInfo.AddNodeSoftware("node1", "s2")
	if failedUpgradeInfo.GetCount() != 2 {
		t.Fatalf("%s %d", CGetCountShouldReturn, 2)
	}
}
