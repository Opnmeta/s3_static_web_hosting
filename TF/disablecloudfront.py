import boto3
import json



def lambda_handler(event, context):
    client = boto3.client('cloudfront')
    distributions = client.list_distributions()
    for distribution in distributions['DistributionList']['Items']:
        distribution_config_response = client.get_distribution_config(Id=distribution['Id'])
        distribution_config = distribution_config_response["DistributionConfig"]
        distribution_id = distribution['Id']
        distribution_etag = distribution_config_response["ETag"]
        distribution_config["Enabled"] = False
        client.update_distribution(
            DistributionConfig=distribution_config,
            Id=distribution_id,
            IfMatch=distribution_etag,
        )

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Cloudfront disabled successfully!",
        }),
    }
