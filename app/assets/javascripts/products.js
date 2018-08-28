executeScriptFor('.products-controller .form-partial', ()=> {
    var app = new Vue({
        el: '#app',
        data: {
            product: {
                type: $('#product_type').val() || null,
                name: $('#product_name').val() || null,
                description: $('#product_description').val() || null,
                symbols: $('#product_symbols').val() || null,
                classification: $('#product_classification').val() || null
            }
        },
        methods: {
            changeType(newType) {
                this.product.type = newType;
                for (let key of Object.keys(this.product)) {
                    if (key != 'type') {
                        this.product[key] = null;
                    }
                }
            }
        }
    });

});