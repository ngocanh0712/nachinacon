# NaChiNaCon - Baby Memory Keepsake Website

## Overview
Website lưu giữ kỷ niệm con trai từ 0-3 tuổi. UI pastel nhẹ nhàng, public hoàn toàn.

**Tech Stack:** Rails 7.1 + Tailwind CSS + MySQL + Active Storage

## Current Status
- Base code có sẵn: Admin auth, Memory model, Milestone model
- Thiếu: Album model, UI hoàn chỉnh, responsive, seed data

## Implementation Phases

| # | Phase | Status | Description |
|---|-------|--------|-------------|
| 1 | [Database & Models](./phase-01-database-models.md) | Pending | Thêm Album model, cập nhật quan hệ |
| 2 | [Admin Panel](./phase-02-admin-panel.md) | Pending | CRUD Albums, cải thiện UI admin |
| 3 | [Public Pages](./phase-03-public-pages.md) | Pending | Hoàn thiện Home, Timeline, Milestones, Albums |
| 4 | [UI Enhancement](./phase-04-ui-enhancement.md) | Pending | Animations, responsive, polish |
| 5 | [Seed Data & Testing](./phase-05-seed-testing.md) | Pending | Sample data, manual testing |

## Color Palette
| Color | Hex | Usage |
|-------|-----|-------|
| Primary | #C1DDD8 | Buttons, headers |
| Secondary | #F2C2C2 | Accents, badges |
| Background | #F6F2EC | Page background |
| Accent | #C0DFD0 | Tags, highlights |

## Key Dependencies
- Ruby 3.2.1, Rails 7.1
- Tailwind CSS 4.x
- Active Storage (local/S3)
- MySQL database

## Success Criteria
- [ ] Public pages load fast, beautiful UI
- [ ] Admin can CRUD memories, milestones, albums
- [ ] Images display correctly with variants
- [ ] Responsive trên mobile/tablet/desktop
- [ ] Timeline hiển thị theo age group
- [ ] Albums nhóm ảnh theo category
