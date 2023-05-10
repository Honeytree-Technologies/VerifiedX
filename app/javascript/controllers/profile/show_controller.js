import {Controller} from "@hotwired/stimulus"
import * as MastodonAPI from '../../mastodon-api'
import {template} from "lodash"
import {Turbo} from "@hotwired/turbo-rails";
import {get, post, put, patch, destroy} from '@rails/request.js'


export default class extends Controller {
    static values = {handle: String, account: Object}
    static targets = ['accountInfo', 'note', 'accountStatuses', 'title', 'modalButton', 'description', 'avatar', 'followers', 'mastodonUrl', 'accountTemplate', 'accountFieldTemplate']

    connect() {
        if (this.hasHandleValue) {
            MastodonAPI.getAccount(this.handleValue).then(json => {
                this.accountValue = json;
                this.accountValue.handle = this.handleValue;
                if (json.note !== '') {
                    this.descriptionTarget.innerHTML = json.note;
                    this.descriptionTarget.parentElement.classList.remove('hidden');
                }
                this.avatarTarget.src = json.avatar;
                this.avatarTarget.classList.add('animate__animated', 'animate__bounceIn');
                this.mastodonUrlTarget.href = json.url;
                if (this.hasAccountStatusesTarget) {
                    MastodonAPI.getPosts(this.accountValue).then(posts => {
                        post("/accounts/show_statuses", {
                            body: {
                                posts: JSON.stringify(posts)
                            }, contentType: "application/json", responseKind: "turbo-stream"
                        })
                    });
                }
            }).catch(error => console.log(error));
        }
    }
}