# Builder stage - compile dependencies and build application
FROM python:3.13-alpine AS builder

ENV APP_DIR=/usr/src/snappass

WORKDIR $APP_DIR

# Install build dependencies required for cryptography and other packages
RUN apk add --no-cache \
    gcc \
    musl-dev \
    libffi-dev \
    openssl-dev \
    cargo \
    rust

# Copy application files
COPY ["setup.py", "requirements.txt", "MANIFEST.in", "README.md", "AUTHORS.md", "$APP_DIR/"]
COPY ["./snappass", "$APP_DIR/snappass"]

# Install Python dependencies without cache
RUN pip install --no-cache-dir -r requirements.txt

# Compile translations
RUN pybabel compile -d snappass/translations

# Build and install the application
RUN python setup.py install

# Runtime stage - minimal final image
FROM python:3.13-alpine

ENV APP_DIR=/usr/src/snappass

# Install only runtime dependencies
RUN apk add --no-cache \
    libffi \
    openssl

# Create non-root user
RUN addgroup -S snappass && \
    adduser -S -G snappass snappass && \
    mkdir -p $APP_DIR

WORKDIR $APP_DIR

# Copy Python packages from builder
COPY --from=builder /usr/local/lib/python3.13/site-packages /usr/local/lib/python3.13/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy application files from builder
COPY --from=builder $APP_DIR $APP_DIR

# Set ownership
RUN chown -R snappass:snappass $APP_DIR

USER snappass

# Default Flask port
EXPOSE 5000

CMD ["waitress-serve", "--listen=*:5000", "snappass.main:app"]
