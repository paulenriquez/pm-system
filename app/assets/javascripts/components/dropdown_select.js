(()=> {
    const SELECTOR = '.dropdown-select';

// Create a dropdown option in the tank deliveries.
    $.fn.extend({
        dropdownSelect(action=null, params=null) {
            var actions = {
                'initialize': ()=> {
                    $(this)
                        .find('.dropdown-toggle .dropdown-text')
                        .text( $(this).attr('data-default-text') );
                    
                    $(this).dropdownSelect('set_selection',
                        $(this).attr('data-value'));
                },
                'reset_selection': ()=> {
                    $(this)
                        .attr('data-value', '')
                        .attr('data-text', '')
                        .attr('data-store', '');
                        
                    $(this).find('.dropdown-toggle .dropdown-text')
                        .text( $(this).attr('data-default-text') );
                },
                'get_all_items': ()=> {
                    var items = [];
                    $(this).find('.dropdown-menu .items-container .dropdown-item').each((i, elem)=> {
                        items.push({
                            value: $(item).attr('data-value'),
                            text: $(item).attr('data-text')
                        });
                    });
                    return items;
                },
                'get_item_by_value': ()=> {
                    var result = -1;
                    $(this).find('.dropdown-menu .items-container .dropdown-item').each((i, item)=> {
                        if ($(item).attr('data-value') == params) {
                            result = {
                                value: $(item).attr('data-value'),
                                text:  $(item).attr('data-text')
                            };
                        }
                    });
                    return result;
                },
                'get_selection': ()=> {
                    if ($(this).attr('data-value')) {
                        return {
                            value: $(this).attr('data-value'),
                            text:  $(this).attr('data-text')
                        }
                    } else {
                        return null;
                    }
                },
                'set_selection': ()=> {
                    var menuItem = null;
                    $(this).find('.dropdown-menu .items-container .dropdown-item').each((i, item)=> {
                        item = $(item);
                        if (item.attr('data-value') == params) {
                            menuItem = item;
                        }
                    });

                    if (menuItem != null) {
                        $(this).attr('data-value', params);
                        $(this).attr('data-text', menuItem.attr('data-text'));
                        $(this).attr('data-store', menuItem.attr('data-store'));
                        
                        $(this).find('.dropdown-menu .items-container .dropdown-item').removeClass('active');
                        menuItem.addClass('active');

                        $(this).find('.dropdown-toggle .dropdown-text').text(menuItem.attr('data-text'));

                        $(this).trigger('dropdown-select:change');
                    }
                },
                'disable_item_by_value': ()=> {
                    $(this).find('.dropdown-menu .items-container .dropdown-item').each((i, item)=> {
                        item = $(item);
                        if (item.attr('data-value') == params) {
                            item.addClass('disabled');
                        }
                    });
                },
                'enable_item_by_value': ()=> {
                    $(this).find('.dropdown-menu .items-container .dropdown-item').each((i, item)=> {
                        item = $(item);
                        if (item.attr('data-value') == params) {
                            item.removeClass('disabled');
                        }
                    });
                }
            }

            if (action != null) {
                return actions[action.toLowerCase()]();
            } else {
                return actions['initialize']();
            }
        }
    });

    $(document)
        .on('mousedown', `${SELECTOR} .dropdown-item`, (e)=> {
            var elem       = $(e.currentTarget),
                mainParent = elem.parents(SELECTOR);

            elem.parent().find('.dropdown-item').removeClass('active');
            elem.addClass('active');
        })
        .on('click', `${SELECTOR} .dropdown-item`, (e)=> {
            var elem       = $(e.currentTarget),
                mainParent = elem.parents(SELECTOR);

            mainParent.dropdownSelect('set_selection', elem.attr('data-value'));
        });
})();