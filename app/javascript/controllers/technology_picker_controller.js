import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input", "checkbox", "result" ]
  static values = { aliases: Object }

  apply() {
    const pastedTechnologies = this.inputTarget.value
      .split(/[;,\n]+/)
      .map((technology) => technology.trim())
      .filter(Boolean)

    const checkboxesByName = new Map(
      this.checkboxTargets.map((checkbox) => [
        this.normalize(checkbox.dataset.technologyName),
        checkbox
      ])
    )
    const checkboxesByAlias = new Map()
    Object.entries(this.aliasesValue || {}).forEach(([canonicalName, aliases]) => {
      const checkbox = checkboxesByName.get(this.normalize(canonicalName))
      if (!checkbox) return

      aliases.forEach((alias) => {
        const normalizedAlias = this.normalize(alias)
        checkboxesByAlias.set(normalizedAlias, [
          ...(checkboxesByAlias.get(normalizedAlias) || []),
          checkbox
        ])
      })
    })
    const unmatched = []
    const selected = new Set()

    pastedTechnologies.forEach((technology) => {
      const normalizedTechnology = this.normalize(technology)
      const matchingCheckboxes = [
        ...(checkboxesByName.has(normalizedTechnology) ? [checkboxesByName.get(normalizedTechnology)] : []),
        ...(checkboxesByAlias.get(normalizedTechnology) || [])
      ]

      if (matchingCheckboxes.length) {
        matchingCheckboxes.forEach((checkbox) => {
          checkbox.checked = true
          selected.add(checkbox.dataset.technologyName)
        })
      } else {
        unmatched.push(technology)
      }
    })

    const messages = []
    if (selected.size > 0) messages.push(`${selected.size} ${selected.size === 1 ? "technology" : "technologies"} selected`)
    if (unmatched.length) messages.push(`Not found: ${unmatched.join(", ")}`)

    this.resultTarget.textContent = messages.join(". ") || "Paste one or more technologies to match the catalog."
  }

  normalize(technology) {
    return technology.toLowerCase().replace(/\s+/g, " ").trim()
  }
}