# Makefile for CloudTrail CloudFormation Stack

# Variables
STACK_NAME ?= cloudtrail-stack
REGION ?= us-west-2
TEMPLATE_FILE = cloudtrail-stack.yaml
PROFILE ?= default

# Detect CloudShell environment and adjust profile usage
# CloudShell sets AWS_CONTAINER_CREDENTIALS_FULL_URI to localhost:1338
# and typically has /home/cloudshell-user as the home directory
ifeq ($(shell echo $$AWS_CONTAINER_CREDENTIALS_FULL_URI | grep -q "127.0.0.1:1338" && echo true),true)
    AWS_PROFILE_ARG =
else ifeq ($(shell echo $$HOME | grep -q "cloudshell-user" && echo true),true)
    AWS_PROFILE_ARG =
else
    AWS_PROFILE_ARG = --profile $(PROFILE)
endif

# Parameters with defaults
TRAIL_NAME ?= organization-cloudtrail
S3_BUCKET_PREFIX ?= cloudtrail-logs
RETENTION_DAYS ?= 90
GLACIER_TRANSITION_DAYS ?= 30
DEEP_ARCHIVE_TRANSITION_DAYS ?= 60
LAKE_RETENTION_DAYS ?= 7
ENABLE_LOG_VALIDATION ?= true
ENABLE_S3_DATA_EVENTS ?= false

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m # No Color

.PHONY: help
help: ## Show this help message
	@echo "CloudTrail Stack Management"
	@echo ""
	@echo "Usage: make [target] [VARIABLE=value ...]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "Variables:"
	@echo "  $(YELLOW)STACK_NAME$(NC)            Stack name (default: $(STACK_NAME))"
	@echo "  $(YELLOW)REGION$(NC)                AWS region (default: $(REGION))"
	@echo "  $(YELLOW)PROFILE$(NC)               AWS profile (default: $(PROFILE), auto-detected in CloudShell)"
	@echo "  $(YELLOW)TRAIL_NAME$(NC)            CloudTrail name (default: $(TRAIL_NAME))"
	@echo "  $(YELLOW)RETENTION_DAYS$(NC)        S3 retention in days (default: $(RETENTION_DAYS))"
	@echo "  $(YELLOW)LAKE_RETENTION_DAYS$(NC)   CloudTrail Lake retention (default: $(LAKE_RETENTION_DAYS))"

.PHONY: validate
validate: ## Validate the CloudFormation template
	@echo "$(GREEN)Validating CloudFormation template...$(NC)"
	@aws cloudformation validate-template \
		--template-body file://$(TEMPLATE_FILE) \
		--region $(REGION) \
		$(AWS_PROFILE_ARG) \
		--output text
	@echo "$(GREEN)✓ Template is valid$(NC)"

.PHONY: create
create: validate ## Create the CloudTrail stack
	@echo "$(GREEN)Creating CloudTrail stack: $(STACK_NAME)$(NC)"
	@aws cloudformation create-stack \
		--stack-name $(STACK_NAME) \
		--template-body file://$(TEMPLATE_FILE) \
		--parameters \
			ParameterKey=TrailName,ParameterValue=$(TRAIL_NAME) \
			ParameterKey=S3BucketPrefix,ParameterValue=$(S3_BUCKET_PREFIX) \
			ParameterKey=RetentionInDays,ParameterValue=$(RETENTION_DAYS) \
			ParameterKey=GlacierTransitionDays,ParameterValue=$(GLACIER_TRANSITION_DAYS) \
			ParameterKey=DeepArchiveTransitionDays,ParameterValue=$(DEEP_ARCHIVE_TRANSITION_DAYS) \
			ParameterKey=CloudTrailLakeRetentionDays,ParameterValue=$(LAKE_RETENTION_DAYS) \
			ParameterKey=EnableLogFileValidation,ParameterValue=$(ENABLE_LOG_VALIDATION) \
			ParameterKey=EnableS3DataEvents,ParameterValue=$(ENABLE_S3_DATA_EVENTS) \
		--capabilities CAPABILITY_NAMED_IAM \
		--region $(REGION) \
		$(AWS_PROFILE_ARG) \
		--output text
	@echo "$(YELLOW)Stack creation initiated. Run 'make status' to check progress$(NC)"

