namespace Microsoft.SubscriptionBilling;

using Microsoft.CRM.Contact;

codeunit 8000 "Contact Management"
{
    Access = Internal;

    procedure OpenContactCard(ContactNo: Code[20])
    var
        Contact: Record Contact;
    begin
        if ContactNo = '' then
            exit;

        Contact.Get(ContactNo);
        Page.Run(Page::"Contact Card", Contact);
    end;
}