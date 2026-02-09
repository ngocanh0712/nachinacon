import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "intro", "gameBoard", "victory", "grid",
    "movesCount", "timer", "pairsFound", "totalPairs",
    "finalScore", "finalMoves", "finalTime"
  ]

  connect() {
    this.cards = []
    this.flippedCards = []
    this.matchedPairs = 0
    this.totalPairsCount = 0
    this.moves = 0
    this.timeElapsed = 0
    this.timerInterval = null
    this.isLocked = false
  }

  disconnect() {
    this.stopTimer()
  }

  async selectDifficulty(event) {
    const difficulty = event.currentTarget.dataset.difficulty

    try {
      const response = await fetch('/games/memory/start', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
        body: JSON.stringify({ difficulty })
      })
      const data = await response.json()

      this.cards = data.cards
      this.difficulty = data.difficulty
      this.totalPairsCount = data.pairs
      this.matchedPairs = 0
      this.moves = 0
      this.timeElapsed = 0
      this.flippedCards = []
      this.isLocked = false

      this.introTarget.classList.add('hidden')
      this.victoryTarget.classList.add('hidden')
      this.gameBoardTarget.classList.remove('hidden')

      this.totalPairsTarget.textContent = this.totalPairsCount
      this.pairsFoundTarget.textContent = '0'
      this.movesCountTarget.textContent = '0'
      this.timerTarget.textContent = '0:00'

      this.renderCards()
      this.startTimer()

    } catch (error) {
      console.error('Failed to start game:', error)
    }
  }

  renderCards() {
    const grid = this.gridTarget

    // Set grid columns based on card count
    const cols = this.cards.length <= 12 ? 4 : this.cards.length <= 16 ? 4 : 5
    grid.style.gridTemplateColumns = `repeat(${cols}, 1fr)`

    grid.innerHTML = ''

    this.cards.forEach((card, index) => {
      const cardEl = document.createElement('div')
      cardEl.className = 'game-memory-card'
      cardEl.dataset.index = index
      cardEl.dataset.memoryId = card.memory_id
      cardEl.style.cssText = 'aspect-ratio:1;perspective:1000px;cursor:pointer;'

      cardEl.innerHTML = `
        <div class="game-memory-card-inner" style="position:relative;width:100%;height:100%;transition:transform 0.6s;transform-style:preserve-3d;">
          <!-- Front (hidden face) -->
          <div style="position:absolute;width:100%;height:100%;backface-visibility:hidden;border-radius:16px;overflow:hidden;display:flex;align-items:center;justify-content:center;background:linear-gradient(135deg,#C1DDD8,#A8CEC8);box-shadow:0 4px 15px rgba(0,0,0,0.1);">
            <span style="font-size:2.5rem;opacity:0.8;">🌟</span>
          </div>
          <!-- Back (photo) -->
          <div style="position:absolute;width:100%;height:100%;backface-visibility:hidden;transform:rotateY(180deg);border-radius:16px;overflow:hidden;box-shadow:0 4px 15px rgba(0,0,0,0.1);">
            <img src="${card.image_url}" alt="${card.title}" style="width:100%;height:100%;object-fit:cover;"/>
          </div>
        </div>
      `

      cardEl.addEventListener('click', () => this.flipCard(cardEl, index))
      grid.appendChild(cardEl)
    })
  }

  flipCard(cardEl, index) {
    if (this.isLocked) return
    if (this.flippedCards.length >= 2) return
    if (cardEl.dataset.matched === 'true') return
    if (this.flippedCards.some(f => f.index === index)) return

    // Flip the card
    const inner = cardEl.querySelector('.game-memory-card-inner')
    inner.style.transform = 'rotateY(180deg)'

    this.flippedCards.push({ el: cardEl, index, memoryId: this.cards[index].memory_id })

    if (this.flippedCards.length === 2) {
      this.moves++
      this.movesCountTarget.textContent = this.moves

      const [card1, card2] = this.flippedCards

      if (card1.memoryId === card2.memoryId) {
        // Match found
        this.matchedPairs++
        this.pairsFoundTarget.textContent = this.matchedPairs
        card1.el.dataset.matched = 'true'
        card2.el.dataset.matched = 'true'

        // Add matched visual
        setTimeout(() => {
          card1.el.style.opacity = '0.7'
          card2.el.style.opacity = '0.7'
        }, 300)

        this.flippedCards = []

        // Check if game is won
        if (this.matchedPairs === this.totalPairsCount) {
          setTimeout(() => this.gameWon(), 600)
        }
      } else {
        // No match - flip back
        this.isLocked = true
        setTimeout(() => {
          const inner1 = card1.el.querySelector('.game-memory-card-inner')
          const inner2 = card2.el.querySelector('.game-memory-card-inner')
          inner1.style.transform = ''
          inner2.style.transform = ''
          this.flippedCards = []
          this.isLocked = false
        }, 1000)
      }
    }
  }

  startTimer() {
    this.stopTimer()
    this.timerInterval = setInterval(() => {
      this.timeElapsed++
      const minutes = Math.floor(this.timeElapsed / 60)
      const seconds = this.timeElapsed % 60
      this.timerTarget.textContent = `${minutes}:${seconds.toString().padStart(2, '0')}`
    }, 1000)
  }

  stopTimer() {
    if (this.timerInterval) {
      clearInterval(this.timerInterval)
      this.timerInterval = null
    }
  }

  async gameWon() {
    this.stopTimer()

    // Calculate score: 10000 - (time * 10) - (moves * 50), min 0
    const score = Math.max(0, 10000 - (this.timeElapsed * 10) - (this.moves * 50))

    const minutes = Math.floor(this.timeElapsed / 60)
    const seconds = this.timeElapsed % 60

    this.gameBoardTarget.classList.add('hidden')
    this.victoryTarget.classList.remove('hidden')

    this.finalScoreTarget.textContent = score
    this.finalMovesTarget.textContent = this.moves
    this.finalTimeTarget.textContent = `${minutes}:${seconds.toString().padStart(2, '0')}`

    // Save score
    try {
      await fetch('/games/memory/complete', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
        body: JSON.stringify({
          score,
          moves: this.moves,
          time_seconds: this.timeElapsed,
          difficulty: this.difficulty
        })
      })
    } catch (error) {
      console.error('Failed to save score:', error)
    }

    // Confetti!
    this.launchConfetti()
  }

  restart() {
    this.victoryTarget.classList.add('hidden')
    this.gameBoardTarget.classList.add('hidden')
    this.introTarget.classList.remove('hidden')
    this.stopTimer()
  }

  launchConfetti() {
    const colors = ['#F2C2C2', '#C1DDD8', '#C0DFD0', '#E8B0B0', '#DBEAFE', '#FEF3C7']
    for (let i = 0; i < 50; i++) {
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
