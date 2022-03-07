import time
import random

from dagster import job, op, DynamicOut, DynamicOutput, get_dagster_logger
from dagster_celery_k8s import celery_k8s_job_executor
from dagster_aws.s3 import s3_pickle_io_manager, s3_resource

@op(
    out=DynamicOut(str),
)
def init_step(amount: int) -> str:
    for i in range(amount):
        seq_id = f"{i:02}"
        yield DynamicOutput(seq_id, mapping_key=seq_id)


@op
def map_step_one(seq_id: str) -> str:
    print("processing", seq_id)
    time.sleep(random.random() * 3)
    get_dagster_logger().info(f"processing, {seq_id}")
    return seq_id



@op
def map_step_two(seq_id: str):
    print("processing", seq_id)
    get_dagster_logger().info(f"processing, {seq_id}")
    time.sleep(random.random() * 3)


@job(
    executor_def=celery_k8s_job_executor,
    resource_defs={
        "s3": s3_resource,
        "io_manager": s3_pickle_io_manager
    },
    config={
        "execution": {
            "config": {
                "job_namespace": "dagster"
            }
        },
        "resources": {
            "s3": {
                "config": {
                    "endpoint_url": "http://minio:9000"
                }
            },
            "io_manager": {
                "config": {
                    "s3_bucket": "dagster",
                    "s3_prefix": "dagster-k8s"
                }
            }
        },
        "ops": {
            "init_step": {
                "inputs": {
                    "amount": 5
                }
            }
        }
    }
)
def basic_job():
    seq_ids = init_step()
    results = seq_ids.map(map_step_one)
    # results.map(step_three)
