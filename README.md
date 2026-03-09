# NaChiNaCon - Baby Memory Keepsake

Private family web app to preserve baby memories (0-3 years) with a soft pastel UI.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Language | Ruby 3.2.1 |
| Framework | Rails 7.1.x |
| Database | MySQL |
| Frontend | Tailwind CSS + Hotwire (Turbo/Stimulus) |
| File Storage | Active Storage + Cloudinary CDN |
| Auth | bcrypt (session-based) |
| Pagination | Pagy |
| Deployment | Railway |

## Quick Start

```bash
bundle install
bin/rails db:create db:migrate db:seed
bin/dev
```

- **Public**: http://localhost:3000
- **Admin**: http://localhost:3000/admin/login

## Features

### Public Pages
- **Home** - Recent memories, milestones, albums, baby age counter
- **Timeline** - Browse memories by age group (0-3m, 3-6m, 6-12m, 1-2y, 2-3y)
- **Milestones** - Track developmental achievements (first smile, first step, etc.)
- **Albums** - Thematic memory collections
- **Search** - Full-text search with age group filters

### Admin Panel
- Upload/manage photos & videos with metadata (title, caption, date, tags)
- Create/track milestones and albums
- Dashboard with statistics
- Site settings (baby birth date)
- Cloudinary health checks

## Project Structure

```
nachinacon/
├── app/
│   ├── controllers/
│   │   ├── admin/                  # Admin CRUD controllers (7)
│   │   ├── pages_controller.rb     # Public pages
│   │   └── sessions_controller.rb  # Login/logout
│   ├── models/
│   │   ├── admin_user.rb           # Auth (has_secure_password)
│   │   ├── memory.rb               # Photos/videos + tags + albums
│   │   ├── milestone.rb            # Developmental achievements
│   │   ├── album.rb                # Memory collections
│   │   ├── tag.rb                  # Categorization with colors
│   │   └── site_setting.rb         # Key-value config store
│   ├── views/
│   │   ├── layouts/                # application + admin layouts
│   │   ├── pages/                  # Public: home, timeline, milestones, albums, search
│   │   ├── admin/                  # Admin: dashboard, memories, milestones, albums, settings
│   │   └── shared/                 # Reusable partials
│   └── javascript/controllers/     # Stimulus: flash_message, mobile_menu
├── config/
│   ├── routes.rb                   # Public + admin routes
│   ├── storage.yml                 # Cloudinary config
│   └── database.yml                # MySQL config
├── db/
│   ├── schema.rb                   # 8 tables + Active Storage
│   ├── seeds.rb                    # Initial data
│   └── migrate/                    # 13+ migrations
├── docs/                           # Detailed documentation
├── Dockerfile                      # Container setup
└── railway.toml                    # Railway deployment
```

## Data Model

```
AdminUser ─── (authentication)

Memory ──┬── AlbumMemory ──── Album
         └── MemoryTag ────── Tag

Milestone ─── (standalone, has_one_attached :photo)

SiteSetting ─── (key-value config)
```

### Key Models
- **Memory**: title, caption, taken_at, age_group, memory_type, media (Active Storage)
- **Milestone**: name, description, achieved_at, milestone_type, photo (Active Storage)
- **Album**: name, description, cover_photo; has_many memories through album_memories
- **Tag**: name, color; has_many memories through memory_tags

## Routes

```
# Public
GET /                    → home
GET /timeline            → timeline (?age_group=)
GET /milestones          → milestones
GET /albums              → albums
GET /albums/:id          → album detail
GET /search              → search (?q=&age_group=)

# Admin
GET/POST   /admin/login  → login
DELETE     /admin/logout  → logout
GET        /admin         → dashboard
CRUD       /admin/memories, /admin/milestones, /admin/albums
GET/PATCH  /admin/settings
GET        /admin/system/cloudinary
```

## Color Palette

| Color | Hex | Usage |
|-------|-----|-------|
| Primary | `#C1DDD8` | Buttons, headers |
| Secondary | `#F2C2C2` | Accents |
| Background | `#F6F2EC` | Page background |
| Accent | `#C0DFD0` | Badges, tags |

## Environment Variables

| Variable | Purpose |
|----------|---------|
| `CLOUDINARY_CLOUD_NAME` | Cloudinary cloud name |
| `CLOUDINARY_API_KEY` | Cloudinary API key |
| `CLOUDINARY_API_SECRET` | Cloudinary API secret |
| `DATABASE_URL` | MySQL connection (Railway) |
| `RAILS_MASTER_KEY` | Rails credentials key |

## Deployment (Railway)

1. Push to GitHub main branch
2. Railway auto-deploys via Docker
3. MySQL addon for database
4. Environment variables for Cloudinary + Rails
5. Puma serves on port 3000

## Development Commands

```bash
bin/dev                          # Start dev server (Rails + Tailwind)
bin/rails console                # Rails console
bin/rails db:migrate             # Run migrations
bin/rails db:seed                # Seed data
bin/rails test                   # Run tests
bin/rails credentials:edit       # Manage secrets
```

## Documentation

Detailed documentation available in [docs/](docs/):

| Document | Description |
|----------|-------------|
| [project-overview-pdr.md](docs/project-overview-pdr.md) | Project overview & product development requirements |
| [codebase-summary.md](docs/codebase-summary.md) | Full codebase structure, models, controllers, routes |
| [code-standards.md](docs/code-standards.md) | Coding conventions, style guide, review checklist |
| [system-architecture.md](docs/system-architecture.md) | Architecture diagrams, request flows, deployment |

## License

Private project.
