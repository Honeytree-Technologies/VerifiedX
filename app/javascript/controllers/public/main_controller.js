import {Controller} from "@hotwired/stimulus"
import * as MastodonAPI from '../../mastodon-api'
import {Dropdown} from 'flowbite';
import Rails from "@rails/ujs";
import {phone} from "phone";
import isValidDomain from "is-valid-domain";

export default class extends Controller {
    static values = {user: Object, url: String};
    static targets = ['loginStatus', 'loginButton', 'logoutButton', 'userAvatar', 'claimButton',
        'userHandle', 'userName', 'userProfile', 'addAccount', 'serverURL',
        'serverError', 'profileModalButton', 'accountType', 'profileAddress',
        'profileAvatar', 'profileHandle', 'profileName', 'profileTopic',
        'profileEmail', 'profilePhoneNumber', 'profileFirstName', 'profileKeywords', 'profileHashtags',
        'profileLastName', 'profileCountry', 'profileRegion', 'profileShowLocation',
        'profileTopic', 'profileJobTitle', 'profileOrganisation', 'profileOrganisationType',
        'profileWebsiteUrl', 'profileBlogUrl', 'otherUrl', 'profileShowEmail', 'profileShowPhone'];

    connect() {
        window.onbeforeunload = function () {
            window.scrollTo(0, 0);
        }
        MastodonAPI.getUserInfo().then(user => {
            this.userValue = user;
            this.checkUser();
        });
    }

    modalClosed() {
        this.serverErrorTarget.classList.add('hidden');
        this.serverURLTarget.classList.remove('border-red-500');
        this.serverURLTarget.value = '';
    }

    checkUser() {
        if (!MastodonAPI.isLoggedIn()) {
            this.toggleLogin();
            return;
        }
        Rails.ajax({
            url: '/accounts/check.json',
            type: 'post',
            success: (response) => {
                let user = this.userValue
                user.subscribed = response.success;
                if (response.success)
                    user.account = response.account;
                this.userValue = user;
                this.toggleLogin();
            },
        });
    }

    toggleLogin() {
        if (MastodonAPI.isLoggedIn()) {
            this.loginButtonTarget.classList.add('hidden');
            this.logoutButtonTarget.classList.remove('hidden');
            this.logoutButtonTarget.removeAttribute('disabled');
            this.userAvatarTarget.setAttribute('src', this.userValue.avatar);
            this.userHandleTarget.innerHTML = this.userValue.handle;
            this.userNameTarget.innerHTML = this.userValue.display_name;
            this.userProfileTarget.innerHTML = this.userValue.subscribed ? 'Profile' : 'Add your Account';
        } else {
            this.logoutButtonTarget.classList.add('hidden');
            this.loginButtonTarget.classList.remove('hidden', 'invisible');
            this.loginButtonTarget.removeAttribute('disabled');
            this.userAvatarTarget.setAttribute('src', '');
            this.userHandleTarget.innerHTML = '';
            this.userNameTarget.innerHTML = '';
            this.userValue = {};
        }
        for (const elt of this.claimButtonTargets) elt.removeAttribute('disabled');

    }

    logout() {
        const dropdown = new Dropdown(document.getElementById('user-dropdown'),
            document.getElementById('user-menu-button'));
        dropdown.hide();
        fetch('/logout', {method: "DELETE"});
        Turbo.visit('/');
    }

    login() {
        const instance = MastodonAPI.cleanServerName(this.serverURLTarget.value);
        if (isValidDomain(instance)) {
            this.serverErrorTarget.classList.add('hidden');
            this.serverErrorTarget.innerHTML = '';
            this.serverURLTarget.classList.remove('border-red-500');
            fetch('/login.json', {
                method: "POST", body: JSON.stringify({instance: instance}),
                headers: {"Content-Type": "application/json"},
            }).then(response => response.json())
                .then(data => {
                    if (!data.success)
                        this.invalidInstance();
                    else
                        window.location = `${data.url}?client_id=${data.client_id}&redirect_uri=${encodeURIComponent(data.redirect_uri)}&response_type=code&scope=read:accounts`;
                });
        } else
            this.invalidInstance();
    }

    invalidInstance() {
        this.serverErrorTarget.classList.remove('hidden');
        this.serverURLTarget.classList.add('border-red-500');
        if (this.serverURLTarget.value === '')
            this.serverErrorTarget.innerHTML = 'Please enter your Mastodon instance name';
        else
            this.serverErrorTarget.innerHTML = 'Please enter a valid Mastodon instance name';
    }

    editProfile() {
        if (this.userValue != null && this.userValue.handle !== undefined && this.userValue.account != null) {
            Turbo.visit('/profile');
        } else {
            Turbo.visit(`/accounts/new?handle=${this.userValue.handle}`)
        }
    }

    scroll() {
        document.getElementById('search-engine').scrollIntoView({behavior: 'smooth'});
    }

    addAccount() {
        Turbo.visit('/accounts/new');
    }

