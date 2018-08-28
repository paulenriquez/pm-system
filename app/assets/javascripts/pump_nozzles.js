executeScriptFor('.pump_nozzles-controller .form-partial', ()=> {
    var app = new Vue({
        el: '#app',
        data: {
            pumpNozzle: {
                pumpIslandNum: $('#pump_nozzle_pump_island_num').val() || null,
                loadingPointNum: $('#pump_nozzle_loading_point_num').val() || null,
                nozzleNum: $('#pump_nozzle_nozzle_num').val() || null,
                productId: $('#pump_nozzle_product_id').val() || null
            }
        }
    });

    $('#select-product').dropdownSelect('set_selection', app.pumpNozzle.productId);
    $('#select-product').on('dropdown-select:change', (e)=> {
        app.pumpNozzle.productId = $(e.currentTarget).dropdownSelect('get_selection').value;
    });
});