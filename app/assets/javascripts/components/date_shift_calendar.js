(()=> {
    const SELECTOR = '.date-shift-calendar';
    
// Seen in Shift Inventory Updates
// Listener for current queries of different data in different dates in different shifts
// Allows user to switch between dates with the indication of whether or not data
// is available on each shift of any dates

    $(document)
        .on('ready', (e)=> {
            $(`${SELECTOR} .calendar-cells`).datetimepicker({
                inline: true,
                format: 'L',
                icons: {
                    previous: 'mdi mdi-chevron-left',
                    next: 'mdi mdi-chevron-right',
                }
            });
            $(`${SELECTOR} .calendar-cells`).datetimepicker('date', new Date);
            $(`${SELECTOR} .calendar-cells`).datetimepicker('maxDate', new Date);
        })

        .on('change.datetimepicker', `${SELECTOR} .calendar-cells`, (e)=> {
            var elem       = $(e.currentTarget),
                mainParent = elem.parents(SELECTOR);

            if (!elem.html()) return;
            
            var selectedDate = elem.datetimepicker('date');
    
            $('.fade-container')
                .fadeOut(150, ()=> { changeDate(); })
                .fadeIn(150);
            function changeDate() {
                mainParent.find('.shift-links-container').find('.date-text')
                    .text( selectedDate.format('MMM DD, YYYY (ddd)') );

                var diff = moment(selectedDate.format('YYYY-MM-DD'))
                    .diff(moment(new Date()).format('YYYY-MM-DD'), 'days');

                if ( moment(selectedDate.format('YYYY-MM-DD')).isSame( moment(new Date()).format('YYYY-MM-DD') ) ) {
                    mainParent.find('.date-description').text('Today');
                } else if ( moment(selectedDate.format('YYYY-MM-DD')).subtract(1, 'd').isSame( moment(new Date()).format('YYYY-MM-DD') ) ) {
                    mainParent.find('.date-description').text('Tomorrow');
                } else if ( moment(selectedDate.format('YYYY-MM-DD')).add(1, 'd').isSame( moment(new Date()).format('YYYY-MM-DD') ) ) {
                    mainParent.find('.date-description').text('Yesterday');
                } else {
                    mainParent.find('.date-description')
                        .text(`${moment.duration(diff, 'days').humanize()} ${diff < 0 ? 'ago' : 'from now'}`);
                }
            }
    
            var shifts = [1,2,3],
                queryDate = selectedDate.format('YYYY-MM-DD');
            
                shifts.forEach((shift)=> {
                mainParent.find(`#list-shift${shift}`).find('.edit-link')
                    .attr('href', `/shift_inventory_updates/load_form?date=${queryDate}&shift=${shift}`);
                mainParent.find(`#list-shift${shift}`).find('.view-link')
                    .attr('href', `/shift_inventory_updates/load_view?date=${queryDate}&shift=${shift}`);
            });
        })

        .on('click', `${SELECTOR} #button-calToday`, (e)=> {
            var elem       = $(e.currentTarget),
                mainParent = elem.parents(SELECTOR);

            mainParent.find('.calendar-cells').datetimepicker('date', new Date);
        })
})();