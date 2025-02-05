codeunit 11614 "Create CH Sales Recev. Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateSalesReceivableSetup();
    end;

    local procedure UpdateSalesReceivableSetup()
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        if SalesReceivablesSetup.Get() then begin
            SalesReceivablesSetup.Validate("Shipment on Invoice", true);
            SalesReceivablesSetup.Modify(true);
        end;
    end;
}