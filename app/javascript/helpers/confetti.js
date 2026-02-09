// Shared confetti animation helper
// Usage: import { triggerConfetti } from "helpers/confetti"
export function triggerConfetti(options = {}) {
  const count = options.count || 50
  const colors = options.colors || ['#C1DDD8', '#F2C2C2', '#C0DFD0', '#E8B0B0', '#A8CEC8', '#F8D8D8']
  const container = options.container || document.body
  const duration = options.duration || 3000

  for (let i = 0; i < count; i++) {
    const particle = document.createElement('div')
    const size = 6 + Math.random() * 6
    const color = colors[Math.floor(Math.random() * colors.length)]
    const isCircle = Math.random() > 0.5

    particle.style.cssText = `
      position: fixed;
      width: ${size}px;
      height: ${isCircle ? size : size * 0.6}px;
      background: ${color};
      border-radius: ${isCircle ? '50%' : '2px'};
      top: -10px;
      left: ${Math.random() * 100}vw;
      z-index: 99999;
      pointer-events: none;
      opacity: 1;
    `

    container.appendChild(particle)

    // Animate falling
    const fallDuration = 2000 + Math.random() * 2000
    const delay = Math.random() * 500
    const horizontalDrift = (Math.random() - 0.5) * 200

    particle.animate([
      { transform: 'translateY(0) rotate(0deg)', opacity: 1 },
      { transform: `translateY(100vh) translateX(${horizontalDrift}px) rotate(${360 + Math.random() * 720}deg)`, opacity: 0 }
    ], {
      duration: fallDuration,
      delay: delay,
      easing: 'cubic-bezier(0.25, 0.46, 0.45, 0.94)',
      fill: 'forwards'
    })

    setTimeout(() => particle.remove(), fallDuration + delay + 100)
  }
}
