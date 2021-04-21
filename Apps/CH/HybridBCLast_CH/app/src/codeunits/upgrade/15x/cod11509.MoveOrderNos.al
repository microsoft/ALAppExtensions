codeunit 11509 "Move Order Nos CH"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '17.0';

    trigger OnRun()
    begin
        // This code is based on app upgrade logic for DACH.
        // Matching file: .\App\Layers\DACH\BaseApp\Upgrade\UPGLocalFunctionality.al
        // Based on commit: d4aef6b7b9
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnUpgradePerCompanyDataForVersion', '', false, false)]
    local procedure OnCompanyMigrationUpgrade(TargetVersion: Decimal)
    begin
        if TargetVersion <> 15.0 then
            exit;

        LoadInventorySetup();
        LoadSourceCodeSetup();
        MoveCurrencyISOCode();
    end;

    local procedure LoadInventorySetup()
    var
        InventorySetup: Record "Inventory Setup";
    begin
        if InventorySetup.Get() then begin
            InventorySetup."Phys. Invt. Order Nos." := InventorySetup."Phys. Inv. Order Nos.";
            InventorySetup."Posted Phys. Invt. Order Nos." := InventorySetup."Posted Phys. Inv. Order Nos.";
            InventorySetup.Modify();
        end;
    end;

    local procedure LoadSourceCodeSetup()
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        if SourceCodeSetup.Get() then begin
            SourceCodeSetup."Phys. Invt. Orders" := SourceCodeSetup."Phys. Invt. Order";
            SourceCodeSetup.Modify();
        end;
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
        END;
    end;
}