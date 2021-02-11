codeunit 11510 "Move Currency ISO Code"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '17.0';

    trigger OnRun()
    begin
        // This code is based on app upgrade logic for DACH.
        // Matching file: .\App\Layers\CH\BaseApp\Upgrade\ISOCodeUPGCH.Codeunit.al
        // Based on commit: d4aef6b7b9
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnUpgradePerCompanyDataForVersion', '', false, false)]
    local procedure OnCompanyMigrationUpgrade(TargetVersion: Decimal)
    begin
        if TargetVersion <> 15.0 then
            exit;

        MoveCurrencyISOCode();
    end;

    local procedure MoveCurrencyISOCode()
    var
        Currency: Record "Currency";
    begin
        with Currency do begin
            SetFilter("ISO Currency Code", '<>%1', '');
            If FindSet(true, false) then
                repeat
                    "ISO Code" := "ISO Currency Code";
                    Modify();
                until Next() = 0;
        end;
    end;
}