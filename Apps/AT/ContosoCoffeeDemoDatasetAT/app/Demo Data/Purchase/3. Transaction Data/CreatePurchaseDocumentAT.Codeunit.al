codeunit 11153 "Create Purchase Document AT"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    begin
        UpdatePurchaseLine();
    end;

    local procedure UpdatePurchaseLine()
    var
        PurchaseLine: Record "Purchase Line";
        Resource: Record Resource;
    begin
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Resource);
        if PurchaseLine.FindSet() then
            repeat
                Resource.Get(PurchaseLine."No.");
                PurchaseLine.Validate("Direct Unit Cost", Resource."Direct Unit Cost");
                PurchaseLine.Modify(true);
            until PurchaseLine.Next() = 0;
    end;
}