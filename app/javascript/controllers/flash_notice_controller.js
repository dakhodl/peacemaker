import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flash-notice"
// Simply removes a flash notice 5s after being shown.
export default class extends Controller {
  static targets = ["notice"];

  connect(e) {
    const target = this.noticeTarget;

    setTimeout(() => {
      target.remove();
    }, 5000)
  }
}
