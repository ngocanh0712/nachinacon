import { Controller } from "@hotwired/stimulus"

// Flash message controller for auto-hiding notifications
export default class extends Controller {
  connect() {
    // Auto-hide flash message after 4 seconds
    this.timeoutId = setTimeout(() => {
      this.hide()
    }, 4000)
  }

  disconnect() {
    // Clear timeout if element is removed
    if (this.timeoutId) {
      clearTimeout(this.timeoutId)
    }
  }

  hide() {
    this.element.style.opacity = "0"
    this.element.style.transition = "opacity 0.5s ease"

    setTimeout(() => {
      this.element.remove()
    }, 500)
  }
}
