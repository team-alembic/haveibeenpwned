###
### Docker is used for CI only!
###

# Use a minial Elixir  image
FROM elixir:1.7.4-alpine

# Install git
RUN apk --update --no-cache add git

# Configure workspace
RUN mix local.hex --force
RUN mix local.rebar --force
RUN apk --update --no-cache add build-base

# Create working directory
RUN mkdir /app
WORKDIR /app

# Get the things
ADD . /app

# Build dependencies
RUN mix deps.get

# Compile application in test environment
RUN MIX_ENV=test mix compile
