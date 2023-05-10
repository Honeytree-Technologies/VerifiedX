import {Controller} from "@hotwired/stimulus"
import {Turbo} from '@hotwired/turbo-rails'

export default class extends Controller {
    static values = {status: String}
    static targets = ['statusSelect','statusButtons', 'search']

    statusFilter(event) {
        this.searchTarget.value = ''
        if(event.type === 'change'){
            this.statusValue = event.target.value
        } else {
            this.statusValue = event.params.value
            this.statusSelectTarget.value = this.statusValue
        }
        Turbo.visit(`accounts?status=${this.statusValue}`)
    }

    search() {
        Turbo.visit(`accounts?search=${this.searchTarget.value}&status=${this.statusValue}`)
    }
}