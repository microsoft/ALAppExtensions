codeunit 11386 "Create Sales Rec. Setup BE"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateGenJnlTemplateBE: Codeunit "Create Gen. Jnl Template BE";
    begin
        UpdateSaleReceivableSetup(CreateGenJnlTemplateBE.Sales(), CreateGenJnlTemplateBE.SalesCreditMemo());
    end;

    local procedure UpdateSaleReceivableSetup(SalesInvoiceTemplate: Code[10]; SalesInvCrMemoTemplate: Code[10])
    var
        SalesReceivableSetup: Record "Sales & Receivables Setup";
    begin
        if SalesReceivableSetup.Get() then begin
            SalesReceivableSetup.Validate("S. Invoice Template Name", SalesInvoiceTemplate);
            SalesReceivableSetup.Validate("S. Cr. Memo Template Name", SalesInvCrMemoTemplate);
            SalesReceivableSetup.Validate("S. Prep. Inv. Template Name", SalesInvoiceTemplate);
            SalesReceivableSetup.Validate("S. Prep. Cr.Memo Template Name", SalesInvCrMemoTemplate);
            SalesReceivableSetup.Modify(true);
        end;
    end;
}