.PHONY: update
update: validate ## Update the CloudTrail stack
	@echo "$(GREEN)Updating CloudTrail stack: $(STACK_NAME)$(NC)"
	@aws cloudformation update-stack \
		--stack-name $(STACK_NAME) \
		--template-body file://$(TEMPLATE_FILE) \
		--parameters \
			ParameterKey=TrailName,ParameterValue=$(TRAIL_NAME) \
			ParameterKey=S3BucketPrefix,ParameterValue=$(S3_BUCKET_PREFIX) \
			ParameterKey=RetentionInDays,ParameterValue=$(RETENTION_DAYS) \
			ParameterKey=GlacierTransitionDays,ParameterValue=$(GLACIER_TRANSITION_DAYS) \
			ParameterKey=DeepArchiveTransitionDays,ParameterValue=$(DEEP_ARCHIVE_TRANSITION_DAYS) \
			ParameterKey=CloudTrailLakeRetentionDays,ParameterValue=$(LAKE_RETENTION_DAYS) \
			ParameterKey=EnableLogFileValidation,ParameterValue=$(ENABLE_LOG_VALIDATION) \
			ParameterKey=EnableS3DataEvents,ParameterValue=$(ENABLE_S3_DATA_EVENTS) \
		--capabilities CAPABILITY_NAMED_IAM \
		--region $(REGION) \
		$(AWS_PROFILE_ARG) \
		--output text || echo "$(YELLOW)No updates to perform$(NC)"

.PHONY: delete
delete: ## Delete the CloudTrail stack
	@echo "$(RED)WARNING: This will delete the CloudTrail stack: $(STACK_NAME)$(NC)"
	@echo "Press Ctrl+C to cancel, or Enter to continue..."
	@read confirm
	@echo "$(RED)Deleting stack...$(NC)"
	@aws cloudformation delete-stack \
		--stack-name $(STACK_NAME) \
		--region $(REGION) \
		$(AWS_PROFILE_ARG)
	@echo "$(YELLOW)Stack deletion initiated. Run 'make status' to check progress$(NC)"

.PHONY: status
status: ## Check stack status
	@echo "$(GREEN)Checking stack status: $(STACK_NAME)$(NC)"
	@aws cloudformation describe-stacks \
		--stack-name $(STACK_NAME) \
		--region $(REGION) \
		$(AWS_PROFILE_ARG) \
		--query 'Stacks[0].StackStatus' \
		--output text 2>/dev/null || echo "Stack not found"

.PHONY: events
events: ## Show recent stack events
	@echo "$(GREEN)Recent stack events for: $(STACK_NAME)$(NC)"
	@aws cloudformation describe-stack-events \
		--stack-name $(STACK_NAME) \
		--region $(REGION) \
		$(AWS_PROFILE_ARG) \
		--max-items 10 \
		--query 'StackEvents[*].[Timestamp,ResourceStatus,ResourceType,LogicalResourceId,ResourceStatusReason]' \
		--output table

.PHONY: outputs
outputs: ## Show stack outputs
	@echo "$(GREEN)Stack outputs for: $(STACK_NAME)$(NC)"
	@aws cloudformation describe-stacks \
		--stack-name $(STACK_NAME) \
		--region $(REGION) \
		$(AWS_PROFILE_ARG) \
		--query 'Stacks[0].Outputs[*].[OutputKey,OutputValue,Description]' \
		--output table

.PHONY: wait-create
wait-create: ## Wait for stack creation to complete
	@echo "$(GREEN)Waiting for stack creation to complete...$(NC)"
	@aws cloudformation wait stack-create-complete \
		--stack-name $(STACK_NAME) \
		--region $(REGION) \
		$(AWS_PROFILE_ARG)
	@echo "$(GREEN)✓ Stack creation complete$(NC)"

.PHONY: wait-update
wait-update: ## Wait for stack update to complete
	@echo "$(GREEN)Waiting for stack update to complete...$(NC)"
	@aws cloudformation wait stack-update-complete \
		--stack-name $(STACK_NAME) \
		--region $(REGION) \
		$(AWS_PROFILE_ARG)
	@echo "$(GREEN)✓ Stack update complete$(NC)"

