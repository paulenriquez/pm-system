executeScriptFor('.shift_inventory_updates-controller.index-view', ()=> {
    
});

executeScriptFor('.shift_inventory_updates-controller.edit-view', ()=> {
    new Vue({
        el: '#app',
        data: {
            shiftInventoryUpdate: {
                remarks: $('#shift_inventory_update_remarks').val() || null
            }
        }
    });
});

executeScriptFor('.shift_inventory_updates-controller .form-partial .deliveries-form', ()=> {
    var deliveryItemCounter = 0;
    var deliveriesNFRS = new NestedFieldsRenderService({
        parentElem: $('.delivery-form-panels'),
        itemSelector: '.delivery-item',
        fields: {
            '.sales-order-num-field': {
                selector: '#input-salesOrderNum',
                renderFn: 'val',
                events: { 'input': (e, field)=> { field.val($(e.currentTarget).val()) } }
            },
            '.received-by-field': {
                selector: '#input-receivedBy',
                renderFn: 'val',
                events: { 'input': (e, field)=> { field.val($(e.currentTarget).val()) } }
            },
            '.invoice-num-field': {
                selector: '#input-invoiceNum',
                renderFn: 'val',
                events: { 'input': (e, field)=> { field.val($(e.currentTarget).val()) } }
            },
            '.time-received-field': {
                selector: '#input-timeReceived',
                renderFn: (target, value)=> {
                    if (value) {
                        target.val( value.split(' ')[1].split(':').splice(0,2).join(':') )
                    }
                },
                events: { 'input': (e, field)=> { field.val($(e.currentTarget).val()) } }
            },
            '.amount-field': {
                selector: '#input-amount',
                renderFn: (target, value)=> { target.val( formatNum(value) ) },
                events: { 'input': (e, field)=> { field.val($(e.currentTarget).numericVal()) } }
            },
            '.remarks-field': {
                selector: '#input-remarks',
                renderFn: 'val',
                events: { 'input': (e, field)=> { field.val($(e.currentTarget).val()) } }
            }
        },
        renderEvents: {
            afterItem: afterDeliveryItemRender
        }
    });

    function afterDeliveryItemRender(item) {
        deliveryItemCounter++;
        var listItemHtml = `
            <a class="list-group-item list-group-item-action"
                data-toggle="list"
                href="#delivery-item-${deliveryItemCounter}">
            </a>
        `;

        item.attr('id', `delivery-item-${deliveryItemCounter}`);
        $('.deliveries-form .delivery-list-items').append(listItemHtml);

        var listItem = $(`.deliveries-form .delivery-list-items .list-group-item[href="#delivery-item-${deliveryItemCounter}"]`);
        
        listItem
            .hide()
            .fadeIn(150);

        $('.deliveries-form .delivery-item').removeClass('active show');
        listItem.tab('show');
    
        function setRefTextHtml(html) {
            listItem.html(html);
            item.find('.delivery-item-header-text').html(html);
        }

        function getReadableDeliveryType(rawType) {
            if (rawType === 'Fuel')
                return 'Fuel';
            else if (rawType === 'NonFuel')
                return 'Non-Fuel';
        }
        
        function renderTypeSpecificElems(type) {       
            item.find('.delivery-type-text')
                .text( getReadableDeliveryType(type) );

            if (type === 'Fuel') {
                item.find('#select-product').hide();
                item.find('#select-tank')
                    .show()
                    .dropdownSelect();

                item.find('.item-to-select').text('Tank');
                item.find('.product-description').text('Fuel & Tank');
                item.find('.unit-description').text('Volume');
                item.find('.unit-measurement').text('L');

            } else if (type === 'NonFuel') {
                item.find('#select-tank').hide();
                item.find('#select-product')
                    .show()
                    .dropdownSelect();
                
                item.find('.item-to-select').text('Non-Fuel Product');
                item.find('.product-description').text('Non-Fuel Product')
                item.find('.unit-description').text('Units');
                item.find('.unit-measurement').text('units');
            }
        }

        if (item.find('.delivery-type-field').val()) {
            var deliveryType = getReadableDeliveryType(item.find('.delivery-type-field').val());

            setRefTextHtml(`SO# ${item.find('.sales-order-num-field').val()} — ${deliveryType}`);
            item.find('.delivery-type-selector').hide();
            item.find('.delivery-item-fields-container').show();

            renderTypeSpecificElems(item.find('.delivery-type-field').val());
        } else {
            setRefTextHtml(`<em>Unsaved Delivery</em>`);

            item.find('.select-delivery-type').click((e)=> {
                renderTypeSpecificElems($(e.currentTarget).attr('data-value'));
                
                var deliveryType = getReadableDeliveryType($(e.currentTarget).attr('data-value'));
                item.find('.delivery-type-field')
                    .val($(e.currentTarget).attr('data-value'));
                
                item.find('.delivery-type-selector')
                    .fadeOut(150)
                    .hide()
                    .parent()
                    .find('.delivery-item-fields-container')
                    .fadeIn(150);
    
                setRefTextHtml(`<em>Unsaved ${deliveryType} Delivery</em>`);

                item.find('#input-salesOrderNum').focus();
            });
        }

        item.find('#input-salesOrderNum').on('input', (e)=> {
            var salesOrderNum = $(e.currentTarget).val(),
                deliveryType = getReadableDeliveryType(item.find('.delivery-type-field').val());

            if (salesOrderNum) {
                setRefTextHtml(`SO# ${$(e.currentTarget).val()} — ${deliveryType}`);
            } else {
                setRefTextHtml(`<em>Unsaved ${deliveryType} Delivery</em>`);
            }
        });

        cleaveNum(item.find('#input-amount'));

        cleaveNum(item.find('#input-qtyDelivered'));

        item.find('.add-product-delivery-fields')
            .data('association-insertion-method', 'append')
            .data('association-insertion-node', (link)=> {
                return item.find('#table-productDeliveries tbody')
            });

        var productDeliveryNFRS = new NestedFieldsRenderService({
            parentElem: item.find('#table-productDeliveries'),
            itemSelector: '.product-delivery-item',
            fields: {
                '.product-id-field': {
                    selector: '.description-col',
                    renderFn: (target, value)=> {
                        var tankIdVal = target.parents('.product-delivery-item')
                            .find('.tank-id-field').val();

                        if (tankIdVal) {
                            target.text(item.find('#select-tank')
                                .dropdownSelect('get_item_by_value', tankIdVal).text
                            );
                        } else {
                            target.text(item.find('#select-product')
                                .dropdownSelect('get_item_by_value', value).text
                            );
                        }
                    }
                },
                '.qty-delivered-field': { 
                    selector: '.qty-delivered-col',
                    renderFn: (target, value)=> {
                        target.text( formatNum(value) );
                    }
                }
            },
            renderEvents: {
                afterItem(renderedItem) {
                    if (renderedItem.find('.tank-id-field').val()) {
                        item.find('#select-tank').dropdownSelect('disable_item_by_value',
                            renderedItem.find('.tank-id-field').val());
                    } else {
                        item.find('#select-product').dropdownSelect('disable_item_by_value',
                            renderedItem.find('.product-id-field').val());
                    }

                    item.find('#select-tank').dropdownSelect('reset_selection');
                    item.find('#select-product').dropdownSelect('reset_selection');
                        
                    item.find('#input-qtyDelivered').val('');
                }
            }
        });

        item.find('#select-tank, #select-product').on('dropdown-select:change', (e)=> {
            item.find('#input-qtyDelivered').select();
        });

        item.find('.add-product-delivery-fields')
            .data('association-insertion-method', 'append')
            .data('association-insertion-node', (link)=> {
                return item.find('#table-productDeliveries tbody')
            });

        item.find('#table-productDeliveries')
            .on('cocoon:after-insert', (e, insertedItem)=> {
                if (item.find('.delivery-type-field').val() === 'Fuel') {
                    tankData = JSON.parse(item.find('#select-tank').attr('data-store'));
                    productDeliveryNFRS.add(insertedItem, {
                        '.product-id-field': tankData.fuelId,
                        '.tank-id-field': item.find('#select-tank').attr('data-value'),
                        '.qty-delivered-field': item.find('#input-qtyDelivered').numericVal()
                    });
                } else if (item.find('.delivery-type-field').val() === 'NonFuel') {
                    productDeliveryNFRS.add(insertedItem, {
                        '.product-id-field': item.find('#select-product').attr('data-value'),
                        '.tank-id-field': null,
                        '.qty-delivered-field': item.find('#input-qtyDelivered').numericVal()
                    });
                }
            })
            .on('cocoon:after-remove', (e, removedItem)=> {
                if (removedItem.find('.tank-id-field').val()) {
                    item.find('#select-tank').dropdownSelect('enable_item_by_value',
                        removedItem.find('.tank-id-field').val());
                } else {
                    item.find('#select-product').dropdownSelect('enable_item_by_value',
                        removedItem.find('.product-id-field').val());
                }
            });
    }

    $('.deliveries-form .delivery-form-panels')
        .on('cocoon:after-insert', (e, insertedItem)=> {
            if (e.target != e.currentTarget) return;
            
            deliveriesNFRS.add(insertedItem);
        })
        .on('cocoon:before-remove', (e, removedItem)=> {
            if (e.target != e.currentTarget) return;

            $(e.currentTarget).data('remove-timeout', 150);
            $(`
                #${removedItem.attr('id')},
                .deliveries-form .list-group-item[href="#${removedItem.attr('id')}"]
            `).fadeOut(150)
        })
        .on('cocoon:after-remove', (e, removedItem)=> {
            $(`.deliveries-form .list-group-item[href="#${removedItem.attr('id')}"]`)
                .remove();
        });
});

