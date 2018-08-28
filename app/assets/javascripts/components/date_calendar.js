(()=> {
    const SELECTOR = '.date-calendar';

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

            var usp = new URLSearchParams(window.location.search);
            if (usp.has('date') && moment(usp.get('date')).isValid()) {
                $(`${SELECTOR} .calendar-cells`).datetimepicker('date', moment(usp.get('date')));
            } else {
                $(`${SELECTOR} .calendar-cells`).datetimepicker('date', new Date);
            }

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

                mainParent.find('#button-loadData')
                    .attr('href', `/inventory_and_sales?date=${selectedDate.format('YYYY-MM-DD')}`)
                    .find('.load-text')
                        .text(`Load ${selectedDate.format('MMM DD, YYYY')}`);

            }
        });
})();