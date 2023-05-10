import {Controller} from "@hotwired/stimulus"


export default class extends Controller {
    static targets = ['profileCountry', 'profileRegion']

    connect() {
    }
    updateRegion(event) {
        if(this.hasProfileRegionTarget) {
            this.profileRegionTarget.setAttribute('data-tom-select-params-value', `&country=${event.target.value}`);
            this.profileRegionTarget.removeAttribute('disabled');
            let regionTomSelect = this.profileRegionTarget.tomselect;
            if(!!regionTomSelect) {
                this.profileRegionTarget.tomselect.clear();
                this.profileRegionTarget.tomselect.clearOptions();
                this.profileRegionTarget.tomselect.enable();
                this.profileRegionTarget.value = '';
            }
        }
    }
}