executeScriptFor('.shift_inventory_updates-controller .form-partial .fuel-sales-form', ()=> {
    new NestedFieldsRenderService({
        parentElem: $('#table-fuelSales'),
        itemSelector: '.fuel-sale-item',
        fields: {
            '.dispensed-field': {
                selector: '#input-dispensed',
                renderFn: (target, value)=> { 
                    target.val( formatNum(value) ) 
                    cleaveNum(target);
                },
                events: {
                    'input': (e, field)=> {
                        field.val( extractNum( $(e.currentTarget).val() ) );

                        field.parents('.fuel-sale-item')
                            .find('._destroy-field')
                            .val( $(e.currentTarget).val() === '' );
                    }
                }
            }
        }
    })
});

executeScriptFor('.shift_inventory_updates-controller .form-partial .dipstick-measurements-form', ()=> {
    new NestedFieldsRenderService({
        parentElem: $('#table-dipstickMeasurements'),
        itemSelector: '.dipstick-measurement-item',
        fields: {
            '.converted-vol-field': {
                selector: '#input-convertedVol',
                renderFn: (target, value)=> { 
                    target.val( formatNum(value) ) 
                    cleaveNum(target);
                },
                events: { 'input': onConvertedVolInput }
            }
        },
        renderEvents: {
            afterItem(item) {
                item.find('[data-toggle="popover"]').popover({html: true});
                computeAll();
            }
        }
    });

    new MutationObserver(deliveriesCallback).observe(
        $('.deliveries-form .delivery-form-panels')[0],
        {childList: true}
    );

    (()=> {
        $('.deliveries-form .delivery-form-panels .delivery-item').each((i, item)=> {
            new MutationObserver(()=> { computeAll() }).observe(
                $(item).find('[id$="_destroy"]')[0], {attributes: true, attributeFilter: ['value']}
            );
        });
    })();

    function deliveriesCallback(mutations) {
        mutations.forEach((mutation)=> {
            var target = $(mutation.target);
            
            new MutationObserver(()=> { computeAll() }).observe(
                $(target).find('#table-productDeliveries tbody')[0],
                {childList: true}
            );

            $(target).find('#table-productDeliveries .product-delivery-item').each((i, item)=> {
                new MutationObserver(()=> { computeAll() }).observe(
                    $(item).find('[id$="_destroy"]')[0], {attributes: true, attributeFilter: ['value']}
                )
            });
        });
        computeAll();
    }

    (()=> {
        $('.deliveries-form .delivery-form-panels .delivery-item').each((i, delivery)=> {
            new MutationObserver(()=> { computeAll() }).observe(
                $(delivery).find('#table-productDeliveries tbody')[0],
                { childList: true}
            );

            $(delivery).find('#table-productDeliveries .product-delivery-item').each((i, productDelivery)=> {
                new MutationObserver(()=> { computeAll() }).observe(
                    $(productDelivery).find('[id$="_destroy"]')[0],
                    {attributes: true, attributeFilter: ['value']}
                )
            });
        });
    })();

    $('.fuel-sales-form #table-fuelSales .fuel-sale-item').each((i, fuelSale)=> {
        new MutationObserver(()=> { computeAll() }).observe(
            $(fuelSale).find('.dispensed-field')[0],
            {attributes: true, attributeFilter: ['value']}
        )
    });

    function onConvertedVolInput(e, field) {
        var renderedField = $(e.currentTarget),
            item = field.parents('.dipstick-measurement-item');

        item.find('._destroy-field').val( renderedField.val() === '' );
        
        field.val( extractNum( renderedField.val() ) );
        calculateEndingAmt(item);
        calculateDifference(item);
    }

    function computeAll() {
        writeDeliveries();
        writeSales();

        $('#table-dipstickMeasurements .dipstick-measurement-item').each((i, item)=> {
            calculateEndingAmt($(item));
            calculateDifference($(item));
        });
    }

    function writeDeliveries() {
        var totals = getTotalDeliveriesByTank();
        $('#table-dipstickMeasurements .dipstick-measurement-item').each((i, item)=> {
            var tankId = $(item).find('.tank-id-field').val(),
                ind = totals.findIndex((elem)=> { return elem.tankId == tankId });

            if (ind != -1) {
                var summary = totals[ind];
                $(item).find('.deliveries-col').text( formatNum(summary.totalDelivered) );
            } else {
                $(item).find('.deliveries-col').text( '0.00' );
            }
        });
    }

    function writeSales() {
        var totals = getDispensedByTank();
        $('#table-dipstickMeasurements .dipstick-measurement-item').each((i, item)=> {
            var tankId = $(item).find('.tank-id-field').val(),
                ind = totals.findIndex((elem)=> { return elem.tankId == tankId });

            if (ind != -1) {
                var summary = totals[ind];
                $(item).find('.dispensed-col').text( formatNum(summary.dispensed) );
            } else {
                $(item).find('.dispensed-col').text( '0.00' );
            }
        })
    }

    function calculateEndingAmt(item) {
        var beginningAmtVal = extractNum( item.find('.beginning-amt-col .val').text() ),
            deliveriesVal = extractNum( item.find('.deliveries-col').text() ),
            dispensedVal = extractNum( item.find('.dispensed-col').text() );

        if (isNaN(beginningAmtVal) || isNaN(deliveriesVal) || isNaN(dispensedVal)) {
            item.find('.ending-amt-col').html('<span class="text-muted">n/a</span>');
        } else {
            var endingAmt = (beginningAmtVal + deliveriesVal) - dispensedVal;
            item.find('.ending-amt-col').html( formatNum(endingAmt) );
        }
    }

    function calculateDifference(item) {
        var endingAmtVal = extractNum( item.find('.ending-amt-col').text() ),
            convertedVolVal = parseFloat( item.find('#input-convertedVol').numericVal() );

        if (isNaN(endingAmtVal) || isNaN(convertedVolVal)) {
            item.find('.difference-col').html('<span class="text-muted">n/a</span>');
        } else if (item.find('#input-convertedVol').val() === '') {
            item.find('.difference-col').html(`
                <div class="none-icon"></div>
            `);
        } else {
            var difference = convertedVolVal - endingAmtVal;
            var differencePct = (convertedVolVal - endingAmtVal) / endingAmtVal;

            item.find('.difference-col').html(`
                <div>${formatNum(difference)}</div>
                <div class="fs-pt8">(${formatNum(differencePct, 2, false)}%)</div>
            `);
        }
    }
});

