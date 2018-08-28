module ApplicationHelper
    def get_icon_class(chg)
        if chg > 0
            'mdi-triangle'
        elsif chg < 0
            'mdi-triangle mdi-rotate-180'
        else
            'mdi-minus-box'
        end
    end

    def get_text_class(chg)
        if chg > 0
            'text-success'
        elsif chg < 0
            'text-danger'
        else
            'text-warning'
        end
    end
end
