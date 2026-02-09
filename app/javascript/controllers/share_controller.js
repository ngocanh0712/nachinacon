import { Controller } from "@hotwired/stimulus"

// Share controller for copy link + Web Share API
export default class extends Controller {
  static targets = ["nativeBtn", "copyBtn", "copyIcon", "checkIcon", "tooltip"]
  static values = { url: String, title: String }

  connect() {
    // Show native share button on mobile if Web Share API available
    if (navigator.share && this.hasNativeBtnTarget) {
      this.nativeBtnTarget.classList.remove("hidden")
    }
  }

  async nativeShare() {
    try {
      await navigator.share({
        title: this.titleValue,
        url: this.urlValue
      })
    } catch (err) {
      // User cancelled or error - silently ignore
    }
  }

  async copyLink() {
    try {
      await navigator.clipboard.writeText(this.urlValue)
      // Show check icon + tooltip
      this.copyIconTarget.classList.add("hidden")
      this.checkIconTarget.classList.remove("hidden")
      this.tooltipTarget.classList.remove("opacity-0")
      this.tooltipTarget.classList.add("opacity-100")

      // Reset after 2 seconds
      setTimeout(() => {
        this.copyIconTarget.classList.remove("hidden")
        this.checkIconTarget.classList.add("hidden")
        this.tooltipTarget.classList.remove("opacity-100")
        this.tooltipTarget.classList.add("opacity-0")
      }, 2000)
    } catch (err) {
      // Fallback for older browsers
      const textArea = document.createElement("textarea")
      textArea.value = this.urlValue
      textArea.style.position = "fixed"
      textArea.style.opacity = "0"
      document.body.appendChild(textArea)
      textArea.select()
      document.execCommand("copy")
      document.body.removeChild(textArea)
    }
  }
}
