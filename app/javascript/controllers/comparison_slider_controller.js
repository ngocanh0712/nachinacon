import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "beforeClip", "handle"]

  connect() {
    this.isDragging = false
    this.position = 50

    // Bind event handlers
    this.boundDrag = this.drag.bind(this)
    this.boundStopDrag = this.stopDrag.bind(this)

    document.addEventListener('mousemove', this.boundDrag)
    document.addEventListener('mouseup', this.boundStopDrag)
    document.addEventListener('touchmove', this.boundDrag, { passive: false })
    document.addEventListener('touchend', this.boundStopDrag)
  }

  disconnect() {
    document.removeEventListener('mousemove', this.boundDrag)
    document.removeEventListener('mouseup', this.boundStopDrag)
    document.removeEventListener('touchmove', this.boundDrag)
    document.removeEventListener('touchend', this.boundStopDrag)
  }

  startDrag(event) {
    event.preventDefault()
    this.isDragging = true
  }

  drag(event) {
    if (!this.isDragging) return
    event.preventDefault()

    const container = this.containerTarget
    const rect = container.getBoundingClientRect()
    const clientX = event.touches ? event.touches[0].clientX : event.clientX
    let position = ((clientX - rect.left) / rect.width) * 100

    // Clamp between 5% and 95%
    position = Math.max(5, Math.min(95, position))
    this.position = position

    this.updatePosition(position)
  }

  stopDrag() {
    this.isDragging = false
  }

  updatePosition(percent) {
    // Update clip-path for before image
    this.beforeClipTarget.style.clipPath = `inset(0 ${100 - percent}% 0 0)`

    // Update handle position
    this.handleTarget.style.left = `${percent}%`
  }
}
