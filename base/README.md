# Google Cloud Logging Agent Base Image

[Google Cloud Logging](https://cloud.google.com/logging/docs) is a service for collecting, storing and viewing logs on the Google Cloud Platform. By default, various project- and instance-level events are recorded to the activity_log. In addition, Google provides a logging agent, [google-fluentd](https://github.com/GoogleCloudPlatform/google-fluentd), which can collect custom logs from virtual machines.

The **reactivehub/google-fluentd-base** image contains vanilla google-fluentd. It does not, however, include any configuration how to read logs. It is intended as the base for custom images which must add their own specific configuration. If you need an image which can be used straight away, you can choose [reactivehub/google-fluentd-catch-all](https://registry.hub.docker.com/u/reactivehub/google-fluentd-catch-all) – it bundles both the agent and Google's [catch-all configs](https://github.com/GoogleCloudPlatform/fluentd-catch-all-config).

The image exports volume `/var/log`. Service containers can mount the volume and write their logs to it:

```
docker run --name my-service --volumes-from="my-agent" my-service
```

To function properly, google-fluentd requires that the Google Cloud Logging API is enabled, the service account has permission *Can edit* and the instance has authorization scope  *https://www.googleapis.com/auth/logging.write*. If it does not, the instance can be either recreated (all new instances have the scope by default) or alternative [service account client ID authorization](https://cloud.google.com/logging/docs/install/troubleshooting#configuring_client_id_authorization) can be used. This image supports both authorization methods.

Google-fluentd uses the metadata service, therefore container must be able to resolve hostname metadata; e.g. the host record can be added to the container's `/etc/hosts` file:

```
docker run --add-host="metadata:169.254.169.254" my-agent
```

## How to build a custom logging agent image

The following image adds google-fluentd configuration for a supposed docker container my-service. My-service writes logs to `/var/log/my-service/my-service.log`.

Dockerfile:

```
FROM reactivehub/google-fluentd-base
RUN mkdir -p /var/log/my-service
ADD *.conf /etc/google-fluentd/config.d/
```

my-service.conf:

```
<source>
  type tail
  tag my-service
  path /var/log/my-service/my-service.log
  read_from_head true
  format multiline
  format_firstline /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}/
  format1 /^(?<time>[^ ]+ [^ ]+) (?<severity>[A-Z]+) (?<message>.*)/
  pos_file /var/tmp/my-service.log.pos
  time_format %Y-%m-%d %H:%M:%S.%L
</source>
```

Build custom logging agent image and tag it my-agent:

```
docker build -t my-agent .
```

## Run logging agent with default authorization

```
docker run --name my-agent --add-host="metadata:169.254.169.254" my-agent
docker run --name my-service --volumes-from="my-agent" my-service  
```

## Troubleshooting logging agent

To [troubleshoot](https://cloud.google.com/logging/docs/install/troubleshooting
) the logging agent, access the agent's log file with the following command:

```
docker run -it --rm --volumes-from pb-logger busybox tail -f /var/log/google-fluentd/google-fluentd.log
```
