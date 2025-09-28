# CloudTrail Lake Sample Queries

## Overview
This document contains sample SQL queries for AWS CloudTrail Lake to help with security analysis and compliance monitoring. Replace `$EDS_ID` with your actual Event Data Store ID.

---

## 1. Failed Console Logins (Last 7 Days)
Monitor failed authentication attempts to the AWS Management Console.

```sql
SELECT eventTime, userIdentity.principalId, 
       sourceIPAddress, errorCode
FROM $EDS_ID
WHERE eventName = 'ConsoleLogin'
  AND errorCode IS NOT NULL
  AND eventTime > dateadd('day', -7, now())
ORDER BY eventTime DESC
```

---

## 2. Root Account Usage
Track when the root account is being used for operations.

```sql
SELECT eventTime, eventName, sourceIPAddress,
       userAgent, awsRegion
FROM $EDS_ID
WHERE userIdentity.type = 'Root'
  AND userIdentity.invokedBy IS NULL
  AND eventType != 'AwsServiceEvent'
ORDER BY eventTime DESC
```

---

## 3. IAM Policy Changes
Monitor modifications to IAM policies that could affect security posture.

```sql
SELECT eventTime, eventName, 
       userIdentity.principalId, requestParameters
FROM $EDS_ID
WHERE eventSource = 'iam.amazonaws.com'
  AND eventName IN ('PutUserPolicy', 'PutGroupPolicy',
                     'PutRolePolicy', 'CreatePolicy',
                     'AttachUserPolicy', 'AttachGroupPolicy')
ORDER BY eventTime DESC
```

---

## 4. Security Group Modifications
Track changes to EC2 security groups that affect network access.

```sql
SELECT eventTime, eventName, sourceIPAddress,
       requestParameters.groupId, requestParameters.ipPermissions
FROM $EDS_ID
WHERE eventSource = 'ec2.amazonaws.com'
  AND eventName IN ('AuthorizeSecurityGroupIngress',
                     'AuthorizeSecurityGroupEgress',
                     'RevokeSecurityGroupIngress')
ORDER BY eventTime DESC
```

---

## 5. S3 Bucket Permission Changes
Monitor changes to S3 bucket policies and ACLs.

```sql
SELECT eventTime, eventName, requestParameters.bucketName,
       userIdentity.principalId, sourceIPAddress
FROM $EDS_ID
WHERE eventSource = 's3.amazonaws.com'
  AND eventName IN ('PutBucketPolicy', 'DeleteBucketPolicy',
                     'PutBucketAcl', 'PutObjectAcl')
ORDER BY eventTime DESC
```

---

## 6. Unauthorized API Calls
Identify access denied errors across all services.

```sql
SELECT eventTime, eventName, eventSource,
       userIdentity.principalId, errorCode, errorMessage
FROM $EDS_ID
WHERE errorCode IN ('UnauthorizedOperation', 'AccessDenied', 
                    'UnauthorizedAccess', 'TokenRefreshRequired')
  AND eventTime > dateadd('day', -1, now())
ORDER BY eventTime DESC
```

---

## 7. EC2 Instance Launches
Track new EC2 instance deployments.

```sql
SELECT eventTime, awsRegion, responseElements.instancesSet.items[0].instanceId as instanceId,
       requestParameters.instanceType, userIdentity.principalId
FROM $EDS_ID
WHERE eventName = 'RunInstances'
  AND errorCode IS NULL
ORDER BY eventTime DESC
```

---

## 8. User Creation and Deletion
Monitor IAM user lifecycle events.

```sql
SELECT eventTime, eventName, requestParameters.userName,
       userIdentity.principalId, sourceIPAddress
FROM $EDS_ID
WHERE eventSource = 'iam.amazonaws.com'
  AND eventName IN ('CreateUser', 'DeleteUser', 'CreateAccessKey', 
                     'DeleteAccessKey', 'UpdateAccessKey')
ORDER BY eventTime DESC
```

---

## 9. CloudTrail Configuration Changes
Detect attempts to modify or disable CloudTrail logging.

```sql
SELECT eventTime, eventName, requestParameters.name,
       userIdentity.principalId, sourceIPAddress
FROM $EDS_ID
WHERE eventSource = 'cloudtrail.amazonaws.com'
  AND eventName IN ('StopLogging', 'DeleteTrail', 'UpdateTrail',
                     'PutEventSelectors')
ORDER BY eventTime DESC
```

---

## 10. Cross-Account Activity
Identify API calls made from external AWS accounts.

```sql
SELECT eventTime, eventName, userIdentity.accountId,
       userIdentity.principalId, eventSource, awsRegion
FROM $EDS_ID
WHERE userIdentity.accountId != recipientAccountId
  AND eventTime > dateadd('day', -7, now())
ORDER BY eventTime DESC
```

---

## Usage Notes

### Prerequisites
- Ensure CloudTrail Lake is enabled in your AWS account
- Create an Event Data Store with appropriate retention period
- Note your Event Data Store ID to replace `$EDS_ID` in queries

### Query Syntax
- CloudTrail Lake uses SQL syntax similar to Athena
- Supports standard SQL functions and operators
- JSON fields can be accessed using dot notation
- Array elements can be accessed using bracket notation

### Best Practices
1. Use specific time ranges to improve query performance
2. Filter by `eventSource` when looking for service-specific events
3. Include `errorCode IS NULL` to find only successful operations
4. Use `LIMIT` clause for initial query testing
5. Save frequently used queries as saved queries in CloudTrail Lake

### Common Fields Reference
- `eventTime`: When the API call was made
- `eventName`: The API action that was called
- `eventSource`: The AWS service that was called
- `userIdentity.principalId`: Who made the API call
- `sourceIPAddress`: Where the call originated from
- `errorCode`: If the API call failed, why it failed
- `requestParameters`: Input parameters for the API call
- `responseElements`: Output from the API call

### Additional Resources
- [AWS CloudTrail Lake Documentation](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-lake.html)
- [CloudTrail Event Reference](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-event-reference.html)
- [SQL Query Syntax](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-lake-query-syntax.html)