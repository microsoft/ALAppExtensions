codeunit 10828 "Create ES Sales Document"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        SalesHeader: Record "Sales Header";
    begin
        if SalesHeader.FindSet() then
            repeat
                SalesHeader.Validate("Sell-to Customer No.");
            until SalesHeader.Next() = 0;
    end;
}