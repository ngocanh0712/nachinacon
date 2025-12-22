# Phase 4: UI Enhancement

## Context
- Parent plan: [plan.md](./plan.md)
- Dependencies: Phase 3

## Overview
- **Priority:** Medium
- **Status:** Pending
- **Description:** Animations, responsive polish, hover effects, mobile menu

## Key Insights
- Tailwind CSS đã có custom theme với colors, fonts
- Float animation đã định nghĩa
- Cần thêm hover states, transitions
- Mobile menu cần Stimulus controller

## Requirements

### Functional
- Mobile menu toggle
- Image lightbox/modal
- Smooth scroll
- Loading states

### Non-functional
- 60fps animations
- Reduced motion support
- Touch-friendly targets

## Architecture

### Stimulus Controllers
```
controllers/
├── mobile_menu_controller.js
├── lightbox_controller.js
└── lazy_load_controller.js
```

### CSS Enhancements
```css
/* Hover effects */
.card-hover { transition + transform }
.btn-hover { scale + shadow }

/* Animations */
.fade-in { opacity animation }
.slide-up { translateY animation }
```

## Related Code Files

### Create
- `app/javascript/controllers/mobile_menu_controller.js`
- `app/javascript/controllers/lightbox_controller.js`

### Modify
- `app/assets/tailwind/application.css` - thêm animations
- `app/views/layouts/application.html.erb` - mobile menu
- All view files - thêm hover classes

## Implementation Steps

### 1. Create Mobile Menu Controller
```javascript
// app/javascript/controllers/mobile_menu_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle() {
    this.menuTarget.classList.toggle("hidden")
  }

  close() {
    this.menuTarget.classList.add("hidden")
  }
}
```

### 2. Update layout with mobile menu
```erb
<!-- Mobile menu panel -->
<div data-controller="mobile-menu">
  <button data-action="click->mobile-menu#toggle">
    <!-- hamburger icon -->
  </button>

  <div data-mobile-menu-target="menu" class="hidden md:hidden">
    <!-- nav links -->
  </div>
</div>
```

### 3. Create Lightbox Controller
```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "image"]

  open(event) {
    const src = event.currentTarget.dataset.src
    this.imageTarget.src = src
    this.modalTarget.classList.remove("hidden")
  }

  close() {
    this.modalTarget.classList.add("hidden")
  }
}
```

### 4. Add CSS animations
```css
/* Hover effects */
.card-hover {
  @apply transition-all duration-300;
}
.card-hover:hover {
  @apply -translate-y-1 shadow-lg;
}

/* Button hover */
.btn-primary:hover {
  background-color: var(--color-primary-hover);
}

/* Fade in animation */
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.animate-fade-in {
  animation: fadeIn 0.5s ease-out forwards;
}

/* Staggered children */
.stagger-children > * {
  animation: fadeIn 0.5s ease-out forwards;
}
.stagger-children > *:nth-child(1) { animation-delay: 0.1s; }
.stagger-children > *:nth-child(2) { animation-delay: 0.2s; }
/* ... */
```

### 5. Add responsive breakpoints
```css
/* Mobile optimizations */
@media (max-width: 640px) {
  .hero-text { font-size: 2rem; }
  .grid-cols-3 { grid-template-columns: repeat(2, 1fr); }
}
```

### 6. Update views with animation classes

## Todo List
- [ ] Create mobile_menu_controller.js
- [ ] Create lightbox_controller.js
- [ ] Update application.css with animations
- [ ] Update layout with mobile menu
- [ ] Add hover effects to cards
- [ ] Add fade-in animations to grids
- [ ] Create lightbox modal component
- [ ] Test on mobile devices
- [ ] Verify reduced-motion works

## Success Criteria
- [ ] Mobile menu toggle hoạt động
- [ ] Lightbox mở ảnh full-screen
- [ ] Hover effects smooth
- [ ] Animations không jank
- [ ] Reduced motion respected

## Risk Assessment
- **Low:** CSS/JS enhancements
- Test trên nhiều browsers

## Security Considerations
- Không có security concerns

## Next Steps
→ Phase 5: Seed Data & Testing
