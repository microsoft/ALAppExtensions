codeunit 13435 "Create Purchase Order FI"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        PurchHeader: Record "Purchase Header";
        CreateVendor: Codeunit "Create Vendor";
        CreatePaymentTerms: Codeunit "Create Payment Terms";
    begin
        if PurchHeader.FindSet() then
            repeat
                PurchHeader.Validate("Message Type", PurchHeader."Message Type"::Message);
                PurchHeader.Validate("Invoice Message", PurchHeader."No.");
                PurchHeader.Modify(true);
            until PurchHeader.Next() = 0;

        PurchHeader.Reset();
        PurchHeader.SetRange("Buy-from Vendor No.", CreateVendor.DomesticFirstUp());
        if PurchHeader.FindSet() then
            repeat
                PurchHeader.Validate("Payment Terms Code", CreatePaymentTerms.PaymentTermsDAYS30());
                PurchHeader.Modify(true);
            until PurchHeader.Next() = 0;
    end;
}