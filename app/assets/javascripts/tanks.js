executeScriptFor('.tanks-controller .form-partial', ()=> {
    var app = new Vue({
        el: '#app',
        data: {
            tank: {
                productId: $('#tank_product_id').val() || null,
                capacity: $('#tank_capacity').val() || null
            },
            nextAlias: null,
            ordinalizedTankNum: null
        }
    });

    $('#select-product').dropdownSelect('set_selection', app.tank.productId);
    $('#select-product').on('dropdown-select:change', (e)=> {
        app.tank.productId = $(e.currentTarget).dropdownSelect('get_selection').value;
        
        app.nextAlias = null;
        $.get(`${API_PATH}/tanks/next_alias`, {product_id: app.tank.productId})
            .done((data)=> {
                app.nextAlias = data.data.next_alias;
                app.ordinalizedTankNum = data.data.ordinalized_tank_num;
            });
    });
});