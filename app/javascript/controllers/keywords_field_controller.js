import {Controller} from "@hotwired/stimulus"
import TomSelect from "tom-select";


export default class extends Controller {
    static values = {placeholder: String, items: Array}

    connect() {
        document.addEventListener("turbo:load", this.setSelectValue.bind(this));
        let select = new TomSelect(this.element, {
            render: {
                no_results: null,
                loading: null
            },
            maxItems: 10,
            create: true,
            closeAfterSelect: true,
            placeholder: this.placeholderValue,
        });
        this.setSelectValue();
    }

    setSelectValue() {
        if (this.hasItemsValue) {
            this.itemsValue.forEach(item => {
                this.element.tomselect.createItem(item);
            })
        }
    }
}