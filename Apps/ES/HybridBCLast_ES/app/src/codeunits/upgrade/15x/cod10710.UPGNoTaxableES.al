codeunit 10710 "Upg No Taxable ES"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '17.0';

    trigger OnRun()
    begin
        // This code is based on app upgrade logic for APAC.
        // Matching file: .\App\Layers\ES\BaseApp\Upgrade\UPGNoTaxable.Codeunit.al
        // Based on commit: d4aef6b7b9
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnUpgradePerCompanyDataForVersion', '', false, false)]
    local procedure OnCompanyMigrationUpgrade(TargetVersion: Decimal)
    begin
        if TargetVersion <> 15.0 then
            exit;

        UpdateNoTaxableEntries();
    end;

    local procedure UpdateNoTaxableEntries()
    begin
        Codeunit.Run(Codeunit::"No Taxable - Generate Entries");
    end;
}

