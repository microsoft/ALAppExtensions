codeunit 5150 "Create FA Jnl. Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        FAModuleSetup: Record "FA Module Setup";
        ContosoFixedAsset: Codeunit "Contoso Fixed Asset";
        CreateFAJnlTemplate: Codeunit "Create FA Jnl. Template";
        CreateFAInsTemplate: Codeunit "Create FA Ins Jnl. Template";
    begin
        FAModuleSetup.Get();

        ContosoFixedAsset.InsertFAJournalSetup('', FAModuleSetup."Default Depreciation Book", CreateFAJnlTemplate.Assets(), CreateFAInsTemplate.Default(), CreateFAJnlTemplate.Assets(), CreateFAInsTemplate.Default(), CreateFAInsTemplate.Insurance(), CreateFAJnlTemplate.Default());
    end;
}