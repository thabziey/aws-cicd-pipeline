#!/bin/bash

set -e

CLUSTER_NAME="webapp-cicd-cluster"
SERVICE_NAME="webapp-cicd-service"
ECR_REPO_NAME="my-webapp"
LOG_GROUP_NAME="/ecs/webapp-cicd-task"

echo "🛑 WARNING: This script will stop and delete your ECS service, cluster, ECR repo, and CloudWatch logs."
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
  echo "Aborted by user."
  exit 0
fi

echo "⏳ Setting desired count to 0 to stop running tasks..."
aws ecs update-service --cluster "$CLUSTER_NAME" --service "$SERVICE_NAME" --desired-count 0
echo "✅ Service desired count updated to 0."

echo "⏳ Waiting for running tasks to stop..."
while true; do
  RUNNING_COUNT=$(aws ecs describe-services --cluster "$CLUSTER_NAME" --services "$SERVICE_NAME" --query "services[0].runningCount" --output text)
  echo "Running tasks count: $RUNNING_COUNT"
  if [[ "$RUNNING_COUNT" == "0" ]]; then
    break
  fi
  sleep 5
done
echo "✅ All tasks stopped."

echo "⏳ Deleting ECS service..."
aws ecs delete-service --cluster "$CLUSTER_NAME" --service "$SERVICE_NAME" --force
echo "✅ Service deleted."

echo "⏳ Deleting ECS cluster..."
aws ecs delete-cluster --cluster "$CLUSTER_NAME"
echo "✅ Cluster deleted."

echo "⏳ Deleting ECR repository (and all images)..."
aws ecr delete-repository --repository-name "$ECR_REPO_NAME" --force
echo "✅ ECR repository deleted."

echo "⏳ Deleting CloudWatch log group..."
aws logs delete-log-group --log-group-name "$LOG_GROUP_NAME"
echo "✅ CloudWatch log group deleted."

echo "🎉 Cleanup complete!"
