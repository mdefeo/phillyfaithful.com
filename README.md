# phillyfaithful.com

WordPress site with WooCommerce, running in Docker containers and automatically deployed to a Digital Ocean Droplet via GitHub Actions on every push to `main`.

---

## Architecture

| Service     | Image                          | Purpose                              |
|-------------|--------------------------------|--------------------------------------|
| `db`        | `mariadb:10.11`                | MySQL-compatible database            |
| `wordpress` | Custom (see `Dockerfile`)      | WordPress + PHP-FPM + WP-CLI         |
| `nginx`     | `nginx:1.25-alpine`            | Reverse proxy / web server           |

---

## Local Development

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/)

### Quick Start

```bash
# 1. Copy environment variables
cp .env.example .env
# Edit .env and fill in secure passwords

# 2. Build and start all services
docker compose up -d --build

# 3. Install WordPress core and WooCommerce (first time only)
docker compose exec wordpress bash /scripts/install-wordpress.sh

# 4. Open your browser
open http://localhost
```

The WordPress admin panel is available at `http://localhost/wp-admin`.

---

## Production Deployment (Digital Ocean Droplet)

### 1. Prepare the Droplet

SSH into a fresh Ubuntu 22.04 Droplet and run:

```bash
git clone https://github.com/mdefeo/phillyfaithful.com.git /opt/phillyfaithful.com
cd /opt/phillyfaithful.com
bash scripts/setup-server.sh
```

### 2. Configure Environment

```bash
cd /opt/phillyfaithful.com
cp .env.example .env
# Edit .env with production values (strong passwords, correct domain, etc.)
```

### 3. Start the Site

```bash
docker compose up -d --build
docker compose exec wordpress bash /scripts/install-wordpress.sh
```

### 4. Configure GitHub Secrets

In your GitHub repository, go to **Settings → Secrets and variables → Actions** and add:

| Secret Name          | Description                                       |
|----------------------|---------------------------------------------------|
| `DO_SSH_HOST`        | IP address or hostname of the Droplet             |
| `DO_SSH_USERNAME`    | SSH user (e.g. `root` or a deploy user)           |
| `DO_SSH_PRIVATE_KEY` | Private SSH key with access to the Droplet        |
| `DO_SSH_PORT`        | SSH port (optional, defaults to `22`)             |

### 5. Automatic Deploys

Every push to the `main` branch triggers the GitHub Actions workflow (`.github/workflows/deploy.yml`), which:

1. SSH-es into the Droplet
2. Pulls the latest code (`git pull origin main`)
3. Rebuilds and restarts containers (`docker compose up -d --build`)
4. Prunes unused Docker images

---

## Adding Custom Themes and Plugins

Place your custom themes and plugins in the `wp-content/` directory. They are bind-mounted into both the `wordpress` and `nginx` containers at `/var/www/html/wp-content`.

```
wp-content/
├── plugins/   ← custom plugins
├── themes/    ← custom themes
└── uploads/   ← user uploads (git-ignored)
```

---

## Available Scripts

| Script                          | Purpose                                         |
|---------------------------------|-------------------------------------------------|
| `scripts/setup-server.sh`       | Bootstrap Docker on a fresh Ubuntu Droplet      |
| `scripts/install-wordpress.sh`  | Install WordPress core + WooCommerce via WP-CLI |

---

## Environment Variables

See [`.env.example`](.env.example) for a full list of configurable variables. **Never commit `.env` to version control.**
