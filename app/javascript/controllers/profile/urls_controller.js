import {Controller} from "@hotwired/stimulus"


export default class extends Controller {
    static values = {controller: String, tabindex: String}

    connect() {
        if (this.element.childElementCount === 0)
            this.addUrl();
    }

    addUrl() {
        if (this.element.childElementCount < 5) {
            let tabindex = this.hasTabIndexValue ? `tabindex="${this.tabindexValue}"` : ''
            this.element.insertAdjacentHTML('beforeend', `
                  <div class="group flex items-center w-full">
            <input type="text" placeholder="Add Other URL" ${tabindex} data-${this.controllerValue}-target="otherUrl"
                   class="w-2/3 bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500
                    focus:border-blue-500 block w-full p-2.5 dark:bg-gray-600 dark:border-gray-500
                     dark:placeholder-gray-400 dark:text-white" name="account[urls][]">
            <button data-action="profile--urls#removeUrl" type="button" class="text-blue-700 border border-blue-700 hover:bg-blue-700 hover:text-white
             focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-full text-sm p-1 text-center
              inline-flex items-center dark:border-blue-500 dark:text-blue-500 dark:hover:text-white
               dark:focus:ring-blue-800 mx-2">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-4 h-4">
                <path stroke-linecap="round" stroke-linejoin="round" d="M18 12H6" />
              </svg>
              <span class="sr-only">Icon description</span>
            </button>
            <button data-action="profile--urls#addUrl" type="button" class="group-[:last-child]:visible group-[:nth-of-type(4)]:visible group-[:nth-of-type(5)]:invisible invisible text-blue-700 border border-blue-700 hover:bg-blue-700 hover:text-white
             focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-full text-sm p-1 text-center
              inline-flex items-center dark:border-blue-500 dark:text-blue-500 dark:hover:text-white
               dark:focus:ring-blue-800 mx-2">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-4 h-4">
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 6v12m6-6H6" />
              </svg>
              <span class="sr-only">Icon description</span>
            </button>
          </div>
        `);
        }
    }

    removeUrl(event) {
        let group = event.target.closest('.group');
        if (!(!group.nextElementSibling && !group.previousElementSibling))
            group.remove();
        else
            group.getElementsByTagName('input')[0].value = '';
    }
}