executeScriptFor('.admin_account_manager-controller .form-partial', ()=> {
    var app = new Vue({
        el: '#app',
        data: {
            user: {
                accountType: (()=> {
                    return $('#account_type').val() === 'administrator'
                })()
            }
        },
        computed: {
            convertedAccountType() {
                return this.user.accountType ? 'administrator' : null;
            }
        }
    })
});