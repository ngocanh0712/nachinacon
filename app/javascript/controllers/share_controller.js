import { Controller } from "@hotwired/stimulus"

// Share controller for copy link + Web Share API + social sharing
export default class extends Controller {
  static targets = ["nativeBtn", "copyBtn", "copyIcon", "checkIcon", "tooltip"]
  static values = { url: String, title: String }

  connect() {
    // Show native share button on mobile if Web Share API available
    if (navigator.share && this.hasNativeBtnTarget) {
      this.nativeBtnTarget.style.display = "flex"
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

  shareFacebook(event) {
    event.preventDefault()
    const url = `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(this.urlValue)}`
    this._openShareUrl(url)
  }

  shareZalo(event) {
    event.preventDefault()
    const url = `https://zalo.me/share?url=${encodeURIComponent(this.urlValue)}`
    this._openShareUrl(url)
  }

  shareWhatsApp(event) {
    event.preventDefault()
    const text = `${this.titleValue} ${this.urlValue}`
    const url = `https://api.whatsapp.com/send?text=${encodeURIComponent(text)}`
    this._openShareUrl(url)
  }

  shareMessenger(event) {
    event.preventDefault()
    const url = `fb-messenger://share/?link=${encodeURIComponent(this.urlValue)}`
    // Try Messenger deep link first, fallback to web
    window.location.href = url
    setTimeout(() => {
      window.open(`https://www.facebook.com/dialog/send?link=${encodeURIComponent(this.urlValue)}&app_id=&redirect_uri=${encodeURIComponent(window.location.href)}`, '_blank')
    }, 500)
  }

  _openShareUrl(url) {
    // On mobile, use location.href for better app deep linking
    const isMobile = /iPhone|iPad|iPod|Android/i.test(navigator.userAgent)
    if (isMobile) {
      window.location.href = url
    } else {
      window.open(url, '_blank', 'width=600,height=400,scrollbars=yes')
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
