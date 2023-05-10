import { Controller } from "stimulus"
import DataTable from 'datatables.net-dt'

export default class extends Controller {

    connect() {
        this.table = new DataTable('#dataTable', {
            retrieve: true,
            responsive: true,
            searching: false,
            ordering:  false,
            lengthChange: false
        });
    }
}