executeScriptFor('.price_updates-controller.index-view', ()=> {
    $('.price-update-item, .price-update-item .collapse-content').on('show.bs.collapse', (e)=> {
        $(e.currentTarget)
            .find('.toggle-icon')
            .removeClass('mdi-chevron-down')
            .addClass('mdi-chevron-up');
    });

    $('.price-update-item, .price-update-item .collapse-content').on('hide.bs.collapse', (e)=> {
        $(e.currentTarget)
            .find('.toggle-icon')
            .removeClass('mdi-chevron-up')
            .addClass('mdi-chevron-down');
    });

    $('.price-update-item:first')
        .find('.collapse-content')
        .collapse('show');
    
    $('.price-update-item:first')
        .find('.toggle-icon')
        .removeClass('mdi-chevron-down')
        .addClass('mdi-chevron-up'); 
});

executeScriptFor('.price_updates-controller .form-partial', ()=> {
    var app = new Vue({
        el: '#app',
        data: {
            priceUpdate: {
                remarks: $('#price_update_remarks').val() || null
            }
        }
    });

    var productPriceUpdatesNFRS = new NestedFieldsRenderService({
        parentElem: $('#table-productPriceUpdates tbody'),
        itemSelector: '.product-price-update-item',
        fields: {
            '.product-id-field': {
                selector: '.product-name-col',
                renderFn: (target, value)=> {
                    $(target).text($('#select-product')
                        .dropdownSelect('get_item_by_value', value).text);
                }
            },
            '.effective-on-field': { 
                selector: '.effective-on-col',
                renderFn: (target, value)=> {
                    $(target).text(moment(value).format('MMM DD, YYYY (ddd)'));
                }
            },
            '.new-price-field': { selector: '.new-price-col' }
        },
        renderEvents: {
            afterItem(item) {
                $('#select-product').dropdownSelect('disable_item_by_value', 
                    item.find('.product-id-field').val());

                $('#select-product').dropdownSelect('reset_selection');
                $('#input-effectiveOn').val('');
                $('#input-newPrice').val('');
            }
        }
    })


    function validateNestedFieldsForm(data) {

    }

    $('#select-product').on('dropdown-select:change', (e)=> {
        $('#input-effectiveOn').select();
    });

    $('#table-productPriceUpdates')
        .on('cocoon:after-insert', (e, insertedItem)=> {
            productPriceUpdatesNFRS.add(insertedItem, {
                '.product-id-field': $('#select-product').dropdownSelect('get_selection').value,
                '.effective-on-field': $('#input-effectiveOn').val(),
                '.new-price-field': $('#input-newPrice').val()
            })
        })
        .on('cocoon:after-remove', (e, removedItem)=> {
            $('#select-product').dropdownSelect('enable_item_by_value',
                removedItem.find('.product-id-field').val());
        });
});