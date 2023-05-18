import { Controller } from "stimulus"
import ApexCharts from 'apexcharts'

export default class extends Controller {
    static values = {
        options: Object
    }

    connect() {
        if(!this.hasOptionsValue)
            return;
        this.chart = new ApexCharts(this.element, this.optionsValue);
        this.chart.render();
    }
}