codeunit 10799 "Create ES Inv Posting Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CreateInventoryPostingGroup: Codeunit "Create Inventory Posting Group";
        CreateESGLAccounts: Codeunit "Create ES GL Accounts";
        CreateLocation: Codeunit "Create Location";
    begin
        ContosoPostingSetup.SetOverwriteData(true);
        ContosoPostingSetup.InsertInventoryPostingSetup(BlankLocationLbl, CreateInventoryPostingGroup.Resale(), CreateESGLAccounts.Goods(), CreateESGLAccounts.BillOfMaterTradeCred());
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.EastLocation(), CreateInventoryPostingGroup.Resale(), CreateESGLAccounts.Goods(), CreateESGLAccounts.BillOfMaterTradeCred());
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.MainLocation(), CreateInventoryPostingGroup.Resale(), CreateESGLAccounts.Goods(), CreateESGLAccounts.BillOfMaterTradeCred());
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.OutLogLocation(), CreateInventoryPostingGroup.Resale(), CreateESGLAccounts.Goods(), CreateESGLAccounts.GoodsTradeCred());
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.OwnLogLocation(), CreateInventoryPostingGroup.Resale(), CreateESGLAccounts.Goods(), CreateESGLAccounts.GoodsTradeCred());
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.WestLocation(), CreateInventoryPostingGroup.Resale(), CreateESGLAccounts.Goods(), CreateESGLAccounts.BillOfMaterTradeCred());
        ContosoPostingSetup.SetOverwriteData(false);
    end;

    var
        BlankLocationLbl: Label '', MaxLength = 10;
}