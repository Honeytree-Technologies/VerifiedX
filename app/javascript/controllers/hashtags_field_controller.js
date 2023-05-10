import {Controller} from "@hotwired/stimulus"
import TomSelect from "tom-select";


export default class extends Controller {
    static values = {placeholder: String, items: Array, url: String}

    connect() {
        document.addEventListener("turbo:load", this.setSelectValue.bind(this));
        let select = new TomSelect(this.element, {
            valueField: 'name',
            labelField: 'name',
            searchField: 'name',
            maxItems: 10,
            create: true,
            render: {
                option: function(data, escape) {
                    data.name = data.name.replaceAll('#', '')
                    return '<div>#' + escape(data.name) + '</div>';
                },
                item: function(data, escape) {
                    data.name = data.name.replaceAll('#', '')
                    return '<div>#' + escape(data.name) + '</div>';
                },
                option_create: function(data, escape) {
                    data.input = data.input.replaceAll('#', '')
                    return '<div class="create">Add <strong>#' + escape(data.input) + '</strong>&hellip;</div>';
                },},
            onItemAdd: function (value, item){
                value = value.replaceAll('#', '')
            },
            load: function (query, callback) {
                let url = `https://${this.urlValue}/api/v2/search?type=hashtags&q=${encodeURIComponent(query.replaceAll('#', ''))}`;
                fetch(url)
                    .then(response => response.json())
                    .then(json => {
                        callback(json.hashtags);
                    }).catch(() => {
                    callback();
                });
            }.bind(this),
            closeAfterSelect: true,
            placeholder: this.placeholderValue,
        });
        this.setSelectValue();
    }

    setSelectValue() {
        if (this.hasItemsValue) {
            this.itemsValue.forEach(item => {
                item = item.replaceAll('#', '')
                this.element.tomselect.createItem(item);
            })
        }
    }
}