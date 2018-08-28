executeScriptFor('.inventory_and_sales-controller.index-view', ()=> {

    new TableCellMergerService({
        table: '.shift-table',
        cells: {
            '.shift-col': 'vertical'
        }
    })
});