<p>
  <a href="https://hub.docker.com/r/luisgabrielroldan/ddogzip"><img alt="Docker Pulls" src="https://img.shields.io/docker/image-size/luisgabrielroldan/ddogzip"></a>
</p>

# DDogZip

DDogZip is a simple application that functions as a Datadog traces collector. It listens for tracing data from Datadog clients, translates it, and forwards it to a Zipkin collector.

This tool is ideal for local development environments where you want to debug tracing without sending data to Datadog's infrastructure.

## Getting Started


### Configuration

DDogZip can be configured using environment variables as follows:

`DDTRACE_PORT`: Port to listen for Datadog client requests (default: 8126)
`ZIPKIN_HOST`: Hostname for the Zipkin collector (default: localhost)
`ZIPKIN_PORT`: Port for the Zipkin collector (default: 9411)
`LOG_LEVEL`: Logging level (warn, info, error, debug) (default: info)

### Running Locally

To start the application, run:

mix run --no-halt

### Runnin with Docker
```bash
docker run \
    -p 8126:8126 \
    -e DDTRACE_PORT=8126 \
    -e ZIPKIN_HOST=localhost \
    -e ZIPKIN_PORT=9411 \
    ddogzip
```

Make sure to adjust the ZIPKIN_HOST, ZIPKIN_PORT, and LOG_LEVEL environment variables according to your Zipkin configuration and logging preferences.
