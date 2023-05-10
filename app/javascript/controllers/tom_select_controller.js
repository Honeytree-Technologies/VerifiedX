import {Controller} from "@hotwired/stimulus"
import TomSelect from "tom-select";


export default class extends Controller {
    static values = {url: String, placeholder: String, params: String, items: Object}

    connect() {
        document.addEventListener("turbo:load", this.setSelectValue.bind(this));
        this.select = new TomSelect(this.element, {
            valueField: 'id',
            labelField: 'name',
            searchField: 'name',
            maxOptions: 20,
            load: function (query, callback) {
                let url = `${this.urlValue}?q=${encodeURIComponent(query)}${this.paramsValue}`;
                fetch(url)
                    .then(response => response.json())
                    .then(json => {
                        callback(json);
                    }).catch(() => {
                    callback();
                });
            }.bind(this),
            openOnFocus: true, maxItems: 1,
            closeAfterSelect: true, placeholder: this.placeholderValue,
        });
        this.setSelectValue();
    }

    setSelectValue() {
        if (this.hasItemsValue) {
            this.select.addOption(this.itemsValue);
            this.select.addItem(this.itemsValue.id);
        }
    }
}