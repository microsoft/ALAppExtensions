codeunit 19033 "Create IN Sales Rcvble Setup"
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
    begin
        SalesReceivablesSetup.Get();

        SalesReceivablesSetup.Validate("GST Dependency Type", Enum::"GST Dependency Type"::"Bill-to Address");
        SalesReceivablesSetup.Modify(true);
    end;
}