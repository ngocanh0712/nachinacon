import { Controller } from "@hotwired/stimulus"

// Reactions controller for memory modal
// Handles emoji reactions with localStorage dedup and server persistence
export default class extends Controller {
  static targets = ["btn", "count"]

  // Use memoryIdValueChanged to detect when modal sets the memory ID dynamically
  get memoryId() {
    return this.element.getAttribute('data-reactions-memory-id-value')
  }

  async react(event) {
    const button = event.currentTarget
    const emoji = button.dataset.emoji
    const memoryId = this.memoryId

    if (!memoryId || memoryId === '' || memoryId === '0') {
      console.warn('No memory ID set for reactions')
      return
    }

    const storageKey = `reacted_${memoryId}_${emoji}`

    // Check localStorage to prevent spam
    if (localStorage.getItem(storageKey)) {
      this.shakeButton(button)
      return
    }

    try {
      const response = await fetch(`/memories/${memoryId}/react`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify({ emoji: emoji })
      })

      if (!response.ok) throw new Error('Failed to react')

      const data = await response.json()

      // Update count display
      const countEl = button.querySelector('[data-reactions-target="count"]')
      if (countEl) {
        countEl.textContent = data.count
        countEl.style.display = 'inline'
      }

      // Mark as reacted in localStorage
      localStorage.setItem(storageKey, 'true')
      button.classList.add('reacted')

      // Animate
      this.animateReaction(button, emoji)

    } catch (error) {
      console.error('Reaction error:', error)
    }
  }

  animateReaction(button, emoji) {
    // Float emoji upward animation
    const floater = document.createElement('span')
    floater.textContent = emoji
    floater.style.cssText = 'position:absolute;font-size:24px;pointer-events:none;z-index:100;top:0;left:50%;transform:translateX(-50%);'
    button.appendChild(floater)

    // Animate using Web Animations API (more reliable than CSS keyframes)
    floater.animate([
      { opacity: 1, transform: 'translateX(-50%) translateY(0) scale(1)' },
      { opacity: 0, transform: 'translateX(-50%) translateY(-50px) scale(1.5)' }
    ], { duration: 1000, easing: 'ease-out' }).onfinish = () => floater.remove()

    // Scale bounce on button
    button.animate([
      { transform: 'scale(1)' },
      { transform: 'scale(1.25)' },
      { transform: 'scale(1)' }
    ], { duration: 300, easing: 'ease-out' })
  }

  shakeButton(button) {
    button.animate([
      { transform: 'translateX(0)' },
      { transform: 'translateX(-4px)' },
      { transform: 'translateX(4px)' },
      { transform: 'translateX(-4px)' },
      { transform: 'translateX(4px)' },
      { transform: 'translateX(0)' }
    ], { duration: 400, easing: 'ease-in-out' })
  }
}
