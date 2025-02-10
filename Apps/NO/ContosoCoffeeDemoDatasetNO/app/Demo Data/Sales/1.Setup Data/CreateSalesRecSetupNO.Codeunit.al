codeunit 10719 "Create Sales Rec. Setup NO"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateVatPostingGroupsNO: Codeunit "Create Vat Posting Groups NO";
    begin
        UpdateSaleReceivableSetup(CreateVatPostingGroupsNO.CUSTHIGH());
    end;

    local procedure UpdateSaleReceivableSetup(VATBusPostingGrPrice: Code[20])
    var
        SalesReceivableSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivableSetup.Get();
        SalesReceivableSetup.Validate("VAT Bus. Posting Gr. (Price)", VATBusPostingGrPrice);
        SalesReceivableSetup.Modify(true);
    end;
}