from dagster import repository

from .basic import basic_job

@repository
def repo():
    return [basic_job]
