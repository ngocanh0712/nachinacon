import { Controller } from "@hotwired/stimulus"

// Enables swipe/keyboard navigation between memories in the modal.
// Collects all .memory-card elements on the page and allows
// cycling through them with swipe gestures, arrow keys, or nav buttons.
export default class extends Controller {
  static values = { currentIndex: { type: Number, default: -1 } }

  connect() {
    this.memories = []
    this.touchStartX = 0
    this.touchEndX = 0
    this.swipeThreshold = 50

    // Bind handlers for cleanup
    this._onKeydown = this.handleKeydown.bind(this)
    this._onTouchStart = this.handleTouchStart.bind(this)
    this._onTouchEnd = this.handleTouchEnd.bind(this)

    document.addEventListener("keydown", this._onKeydown)
    this.element.addEventListener("touchstart", this._onTouchStart, { passive: true })
    this.element.addEventListener("touchend", this._onTouchEnd, { passive: true })

    // Inject nav buttons and counter into modal image section
    this.injectNavElements()
  }

  disconnect() {
    document.removeEventListener("keydown", this._onKeydown)
    this.element.removeEventListener("touchstart", this._onTouchStart)
    this.element.removeEventListener("touchend", this._onTouchEnd)
  }

  // Collect all memory cards from page and find current index
  collectMemories() {
    const cards = document.querySelectorAll("[data-memory-id]")
    this.memories = Array.from(cards).map(card => ({
      title: card.dataset.memoryTitle || "",
      date: card.dataset.memoryDate || "",
      caption: card.dataset.memoryCaption || "",
      imageUrl: card.dataset.memoryImage || "",
      ageGroup: card.dataset.memoryAgeGroup || "",
      ageColor: card.dataset.memoryAgeColor || "#DBEAFE;#3B82F6",
      memoryId: card.dataset.memoryId || ""
    }))
  }

  // Called when modal opens - set current memory index
  setCurrentMemory(memoryId) {
    this.collectMemories()
    this.currentIndexValue = this.memories.findIndex(m => m.memoryId === String(memoryId))
    this.updateNavState()
  }

  // Navigate to previous memory
  prev() {
    if (this.currentIndexValue > 0) {
      this.currentIndexValue--
      this.navigateToCurrentMemory("right")
    }
  }

  // Navigate to next memory
  next() {
    if (this.currentIndexValue < this.memories.length - 1) {
      this.currentIndexValue++
      this.navigateToCurrentMemory("left")
    }
  }

  navigateToCurrentMemory(direction) {
    const memory = this.memories[this.currentIndexValue]
    if (!memory) return

    const img = document.getElementById("modalImage")
    if (img) {
      // Slide animation
      const offset = direction === "left" ? "-20px" : "20px"
      img.style.transition = "transform 0.15s ease-out, opacity 0.15s ease-out"
      img.style.transform = `translateX(${offset})`
      img.style.opacity = "0.5"

      setTimeout(() => {
        // Update content via existing function
        if (typeof openMemoryModal === "function") {
          openMemoryModal(memory)
        }
        // Slide in from opposite side
        const inOffset = direction === "left" ? "20px" : "-20px"
        img.style.transform = `translateX(${inOffset})`
        requestAnimationFrame(() => {
          img.style.transform = "translateX(0)"
          img.style.opacity = "1"
        })
      }, 150)
    } else {
      if (typeof openMemoryModal === "function") {
        openMemoryModal(memory)
      }
    }

    this.updateNavState()
  }

  // Update button disabled states and counter
  updateNavState() {
    const prevBtn = this.element.querySelector(".gallery-prev")
    const nextBtn = this.element.querySelector(".gallery-next")
    const counter = this.element.querySelector(".gallery-counter")

    if (prevBtn) prevBtn.disabled = this.currentIndexValue <= 0
    if (nextBtn) nextBtn.disabled = this.currentIndexValue >= this.memories.length - 1
    if (counter && this.memories.length > 0) {
      counter.textContent = `${this.currentIndexValue + 1} / ${this.memories.length}`
      counter.style.display = "block"
    }
  }

  // Keyboard navigation
  handleKeydown(e) {
    const modal = document.getElementById("memoryModal")
    if (!modal || modal.classList.contains("hidden")) return

    if (e.key === "ArrowLeft") {
      e.preventDefault()
      this.prev()
    } else if (e.key === "ArrowRight") {
      e.preventDefault()
      this.next()
    }
  }

  // Touch swipe handlers
  handleTouchStart(e) {
    this.touchStartX = e.changedTouches[0].screenX
  }

  handleTouchEnd(e) {
    this.touchEndX = e.changedTouches[0].screenX
    const diff = this.touchStartX - this.touchEndX

    if (Math.abs(diff) > this.swipeThreshold) {
      if (diff > 0) {
        this.next() // Swipe left = next
      } else {
        this.prev() // Swipe right = prev
      }
    }
  }

  // Inject navigation buttons and counter into modal
  injectNavElements() {
    const imageSection = this.element.querySelector(".relative.bg-gray-100")
    if (!imageSection) return

    // Only inject once
    if (imageSection.querySelector(".gallery-prev")) return

    // Previous button
    const prevBtn = document.createElement("button")
    prevBtn.className = "gallery-nav-btn gallery-prev"
    prevBtn.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" style="width:20px;height:20px;"><path stroke-linecap="round" stroke-linejoin="round" d="M15.75 19.5L8.25 12l7.5-7.5"/></svg>`
    prevBtn.addEventListener("click", (e) => { e.stopPropagation(); this.prev() })

    // Next button
    const nextBtn = document.createElement("button")
    nextBtn.className = "gallery-nav-btn gallery-next"
    nextBtn.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" style="width:20px;height:20px;"><path stroke-linecap="round" stroke-linejoin="round" d="M8.25 4.5l7.5 7.5-7.5 7.5"/></svg>`
    nextBtn.addEventListener("click", (e) => { e.stopPropagation(); this.next() })

    // Counter
    const counter = document.createElement("div")
    counter.className = "gallery-counter"
    counter.style.display = "none"

    imageSection.appendChild(prevBtn)
    imageSection.appendChild(nextBtn)
    imageSection.appendChild(counter)
  }
}
