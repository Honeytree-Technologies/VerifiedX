import {Controller} from "@hotwired/stimulus"
import {Turbo} from "@hotwired/turbo-rails";


export default class extends Controller {
    static targets = ['frame', 'wrapper', 'input', 'placeholder', 'resultItem', 'searchTopic', 'searchInput']

    connect() {
        window.addEventListener('click', this.closeHandler.bind(this));
        window.addEventListener('keydown', this.closeHandler.bind(this));
    }

    addTopic(event) {
        let id = event.params.topic
        this.inputTarget.value = this.inputTarget.value === '' ? id : `${this.inputTarget.value},${id}`;
        this.inputTarget.value = [...new Set(this.inputTarget.value.split(','))];
        this.query();
    }

    removeTopic(event) {
        let selected = this.inputTarget.value.split(',');
        let index = selected.indexOf(event.params.topic.toString());
        if (index !== -1) {
            selected.splice(index, 1);
        }
        this.inputTarget.value = selected.join(',');
        this.query();
    }

    query(event, reload = false) {
        let selected = this.inputTarget.value;
        let query = 'topic_id='
        if (reload || (event && 'topic' in event.params))
            query += `${event.params?.topic ?? ''}&reload=reload`;
        else {
            if (this.hasSearchTopicTarget)
                query += this.searchTopicTarget?.value ?? '';
            if (this.hasSearchInputTarget)
                query += `&q=${this.searchInputTarget?.value ?? ''}`;
        }
        Turbo.visit(`/topics?${query}&selected=${selected}&frame_id=${this.frameTarget.id}&format=turbo_stream`);
    }

    toggle(event) {
        if (this.frameTarget.childNodes.length === 0)
            this.query(event, true);
        else
            this.close();
    }

    clearSearch() {
        this.inputTarget.value = '';
        for (let item of this.resultItemTargets) item.remove();
        this.close();
    }

    closeHandler(event) {
        if (event.keyCode === 27 || !this.element.contains(event.target)) {
            this.close();
        }
    }

    close() {
        this.frameTarget.innerHTML = '';
    }

    disconnect() {
        window.removeEventListener('click', this.close.bind(this));
        window.removeEventListener('keydown', this.close.bind(this));
    }
}