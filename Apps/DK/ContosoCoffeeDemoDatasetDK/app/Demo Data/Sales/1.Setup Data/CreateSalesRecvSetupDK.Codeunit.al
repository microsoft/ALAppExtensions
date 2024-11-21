codeunit 13734 "Create Sales Recv. Setup DK"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    begin
        UpdateSalesReceivablesSetup();
    end;

    local procedure UpdateSalesReceivablesSetup()
    var
        CreateNoSeries: Codeunit "Create No. Series";
    begin
        ValidateRecordFields(true, CreateNoSeries.PostedSalesInvoice(), CreateNoSeries.PostedSalesCreditMemo());
    end;

    local procedure ValidateRecordFields(AllowVatDifference: Boolean; PostedPrepmtInvNos: Code[20]; PostedPrepmtCrMemoNos: Code[20])
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup.Validate("Allow VAT Difference", AllowVatDifference);
        SalesReceivablesSetup.Validate("Posted Prepmt. Inv. Nos.", PostedPrepmtInvNos);
        SalesReceivablesSetup.Validate("Posted Prepmt. Cr. Memo Nos.", PostedPrepmtCrMemoNos);
        SalesReceivablesSetup.Modify(true);
    end;
}