executeScriptFor('.shift_inventory_updates-controller .form-partial .calibrations-form', ()=> {
    new NestedFieldsRenderService({
        parentElem: $('#table-calibrations'),
        itemSelector: '.calibration-item',
        fields: {
            '.amount-field': {
                selector: '#input-amount',
                renderFn: (target, value)=> { 
                    target.val( formatNum(value) ) 
                    cleaveNum(target);
                },
                events: {
                    'input': (e, field)=> { 
                        field.val($(e.currentTarget).numericVal()) 
                    } 
                }
            }
        }
    });

    new TableCellMergerService({
        table: '#table-calibrations',
        cells: {
            '.pump-island-col': 'vertical',
            '.loading-point-col': 'vertical'
        }
    });

    cleaveNum( $('#input-amountAll') );
    $('#button-inputAmountAll').on('click', (e)=> {
        if ($('#input-amountAll').val() !== '') {
            var val = $('#input-amountAll').numericVal();
            $('.calibrations-form .calibration-item').each((i, item)=> {
                item = $(item);
                item.find('#input-amount').val( formatNum(val) );
                item.find('#input-amount').trigger('input');
            });
            $('#input-amountAll').val('');
        }
    }); 
});

executeScriptFor('.shift_inventory_updates-controller .form-partial .pump-meter-readings-form', ()=> {
    new NestedFieldsRenderService({
        parentElem: $('#table-pumpMeterReadings'),
        itemSelector: '.pump-meter-reading-item',
        fields: {
            '.ending-bal-field': {
                selector: '#input-endingBal',
                renderFn: (target, value)=> { 
                    target.val( formatNum(value) ) 
                    cleaveNum(target);
                },
                events: { 'input': onEndingBalInput }
            }
        },
        renderEvents: {
            afterItem(item) {
                $('[data-toggle="popover"]').popover({html: true});
            },
            afterAll() {
                computeAll();
            }
        }
    });

    $('.calibrations-form #table-calibrations .calibration-item').each((i, item)=> {
        new MutationObserver(()=> { computeAll() }).observe(
            $(item).find('.amount-field')[0],
            {attributes: true, attributeFilter: ['value']}
        );
    });

    function onEndingBalInput(e, field) {
        var renderedField = $(e.currentTarget),
            item = field.parents('.pump-meter-reading-item');

        item.find('._destroy-field').val( renderedField.val() === '' );

        field.val( extractNum( renderedField.val() ) );
        calculateDispensed(item);
    }

    function computeAll() {
        summarizeCalibrations();
        $('#table-pumpMeterReadings .pump-meter-reading-item').each((i, item)=> {
            calculateDispensed($(item));
        });
    }

    function summarizeCalibrations(item=null) {
        var calibrations = $('.calibrations-form #table-calibrations .calibration-item'),
            pumpMeterReadings = $('.pump-meter-readings-form #table-pumpMeterReadings .pump-meter-reading-item');
        
        calibrations.each((i, calibration)=> {
            var amount = $(calibration).find('.amount-field').numericVal(),
                pumpNozzleId = $(calibration).find('.pump-nozzle-id-field').val();

            pumpMeterReadings.each((j, pumpMeterReading)=> {
                if ($(pumpMeterReading).find('.pump-nozzle-id-field').val() == pumpNozzleId) {
                    $(pumpMeterReading).find('.calibration-col').text( formatNum(amount) );
                }
            });
        });
    }

    function calculateDispensed(item) {
        var beginningBalVal = extractNum( item.find('.beginning-bal-col .val').text() ),
            endingBalVal = item.find('#input-endingBal').numericVal(),
            calibrationVal = extractNum( item.find('.calibration-col').text() );

        if (isNaN(beginningBalVal) || isNaN(endingBalVal) || isNaN(calibrationVal)) {
            item.find('.dispensed-col').html('<span class="text-muted">n/a</span>');
        } else if (item.find('#input-endingBal').val() === '') {
            item.find('.dispensed-col').html('<span class="none-icon"></span>');
        } else {
            var dispensed = (endingBalVal - calibrationVal ) - beginningBalVal;
            item.find('.dispensed-col').text( formatNum(dispensed) );
        }
    }

    new TableCellMergerService({
        table: $('#table-pumpMeterReadings'),
        cells: {
            '.pump-island-col': 'vertical',
            '.loading-point-col': 'vertical'
        }
    })
});

