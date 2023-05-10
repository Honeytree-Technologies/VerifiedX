import {Controller} from "@hotwired/stimulus"
import * as MastodonAPI from '../../mastodon-api'
import Rails from '@rails/ujs'
import {phone} from 'phone';

const colorsRegExp = /blue|green|gray|red/g;
export default class extends Controller {
    static values = {url: String, account: Object, handle: String, accountType: {type: String, default: 'people'}}
    static targets = ['mastodonHandle', 'handleError', 'step0', 'step01', 'step1', 'step2', 'stepper0', 'stepper1', 'stepper2',
        'subscribeForm', 'formTitle', 'accountIndividual', 'accountOrganization',
        'accountAvatar', 'accountName', 'accountHandle', 'accountKeywords', 'accountHashtags',
        'accountEmail', 'accountPhoneNumber', 'accountFirstName', 'backdrop',
        'accountLastName', 'accountCountry', 'accountRegion', 'accountAddress',
        'accountTopic', 'accountJobTitle', 'accountOrganisation', 'accountOrganisationType',
        'accountWebsiteUrl', 'accountBlogUrl', 'topicsController', 'otherUrl']

    connect() {
        this.accountValue = {};

        // show route
        if (this.handleValue) {
            this.mastodonHandleTarget.value = this.handleValue;
            this.check();
        } else {
            this.backdropTarget.classList.add('hidden');
        }
    }

    async check() {
        let mastodonHandleRGEX = /@?\b([A-Z0-9._%+-]+)@([A-Z0-9.-]+\.[A-Z]{2,})\b/gmi;
        let handle = this.mastodonHandleTarget.value;
        if (!mastodonHandleRGEX.test(this.mastodonHandleTarget.value)) {
            this.resetForm();
            this.mastodonHandleTarget.value = handle;
            this.showError('Please Enter a valid mastodon Handle');
        } else {
            this.handleErrorTarget.classList.add('hidden');
            this.mastodonHandleTarget.classList.remove('border-red-500');
            this.mastodonHandleTarget.disabled = true;
            if (this.mastodonHandleTarget.value[0] !== '@')
                this.mastodonHandleTarget.value = `@${this.mastodonHandleTarget.value}`;
            MastodonAPI.getAccount(this.mastodonHandleTarget.value).then(async account => {
                fetch(`/accounts/show.json?handle=${account.handle}`).then(response => response.json())
                    .then((data) => {
                        if (data.success) {
                            this.showError('Handle already exists');
                        } else {
                            this.accountValue = account;
                            this.accountHashtagsTarget.setAttribute('data-hashtags-field-url-value', account.handle.split('@').slice(-1));
                            this.accountAvatarTarget.setAttribute('src', this.accountValue.avatar);
                            this.accountNameTarget.innerHTML = this.accountValue.display_name;
                            this.accountHandleTarget.innerHTML = this.accountValue.handle;
                            if (this.accountTypeValue === 'people' || this.accountTypeValue === 'organizations') {
                                this.formTitleTarget.querySelector('a').setAttribute('href', account.url);
                                this.step1();
                            } else {
                                this.formTitleTarget.innerHTML = `Add <a href="${account.url}" target="_blank">${account.handle}</a>`;
                                this.step01();
                            }
                        }
                    });
            }).catch(error => {
                this.resetForm();
                this.mastodonHandleTarget.value = handle;
                this.showError('Mastodon Handle not found');
            });
        }
    }

    resetForm() {
        this.accountTypeValue = null;
        history.replaceState({}, '', `/accounts/new`);
        this.hideError();
        this.emptyFields();
        this.step0Target.classList.remove('hidden');
        this.step01Target.classList.add('hidden');
        this.step1Target.classList.add('hidden');
        this.step2Target.classList.add('hidden');
        this.accountIndividualTarget.checked = true;
        this.accountOrganizationTarget.checked = false;
        this.formTitleTarget.innerHTML = 'Suggest New Listing';
        this.switchStepper(this.stepper0Target, 'blue');
        this.switchStepper(this.stepper1Target, 'gray');
        this.switchStepper(this.stepper2Target, 'gray');
        this.backdropTarget.classList.add('hidden');
    }

