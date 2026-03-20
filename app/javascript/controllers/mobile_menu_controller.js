import { Controller } from "@hotwired/stimulus"

// Mobile menu controller for responsive navigation
export default class extends Controller {
  static targets = ["menu", "iconOpen", "iconClose"]

  connect() {
    // Ensure menu is closed on initial load
    this.close()
  }

  disconnect() {
  }

  toggle() {
    const menu = this.menuTarget
    const isOpen = menu.style.maxHeight !== "0px" && menu.style.maxHeight !== ""

    if (isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.menuTarget.style.maxHeight = this.menuTarget.scrollHeight + "px"
    this.iconOpenTarget.classList.add("hidden")
    this.iconCloseTarget.classList.remove("hidden")
  }

  close() {
    this.menuTarget.style.maxHeight = "0px"
    this.iconOpenTarget.classList.remove("hidden")
    this.iconCloseTarget.classList.add("hidden")
  }

}
