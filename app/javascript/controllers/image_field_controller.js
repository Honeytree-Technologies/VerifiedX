import {Controller} from "@hotwired/stimulus"
import TomSelect from "tom-select";


export default class extends Controller {
    static values = {label: String, name: String, filename: String, url: String}
    static targets = ['input', 'label', 'removeInput']

    connect() {
        this.element.insertAdjacentHTML('beforeend', `
            <div class="w-full p-4 text-gray-900 bg-white rounded-lg shadow dark:bg-gray-800 dark:text-gray-300">
                <input id="${this.nameValue}" type="file" name="${this.nameValue}" class="hidden"
                 data-action="change->image-field#change" data-image-field-target="input">
                 <input name="${this.nameValue}_remove" data-image-field-target="removeInput" type="hidden">
                <div class="flex items-center mb-3">
                    <span class="mb-1 text-sm font-semibold text-gray-900 dark:text-white">${this.labelValue}</span>
                    <button type="button" class="ml-auto -mx-1.5 -my-1.5 bg-white text-gray-400 hover:text-gray-900
                     rounded-lg focus:ring-2 focus:ring-gray-300 p-1.5 hover:bg-gray-100 inline-flex h-8 w-8
                     dark:text-gray-500 dark:hover:text-white dark:bg-gray-800 dark:hover:bg-gray-700"
                     data-action="image-field#remove">
                        <span class="sr-only">Close</span>
                        <svg aria-hidden="true" class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"></path></svg>
                    </button>
                </div>
                <label class="cursor-pointer flex flex-col items-center" for="${this.nameValue}" data-image-field-target="label">
                </label>
            </div>`);
        this.labelTarget.innerHTML = this.hasFilenameValue && this.filenameValue ?
            `<img src="${this.urlValue}" alt="${this.filenameValue}" class="max-h-40"><small>Click to change</small>` :
            `<small>Click to add file</small>`
    }

    change() {
        if (this.inputTarget.files && this.inputTarget.files[0]) {
            let reader = new FileReader();
            let label = this.labelTarget;
            this.filenameValue = this.inputTarget.value.replace(/.*[\/\\]/, '');
            let alt = this.filenameValue;
            this.removeInputTarget.value = null;
            reader.onload = function () {
                label.innerHTML = `<img src="${reader.result}" alt="${alt}" class="max-h-40"><small>Click to change</small>`;
            }
            reader.readAsDataURL(this.inputTarget.files[0]);
        }
    }

    remove() {
        this.inputTarget.value = null;
        this.removeInputTarget.value = true;
        this.labelTarget.innerHTML = `<small>Click to add file</small>`;
        this.filenameValue = '';
    }


}