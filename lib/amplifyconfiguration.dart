// TODO: Replace with your own Amplify configuration
// This is a template - you need to configure your own AWS Amplify backend
const amplifyconfig = '''{
    "UserAgent": "aws-amplify-cli/2.0",
    "Version": "1.0",
    "api": {
        "plugins": {
            "awsAPIPlugin": {
                "YOUR_API_ID": {
                    "endpointType": "REST",
                    "endpoint": "https://YOUR_API_GATEWAY_ENDPOINT.execute-api.YOUR_REGION.amazonaws.com/YOUR_STAGE",
                    "region": "YOUR_REGION",
                    "authorizationType": "AWS_IAM"
                }
            }
        }
    },
    "auth": {
        "plugins": {
            "awsCognitoAuthPlugin": {
                "UserAgent": "aws-amplify-cli/0.1.0",
                "Version": "0.1.0",
                "IdentityManager": {
                    "Default": {}
                },
                "CredentialsProvider": {
                    "CognitoIdentity": {
                        "Default": {
                            "PoolId": "YOUR_REGION:YOUR_IDENTITY_POOL_ID",
                            "Region": "YOUR_REGION"
                        }
                    }
                },
                "CognitoUserPool": {
                    "Default": {
                        "PoolId": "YOUR_REGION_YOUR_USER_POOL_ID",
                        "AppClientId": "YOUR_APP_CLIENT_ID",
                        "Region": "YOUR_REGION"
                    }
                },
                "Auth": {
                    "Default": {
                        "authenticationFlowType": "USER_SRP_AUTH",
                        "socialProviders": [],
                        "usernameAttributes": [
                            "EMAIL"
                        ],
                        "signupAttributes": [
                            "EMAIL"
                        ],
                        "passwordProtectionSettings": {
                            "passwordPolicyMinLength": 8,
                            "passwordPolicyCharacters": []
                        },
                        "mfaConfiguration": "OFF",
                        "mfaTypes": [
                            "SMS"
                        ],
                        "verificationMechanisms": [
                            "EMAIL"
                        ]
                    }
                },
                "S3TransferUtility": {
                    "Default": {
                        "Bucket": "YOUR_S3_BUCKET_NAME",
                        "Region": "YOUR_REGION"
                    }
                }
            }
        }
    },
    "storage": {
        "plugins": {
            "awsS3StoragePlugin": {
                "bucket": "YOUR_S3_BUCKET_NAME",
                "region": "YOUR_REGION",
                "defaultAccessLevel": "guest"
            }
        }
    }
}''';