executeScriptFor('.shift_inventory_updates-controller .form-partial .pump-reconciliation-totals-form', ()=> {
    new NestedFieldsRenderService({
        parentElem: $('#table-pumpReconciliationTotals'),
        itemSelector: '.pump-reconciliation-total-item',
        fields: {
            '.ending-bal-field': {
                selector: '#input-endingBal',
                renderFn: (target, value)=> { 
                    target.val( formatNum(value) ) 
                    cleaveNum(target);
                },
                events: { 'input': onEndingBalInput }
            }
        },
        renderEvents: {
            afterItem(item) {
                $('[data-toggle="popover"]').popover({html: true});
            },
            afterAll() {
                computeAll();
            }
        }
    });

    $('.calibrations-form #table-calibrations .calibration-item').each((i, item)=> {
        new MutationObserver(()=> { computeAll() }).observe(
            $(item).find('.amount-field')[0],
            {attributes: true, attributeFilter: ['value']}
        );
    });
    
    function onEndingBalInput(e, field) {
        var renderedField = $(e.currentTarget),
            item = field.parents('.pump-reconciliation-total-item');

        item.find('._destroy-field').val( renderedField.val() === '' );

        field.val( extractNum( renderedField.val() ) );
        calculateDispensed(item);
    }

    function computeAll() {
        summarizeCalibrations();
        $('#table-pumpReconciliationTotals .pump-reconciliation-total-item').each((i, item)=> {
            calculateDispensed($(item));
        });
    }

    function summarizeCalibrations() {
        var totals = [];
        var calibrations = $('.calibrations-form #table-calibrations .calibration-item');

        calibrations.each((i, calibration)=> {
            if ($(calibration).find('[id$="_destroy"]').val() != true) {
                var fuelId = $(calibration).attr('data-fuel-id'),
                    calibration = parseFloat( $(calibration).find('.amount-field').val() );

                if (totals.find((elem)=> { return elem.fuelId == fuelId }) === undefined) {
                    totals.push({
                        fuelId: fuelId,
                        totalCalibrations: (calibration || 0)
                    });
                } else {
                    var ind = totals.findIndex((elem)=> { return elem.fuelId == fuelId });
                    totals[ind].totalCalibrations += (calibration || 0);
                }
            }
        });

        $('#table-pumpReconciliationTotals .pump-reconciliation-total-item').each((i, item)=> {
            var fuelId = $(item).find('.product-id-field').val(),
                ind = totals.findIndex((elem)=> { return elem.fuelId == fuelId });

            if (ind != -1) {
                var summary = totals[ind];
                $(item).find('.calibrations-col').text( formatNum(summary.totalCalibrations) );
            } else {
                $(item).find('.calibrations-col').text( '0.00' );
            }
        });
    }

    function calculateDispensed(item) {
        var beginningBalVal = extractNum( item.find('.beginning-bal-col .val').text() ),
            endingBalVal = parseFloat( item.find('#input-endingBal').numericVal() ),
            calibrationsVal = extractNum( item.find('.calibrations-col').text() );

        if (isNaN(beginningBalVal) || isNaN(endingBalVal) || isNaN(calibrationsVal)) {
            item.find('.dispensed-col').html('<span class="text-muted">n/a</span>')
        } else if (item.find('#input-endingBal').val() === '') {
            item.find('.dispensed-col').html('<span class="none-icon"></span>')
        } else {
            var dispensed = (endingBalVal - calibrationsVal) - beginningBalVal;
            item.find('.dispensed-col').text( formatNum(dispensed) );
        }
    }

});

