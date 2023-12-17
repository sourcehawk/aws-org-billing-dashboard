"""
Lambda function to **trigger the AWS Glue crawler** that loads new cur reports to athena.
The crawler is triggered every time that new CUR data is added to S3 by aws.
"""
import os
import boto3


def lambda_handler(_event, _context):
    """
    Trigger the crawler in AWS Glue.
    """
    glue_client = boto3.client('glue')
    try:
        glue_client.start_crawler(
            Name=os.environ['CRAWLER_NAME']
        )
        print('Successfully triggered crawler')
        return None
    except glue_client.exceptions.CrawlerRunningException as err:
        print('Crawler already running; ignoring trigger.')
        return err.response['Error']['Message']
    except glue_client.exceptions.EntityNotFoundException as err:
        print('Crawler does not exist; ignoring trigger.')
        return err.response['Error']['Message']