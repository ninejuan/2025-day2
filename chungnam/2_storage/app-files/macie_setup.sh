#!/bin/bash

set -e

BUCKET_NAME=""
JOB_ID=""

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -b, --bucket BUCKET_NAME    S3 bucket name"
    echo "  -j, --job-id JOB_ID         Macie job ID"
    echo "  -s, --start                 Start the classification job"
    echo "  -c, --check                 Check job status"
    echo "  -r, --results               Get job results"
    echo "  -h, --help                  Display this help message"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -b|--bucket)
            BUCKET_NAME="$2"
            shift 2
            ;;
        -j|--job-id)
            JOB_ID="$2"
            shift 2
            ;;
        -s|--start)
            START_JOB=true
            shift
            ;;
        -c|--check)
            CHECK_STATUS=true
            shift
            ;;
        -r|--results)
            GET_RESULTS=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

if [[ -z "$BUCKET_NAME" ]]; then
    if [[ -f "terraform.tfstate" ]]; then
        BUCKET_NAME=$(terraform output -raw s3_bucket_name 2>/dev/null || echo "")
    fi
fi

if [[ -z "$JOB_ID" ]]; then
    if [[ -f "terraform.tfstate" ]]; then
        JOB_ID=$(terraform output -raw macie_job_id 2>/dev/null || echo "")
    fi
fi

if [[ -z "$BUCKET_NAME" ]]; then
    echo "❌ Error: Bucket name is required. Use -b option or ensure Terraform state exists."
    exit 1
fi

if [[ -z "$JOB_ID" ]]; then
    echo "❌ Error: Job ID is required. Use -j option or ensure Terraform state exists."
    exit 1
fi

echo "🔍 Using bucket: $BUCKET_NAME"
echo "📋 Using job ID: $JOB_ID"
echo ""

if [[ "$START_JOB" == true ]]; then
    echo "🚀 Starting Macie classification job..."
    aws macie2 start-classification-job --job-id "$JOB_ID"
    echo "✅ Job started successfully!"
    echo ""
fi

if [[ "$CHECK_STATUS" == true ]]; then
    echo "📊 Checking job status..."
    STATUS=$(aws macie2 describe-classification-job --job-id "$JOB_ID" --query 'jobStatus' --output text)
    echo "Status: $STATUS"
    
    case $STATUS in
        "RUNNING")
            echo "⏳ Job is currently running..."
            ;;
        "COMPLETE")
            echo "✅ Job completed successfully!"
            ;;
        "CANCELLED")
            echo "⚠️  Job was cancelled"
            ;;
        "USER_PAUSED")
            echo "⏸️  Job is paused"
            ;;
        *)
            echo "📋 Job status: $STATUS"
            ;;
    esac
    echo ""
fi

if [[ "$GET_RESULTS" == true ]]; then
    echo "📈 Getting job results..."
    
    aws macie2 get-classification-export-configuration --job-id "$JOB_ID" 2>/dev/null || echo "No export configuration found"
    
    echo "🔍 Finding statistics:"
    aws macie2 get-usage-statistics --filter-by jobId="$JOB_ID" --max-results 100 2>/dev/null || echo "No statistics available yet"
    
    echo ""
    echo "💡 Tips:"
    echo "   - Use AWS Console to view detailed findings"
    echo "   - Check CloudTrail for detailed API calls"
    echo "   - Monitor S3 access patterns in the masked/ prefix"
fi

if [[ "$START_JOB" != true && "$CHECK_STATUS" != true && "$GET_RESULTS" != true ]]; then
    echo "🔧 Macie Job Management"
    echo "======================"
    echo ""
    echo "Available actions:"
    echo "  Start job:    $0 -s"
    echo "  Check status: $0 -c" 
    echo "  Get results:  $0 -r"
    echo ""
    echo "Current job status:"
    STATUS=$(aws macie2 describe-classification-job --job-id "$JOB_ID" --query 'jobStatus' --output text 2>/dev/null || echo "UNKNOWN")
    echo "  Status: $STATUS"
fi
