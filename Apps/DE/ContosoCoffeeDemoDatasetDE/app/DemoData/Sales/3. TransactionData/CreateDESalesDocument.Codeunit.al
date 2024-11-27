codeunit 11112 "Create DE Sales Document"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        SalesHeader: Record "Sales Header";
        CreateCustomer: Codeunit "Create Customer";
        CreatePaymentTerms: Codeunit "Create Payment Terms";
    begin
        SalesHeader.SetFilter("Bill-to Customer No.", '%1|%2', CreateCustomer.DomesticAdatumCorporation(), CreateCustomer.EUAlpineSkiHouse());
        if SalesHeader.FindSet() then
            repeat
                SalesHeader.Validate("Payment Terms Code", CreatePaymentTerms.PaymentTermsDAYS14());
                SalesHeader.Modify(true);
            until SalesHeader.Next() = 0;
    end;
}