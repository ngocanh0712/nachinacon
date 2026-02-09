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

    // Already reacted: play animation only, no server call
    if (localStorage.getItem(storageKey)) {
      this.animateReaction(button, emoji)
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

      // Sync card reactions outside modal
      this.syncCardReactions(memoryId)

    } catch (error) {
      console.error('Reaction error:', error)
    }
  }

  // Update the reaction display on the memory card outside the modal
  syncCardReactions(memoryId) {
    const cardReactionsEl = document.querySelector(`.card-reactions[data-card-memory-id="${memoryId}"]`)
    if (!cardReactionsEl) return

    // Collect current counts from modal buttons
    const counts = {}
    this.btnTargets.forEach(btn => {
      const emoji = btn.dataset.emoji
      const countEl = btn.querySelector('[data-reactions-target="count"]')
      if (countEl && countEl.style.display !== 'none') {
        const count = parseInt(countEl.textContent) || 0
        if (count > 0) counts[emoji] = count
      }
    })

    // Sort by count descending, take top 3
    const sorted = Object.entries(counts).sort((a, b) => b[1] - a[1]).slice(0, 3)

    // Rebuild card reactions HTML
    cardReactionsEl.innerHTML = sorted.map(([emoji, count]) =>
      `<span class="inline-flex items-center gap-0.5 text-xs" style="color:#6B7280;">` +
        `<span>${emoji}</span>` +
        `<span class="font-heading font-semibold" style="font-size:10px;">${count}</span>` +
      `</span>`
    ).join('')
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
