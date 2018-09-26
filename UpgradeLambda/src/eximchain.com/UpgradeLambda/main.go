package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"path/filepath"

	"time"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"

	"softwareupgrade"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/autoscaling"
	"github.com/aws/aws-sdk-go/service/ec2"
	"github.com/aws/aws-sdk-go/service/kms"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/aws/aws-sdk-go/service/s3/s3manager"
)

// HandleAutoscalingRequest ...
// sample event data:
/* {
Version:0
ID:04cc36a9-10b0-4dcc-bfa3-0d2775f464db
DetailType:EC2 Instance-launch Lifecycle Action
Source:aws.autoscaling
AccountID:037794263736
Time:2018-08-21 09:16:49 +0000 UTC
Region:us-east-1
Resources:[arn:aws:autoscaling:us-east-1:037794263736:autoScalingGroup:bc7b5533-02e1-439c-af1a-feea191649d1:autoScalingGroupName/tf-asg-2018081704184730510000002e]
Detail:
	AutoScalingGroupName:tf-asg-2018081704184730510000002e
	LifecycleHookName:ccw-test1
	EC2InstanceId:i-06cb96806d799b6c3
	LifecycleTransition:autoscaling:EC2_INSTANCE_LAUNCHING
	NotificationMetadata:arn:aws:events:us-east-1:037794263736:rule/ccw-testfunc02
	LifecycleActionToken:c8bc85a6-57d0-4e44-a761-8bb05410ea1d]
}

// sample test data:
{
"Version":"0",
"ID":"04cc36a9-10b0-4dcc-bfa3-0d2775f464db",
"DetailType":"EC2 Instance-launch Lifecycle Action",
"Source":"aws.autoscaling",
"Account":"037794263736",
"Time":"2018-01-02T15:04:05+08:00",
"Region":"us-east-1",
"Resources":["arn:aws:autoscaling:us-east-1:037794263736:autoScalingGroup:bc7b5533-02e1-439c-af1a-feea191649d1:autoScalingGroupName/tf-asg-2018081704184730510000002e"],
"Detail":{
	"AutoScalingGroupName":"tf-asg-2018081704184730510000002e",
	"LifecycleHookName":"ccw-test1",
	"EC2InstanceId":"i-06cb96806d799b6c3",
	"LifecycleTransition":"autoscaling:EC2_INSTANCE_LAUNCHING",
	"NotificationMetadata":"arn:aws:events:us-east-1:037794263736:rule/ccw-testfunc02",
	"LifecycleActionToken":"c8bc85a6-57d0-4e44-a761-8bb05410ea1d]"
 }
}
*/
// HandleAutoscalingRequest ... testing for 102, EC2InstanceId and LifecycleTransition are both empty.
func HandleAutoscalingRequest(ctx context.Context, event events.AutoScalingEvent) (string, error) {
	t := time.Now()
	fmt.Printf("The following strings are from the Go handler\n")
	fmt.Printf("Data available in event is %+v \n", event)
	log.Printf("Log from Go: %s", t.String())
	ec2InstanceID := event.Detail["EC2InstanceId"]
	LifecycleTransition := event.Detail["LifecycleTransition"]
	fmt.Printf("EC2 InstanceId: %s\n", ec2InstanceID)
	fmt.Printf("LifecycleTransition: %s\n", LifecycleTransition)
	return fmt.Sprintf("This is a message from Go - %s", t.String()), nil
}

func handleErr(err error) {
	if aerr, ok := err.(awserr.Error); ok {
		switch aerr.Code() {
		case kms.ErrCodeNotFoundException, kms.ErrCodeDisabledException,
			kms.ErrCodeKeyUnavailableException, kms.ErrCodeDependencyTimeoutException,
			kms.ErrCodeInvalidKeyUsageException, kms.ErrCodeInvalidGrantTokenException,
			kms.ErrCodeInternalException, kms.ErrCodeInvalidStateException,
			autoscaling.ErrCodeResourceContentionFault, autoscaling.ErrCodeServiceLinkedRoleFailure,
			autoscaling.ErrCodeResourceInUseFault:
			fmt.Printf("Code: %s, error: %s\n", aerr.Code(), aerr.Error())
		default:
			fmt.Println(aerr.Error())
		}
	} else {
		fmt.Println(err.Error())
	}
}

