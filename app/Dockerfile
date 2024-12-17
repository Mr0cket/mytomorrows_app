FROM python:3.12-slim AS build
ARG SERVICE_REGION
ARG SERVICE_NAME
ARG ENVIRONMENT

WORKDIR /app
ADD . /app
RUN pip install pipenv && pipenv install --system --deploy

LABEL Description="Generic docker image for a flask application"

EXPOSE 8080
# General Meta-fields 
ENV SERVICE_REGION=$SERVICE_REGION
ENV SERVICE_NAME=$SERVICE_NAME
ENV ENVIRONMENT=$ENVIRONMENT

# Allow statements and log messages to immediately appear in Knative logs
ENV PYTHONUNBUFFERED=True
ENV WORKERS=1
ENV MAX_CONNECTIONS=100
ENV PORT=80

CMD exec granian app --interface WSGI  --host 0.0.0.0 --port $PORT --workers $WORKERS
