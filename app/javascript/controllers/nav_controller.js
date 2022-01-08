import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="nav"
export default class extends Controller {
  static targets = ["openIcon", "closedIcon", "mobileMenu"];

  initialize() {
    this.open = false;
  }

  connect() {
  }

  toggle() {
    this.open = !this.open;
    
    if (this.open) {
      this.openIconTarget.classList.remove('hidden');
      this.openIconTarget.classList.add('block');

      this.closedIconTarget.classList.remove('block');
      this.closedIconTarget.classList.add('hidden');

      this.mobileMenuTarget.classList.remove('hidden');
    } else {
      this.openIconTarget.classList.remove('block');
      this.openIconTarget.classList.add('hidden');

      this.closedIconTarget.classList.remove('hidden');
      this.closedIconTarget.classList.add('block');
      
      this.mobileMenuTarget.classList.add('hidden');
    }
    
  }
}