    emptyFields() {
        this.accountValue = {};
        let topicsController = this.application.getControllerForElementAndIdentifier(
            this.topicsControllerTarget, 'topics'
        );
        if (topicsController)
            topicsController.clearSearch();
        this.accountTopicTarget.value = '';
        this.accountAvatarTarget.setAttribute('src', '');
        this.accountNameTarget.innerHTML = '';
        this.accountHandleTarget.innerHTML = '';
        this.mastodonHandleTarget.value = '';
        this.accountEmailTarget.value = '';
        this.accountPhoneNumberTarget.value = '';
        this.accountFirstNameTarget.value = '';
        this.accountLastNameTarget.value = '';
        this.accountCountryTarget.value = '';
        if (!!this.accountCountryTarget.tomselect) {
            this.accountCountryTarget.tomselect.clear();
            this.accountCountryTarget.tomselect.clearOptions();
        }
        this.accountRegionTarget.value = '';
        if (!!this.accountRegionTarget.tomselect) {
            this.accountRegionTarget.tomselect.clear();
            this.accountRegionTarget.tomselect.clearOptions();
        }
        this.accountJobTitleTarget.value = '';
        this.accountOrganisationTarget.value = '';
        this.accountOrganisationTypeTarget.value = '';
        this.accountWebsiteUrlTarget.value = '';
        this.accountBlogUrlTarget.value = '';
    }

    showError(message) {
        this.handleErrorTarget.classList.remove('hidden');
        this.mastodonHandleTarget.classList.add('border-red-500');
        this.handleErrorTarget.innerHTML = message;
        this.mastodonHandleTarget.disabled = false;
    }

    hideError() {
        this.handleErrorTarget.classList.add('hidden');
        this.mastodonHandleTarget.classList.remove('border-red-500');
        this.handleErrorTarget.innerHTML = '';
        this.mastodonHandleTarget.disabled = false;
    }

    step01() {
        if (!this.accountValue.handle) {
            this.resetForm();
            return;
        }
        this.step0Target.classList.add('hidden');
        this.step1Target.classList.add('hidden');
        this.step2Target.classList.add('hidden');
        this.step01Target.classList.remove('hidden');
        this.switchStepper(this.stepper0Target, 'blue');
        this.switchStepper(this.stepper1Target, 'gray');
        this.switchStepper(this.stepper2Target, 'gray');
        this.backdropTarget.classList.add('hidden');
    }

    accountType() {
        if (this.accountOrganizationTarget.checked) {
            this.accountTypeValue = 'organizations';
        } else {
            this.accountTypeValue = 'people';
        }
        Turbo.visit(`/${this.accountTypeValue}/${this.accountValue.handle}`)
    }

    step1() {
        if (!this.accountValue.handle) {
            this.resetForm();
            return;
        }
        this.accountAvatarTarget.setAttribute('src', this.accountValue.avatar);
        this.accountNameTarget.innerHTML = this.accountValue.display_name;
        this.accountHandleTarget.innerHTML = this.accountValue.handle;
        this.step0Target.classList.add('hidden');
        this.step01Target.classList.add('hidden');
        this.step2Target.classList.add('hidden');
        this.step1Target.classList.remove('hidden');
        this.switchStepper(this.stepper0Target, 'green');
        this.switchStepper(this.stepper1Target, 'blue');
        this.switchStepper(this.stepper2Target, 'gray');
        this.backdropTarget.classList.add('hidden');

    }

