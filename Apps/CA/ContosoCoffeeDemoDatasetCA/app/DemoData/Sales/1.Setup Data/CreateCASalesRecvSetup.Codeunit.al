codeunit 27062 "Create CA Sales Recv. Setup"
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

        SalesReceivablesSetup.Validate("Allow VAT Difference", true);
        SalesReceivablesSetup.Modify(true);
    end;
}
