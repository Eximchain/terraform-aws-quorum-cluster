package main

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/aws/aws-lambda-go/events"
)

func createNotificationInfo() (result map[string]string) {
	result = make(map[string]string)
	notificationInfo := result

	notificationInfo[CBucketName] = "eximchain105-20180926050432026700000001"
	notificationInfo[CBucketKey] = "enc-ssh"
	notificationInfo[CSSHUser] = "ubuntu"
	notificationInfo[CVPC] = "somevpc"
	notificationInfo[CSecurityGroup] = "somegroup"
	notificationInfo[CUpgradeCmd] = "upgrade.sh"
	notificationInfo[CRemoteUpgradeLocation] = "/home/ubuntu"

	return
}

// In order to test this, the instance ID and the bucket name above needs to be renamed to the actual ones generated
func TestSNSHandler(t *testing.T) {
	notificationInfo := createNotificationInfo()
	var (
		ctx context.Context
		// event     events.SNSEvent
		// msg       AWSMessage
		// snsEntity events.SNSEntity
	)
	msg := AWSMessage{EC2InstanceID: "i-07c7c729adc45cf2e"} // instance ID
	event := events.SNSEvent{Records: make([]events.SNSEventRecord, 1)}
	metadata, _ := json.Marshal(&notificationInfo)
	msg.NotificationMetadata = string(metadata)
	marshaledInfo, _ := json.Marshal(&msg)
	snsEntity := events.SNSEntity{Message: string(marshaledInfo)}
	event.Records[0].SNS = snsEntity
	SNSHandler(ctx, event)
}