type (
	// AWSMessage are messages passed from the ASG lifecycle
	AWSMessage struct {
		Progress            int       `json:"Progress"`
		AccountID           string    `json:"AccountId"`
		Description         string    `json:"Description"`
		RequestID           string    `json:"RequestId"`
		EndTime             time.Time `json:"EndTime"` // time.Time 2018-09-16T06:00:09.666Z
		AutoScalingGroupARN string    `json:"AutoScalingGroupARN"`
		ActivityID          string    `json:"ActivityId"`
		StartTime           time.Time `json:"StartTime"` // time.Time 2018-09-16T05:59:37.148Z
		Service             string    `json:"Service"`
		Time                time.Time `json:"Time"` // time.Time 2018-09-16T06:00:09.666Z
		EC2InstanceID       string    `json:"EC2InstanceId"`
		StatusCode          string    `json:"StatusCode"`
		StatusMessage       string    `json:"StatusMessage"`
		Details             struct {
			AvailabilityZone string `json:"Availability Zone"`
		} `json:"Details"`
		AutoScalingGroupName string `json:"AutoScalingGroupName"`
		Cause                string `json:"Cause"`
		Event                string `json:"Event"`
		NotificationMetadata string `json:"NotificationMetadata"`
		LifecycleHookName    string `json:"LifecycleHookName"`
		LifecycleTransition  string `json:"LifecycleTransition"`
		LifecycleActionToken string `json:"LifecycleActionToken"`
	}
)

// Constants block
const (
	CBucketName            = "bucket-name"
	CBucketKey             = "bucket-key"
	CSSHUser               = "ssh_username"
	CUpgradeShell          = "upgrade.sh"
	CUpgradeCmd            = "upgrade_cmd"
	CUpgradeBucketName     = "upgrade-bucket-name"
	CRemoteUpgradeLocation = "upgrade_location"
	CUpgradeZip            = "upgrade.zip"

	// for VPC/VPN
	CSecurityGroup = "security-group"
	CVPC           = "vpc"
)

