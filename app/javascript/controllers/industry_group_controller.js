import { Controller } from "@hotwired/stimulus"

// Shows or hides the segment rows that belong to one top-level industry.
export default class extends Controller {
  static targets = [ "segment", "toggle" ]

  toggle() {
    const expanded = this.toggleTarget.getAttribute("aria-expanded") === "true"

    this.segmentTargets.forEach((row) => { row.hidden = expanded })
    this.toggleTarget.setAttribute("aria-expanded", String(!expanded))
    this.toggleTarget.textContent = expanded ? "\u25B8" : "\u25BE"
  }
}