.PHONY: wait-delete
wait-delete: ## Wait for stack deletion to complete
	@echo "$(YELLOW)Waiting for stack deletion to complete...$(NC)"
	@aws cloudformation wait stack-delete-complete \
		--stack-name $(STACK_NAME) \
		--region $(REGION) \
		$(AWS_PROFILE_ARG)
	@echo "$(GREEN)✓ Stack deletion complete$(NC)"

.PHONY: describe
describe: ## Describe the stack in detail
	@aws cloudformation describe-stacks \
		--stack-name $(STACK_NAME) \
		--region $(REGION) \
		$(AWS_PROFILE_ARG) \
		--output json

.PHONY: estimate-cost
estimate-cost: ## Show estimated monthly costs
	@echo "$(GREEN)Estimated Monthly Costs (USD):$(NC)"
	@echo "================================"
	@echo "CloudTrail:         ~$$2 (first trail free)"
	@echo "S3 Storage:         ~$$0.023/GB (STANDARD)"
	@echo "Glacier Storage:    ~$$0.004/GB (after $(GLACIER_TRANSITION_DAYS) days)"
	@echo "Deep Archive:       ~$$0.001/GB (after $(DEEP_ARCHIVE_TRANSITION_DAYS) days)"
	@echo "CloudTrail Lake:    ~$$2.5/GB ingested + $$0.005/GB scanned"
	@echo "KMS:                ~$$1/month + $$0.03/10k requests"
	@echo "CloudWatch Logs:    ~$$0.50/GB ingested + $$0.03/GB stored"
	@echo "--------------------------------"
	@echo "$(YELLOW)Total Estimate: $$10-50/month (varies by volume)$(NC)"

.PHONY: trail-status
trail-status: ## Check CloudTrail logging status
	@echo "$(GREEN)CloudTrail Status:$(NC)"
	@aws cloudtrail get-trail-status \
		--name $(TRAIL_NAME) \
		--region $(REGION) \
		$(AWS_PROFILE_ARG) \
		--output json 2>/dev/null || echo "Trail not found or not accessible"

.PHONY: start-logging
start-logging: ## Start CloudTrail logging
	@echo "$(GREEN)Starting CloudTrail logging...$(NC)"
	@aws cloudtrail start-logging \
		--name $(TRAIL_NAME) \
		--region $(REGION) \
		$(AWS_PROFILE_ARG)
	@echo "$(GREEN)✓ Logging started$(NC)"

.PHONY: stop-logging
stop-logging: ## Stop CloudTrail logging
	@echo "$(YELLOW)Stopping CloudTrail logging...$(NC)"
	@aws cloudtrail stop-logging \
		--name $(TRAIL_NAME) \
		--region $(REGION) \
		$(AWS_PROFILE_ARG)
	@echo "$(YELLOW)✓ Logging stopped$(NC)"

.PHONY: lookup-events
lookup-events: ## Lookup recent CloudTrail events (last 10)
	@echo "$(GREEN)Recent CloudTrail Events:$(NC)"
	@aws cloudtrail lookup-events \
		--max-items 10 \
		--region $(REGION) \
		$(AWS_PROFILE_ARG) \
		--query 'Events[*].[EventTime,EventName,Username,EventSource]' \
		--output table

.PHONY: deploy
deploy: create wait-create outputs ## Full deployment (create, wait, show outputs)
	@echo "$(GREEN)✓ Deployment complete!$(NC)"

.PHONY: teardown
teardown: delete wait-delete ## Full teardown (delete and wait)
	@echo "$(GREEN)✓ Teardown complete!$(NC)"

.PHONY: redeploy
redeploy: teardown deploy ## Delete and recreate the stack
	@echo "$(GREEN)✓ Redeployment complete!$(NC)"

.PHONY: clean
clean: ## Clean up local files
	@echo "$(GREEN)Cleaning up...$(NC)"
	@rm -f .DS_Store
	@echo "$(GREEN)✓ Clean complete$(NC)"

# Default target
.DEFAULT_GOAL := help