namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Customer;

codeunit 8019 "Customer Management"
{
    Access = Internal;
    procedure OpenCustomerCard(CustomerNo: Code[20])
    var
        Customer: Record Customer;
    begin
        if CustomerNo = '' then
            exit;

        Customer.Get(CustomerNo);
        Page.Run(Page::"Customer Card", Customer);
    end;
}