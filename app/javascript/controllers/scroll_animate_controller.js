import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    animation: { type: String, default: "animate-fade-in-up" },
    threshold: { type: Number, default: 0.15 },
    delay: { type: Number, default: 0 }
  }

  connect() {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      this.element.style.opacity = "1"
      return
    }

    this.element.style.opacity = "0"

    this.observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            if (this.delayValue > 0) {
              setTimeout(() => this._animate(), this.delayValue)
            } else {
              this._animate()
            }
            this.observer.unobserve(entry.target)
          }
        })
      },
      { threshold: this.thresholdValue }
    )

    this.observer.observe(this.element)
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  _animate() {
    this.element.style.opacity = "1"
    this.element.classList.add(this.animationValue)
  }
}
