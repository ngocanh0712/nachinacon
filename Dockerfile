# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.2.1
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

# Rails app lives here
WORKDIR /rails

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"


# Throw-away build stage to reduce size of final image
FROM base as build

# Install packages needed to build gems
# Retry apt to tolerate transient Debian mirror errors (e.g. 502 Gateway Error)
RUN echo 'Acquire::Retries "5";' > /etc/apt/apt.conf.d/80-retries && \
    for i in 1 2 3 4 5; do apt-get update -qq && break || sleep 10; done && \
    apt-get install --no-install-recommends -y build-essential default-libmysqlclient-dev git imagemagick pkg-config

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile


# Final stage for app image
FROM base

# Install packages needed for deployment
# Retry apt to tolerate transient Debian mirror errors (e.g. 502 Gateway Error)
RUN echo 'Acquire::Retries "5";' > /etc/apt/apt.conf.d/80-retries && \
    for i in 1 2 3 4 5; do apt-get update -qq && break || sleep 10; done && \
    apt-get install --no-install-recommends -y curl default-mysql-client imagemagick && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN useradd rails --create-home --shell /bin/bash && \
    mkdir -p public/images && \
    chown -R rails:rails db log storage tmp public/images
USER rails:rails

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