function getTotalDeliveriesByTank() {
    var totals = [];
    var deliveries = $('.deliveries-form .delivery-form-panels .delivery-item');

    deliveries.each((i, delivery)=> {
        delivery = $(delivery);
        if (delivery.find('.delivery-type-field').val() === 'Fuel'
        && delivery.find('[id$="_destroy"]').val() != true) {
            var productDeliveries = delivery.find('.product-delivery-item');

            productDeliveries.each((j, productDelivery)=> {
                productDelivery = $(productDelivery);
                if (productDelivery.find('[id$="_destroy"]').val() != true) {
                    var tankId = productDelivery.find('.tank-id-field').val(),
                        qtyDelivered = parseFloat(productDelivery.find('.qty-delivered-field').val());

                    if (totals.find((elem)=> { return elem.tankId == tankId }) === undefined) {
                        totals.push({ tankId: tankId, totalDelivered: (qtyDelivered || 0) });
                    } else {
                        var indInArr = totals.findIndex((elem)=> { return elem.tankId == tankId });
                        totals[indInArr].totalDelivered += (qtyDelivered || 0);
                    }
                }
            })
        }
    });

    return totals;
}

function getDispensedByTank() {
    var totals = [];
    var fuelSales = $('.fuel-sales-form #table-fuelSales .fuel-sale-item');
    
    fuelSales.each((i, fuelSale)=> {
        fuelSale = $(fuelSale);
        if (fuelSale.find('[id$="_destroy"]').val() != true) {
            var dispensedVal = extractNum( fuelSale.find('.dispensed-field').val() );
            var tankId = fuelSale.find('.tank-id-field').val();

            totals.push({ tankId: tankId, dispensed: (dispensedVal || 0) })
        }
    });

    return totals;
}

