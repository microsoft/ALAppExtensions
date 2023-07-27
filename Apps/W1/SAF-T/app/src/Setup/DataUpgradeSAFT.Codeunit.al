codeunit 5284 "Data Upgrade SAF-T" implements DataUpgradeSAFT
{
    procedure IsDataUpgradeRequired(): Boolean
    begin
        exit(false);
    end;

    procedure GetDataUpgradeDescription(): Text
    begin
    end;

    procedure ReviewDataToUpgrade()
    begin
    end;

    procedure UpgradeData() Result: Boolean
    begin
    end;
}