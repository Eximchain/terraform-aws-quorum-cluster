package main

import "time"

type (
	// AWSLifecycleAction should...
	AWSLifecycleAction struct {
		Version    string   `json:"version"`
		ID         string   `json:"id"`
		DetailType string   `json:"detail-type"`
		Source     string   `json:"source"`
		Account    string   `json:"account"`
		Time       string   `json:"time"`
		Region     string   `json:"region"`
		Resources  []string `json:"resources"`
		Detail     struct {
			LifecycleActionToken string `json:"LifecycleActionToken"`
			AutoScalingGroupName string `json:"AutoScalingGroupName"`
			LifecycleHookName    string `json:"LifecycleHookName"`
			EC2InstanceID        string `json:"EC2InstanceId"`
			LifecycleTransition  string `json:"LifecycleTransition"`
			NotificationMetadata string `json:"NotificationMetadata"`
		} `json:"detail"`
	}

	// AWSLifecycleAction2 should...
	AWSLifecycleAction2 struct {
		Version    string    `json:"version"`
		ID         string    `json:"id"`
		DetailType string    `json:"detail-type"`
		Source     string    `json:"source"`
		Account    string    `json:"account"`
		Time       time.Time `json:"time"`
		Region     string    `json:"region"`
		Resources  []string  `json:"resources"`
		Detail     struct {
			LifecycleActionToken string `json:"LifecycleActionToken"`
			AutoScalingGroupName string `json:"AutoScalingGroupName"`
			LifecycleHookName    string `json:"LifecycleHookName"`
			EC2InstanceID        string `json:"EC2InstanceId"`
			LifecycleTransition  string `json:"LifecycleTransition"`
		} `json:"detail"`
	}
)
