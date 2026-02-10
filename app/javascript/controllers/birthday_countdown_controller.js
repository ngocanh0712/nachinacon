import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { birthDate: String }
  static targets = ["days", "hours", "minutes", "seconds", "message", "countdown"]

  connect() {
    this.update()
    this.timer = setInterval(() => this.update(), 1000)
  }

  disconnect() {
    if (this.timer) clearInterval(this.timer)
  }

  update() {
    const birth = new Date(this.birthDateValue)
    const now = new Date()

    let nextBirthday = new Date(now.getFullYear(), birth.getMonth(), birth.getDate())
    if (nextBirthday <= now) {
      nextBirthday = new Date(now.getFullYear() + 1, birth.getMonth(), birth.getDate())
    }

    const diff = nextBirthday - now

    // Check if today is the birthday
    if (now.getMonth() === birth.getMonth() && now.getDate() === birth.getDate()) {
      if (this.hasCountdownTarget) this.countdownTarget.classList.add("hidden")
      if (this.hasMessageTarget) {
        this.messageTarget.classList.remove("hidden")
        this._launchConfetti()
      }
      return
    }

    const days = Math.floor(diff / (1000 * 60 * 60 * 24))
    const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
    const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))
    const seconds = Math.floor((diff % (1000 * 60)) / 1000)

    if (this.hasDaysTarget) this.daysTarget.textContent = days
    if (this.hasHoursTarget) this.hoursTarget.textContent = String(hours).padStart(2, "0")
    if (this.hasMinutesTarget) this.minutesTarget.textContent = String(minutes).padStart(2, "0")
    if (this.hasSecondsTarget) this.secondsTarget.textContent = String(seconds).padStart(2, "0")
  }

  _launchConfetti() {
    const container = this.element
    const colors = ["#C1DDD8", "#F2C2C2", "#C0DFD0", "#E8B0B0", "#FFD700", "#FF69B4"]

    for (let i = 0; i < 50; i++) {
      setTimeout(() => {
        const confetti = document.createElement("div")
        confetti.style.cssText = `
          position: fixed; width: 10px; height: 10px; border-radius: 50%;
          background: ${colors[Math.floor(Math.random() * colors.length)]};
          left: ${Math.random() * 100}vw; top: -10px;
          z-index: 9999; pointer-events: none;
          animation: confetti-fall ${2 + Math.random() * 2}s linear forwards;
        `
        document.body.appendChild(confetti)
        setTimeout(() => confetti.remove(), 4000)
      }, i * 50)
    }
  }
}
