import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "menuButton", "accountMenu", "accountButton"]

  // Hamburger menu (mobile)
  toggle() {
    const isHidden = this.menuTarget.classList.toggle("hidden")
    this.menuButtonTarget.setAttribute("aria-expanded", (!isHidden).toString())
  }

  close() {
    this.menuTarget.classList.add("hidden")
    this.menuButtonTarget.setAttribute("aria-expanded", "false")
  }

  // Account dropdown (desktop)
  toggleAccount() {
    const isHidden = this.accountMenuTarget.classList.toggle("hidden")
    this.accountButtonTarget.setAttribute("aria-expanded", (!isHidden).toString())
  }

  closeAccount() {
    if (!this.hasAccountMenuTarget) return

    this.accountMenuTarget.classList.add("hidden")
    this.accountButtonTarget.setAttribute("aria-expanded", "false")
  }

  closeAll() {
    this.close()
    this.closeAccount()
  }

  // Click outside the account dropdown closes it (mobile menu already closes via nav#close on each link)
  closeOnOutsideClick(event) {
    if (!this.hasAccountMenuTarget) return
    if (this.accountMenuTarget.classList.contains("hidden")) return
    if (this.element.contains(event.target)) return

    this.closeAccount()
  }
}
