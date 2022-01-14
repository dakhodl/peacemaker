import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="detail-sidebar"
export default class extends Controller {
  static classes = ["selected"];

  connect() {
    // TODO support back button
    console.log('connected');
    this.selectedItem = document.getElementsByClassName('DetailSidebar__item--selected')[0];
  }
  choose (e) {
    if (this.selectedItem) {
      this.selectedItem.classList.remove(...this.selectedClasses);
    }
    e.currentTarget.classList.add(...this.selectedClasses)
    this.selectedItem = e.currentTarget;
  }

  delete(e) {
    const { currentTarget, params: { recordId, endpoint } } = e;
    e.stopPropagation();
    e.preventDefault();
    
    if (window.confirm("Are you sure want to delete this?")) {
      fetch(`/${endpoint}/${recordId}`, {
        method: 'DELETE',
        headers: {
          "X-CSRF-Token": document.head.querySelector(`meta[name="csrf-token"]`).getAttribute("content")
        },
      }).then(() => Turbo.visit(`/${endpoint}`));

      
      currentTarget.parentElement.parentElement.remove();
    }
  }
}