// SNSHandler works for #101, #102, #103, #105
func SNSHandler(ctx context.Context, snsEvent events.SNSEvent) {
	var (
		sess               *session.Session
		sshKey             []byte
		upgradeScriptBytes []byte
		// upgradezip            []byte
		sshUser               string
		sshconfig             *softwareupgrade.SSHConfig
		remoteUpgradeLocation string
		upgradeCmd            string
		// upgradezipName        string
	)
	for _, record := range snsEvent.Records {
		snsRecord := record.SNS

		fmt.Printf("25 Sep 2018 1332 [%s %s] Message = %s \n", record.EventSource, snsRecord.Timestamp, snsRecord.Message)

		// skip to the next message, as current message is a test notification
		if snsRecord.Message == `autoscaling:TEST_NOTIFICATION` {
			continue
		}

		// Message is a JSON structure
		var msg AWSMessage
		if err := json.Unmarshal([]byte(snsRecord.Message), &msg); err == nil {
			fmt.Printf("EC2InstanceId: %s\n", msg.EC2InstanceID)
			// test notifications do not have an EC2 Instance ID, so exit
			if msg.EC2InstanceID == "" {
				fmt.Println("Empty EC2 InstanceID. Exiting.")
				return
			}
			// There's a valid EC2 Instance Id, so load session from shared config
			if sess == nil {
				sess = session.Must(session.NewSessionWithOptions(session.Options{
					SharedConfigState: session.SharedConfigEnable,
				}))
			}

			// Create an EC2 client and ask for the EC2 DNS name
			svc := ec2.New(sess)
			input := &ec2.DescribeInstancesInput{
				InstanceIds: []*string{
					aws.String(msg.EC2InstanceID),
				},
			}

			autoscalingClient := autoscaling.New(sess)

			// heartbeatinput := &autoscaling.RecordLifecycleActionHeartbeatInput{
			// 	AutoScalingGroupName: aws.String(msg.AutoScalingGroupName),
			// 	LifecycleActionToken: aws.String(msg.LifecycleActionToken),
			// 	LifecycleHookName:    aws.String(msg.LifecycleHookName),
			// }
			//
			// if result1, err := autoscalingClient.RecordLifecycleActionHeartbeat(heartbeatinput); err != nil {
			// 	handleErr(err)
			// } else {
			// 	// no errors encountered
			// 	fmt.Printf("RecordLifecycleActionHeartbeat result: %+v\n", result1)
			// }

			var notificationInfo map[string]string
			if err3 := json.Unmarshal([]byte(msg.NotificationMetadata), &notificationInfo); err3 == nil {
				myBucket := notificationInfo[CBucketName]
				myKey := notificationInfo[CBucketKey]
				sshUser = notificationInfo[CSSHUser]
				vpc := notificationInfo[CVPC]
				securitygroup := notificationInfo[CSecurityGroup]
				upgradeCmd = notificationInfo[CUpgradeCmd]
				remoteUpgradeLocation = notificationInfo[CRemoteUpgradeLocation]
				// upgradezipName = notificationInfo[CUpgradeZip]
				fmt.Printf("Notification Info: %+v\n", notificationInfo)
				fmt.Printf("Bucket: '%s', key: '%s', ssh user: '%s', vpc: '%s', security group: '%s'\n",
					myBucket, myKey, sshUser, vpc, securitygroup)
				fmt.Printf("Upgrade cmd: '%s', location: '%s'\n", upgradeCmd, remoteUpgradeLocation)
				downloader := s3manager.NewDownloader(sess)

				getS3BucketObj := func(downloader *s3manager.Downloader, bucketName, bucketKey string) (result []byte, err error) {
					var n int64
					buffer := []byte{}
					buf := aws.NewWriteAtBuffer(buffer)
					fmt.Printf("Downloading %s %s\n", bucketName, bucketKey)
					if n, err = downloader.Download(buf, &s3.GetObjectInput{
						Bucket: aws.String(bucketName),
						Key:    aws.String(bucketKey),
					}); err == nil {
						result = buf.Bytes()
						fmt.Printf("Bytes read: %v for bucket: %s, key: %s\n", n, bucketName, bucketKey)
					} else {
						fmt.Printf("Bucket: %s, Item: %s, err: %v\n", bucketName, bucketKey, err)
					}
					return
				}

				if encryptedData, err := getS3BucketObj(downloader, myBucket, myKey); err == nil {
					input := &kms.DecryptInput{
						CiphertextBlob: encryptedData,
					}
					kmssvc := kms.New(sess)
					result, err := kmssvc.Decrypt(input)
					if err != nil {
						fmt.Println("Decryption failed.")
						handleErr(err)
					} else {
						sshKey = result.Plaintext
						fmt.Printf("Decryption succeeded, len: %d\n", len(sshKey))
					}
				}

				upgradeScriptBytes, _ = getS3BucketObj(downloader, myBucket, CUpgradeShell)

			} else {
				fmt.Printf("Error during unmarshal: %v\n", err3)
			}

			fmt.Println("Retrieving instances...")
			if resp, err := svc.DescribeInstances(input); err == nil {
				fmt.Printf("Len of resp: %d\n", len(resp.Reservations))
				for idx := range resp.Reservations {
					for _, inst := range resp.Reservations[idx].Instances {
						InstanceID := aws.StringValue(inst.InstanceId)
						DNSName := aws.StringValue(inst.PublicDnsName)
						if InstanceID != "" && DNSName != "" {
							fmt.Printf("Instance ID: %s, DNS name: %s, SSH key len: %d\n", InstanceID, DNSName, len(sshKey))
							sshconfig = softwareupgrade.NewSSHConfigKeyBytes(sshUser, sshKey, DNSName)

							if upgradeScriptBytes != nil {

								if bytes, err := sshconfig.ReadBytesFromFile("/home/ubuntu/.ssh/authorized_keys"); err == nil {
									fmt.Printf("Bytes from authorized_keys: %v\n", string(bytes))
								} else {
									fmt.Printf("Error reading authorized_keys: %v", err)
								}

								destName := filepath.Join(remoteUpgradeLocation, upgradeCmd)
								fmt.Println("Copying bytes to ", destName)
								if err := sshconfig.CopyBytesToFileAndVerify(upgradeScriptBytes, destName, "0755"); err != nil {
									fmt.Printf("Error in copying to %s: %v", destName, err)
								} else {
									cmd := fmt.Sprintf(`screen -d -m "%s"`, destName)
									result, err := sshconfig.Run(cmd)
									fmt.Printf("cmd: %s, result: %s, err: %v\n", cmd, result, err)
									sshconfig.MakeSudo()
									t := time.Now()
									cmd = fmt.Sprintf(`echo "Hello world %s" > /tmp/output1.txt`, t.String())
									sshconfig.Run(cmd)

									sshconfig.ClearSudo()
									t = time.Now()
									cmd = fmt.Sprintf(`echo "Hello world %s" > /home/ubuntu/output2.txt`, t.String())
									sshconfig.Run(cmd)

									t = time.Now()
									cmd = fmt.Sprintf(`echo "Hello world %s" > /tmp/output2.txt`, t.String())
									sshconfig.Run(cmd)
								}
							}
							sshconfig.Destroy()
						}
					}
				}

			} else {
				fmt.Printf("Error in describing instance: %+v\n", err)
			}

			lifecycleActionInput := &autoscaling.CompleteLifecycleActionInput{
				AutoScalingGroupName:  aws.String(msg.AutoScalingGroupName),
				InstanceId:            aws.String(msg.EC2InstanceID),
				LifecycleActionResult: aws.String("CONTINUE"),
				LifecycleActionToken:  aws.String(msg.LifecycleActionToken),
				LifecycleHookName:     aws.String(msg.LifecycleHookName),
			}

			if result2, err := autoscalingClient.CompleteLifecycleAction(lifecycleActionInput); err != nil {
				fmt.Println("Error CompleteLifecycleAction")
				handleErr(err)
			} else {
				// no errors encountered
				fmt.Printf("CompleteLifecycleAction result: %+v\n", result2)
			}

		} else {
			fmt.Printf("Error unmarshalling: %+v\n", err)
			fmt.Printf("Struct: '%s'", snsRecord.Message)
		}

	}
}

func main() {
	lambda.Start(SNSHandler)
}
