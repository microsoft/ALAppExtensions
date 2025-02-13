codeunit 31203 "Create Inventory Setup CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateInventorySetup();
    end;

    local procedure UpdateInventorySetup()
    var
        InventorySetup: Record "Inventory Setup";
        CreateInvtMvmtTemplCZ: Codeunit "Create Invt. Mvmt. Templ. CZ";
    begin
        InventorySetup.Get();
        InventorySetup.Validate("Def.Tmpl. for Phys.Pos.Adj CZL", CreateInvtMvmtTemplCZ.Surplus());
        InventorySetup.Validate("Def.Tmpl. for Phys.Neg.Adj CZL", CreateInvtMvmtTemplCZ.Deficiency());
        InventorySetup.Modify(true);
    end;
}