import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "intro", "game", "results",
    "questionNum", "scoreDisplay", "progressBar",
    "questionImage", "options", "feedback", "feedbackText",
    "finalScore", "resultsMessage", "resultsEmoji"
  ]

  connect() {
    this.questions = []
    this.currentQuestion = 0
    this.score = 0
    this.startTime = null
    this.answering = false
  }

  async startGame() {
    try {
      const response = await fetch('/games/guess-age/start', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' }
      })
      const data = await response.json()
      this.questions = data.questions
      this.currentQuestion = 0
      this.score = 0
      this.startTime = Date.now()

      this.introTarget.classList.add('hidden')
      this.resultsTarget.classList.add('hidden')
      this.gameTarget.classList.remove('hidden')

      this.showQuestion()
    } catch (error) {
      console.error('Failed to start quiz:', error)
    }
  }

  showQuestion() {
    if (this.currentQuestion >= this.questions.length) {
      this.showResults()
      return
    }

    const q = this.questions[this.currentQuestion]
    this.questionNumTarget.textContent = `Cau ${this.currentQuestion + 1}/${this.questions.length}`
    this.scoreDisplayTarget.textContent = `${this.score} diem`
    this.progressBarTarget.style.width = `${((this.currentQuestion + 1) / this.questions.length) * 100}%`
    this.questionImageTarget.src = q.image_url
    this.feedbackTarget.classList.add('hidden')
    this.answering = false

    // Render options
    this.optionsTarget.innerHTML = ''
    q.options.forEach(opt => {
      const btn = document.createElement('button')
      btn.className = 'quiz-option font-heading font-semibold'
      btn.textContent = opt.label
      btn.dataset.value = opt.value
      btn.addEventListener('click', () => this.checkAnswer(opt.value, btn))
      this.optionsTarget.appendChild(btn)
    })
  }

  async checkAnswer(answer, button) {
    if (this.answering) return
    this.answering = true

    const q = this.questions[this.currentQuestion]

    try {
      const response = await fetch('/games/guess-age/check', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
        body: JSON.stringify({ memory_id: q.id, answer: answer })
      })
      const data = await response.json()

      // Highlight correct/incorrect
      const buttons = this.optionsTarget.querySelectorAll('.quiz-option')
      buttons.forEach(btn => {
        btn.disabled = true
        if (btn.dataset.value === data.correct_answer) {
          btn.classList.add('correct')
        }
      })

      if (data.correct) {
        button.classList.add('correct')
        this.score++
        this.feedbackTarget.style.background = 'rgba(34, 197, 94, 0.1)'
        this.feedbackTextTarget.textContent = '✅ Dung roi!'
        this.feedbackTextTarget.style.color = '#16A34A'
      } else {
        button.classList.add('incorrect')
        this.feedbackTarget.style.background = 'rgba(239, 68, 68, 0.1)'
        this.feedbackTextTarget.textContent = `❌ Sai roi! Dap an dung: ${data.correct_label}`
        this.feedbackTextTarget.style.color = '#DC2626'
      }
      this.feedbackTarget.classList.remove('hidden')
      this.scoreDisplayTarget.textContent = `${this.score} diem`

      // Next question after delay
      setTimeout(() => {
        this.currentQuestion++
        this.showQuestion()
      }, 1500)

    } catch (error) {
      console.error('Check answer error:', error)
      this.answering = false
    }
  }

  async showResults() {
    const timeSeconds = Math.floor((Date.now() - this.startTime) / 1000)
    this.gameTarget.classList.add('hidden')
    this.resultsTarget.classList.remove('hidden')

    this.finalScoreTarget.textContent = this.score
    const emoji = this.score >= 8 ? '🏆' : this.score >= 5 ? '👏' : '💪'
    this.resultsEmojiTarget.textContent = emoji

    try {
      const response = await fetch('/games/guess-age/complete', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
        body: JSON.stringify({ score: this.score, total: this.questions.length, time_seconds: timeSeconds })
      })
      const data = await response.json()
      this.resultsMessageTarget.textContent = data.message
    } catch {
      this.resultsMessageTarget.textContent = 'Cam on ban da choi!'
    }

    // Confetti if good score
    if (this.score >= 7) this.launchConfetti()
  }

  restart() {
    this.resultsTarget.classList.add('hidden')
    this.introTarget.classList.remove('hidden')
  }

  launchConfetti() {
    const colors = ['#F2C2C2', '#C1DDD8', '#C0DFD0', '#E8B0B0', '#DBEAFE', '#FEF3C7']
    for (let i = 0; i < 30; i++) {
      const particle = document.createElement('div')
      const color = colors[Math.floor(Math.random() * colors.length)]
      const size = Math.random() * 10 + 5
      const startX = Math.random() * window.innerWidth
      particle.style.cssText = `position:fixed;top:-20px;left:${startX}px;width:${size}px;height:${size}px;background:${color};border-radius:${Math.random() > 0.5 ? '50%' : '2px'};pointer-events:none;z-index:9999;`
      document.body.appendChild(particle)
      particle.animate([
        { transform: 'translate(0, 0) rotate(0deg)', opacity: 1 },
        { transform: `translate(${(Math.random() - 0.5) * 200}px, ${window.innerHeight + 50}px) rotate(${Math.random() * 720}deg)`, opacity: 0 }
      ], { duration: Math.random() * 2000 + 1500, easing: 'cubic-bezier(0.25, 0.46, 0.45, 0.94)' }).onfinish = () => particle.remove()
    }
  }
}
