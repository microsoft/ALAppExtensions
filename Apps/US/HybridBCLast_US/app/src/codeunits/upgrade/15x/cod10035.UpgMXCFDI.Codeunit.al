codeunit 10035 "Upg. MX CFDI US"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '17.0';

    trigger OnRun()
    begin
        // This code is based on app upgrade logic for NA.
        // Matching file: .\App\Layers\NA\BaseApp\Upgrade\UPGMXCFDI.Codeunit.al
        // Based on commit: d4aef6b7b9
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnUpgradePerCompanyDataForVersion', '', false, false)]
    local procedure OnCompanyMigrationUpgrade(TargetVersion: Decimal)
    begin
        if TargetVersion <> 15.0 then
            exit;

        UpdateSATCatalogs();
        UpdateCFDIFields();
    end;

    local procedure UpdateSATCatalogs()
    begin
        Codeunit.Run(Codeunit::"Update SAT Payment Catalogs");
    end;

    local procedure UpdateCFDIFields()
    begin
        Codeunit.Run(Codeunit::"Update CFDI Fields Sales Doc");
    end;
}