    updateClaimProfile(event) {
        this.updateProfile(event, true);
    }

    updateProfile(event, claim = false) {
        if (!this.userValue.handle) {
            return;
        }
        if (!this.profileEmailTarget.checkValidity()) {
            this.profileEmailTarget.reportValidity();
            return;
        }
        let validPhone = phone(this.profilePhoneNumberTarget.value);
        if (!validPhone.isValid && this.profilePhoneNumberTarget.value !== '') {
            this.profilePhoneNumberTarget.setCustomValidity('"' + this.profilePhoneNumberTarget.value + '" is not a valid phone number.');
            this.profilePhoneNumberTarget.reportValidity();
            return;
        } else {
            this.profilePhoneNumberTarget.value = validPhone.phoneNumber;
        }
        if (!this.profileFirstNameTarget.checkValidity()) {
            this.profileFirstNameTarget.reportValidity();
            return;
        }
        if (!this.profileLastNameTarget.checkValidity()) {
            this.profileLastNameTarget.reportValidity();
            return;
        }
        if (!this.profileCountryTarget.checkValidity()) {
            this.profileCountryTarget.reportValidity();
            return;
        }
        if (!this.profileRegionTarget.checkValidity()) {
            this.profileRegionTarget.reportValidity();
            return;
        }
        if (!this.profileTopicTarget.checkValidity()) {
            this.profileTopicTarget.reportValidity();
            return;
        }
        if (!this.profileJobTitleTarget.checkValidity()) {
            this.profileJobTitleTarget.reportValidity();
            return;
        }
        if (!this.profileOrganisationTarget.checkValidity()) {
            this.profileOrganisationTarget.reportValidity();
            return;
        }
        if (!this.profileOrganisationTypeTarget.checkValidity()) {
            this.profileOrganisationTypeTarget.reportValidity();
            return;
        }
        let formData = new FormData();
        formData.set('mastodon_handle', this.userValue.handle);
        formData.set('name', this.userValue.display_name);
        formData.set('email', this.profileEmailTarget.value);
        formData.set('phone_number', this.profilePhoneNumberTarget.value);
        formData.set('first_name', this.profileFirstNameTarget.value);
        formData.set('last_name', this.profileLastNameTarget.value);
        formData.set('region_id', this.profileRegionTarget.value);
        formData.set('job_title', this.profileJobTitleTarget.value);
        formData.set('organisation', this.profileOrganisationTarget.value);
        formData.set('organisation_type', this.profileOrganisationTypeTarget.value);
        formData.set('keywords', this.profileKeywordsTarget.value);
        formData.set('hashtags', this.profileHashtagsTarget.value);
        formData.set('website_url', this.profileWebsiteUrlTarget.value);
        formData.set('blog_url', this.profileBlogUrlTarget.value);
        formData.set('show_email', this.profileShowEmailTarget.checked);
        formData.set('show_phone', this.profileShowPhoneTarget.checked);
        formData.set('show_location', this.profileShowLocationTarget.checked);
        formData.set('account_type', this.accountTypeTarget.checked);
        if (this.hasProfileAddressTarget)
            formData.set('address', this.profileAddressTarget.value);
        for (let i = 0; i < this.otherUrlTargets.length; i++) {
            if (this.otherUrlTargets[i].value === '') continue;
            formData.append('urls[]', this.otherUrlTargets[i].value);
        }
        if (this.profileTopicTarget.value.length > 0) {
            let topics_list = this.profileTopicTarget.value.split(',');
            for (let i = 0; i < topics_list.length; i++) {
                formData.append('topic_ids[]', topics_list[i]);
            }
        }
        if (claim) {
            formData.append('status', 'claimed');
        }
        event.target.getElementsByTagName('svg')[0].classList.remove('invisible');
        Rails.ajax({
            url: this.urlValue,
            type: 'post',
            data: formData,
            success: (response) => {
                window.location.reload(true);
            },
        });
    }

    claim({params}) {
        let closeButton = document.querySelector('#public--account-close');
        if (closeButton)
            closeButton.click();
        if (!this.userValue.handle) {
            let loginButton = document.querySelector('#login-button');
            loginButton.click();
        } else {
            if (params.handle.toLowerCase() === this.userValue.handle.toLowerCase()) {
                this.editProfile();
            } else {
                let alertButton = document.querySelector('#alert-modal-button');
                alertButton.click();
                document.querySelector('#alert-modal-message').innerHTML =
                    `Please login as ${params.handle} to claim this listing.`;
                document.querySelector('#alert-modal-title').innerHTML =
                    `Claim Profile`;
            }
        }
    }

    changeType(event) {
        if (!this.userValue.handle) {
            event.target.checked = !event.target.checked;
            return;
        }
        if (event.target.checked)
            Turbo.visit(`/organizations/${this.userValue.handle}`);
        else
            Turbo.visit(`/people/${this.userValue.handle}`);
    }
}