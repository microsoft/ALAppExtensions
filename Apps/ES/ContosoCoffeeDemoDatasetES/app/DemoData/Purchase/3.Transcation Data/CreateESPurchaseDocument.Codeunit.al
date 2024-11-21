codeunit 10814 "Create ES Purchase Document"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        PurchHeader: Record "Purchase Header";
    begin
        if PurchHeader.FindSet() then
            repeat
                PurchHeader.Validate("Buy-from Vendor No.");
            until PurchHeader.Next() = 0;
    end;
}