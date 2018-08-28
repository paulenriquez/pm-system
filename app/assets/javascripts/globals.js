const API_PATH = '/api';

$(document).ready(()=> {
    $('.dropdown-toggle').dropdown();
    $('[data-toggle="popover"]').popover();
});
$(window).on('beforeunload', (e)=> {
    
});

$(document)
    .on('click', 'a[href="#"]', (e)=> {
        e.preventDefault();
    })

    .on('click', 'a[href]:not([href=""]):not([href^="#"])', (e)=> {
        displayLoader();
    })
    .on('submit', 'form', (e)=> {
        displayLoader();
    })

function displayLoader() {
    $('.content-loader').addClass('active')
    $('.view-container').addClass('blurred');
}

function executeScriptFor(refSelector, script) {
    $(()=> {
        $(refSelector).length ? script() : null;
    });
}

class NestedFieldsRenderService {
    constructor(config) {
        this._parentElem   = config.parentElem;
        this._itemSelector = config.itemSelector;
        this._fields       = config.fields;

        this._renderEvents = config.renderEvents;

        this.renderAll();
    }

    _sel(selector) {
        return $(this._parentElem).find(selector);
    }

    _runRenderEventHandler(event, args=[]) {
        if (this._renderEvents != undefined) {
            var renderEvents = this._renderEvents;
            if (renderEvents[event] != undefined
                && typeof(renderEvents[event]) === 'function') {
                renderEvents[event](...args);
            }
        }
    }

    _render(item) {
        var item = $(item);
        var fields = this._fields;

        this._runRenderEventHandler('beforeItem', [item]);

        Object.keys(fields).forEach((field)=> {
            var targetConfig = fields[field];

            var targetElem = item.find(targetConfig.selector),
                fieldElem  = item.find(field);

            if (targetConfig.renderFn === undefined) {
                targetElem.text(fieldElem.val());
            } else if (typeof(targetConfig.renderFn) === 'string') {
                var renderFn = targetConfig.renderFn;
                targetElem[renderFn](fieldElem.val());
            } else if (typeof(targetConfig.renderFn) === 'function') {
                targetConfig.renderFn(targetElem, fieldElem.val());
            }

            if (typeof(targetConfig.events) === 'object') {
                var events = targetConfig.events;
                Object.keys(events).forEach((event)=> {
                    targetElem.on(event, (e)=> {
                        events[event](e, fieldElem);
                    });
                });
            }
        });

        this._runRenderEventHandler('afterItem', [item]);
    }

    add(insertedItem, fieldValuePair={}) {
        Object.keys(fieldValuePair).forEach((field)=> {
            var value = fieldValuePair[field];
            insertedItem.find(field).val(value);
        });
        this._render(insertedItem);
    }

    renderAll() {
        this._runRenderEventHandler('beforeAll');

        var allItems = this._sel(this._itemSelector);
        allItems.each((i, item)=> {
            this._render($(item));
        });

        this._runRenderEventHandler('afterAll');
    }
}

class TableCellMergerService {
    constructor(config) {
        this._table = config.table
        this._cells = config.cells

        this.mergeAll();
    }

    _sel(selector) {
        return $(this._table).find(selector);
    }

    _spanAttr(mergeType) {
        mergeType = mergeType.toLowerCase();
        if (mergeType === 'vertical') {
            return 'rowspan';
        } else if (mergeType === 'horizontal') {
            return 'colspan';
        }
    }

    _merge(cellSelector, mergeType) {
        var cells = this._sel(cellSelector).toArray().map((cell)=> { return $(cell) });
        var refCell = $();

        var spanAttr = this._spanAttr(mergeType);

        for (let i = 0; i < cells.length; i++) {
            if (cells[i].text() != refCell.text()) refCell = cells[i];
            else cells[i].css('display', 'none');

            
            refCell.attr(spanAttr, parseInt(refCell.attr(spanAttr) || 0) + 1);
        }
    }

    mergeAll() {
        var cells = this._cells;
        Object.keys(cells).forEach((cell)=> {
            this._merge(cell, cells[cell]);
        });
    }
}

/** Cleave.js factory function */
function cleaveNum(input, decimals=2) {
    var cleave = new Cleave(input, {
        numeral: true,
        numeralDecimalScale: decimals,
        numeralThousandsGroupStyle: 'thousand'
    });
    $.fn.extend({
        numericVal() {
            var val = extractNum($(this).val()).toString();
            if (val.length > 0 && !isNaN(val)) {
                var parsed = val.split('.');

                if (parsed[1] != undefined) {
                    return extractNum([
                        parsed[0],
                        parsed[1].substring(0, decimals)
                    ].join('.'));
                } else {
                    return extractNum(val);
                }
            } else {
                return 0;
            }
        }
    });
}

/** Numeric Functions */
function formatNum(num, decimals=2, commas=true) {
    if (isNaN(num)) {
        return NaN;
    } else {
        num = parseFloat(num);
        if (commas) {
            var formatted = '';
            formatted = num.toLocaleString(undefined, 
                {minimumFractionDigits: decimals});

            if (Number.isInteger(parseFloat(num))) {
                formatted = formatted.split('.')[0];
                formatted += '.' + '0'.repeat(decimals);
            }
            return formatted;
        } else {
            return parseFloat(num).toFixed(decimals);
        }
    }
}

function extractNum(numStr) {
    var stripped = numStr.replace(/[^\d.-]/g, '');
    return parseFloat(stripped);
}