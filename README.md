# NaChiNaCon - Baby Memory Keepsake

Website lưu giữ kỷ niệm của bé (0-3 tuổi) với giao diện đẹp, màu pastel nhẹ nhàng.

## Tech Stack

- **Ruby**: 3.2.1
- **Rails**: 7.1.x
- **Database**: MySQL
- **CSS**: Tailwind CSS
- **File Storage**: Active Storage

## Quick Start

```bash
# Clone project
cd /Users/anonymous/nachinacon

# Install dependencies
bundle install

# Setup database
bin/rails db:create db:migrate db:seed

# Start development server
bin/dev
```

Truy cập:
- **Public**: http://localhost:3000
- **Admin**: http://localhost:3000/admin/login

## Default Admin

- **Email**: admin@nachinacon.com
- **Password**: password123

## Features

### Public Pages
- **Home**: Trang chủ với kỷ niệm gần đây
- **Timeline**: Xem kỷ niệm theo giai đoạn tuổi
- **Milestones**: Các mốc quan trọng của bé

### Admin Panel
- Upload ảnh/video kỷ niệm
- Quản lý milestones
- Dashboard thống kê

## Project Structure

```
nachinacon/
├── app/
│   ├── controllers/
│   │   ├── admin/          # Admin controllers
│   │   ├── pages_controller.rb
│   │   └── sessions_controller.rb
│   ├── models/
│   │   ├── admin.rb        # Admin user
│   │   ├── memory.rb       # Photos/videos
│   │   └── milestone.rb    # Special events
│   └── views/
│       ├── admin/
│       ├── pages/
│       └── layouts/
└── docs/
    ├── tech-stack.md
    ├── design-guidelines.md
    └── wireframes/
```

## Color Palette

| Color | Hex | Usage |
|-------|-----|-------|
| Primary | #C1DDD8 | Buttons, headers |
| Secondary | #F2C2C2 | Accents |
| Background | #F6F2EC | Page background |
| Accent | #C0DFD0 | Badges, tags |

## Deployment (Railway)

1. Push code to GitHub
2. Connect Railway to repo
3. Add MySQL addon
4. Set environment variables
5. Deploy

## License

Private project.
