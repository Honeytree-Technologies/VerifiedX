import {Controller} from "@hotwired/stimulus"
import * as MastodonAPI from '../../mastodon-api'
import {template} from "lodash"

export default class extends Controller {
    static values = {accountHandle: String, following: Boolean}
    static targets = ['accountInfo', 'note', 'accountStatuses', 'title', 'following', 'claim', 'modalButton', 'verified', 'unVerified']

    renderAccount(account, handle) {
        this.accountInfoTarget.innerHTML = '';
        this.accountStatusesTarget.innerHTML = '';
        this.accountHandleValue = handle
        account.handle = handle;
        this.titleTarget.innerHTML = account.display_name;
        let accountTemplate = template(document.getElementById('account-template').innerHTML);
        this.accountInfoTarget.innerHTML = accountTemplate(account);
        if (account.status === 'verified') {
            this.verifiedTarget.classList.remove('hidden');
            this.claimTarget.classList.add('hidden');
        } else if (account.status === 'claimed') {
            this.unVerifiedTarget.classList.remove('hidden');
            this.claimTarget.classList.add('hidden');
        }

        for (let i = 0; i < account.fields.length; i++) {
            let accountFieldsTemplate = template(document.getElementById('account-fields-template').innerHTML);
            this.accountInfoTarget.getElementsByClassName('account__header__fields')[0].insertAdjacentHTML('beforeend', accountFieldsTemplate(account.fields[i]));
        }
        this.accountStatusesTarget.innerHTML = "";
        MastodonAPI.getPosts(account).then(posts => {
            for (let i = 0; i < posts.length; i++) {
                let post = posts[i];
                if (post.reblog != null) {
                    post.reblog.reblogger = post.account
                    post = post.reblog;
                    post.reblog = true
                }
                if (!post.pinned)
                    post.pinned = false;
                post.handle = account.handle;
                let accountStatusTemplate = template(document.getElementById('account-status-template').innerHTML);
                this.accountStatusesTarget.insertAdjacentHTML('beforeend', accountStatusTemplate(post));
                for (let i = 0; i < post.media_attachments.length; i++) {
                    let img = document.createElement('img');
                    img.src = post.media_attachments[i].preview_url;
                    img.classList.add('w-full');
                    this.accountStatusesTarget.querySelectorAll("article:last-child")[0].insertAdjacentHTML('beforeend', img.outerHTML);
                }
                this.accountStatusesTarget.insertAdjacentHTML('beforeend', '<hr class="h-1 my-2 bg-gray-200 border-0 rounded dark:bg-gray-700">');
            }
            for (const elt of this.accountStatusesTarget.getElementsByClassName('invisible')) elt.classList.add('hidden');
        });
        for (const elt of this.accountInfoTarget.getElementsByClassName('invisible')) elt.classList.add('hidden');
        if (MastodonAPI.getUserHandle() === account.handle) {
            this.followingTarget.classList.add('invisible');
            this.claimTarget.innerHTML = 'Claim Verification'
        }
        this.modalButtonTarget.click();
    }
}