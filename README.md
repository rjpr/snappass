# SnapPass

[![Docker Image](https://img.shields.io/docker/v/rjpr/snappass?label=docker)](https://hub.docker.com/r/rjpr/snappass)
[![GitHub Container Registry](https://img.shields.io/badge/ghcr.io-rjpr%2Fsnappass-blue?logo=github)](https://github.com/rjpr/snappass/pkgs/container/snappass)

**A modernized fork of Pinterest's SnapPass** - Share secrets securely through encrypted, one-time use links.

This version features a modern UI with Pico CSS theming, dark mode support, and extended configuration options. For the original project, see [pinterest/snappass](https://github.com/pinterest/snappass).

<img src="screenshot.png" alt="SnapPass Screenshot" style="max-width: 700px; width: 100%;">

## Overview

SnapPass is a web application for sharing passwords and sensitive data through secure, self-destructing links. Share a secret via URL that expires after being viewed once or after a time limit — no permanent record in email or chat logs.

**What's New in This Fork:**
- Modern, lightweight UI with Pico CSS (95% smaller than Bootstrap)
- Dark mode with automatic system detection
- 20 color themes plus custom color support
- Faster load times and improved mobile experience
- Enhanced configuration with environment variables
- Production-ready Docker deployment
- Python 3.9-3.13 support with latest dependencies

Simple, secure, and now with a modern interface that respects your users' preferences.

## Security

Passwords are encrypted using [Fernet](https://cryptography.io/en/latest/fernet/) symmetric encryption, from the [cryptography](https://cryptography.io/en/latest/) library.
A random unique key is generated for each password, and is never stored; it is rather sent as part of the password link.
This means that even if someone has access to the Redis store, the passwords are still safe.

## Docker Installation (Recommended)

The recommended way to run SnapPass is using Docker Compose, which sets up both SnapPass and Redis together.

### Using Docker Compose

1. Download the production-ready example configuration:
   ```bash
   curl -O https://raw.githubusercontent.com/rjpr/snappass/master/docker-compose.example.yml
   mv docker-compose.example.yml docker-compose.yml
   ```

2. Edit `docker-compose.yml` and customize the environment variables (see comments in file)

3. **Important:** Change the `SECRET_KEY` to a secure random value

4. Start the services:
   ```bash
   docker-compose up -d
   ```

SnapPass will be accessible at http://localhost:5000

The example configuration includes Redis persistence, security settings, and comprehensive comments for all options. Review the Configuration section below for details on each setting.

### Alternative: Using Docker Run

If you prefer to manage containers separately:

```bash
# Start Redis
docker run -d --name redis redis:latest

# Run SnapPass
docker run -d \
  --name snappass \
  --link redis:redis \
  -p 5000:5000 \
  -e REDIS_HOST=redis \
  -e SECRET_KEY=your-secret-key-here \
  rjpr/snappass
```

## Alternative Installation

### Requirements

* [Redis](https://redis.io/) server
* Python 3.9+

### Install from Source

If you prefer to run SnapPass directly without Docker, you can install from source:

```bash
git clone https://github.com/rjpr/snappass.git
cd snappass
pip install -r requirements.txt
python setup.py install
snappass
# * Running on http://0.0.0.0:5000/
# * Restarting with reloader
```

Note: You'll need to ensure Redis is running separately when using this method.

## Migrating from Original SnapPass

To maintain backwards compatibility with existing secret links:

1. Set `TOKEN_PREFIX` to match your current `REDIS_PREFIX` (default: `snappass`)
2. Keep your existing `REDIS_PREFIX` unchanged
3. Use the same Redis instance

Example for default Pinterest SnapPass setup:
```bash
TOKEN_PREFIX=snappass
REDIS_PREFIX=snappass
```

This ensures old secret links continue to work while new ones use the same format.

## Configuration

SnapPass can be configured via environment variables. All settings work with both Docker and pip installations.

### Core Settings

**`SECRET_KEY`**: Unique key used to sign sessions. This should be kept secret. See the [Flask Documentation](http://flask.pocoo.org/docs/quickstart/#sessions) for more information.

**`DEBUG`**: Set to run Flask web server in debug mode. See the [Flask Documentation](http://flask.pocoo.org/docs/quickstart/#debug-mode) for more information.

**`NO_SSL`**: Controls whether generated secret links use `http://` or `https://`. Set to `True` only if users access SnapPass without SSL (e.g., `http://localhost`). This does not enable/disable SSL on the server itself.

### Server Configuration

**`SNAPPASS_BIND_ADDRESS`**: Override the default bind address of 0.0.0.0. Example: `127.0.0.1`

**`SNAPPASS_PORT`**: Override the default port of 5000. Example: `6000`

**`URL_PREFIX`**: Useful when running behind a reverse proxy like nginx. Example: `"/snappass/"` (defaults to `None`)

**`HOST_OVERRIDE`**: Override the base URL if the app is unaware. Useful behind reverse proxies like identity-aware SSO. Example: `sub.domain.com`

**`STATIC_URL`**: Location of static assets (usually doesn't need to be changed)

### Redis Configuration

**`REDIS_HOST`**: Redis server hostname (defaults to `"localhost"`)

**`REDIS_PORT`**: Redis server port (defaults to `6379`)

**`SNAPPASS_REDIS_DB`**: Redis database number (defaults to `0`)

**`REDIS_URL`**: Complete Redis URL (optional). If set, overrides `REDIS_HOST`, `REDIS_PORT`, and `SNAPPASS_REDIS_DB`. Example: `redis://username:password@localhost:6379/0`

**`REDIS_PREFIX`**: Prefix for Redis keys to prevent collisions (defaults to `"snappass"`)

**`TOKEN_PREFIX`**: Prefix for URL tokens, separate from Redis prefix. Allows customization of visible tokens in URLs independently from Redis keys. Example: with `TOKEN_PREFIX=myapp` and `REDIS_PREFIX=prod`, URLs contain `myappXXX~key` while Redis stores `prodXXX`. Defaults to empty string.

**Important for migration:** If migrating from the original Pinterest SnapPass, set `TOKEN_PREFIX=snappass` to maintain backwards compatibility with existing secret links. The parser handles both prefixed and unprefixed tokens, so old links will work while new ones use the configured prefix.

### UI Customization

**`SITE_TITLE`**: Customize the site title. Defaults to "Snappass - Share Secrets". Example: `"Share Secrets | My Company"`

**`THEME_COLOR`**: Customize the primary theme color. Supports Pico CSS theme names: `amber`, `blue`, `cyan`, `fuchsia`, `green`, `grey`, `indigo`, `jade`, `lime`, `orange`, `pink`, `pumpkin`, `purple`, `red`, `sand`, `slate`, `violet`, `yellow`, `zinc`. Also accepts custom CSS color values (hex, rgb, hsl, etc.). See [Pico CSS Version Picker](https://picocss.com/docs/version-picker/) to preview colors. Examples: `THEME_COLOR=pumpkin` or `THEME_COLOR=#57ff33`

**`THEME_MODE`**: Force light or dark mode. Valid values: `light` or `dark`. If not set, automatically switches based on user's system preference. Example: `THEME_MODE=dark`

**`DEFAULT_TTL`**: Set the default expiry time in the password creation form. Valid values: `hour`, `day`, `week`, or `two weeks` (case-insensitive). Defaults to `week`.

**`HIDE_GITHUB_LINK`**: Hide the GitHub icon link at the bottom of the page. Set to `True` to hide. Defaults to `False` (icon visible). Example: `HIDE_GITHUB_LINK=True`

## APIs

SnapPass provides two APIs for programmatic access:

1. **Simple API**: Quick password creation with minimal overhead
2. **REST API (v2)**: Full lifecycle management with proper REST semantics

### Simple API

Create a password link without opening the web interface. Useful for scripts and CI/CD pipelines.

Create a password by sending a POST request to `/api/set_password`:

```bash
curl -X POST -H "Content-Type: application/json" -d '{"password": "foobar"}' http://localhost:5000/api/set_password/
```

Response:

```json
{
    "link": "http://127.0.0.1:5000/snappassbedf19b161794fd288faec3eba15fa41~hHnILpQ50ZfJc3nurDfHCb_22rBr5gGEya68e_cZOrY%3D",
    "ttl": 1209600
}
```

The default TTL is 2 weeks (1209600 seconds). Override it with an expiration parameter:

```bash
curl -X POST -H "Content-Type: application/json" -d '{"password": "foobar", "ttl": 3600}' http://localhost:5000/api/set_password/
```

### REST API (v2)

Fully manage password lifecycle without web interface interaction. Ideal for automation and integration.

#### Create a password

Send a POST request to `/api/v2/passwords`:

```bash
curl -X POST -H "Content-Type: application/json" -d '{"password": "foobar"}' http://localhost:5000/api/v2/passwords
```

Response includes token and links:

```json
{
    "token": "snappassbedf19b161794fd288faec3eba15fa41~hHnILpQ50ZfJc3nurDfHCb_22rBr5gGEya68e_cZOrY=",
    "links": [{
        "rel": "self",
        "href": "http://127.0.0.1:5000/api/v2/passwords/snappassbedf19b161794fd288faec3eba15fa41~hHnILpQ50ZfJc3nurDfHCb_22rBr5gGEya68e_cZOrY%3D"
    }, {
        "rel": "web-view",
        "href": "http://127.0.0.1:5000/snappassbedf19b161794fd288faec3eba15fa41~hHnILpQ50ZfJc3nurDfHCb_22rBr5gGEya68e_cZOrY%3D"
    }],
    "ttl": 1209600
}
```

Override default TTL:

```bash
curl -X POST -H "Content-Type: application/json" -d '{"password": "foobar", "ttl": 3600}' http://localhost:5000/api/v2/passwords
```

For invalid parameters (null/empty password or excessive TTL), the API returns error details:

```json
{
    "invalid-params": [{
        "name": "password",
        "reason": "The password is required and should not be null or empty."
    }, {
        "name": "ttl",
        "reason": "The specified TTL is longer than the maximum supported."
    }],
    "title": "The password and/or the TTL are invalid.",
    "type": "https://127.0.0.1:5000/set-password-validation-error"
}
```

#### Check if a password exists

Send a HEAD request to `/api/v2/passwords/<token>`:

```bash
curl --head http://localhost:5000/api/v2/passwords/snappassbedf19b161794fd288faec3eba15fa41~hHnILpQ50ZfJc3nurDfHCb_22rBr5gGEya68e_cZOrY%3D
```

If the password exists, is unread, and not expired:

```
HTTP/1.1 200 OK
Server: Werkzeug/3.0.1 Python/3.13.0
Date: Fri, 29 Mar 2024 22:15:54 GMT
Content-Type: text/html; charset=utf-8
Content-Length: 0
Connection: close
```

Otherwise:

```
HTTP/1.1 404 NOT FOUND
Server: Werkzeug/3.0.1 Python/3.13.0
Date: Fri, 29 Mar 2024 22:19:29 GMT
Content-Type: text/html; charset=utf-8
Content-Length: 0
Connection: close
```

#### Read a password

Send a GET request to `/api/v2/passwords/<token>`:

```bash
curl -X GET http://localhost:5000/api/v2/passwords/snappassbedf19b161794fd288faec3eba15fa41~hHnILpQ50ZfJc3nurDfHCb_22rBr5gGEya68e_cZOrY%3D
```

If valid and available:

```json
{
    "password": "foobar"
}
```

If not found:

```json
{
    "invalid-params": [{
        "name": "token"
    }],
    "title": "The password doesn't exist.",
    "type": "https://127.0.0.1:5000/get-password-error"
}
```

### Notes on APIs

* You can specify any TTL lower than the configured maximum
* Passwords are passed in request bodies (not URLs) to prevent logging
* Consider exposing `/api` endpoints only to internal networks and placing the web interface behind authentication

