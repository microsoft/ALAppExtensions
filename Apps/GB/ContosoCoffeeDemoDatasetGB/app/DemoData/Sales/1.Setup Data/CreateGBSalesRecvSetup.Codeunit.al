codeunit 11495 "Create GB Sales Recv Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateSalesReceivablesSetup();
    end;

    local procedure UpdateSalesReceivablesSetup()
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        CreateNoSeries: Codeunit "Create No. Series";
    begin
        SalesReceivablesSetup.Get();

        SalesReceivablesSetup.Validate("Allow VAT Difference", true);
        SalesReceivablesSetup.Validate("Posted Prepmt. Inv. Nos.", CreateNoSeries.PostedSalesInvoice());
        SalesReceivablesSetup.Validate("Posted Prepmt. Cr. Memo Nos.", CreateNoSeries.PostedSalesCreditMemo());
        SalesReceivablesSetup.Validate("Posting Date Check on Posting", false);
        SalesReceivablesSetup.Modify(true);
    end;
}