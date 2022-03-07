FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8 \
	LANGUAGE=en_US:en \
	LC_ALL=en_US.UTF-8 \
	TZ=UTC \
    PYTHONPATH=/workspace \
	PYTHONFAULTHANDLER=1 \
	PYTHONHASHSEED=random \
	PYTHONDONTWRITEBYTECODE=1
SHELL ["/bin/bash", "-c"]

WORKDIR /scripts
COPY docker_scripts/ /scripts/
RUN chmod 755 *.sh && /scripts/base.sh && \
	/scripts/libs.sh && \
	/scripts/python3.9.sh && \
	rm /scripts/*

RUN pip install --no-cache-dir --prefer-binary dagster dagster-k8s dagster-postgres dagster-aws dagster-celery-k8s

WORKDIR /workspace

ENV PYTHONPATH /workspace
COPY pipelines ./pipelines