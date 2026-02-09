import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["wheel", "spinBtn", "result", "resultEmoji", "resultBadge", "resultLabel"]

  // Category badge colors
  categoryColors = {
    reward: { bg: '#D1FAE5', text: '#059669' },
    punishment: { bg: '#FCE7F3', text: '#DB2777' },
    challenge: { bg: '#DBEAFE', text: '#2563EB' },
    interaction: { bg: '#FEF3C7', text: '#D97706' }
  }

  connect() {
    this.isSpinning = false
    this.currentRotation = 0
  }

  async spin() {
    if (this.isSpinning) return
    this.isSpinning = true
    this.spinBtnTarget.disabled = true
    this.spinBtnTarget.textContent = '🎰 Dang quay...'

    // Random rotation: at least 5 full rotations + random offset
    const extraRotation = Math.floor(Math.random() * 360)
    const totalRotation = this.currentRotation + 1800 + extraRotation
    this.currentRotation = totalRotation

    // Apply rotation
    this.wheelTarget.style.transform = `rotate(${totalRotation}deg)`

    // Fetch random item while spinning
    try {
      const response = await fetch('/spin-wheel/spin', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        }
      })

      if (!response.ok) throw new Error('Failed to spin')
      const data = await response.json()

      // Wait for spin animation to complete (4s)
      setTimeout(() => {
        this.showResult(data)
        this.isSpinning = false
        this.spinBtnTarget.disabled = false
        this.spinBtnTarget.textContent = '🎰 Quay Ngay!'
      }, 4200)

    } catch (error) {
      console.error('Spin error:', error)
      setTimeout(() => {
        this.isSpinning = false
        this.spinBtnTarget.disabled = false
        this.spinBtnTarget.textContent = '🎰 Quay Ngay!'
      }, 4200)
    }
  }

  showResult(data) {
    this.resultEmojiTarget.textContent = data.emoji || '🎉'
    this.resultLabelTarget.textContent = data.label || ''

    // Set category badge
    const colors = this.categoryColors[data.category] || { bg: '#F3F4F6', text: '#6B7280' }
    this.resultBadgeTarget.textContent = data.category_label || data.category
    this.resultBadgeTarget.style.background = colors.bg
    this.resultBadgeTarget.style.color = colors.text

    this.resultTarget.classList.remove('hidden')
    document.body.style.overflow = 'hidden'

    // Trigger confetti
    this.launchConfetti()
  }

  closeResult() {
    this.resultTarget.classList.add('hidden')
    document.body.style.overflow = 'auto'
  }

  spinAgain() {
    this.closeResult()
    setTimeout(() => this.spin(), 300)
  }

  launchConfetti() {
    const colors = ['#F2C2C2', '#C1DDD8', '#C0DFD0', '#E8B0B0', '#DBEAFE', '#FEF3C7']
    const container = document.body

    for (let i = 0; i < 40; i++) {
      const particle = document.createElement('div')
      const color = colors[Math.floor(Math.random() * colors.length)]
      const size = Math.random() * 10 + 5
      const startX = Math.random() * window.innerWidth
      const isCircle = Math.random() > 0.5

      particle.style.cssText = `
        position: fixed;
        top: -20px;
        left: ${startX}px;
        width: ${size}px;
        height: ${size}px;
        background: ${color};
        border-radius: ${isCircle ? '50%' : '2px'};
        pointer-events: none;
        z-index: 9999;
      `
      container.appendChild(particle)

      const duration = Math.random() * 2000 + 1500
      const drift = (Math.random() - 0.5) * 200
      const rotation = Math.random() * 720

      particle.animate([
        { transform: `translate(0, 0) rotate(0deg)`, opacity: 1 },
        { transform: `translate(${drift}px, ${window.innerHeight + 50}px) rotate(${rotation}deg)`, opacity: 0 }
      ], {
        duration: duration,
        easing: 'cubic-bezier(0.25, 0.46, 0.45, 0.94)'
      }).onfinish = () => particle.remove()
    }
  }
}
