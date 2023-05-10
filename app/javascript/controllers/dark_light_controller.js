import {Controller} from "@hotwired/stimulus"


export default class extends Controller {
    static targets = ['moon', 'sun', 'tooltip']

    toggle() {
        if (this.theme() === 'light') {
            document.documentElement.classList.add('dark');
            localStorage.setItem('color-theme', 'dark');
        } else {
            document.documentElement.classList.remove('dark');
            localStorage.setItem('color-theme', 'light');
        }
    }

    theme() {
        return localStorage.getItem('color-theme') === 'dark' ||
        (!('color-theme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches) ?
            'dark' : 'light'
    }
}