codeunit 10737 "UPG ES BaseApp 17X"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '17.0';

    var
        CountryCodeTxt: Label 'ES', Locked = true;

    trigger OnRun()
    begin
        // This code is based on standard app upgrade logic.
        // Matching file: .\App\Layers\ES\BaseApp\Upgrade\UpgradeBaseApp.Codeunit.al
        // Based on commit: 656770cb
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnUpgradePerCompanyDataForVersion', '', false, false)]
    local procedure OnUpgradePerCompanyDataUpgrade(HybridReplicationSummary: Record "Hybrid Replication Summary"; CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 17.0 then
            exit;

        if CountryCode <> CountryCodeTxt then
            exit;

        UpgradeGLAccountAPIType();
    end;

    local procedure UpgradeGLAccountAPIType()
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
        GLAccount.ModifyAll("API Account Type", GLAccount."API Account Type"::Posting);

        GLAccount.Reset();
        GLAccount.SetRange("Account Type", GLAccount."Account Type"::Heading);
        GLAccount.ModifyAll("API Account Type", GLAccount."API Account Type"::Heading);
    end;
}
