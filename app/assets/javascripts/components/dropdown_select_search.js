(()=> {
    const SELECTOR = '.dropdown-select.dropdown-select-search';
    
// Searches all the available tanks the branch has and have these
// options display in the drop down.

    $(document)
        .on('shown.bs.dropdown', `${SELECTOR}`, (e)=> {
            var mainParent = $(e.currentTarget);

            mainParent.find('.search-box').select();
            mainParent.find('.dropdown-toggle').addClass('menu-open-focus');
        })
        .on('hidden.bs.dropdown', `${SELECTOR}`, (e)=> {
            var mainParent = $(e.currentTarget);
            
            mainParent.find('.dropdown-toggle').removeClass('menu-open-focus');
        })

        .on('input', `${SELECTOR} .search-box`, (e)=> {
            var elem       = $(e.currentTarget),
                mainParent = elem.parents(SELECTOR);

            var query = elem.val().toLowerCase().replace(/ /g,'');

            mainParent.find('.items-container .dropdown-item').each((i, item)=> {
                item = $(item);

                var lookupRef = item.text().toLowerCase().replace(/ /g,'');
                if (!lookupRef.includes(query)) {
                    item.addClass('searched-out');
                } else {
                    item.removeClass('searched-out');
                }
            });

            renderNoResultsFound(mainParent.find('.items-container'));
        })

        .on('click', `${SELECTOR} .search-filter .nav-item .nav-link`, (e)=> {
            var elem       = $(e.currentTarget),
                mainParent = elem.parents(SELECTOR);

            var navItem = elem.parents('.nav-item');
            
            mainParent.find('.search-filter .nav-item').removeClass('active');
            navItem.addClass('active');

            var filter = navItem.attr('data-filter');
            mainParent.find('.items-container .dropdown-item').each((i, item)=> {
                item = $(item);

                if (filter.toLowerCase() === 'all') {
                    item.removeClass('filtered-out');
                } else {
                    if (item.attr('data-filter') != filter) {
                        item.addClass('filtered-out');
                    } else {
                        item.removeClass('filtered-out');
                    }
                }
            });
            mainParent.find('.search-box').select();

            renderNoResultsFound(mainParent.find('.items-container'));

            e.stopPropagation();
        });

    
    function renderNoResultsFound(itemsContainer) {
        itemsContainer = $(itemsContainer);
    
        var noResultHtml = `
            <div class="no-results-message">
                No items found
            </div>
        `;
    
        itemsContainer.find('.no-results-message').remove();
        if (itemsContainer.find('.dropdown-item:not(.searched-out):not(.filtered-out)').length === 0) {
            itemsContainer.append(noResultHtml);
        }
    }
    
})();