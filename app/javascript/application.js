// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "trix";
import "@rails/actiontext";
import "controllers";

// Register service worker for PWA support
if ("serviceWorker" in navigator) {
  navigator.serviceWorker.register("/service-worker.js");
}

// Make table rows clickable - works with Turbo navigation
function initializeClickableRows() {
  const clickableRows = document.querySelectorAll(".clickable-row");

  clickableRows.forEach((row) => {
    // Check if already initialized to avoid duplicate listeners
    if (!row.hasAttribute("data-clickable-initialized")) {
      row.addEventListener("click", function (event) {
        if (event.target.closest("a, button, input, select, textarea, label")) {
          return;
        }

        const href = this.dataset.href;
        if (href) {
          window.location.href = href;
        }
      });

      // Add cursor pointer to indicate clickability
      row.style.cursor = "pointer";
      row.setAttribute("data-clickable-initialized", "true");
    }
  });
}

function initializeStarStoryTemporaryOrdering() {
  const sortButton = document.getElementById("star-story-order-sort");
  const tableBody = document.querySelector("#star_stories tbody");

  if (!sortButton || !tableBody || sortButton.dataset.initialized === "true") {
    return;
  }

  let sortDirection = "asc";

  const readOrderValue = (row) => {
    const input = row.querySelector(".star-story-order-input");
    if (!input) return null;

    const parsed = Number.parseInt(input.value, 10);
    return Number.isNaN(parsed) ? null : parsed;
  };

  const applySort = () => {
    const rows = Array.from(tableBody.querySelectorAll("tr"));

    rows.sort((leftRow, rightRow) => {
      const left = readOrderValue(leftRow);
      const right = readOrderValue(rightRow);

      if (left === null && right === null) return 0;
      if (left === null) return 1;
      if (right === null) return -1;

      return sortDirection === "asc" ? left - right : right - left;
    });

    rows.forEach((row) => tableBody.appendChild(row));
  };

  sortButton.addEventListener("click", () => {
    applySort();
    sortDirection = sortDirection === "asc" ? "desc" : "asc";
    sortButton.textContent = sortDirection === "asc" ? "Order ▲" : "Order ▼";
  });

  sortButton.dataset.initialized = "true";
}

// Initialize on page load
document.addEventListener("DOMContentLoaded", () => {
  initializeClickableRows();
  initializeStarStoryTemporaryOrdering();
});

// Initialize after Turbo navigates to a new page
document.addEventListener("turbo:load", () => {
  initializeClickableRows();
  initializeStarStoryTemporaryOrdering();
});
