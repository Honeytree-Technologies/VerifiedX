import {Controller} from "@hotwired/stimulus"


export default class extends Controller {
    static values = { stamp: String }
    static targets = ['search', 'topic']

    connect() {
    }

    search() {
        history.replaceState({},'',
            `/?search=${this.searchTarget.value.replaceAll('#', '')}&topic=${this.topicTarget.value}&stamp=${this.stampValue}`);
    }

    pagy(event) {
        document.getElementById('search-engine').scrollIntoView({ behavior: 'smooth'});
        history.replaceState({},'', event.target.getAttribute("href"));
    }
}