executeScriptFor('.shift_inventory_updates-controller.show-view', ()=> {
    new Vue({
        el: '#app',
        data: {
            shiftSummary: {},
            associationData: {
                deliveries: {
                    isSummaryOpen: false
                },
                pumpMeterReadings: {
                    isSummaryOpen: false
                },
                pumpReconciliationTotals: {
                    isSummaryOpen: false
                }
            }
        }
    })
});

executeScriptFor('.shift_inventory_updates-controller.show-view .deliveries-data', ()=> {
    $('.delivery-item, .delivery-item .collapse-content').on('show.bs.collapse', (e)=> {
        $(e.currentTarget)
            .find('.toggle-icon')
            .removeClass('mdi-chevron-down')
            .addClass('mdi-chevron-up');
    });

    $('.delivery-item, .delivery-item .collapse-content').on('hide.bs.collapse', (e)=> {
        $(e.currentTarget)
            .find('.toggle-icon')
            .removeClass('mdi-chevron-up')
            .addClass('mdi-chevron-down');
    });

    $('.delivery-items-header #button-expandAll').click((e)=> {
        $('.delivery-item').each((i, item)=> {
            $(item).find('.collapse-content').collapse('show');
            $(item).find('.toggle-icon')
                .removeClass('mdi-chevron-down')
                .addClass('mdi-chevron-up');
        }); 
    });

    $('.delivery-items-header #button-collapseAll').click((e)=> {
        $('.delivery-item').each((i, item)=> {
            $(item).find('.collapse-content').collapse('hide');
            $(item).find('.toggle-icon')
                .removeClass('mdi-chevron-up')
                .addClass('mdi-chevron-down');
        }); 
    });

    $('.delivery-item').each((i, item)=> {
        $(item).find('.collapse-content').collapse('show');
        $(item).find('.toggle-icon')
            .removeClass('mdi-chevron-down')
            .addClass('mdi-chevron-up');
    }); 
});

executeScriptFor('.shift_inventory_updates-controller.show-view .calibrations-data', ()=> {
    new TableCellMergerService({
        table: $('#table-calibrations'),
        cells: {
            'td:nth-child(1)': 'vertical',
            'td:nth-child(2)': 'vertical'
        }
    })
});

executeScriptFor('.shift_inventory_updates-controller.show-view .pump-meter-readings-data', ()=> {
    new TableCellMergerService({
        table: $('#table-pumpMeterReadings'),
        cells: {
            'td:nth-child(1)': 'vertical',
            'td:nth-child(2)': 'vertical'
        }
    })
});