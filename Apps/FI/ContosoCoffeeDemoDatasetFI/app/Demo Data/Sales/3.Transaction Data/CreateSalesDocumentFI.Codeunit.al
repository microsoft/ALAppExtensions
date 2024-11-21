codeunit 13446 "Create Sales Document FI"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        SalesHeader: Record "Sales Header";
        CreateCustomer: Codeunit "Create Customer";
        CreatePaymentTerms: Codeunit "Create Payment Terms";
    begin
        SalesHeader.SetRange("Sell-to Customer No.", CreateCustomer.DomesticTreyResearch());
        if SalesHeader.FindSet() then
            repeat
                SalesHeader.Validate("Payment Terms Code", CreatePaymentTerms.PaymentTermsDAYS30());
                SalesHeader.Modify(true);
            until SalesHeader.Next() = 0;
    end;
}