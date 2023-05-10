import {Controller} from "@hotwired/stimulus"
import {initTooltips} from "flowbite/lib/esm/components/tooltip";


export default class extends Controller {

    connect() {
        initTooltips()
    }
}