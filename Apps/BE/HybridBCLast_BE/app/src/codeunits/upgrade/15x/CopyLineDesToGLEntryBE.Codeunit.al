codeunit 11303 "Copy Line Des. To G/L Entry BE"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '17.0';

    trigger OnRun()
    begin
        // This code is based on app upgrade logic for BE.
        // Matching file: .\App\Layers\BE\BaseApp\Upgrade\CopyLineDescrToGLEntry.Codeunit.al
        // Based on commit: d4aef6b7b9
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnUpgradePerCompanyDataForVersion', '', false, false)]
    local procedure OnCompanyMigrationUpgrade(TargetVersion: Decimal)
    begin
        if TargetVersion <> 15.0 then
            exit;

        SetCopyLineDescrToGLEntries();
    end;

    local procedure SetCopyLineDescrToGLEntries()
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefCountry: Codeunit "Upgrade Tag Def - Country";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefCountry.GetCopyInvNoToPmtRefTag()) then
            exit;

        PurchasesPayablesSetup.SetRange("Copy Line Descr. to G/L Entry", false);
        if PurchasesPayablesSetup.FindFirst() then begin
            PurchasesPayablesSetup."Copy Line Descr. to G/L Entry" := true;
            PurchasesPayablesSetup.Modify();
        end;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefCountry.GetCopyInvNoToPmtRefTag());
    end;
}