    step2() {
        if (!MastodonAPI.isLoggedIn()) {
            let loginButton = document.querySelector('#login-button');
            loginButton.click();
            return;
        }
        if (!this.accountValue.handle) {
            this.resetForm();
            return;
        }
        if (this.accountTypeValue === 'people' && !this.checkFieldValidity([
            this.accountEmailTarget, this.accountPhoneNumberTarget, this.accountFirstNameTarget,
            this.accountLastNameTarget, this.accountCountryTarget, this.accountRegionTarget
        ]))
            return;

        if (this.accountTypeValue === 'organizations' && !this.checkFieldValidity([
            this.accountOrganisationTarget, this.accountOrganisationTypeTarget,
            this.accountEmailTarget, this.accountPhoneNumberTarget,
            this.accountAddressTarget, this.accountCountryTarget, this.accountRegionTarget,
            this.accountFirstNameTarget, this.accountLastNameTarget, this.accountJobTitleTarget
        ]))
            return;
        this.step0Target.classList.add('hidden');
        this.step01Target.classList.add('hidden');
        this.step1Target.classList.add('hidden');
        this.step2Target.classList.remove('hidden');
        this.switchStepper(this.stepper0Target, 'green');
        this.switchStepper(this.stepper1Target, 'green');
        this.switchStepper(this.stepper2Target, 'blue');
    }

    submit(event) {
        if (!this.accountValue.handle) {
            this.resetForm();
            return;
        }

        if (this.accountTypeValue === 'people' && !this.checkFieldValidity([
            this.accountJobTitleTarget, this.accountOrganisationTarget,
            this.accountOrganisationTypeTarget
        ]))
            return;

        let formData = new FormData();
        formData.set('mastodon_handle', this.accountValue.handle);
        formData.set('name', this.accountValue.display_name);
        formData.set('mastodon_url', this.accountValue.url);
        formData.set('email', this.accountEmailTarget.value);
        formData.set('phone_number', this.accountPhoneNumberTarget.value);
        formData.set('first_name', this.accountFirstNameTarget.value);
        formData.set('last_name', this.accountLastNameTarget.value);
        formData.set('region_id', this.accountRegionTarget.value);
        formData.set('job_title', this.accountJobTitleTarget.value);
        formData.set('organisation', this.accountOrganisationTarget.value);
        formData.set('organisation_type', this.accountOrganisationTypeTarget.value);
        formData.set('keywords', this.accountKeywordsTarget.value);
        formData.set('hashtags', this.accountHashtagsTarget.value);
        formData.set('website_url', this.accountWebsiteUrlTarget.value);
        formData.set('blog_url', this.accountBlogUrlTarget.value);
        formData.set('account_type', this.accountTypeValue === 'organizations' ? 'true' : 'false');
        if(this.hasJournalistAddressTarget)
            formData.set('address', this.accountAddressTarget.value);

        for (let i = 0; i < this.otherUrlTargets.length; i++) {
            if (this.otherUrlTargets[i].value === '') continue;
            formData.append('urls[]', this.otherUrlTargets[i].value);
        }
        if (this.accountTopicTarget.value.length > 0) {
            let topics_list = this.accountTopicTarget.value.split(',');
            for (let i = 0; i < topics_list.length; i++) {
                formData.append('topic_ids[]', topics_list[i]);
            }
        }
        event.target.getElementsByTagName('svg')[0].classList.remove('invisible');
        Rails.ajax({
            url: this.urlValue,
            type: 'post',
            data: formData,
            complete: (response) => {
                window.location.reload(true);
            },
        });
    }

    switchStepper(element, color) {
        element.className = element.className.replaceAll(colorsRegExp, color);
        let span = element.getElementsByTagName('span')[0]
        if (!span) return;
        span.className = span.className.replaceAll(colorsRegExp, color);
    }

    checkFieldValidity(fields) {
        for (const item in fields) {
            let field = fields[item];
            if (field.type === 'tel') {
                let validPhone = phone(field.value);
                if (!validPhone.isValid && field.value !== '') {
                    field.setCustomValidity('"' + field.value + '" is not a valid phone number.');
                    field.reportValidity();
                    return false;
                } else {
                    field.value = validPhone.phoneNumber;
                }
            } else {
                if (!field.checkValidity()) {
                    field.reportValidity();
                    return false;
                }
            }
        }
        return true;
    }
}