codeunit 17137 "Create NZ Sales Recv Setup"
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
        CreateNZNoSeries: Codeunit "Create NZ No. Series";
    begin
        SalesReceivablesSetup.Get();

        SalesReceivablesSetup.Validate("Posted Tax Invoice Nos.", CreateNZNoSeries.PostedSalesTaxInvoice());
        SalesReceivablesSetup.Validate("Posted Tax Credit Memo Nos", CreateNZNoSeries.PostedSalesTaxCreditMemo());
        SalesReceivablesSetup.Validate("Copy Line Descr. to G/L Entry", true);
        SalesReceivablesSetup.Modify(true);
    end;
}