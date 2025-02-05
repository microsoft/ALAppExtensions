codeunit 10497 "Create InventoryPostingSetupUS"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    var
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CreateLocation: Codeunit "Create Location";
        CreateInvPostingGroup: Codeunit "Create Inventory Posting Group";
        CreateUSGLAccounts: Codeunit "Create US GL Accounts";
    begin
        ContosoPostingSetup.SetOverwriteData(true);
        ContosoPostingSetup.InsertInventoryPostingSetup('', CreateInvPostingGroup.Resale(), CreateUSGLAccounts.FinishedGoods(), '');
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.EastLocation(), CreateInvPostingGroup.Resale(), CreateUSGLAccounts.FinishedGoods(), '');
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.MainLocation(), CreateInvPostingGroup.Resale(), CreateUSGLAccounts.FinishedGoods(), '');
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.OutLogLocation(), CreateInvPostingGroup.Resale(), CreateUSGLAccounts.FinishedGoods(), '');
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.OwnLogLocation(), CreateInvPostingGroup.Resale(), CreateUSGLAccounts.FinishedGoods(), '');
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.WestLocation(), CreateInvPostingGroup.Resale(), CreateUSGLAccounts.FinishedGoods(), '');
        ContosoPostingSetup.SetOverwriteData(false);
    end;
}