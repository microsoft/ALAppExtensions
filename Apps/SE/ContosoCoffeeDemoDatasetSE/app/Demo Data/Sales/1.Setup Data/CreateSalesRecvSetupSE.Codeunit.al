codeunit 11230 "Create Sales Recv. Setup SE"
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
        SalesReceivablesSetup.Validate("Logo Position on Documents", SalesReceivablesSetup."Logo Position on Documents"::Left);
        SalesReceivablesSetup.Modify(true);
    end;
}