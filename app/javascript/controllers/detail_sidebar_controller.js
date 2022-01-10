import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="detail-sidebar"
export default class extends Controller {
  static classes = ["selected"];

  connect() {
    // TODO support back button

    this.selectedItem = document.getElementsByClassName('DetailSidebar__item--selected')[0];
  }
  choose (e) {
    if (this.selectedItem) {
      this.selectedItem.classList.remove(...this.selectedClasses);
    }
    e.currentTarget.classList.add(...this.selectedClasses)
    this.selectedItem = e.currentTarget;
  }
}
