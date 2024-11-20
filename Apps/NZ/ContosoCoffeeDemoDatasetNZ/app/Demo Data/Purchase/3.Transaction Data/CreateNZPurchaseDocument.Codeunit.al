codeunit 17136 "Create NZ Purchase Document"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreatePaymentTerms: Codeunit "Create Payment Terms";
    begin
        UpdatePaymentTermsOnPurchaseHeader(CreatePaymentTerms.PaymentTermsDAYS30());
    end;

    local procedure UpdatePaymentTermsOnPurchaseHeader(PaymentTermsCode: Code[10]);
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        if PurchaseHeader.FindSet() then
            repeat
                PurchaseHeader.Validate("Payment Terms Code", PaymentTermsCode);
                PurchaseHeader.Modify(true);
            until PurchaseHeader.Next() = 0;
    end;
}