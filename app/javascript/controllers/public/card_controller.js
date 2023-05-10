import {Controller} from "@hotwired/stimulus"
import * as MastodonAPI from '../../mastodon-api'

export default class extends Controller {
    static values = {
        id: String,
        handle: String,
        account: Object,
        status: String
    }
    static targets = ["avatar", 'followers', 'description', 'viewProfile']

    connect() {
        MastodonAPI.getAccount(this.handleValue).then(json => {
            json.status = this.statusValue;
            this.accountValue = json;
            this.descriptionTarget.innerHTML = json.note;
            this.avatarTarget.style.backgroundImage = `url('${json.avatar}')`;
            this.avatarTarget.classList.add('animate__animated', 'animate__bounceIn');
            this.viewProfileTarget.removeAttribute('disabled');
        }).catch(error => console.log(error.message));
    }

    viewProfile() {
        if(this.viewProfileTarget.hasAttribute('disabled'))
            return;
        const accountController = this.application.getControllerForElementAndIdentifier(
            document.getElementById('public--account'), 'public--account'
        );
        accountController.renderAccount(this.accountValue, this.handleValue);
    }

    showProfile() {
        if(this.viewProfileTarget.hasAttribute('disabled'))
            return;
        Turbo.visit(`/accounts/${this.handleValue}`)
    }
}