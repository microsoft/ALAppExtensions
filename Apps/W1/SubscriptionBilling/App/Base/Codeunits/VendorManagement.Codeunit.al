namespace Microsoft.SubscriptionBilling;

using Microsoft.Purchases.Vendor;

codeunit 8016 "Vendor Management"
{
    Access = Internal;

    procedure OpenVendorCard(VendorNo: Code[20])
    var
        Vendor: Record Vendor;
    begin
        if VendorNo = '' then
            exit;

        Vendor.Get(VendorNo);
        Page.Run(Page::"Vendor Card", Vendor);
    end;
}
