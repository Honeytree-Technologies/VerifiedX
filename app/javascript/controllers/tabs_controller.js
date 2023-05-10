import { Controller } from "stimulus"

export default class extends Controller {
    static values = { hash: Boolean }
    static targets = [ "tab", "content" ]

    connect() {
        // Show the first tab by default
        let index = 0;
        let hash = window.location.hash
        if (hash && this.hashValue) {
            hash = hash.substring(1);
            index = this.tabTargets.findIndex(element => element.textContent.trim().toLowerCase() === hash);
        }
        this.showTab(index  || 0);
    }

    showTab(index) {
        // Hide all tabs and content elements
        this.tabTargets.forEach(tab => {
            tab.classList.remove("active", "bg-white", "text-blue-600", "border-blue-600", "dark:text-blue-500", "dark:border-blue-500", "dark:bg-gray-800");
            tab.classList.add("border-transparent", "hover:text-gray-600", "hover:border-gray-300", "dark:hover:text-gray-300");
            tab.getElementsByTagName('svg')[0].classList.remove("text-blue-600", "dark:text-blue-500");
            tab.getElementsByTagName('svg')[0].classList.add("text-gray-400", "group-hover:text-gray-500", "dark:text-gray-500", "dark:group-hover:text-gray-300");
        })
        this.contentTargets.forEach(content => content.classList.add("hidden"));

        // Show the selected tab and corresponding content element
        let tab = this.tabTargets[index]
        if (this.hashValue) {
            window.location.hash = tab.textContent.trim().toLowerCase();
        }
        tab.classList.remove("border-transparent", "hover:text-gray-600", "hover:border-gray-300", "dark:hover:text-gray-300");
        tab.classList.add("active","bg-white", "text-blue-600", "border-blue-600", "dark:text-blue-500", "dark:border-blue-500", "dark:bg-gray-800");
        tab.getElementsByTagName('svg')[0].classList.remove("text-gray-400", "group-hover:text-gray-500", "dark:text-gray-500", "dark:group-hover:text-gray-300");
        tab.getElementsByTagName('svg')[0].classList.add("text-blue-600", "dark:text-blue-500");
        this.contentTargets[index].classList.remove("hidden");
    }

    changeTab(event) {
        event.preventDefault();
        const index = this.tabTargets.indexOf(event.currentTarget);
        this.showTab(index);
    }
}