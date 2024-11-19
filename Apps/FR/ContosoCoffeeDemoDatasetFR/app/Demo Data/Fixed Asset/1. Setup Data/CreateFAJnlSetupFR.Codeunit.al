codeunit 10893 "Create FA Jnl. Setup FR"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateFADepreciationBookFR: Codeunit "Create FA Depreciation Book FR";
        ContosoFixedAsset: Codeunit "Contoso Fixed Asset";
        CreateFAJnlTemplate: Codeunit "Create FA Jnl. Template";
        CreateFAInsTemplate: Codeunit "Create FA Ins Jnl. Template";
    begin
        ContosoFixedAsset.InsertFAJournalSetup('', CreateFADepreciationBookFR.Tax(), CreateFAJnlTemplate.Assets(), CreateFAInsTemplate.Default(), CreateFAJnlTemplate.Assets(), CreateFAInsTemplate.Default(), CreateFAInsTemplate.Insurance(), CreateFAJnlTemplate.Default());
    end;
}