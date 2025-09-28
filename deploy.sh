#!/bin/bash

# CloudTrail Stack Deployment Script
# This script generates a unique random suffix and deploys the CloudTrail stack

set -e

# Configuration
STACK_NAME_PREFIX="cloudtrail-stack"
TEMPLATE_FILE="cloudtrail-stack.yaml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Generate unique suffix using timestamp and random string
generate_unique_suffix() {
    local timestamp=$(date +%Y%m%d%H%M%S)
    local random_string=$(openssl rand -hex 4 2>/dev/null || xxd -l 4 -p /dev/urandom 2>/dev/null || echo $(($RANDOM * $RANDOM)))
    echo "${timestamp}-${random_string}"
}

# Check if AWS CLI is installed and configured
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install it first."
        exit 1
    fi

    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS CLI is not configured or credentials are invalid."
        exit 1
    fi
}

# Validate CloudFormation template
validate_template() {
    print_info "Validating CloudFormation template..."
    if aws cloudformation validate-template --template-body file://"$TEMPLATE_FILE" &> /dev/null; then
        print_info "Template validation successful."
    else
        print_error "Template validation failed."
        exit 1
    fi
}

# Deploy stack
deploy_stack() {
    local stack_name="$1"
    local random_suffix="$2"

    print_info "Deploying stack: $stack_name"
    print_info "Using random suffix: $random_suffix"

    # Deploy the stack
    aws cloudformation deploy \
        --template-file "$TEMPLATE_FILE" \
        --stack-name "$stack_name" \
        --parameter-overrides \
            RandomSuffix="$random_suffix" \
        --capabilities CAPABILITY_NAMED_IAM \
        --no-fail-on-empty-changeset \
        --tags \
            Project="CloudTrail-Implementation" \
            Environment="Production" \
            ManagedBy="CloudFormation" \
            DeployedBy="$(aws sts get-caller-identity --query 'Arn' --output text 2>/dev/null || echo 'Unknown')" \
            DeploymentDate="$(date -Iseconds)"
}

# Check stack status
check_stack_status() {
    local stack_name="$1"

    print_info "Checking stack status..."
    local status=$(aws cloudformation describe-stacks --stack-name "$stack_name" --query 'Stacks[0].StackStatus' --output text 2>/dev/null || echo "NOT_FOUND")

    case $status in
        "CREATE_COMPLETE"|"UPDATE_COMPLETE")
            print_info "Stack deployment successful: $status"
            ;;
        "CREATE_FAILED"|"UPDATE_FAILED"|"ROLLBACK_COMPLETE"|"UPDATE_ROLLBACK_COMPLETE")
            print_error "Stack deployment failed: $status"
            exit 1
            ;;
        "NOT_FOUND")
            print_error "Stack not found: $stack_name"
            exit 1
            ;;
        *)
            print_warning "Stack status: $status"
            ;;
    esac
}

# Display stack outputs
show_outputs() {
    local stack_name="$1"

    print_info "Stack outputs:"
    aws cloudformation describe-stacks \
        --stack-name "$stack_name" \
        --query 'Stacks[0].Outputs[*].[OutputKey,OutputValue,Description]' \
        --output table 2>/dev/null || print_warning "No outputs available"
}

# Main execution
main() {
    print_info "Starting CloudTrail stack deployment..."

    # Parse command line arguments
    if [ $# -eq 0 ]; then
        # Generate unique stack name and suffix
        UNIQUE_SUFFIX=$(generate_unique_suffix)
        STACK_NAME="${STACK_NAME_PREFIX}-${UNIQUE_SUFFIX}"
        RANDOM_SUFFIX="$UNIQUE_SUFFIX"
    elif [ $# -eq 1 ]; then
        # Use provided stack name, generate random suffix
        STACK_NAME="$1"
        RANDOM_SUFFIX=$(generate_unique_suffix)
    elif [ $# -eq 2 ]; then
        # Use provided stack name and suffix
        STACK_NAME="$1"
        RANDOM_SUFFIX="$2"
    else
        print_error "Usage: $0 [stack-name] [random-suffix]"
        print_info "Examples:"
        print_info "  $0                           # Auto-generate both stack name and suffix"
        print_info "  $0 my-cloudtrail-stack      # Use custom stack name, auto-generate suffix"
        print_info "  $0 my-stack custom-suffix   # Use custom stack name and suffix"
        exit 1
    fi

    # Validate inputs
    if [[ ! "$STACK_NAME" =~ ^[a-zA-Z][a-zA-Z0-9-]*$ ]]; then
        print_error "Invalid stack name. Must start with a letter and contain only alphanumeric characters and hyphens."
        exit 1
    fi

    # Check prerequisites
    check_aws_cli
    validate_template

    # Deploy the stack
    deploy_stack "$STACK_NAME" "$RANDOM_SUFFIX"

    # Check final status and show outputs
    check_stack_status "$STACK_NAME"
    show_outputs "$STACK_NAME"

    print_info "Deployment completed successfully!"
    print_info "Stack Name: $STACK_NAME"
    print_info "Random Suffix: $RANDOM_SUFFIX"
}

# Execute main function
main "$@"