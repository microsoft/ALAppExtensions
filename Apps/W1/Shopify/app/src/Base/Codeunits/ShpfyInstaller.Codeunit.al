namespace Microsoft.Integration.Shopify;

using Microsoft.Foundation.Company;
using System.DataAdministration;
using System.Environment.Configuration;
using System.Upgrade;
using System.Visualization;

codeunit 30273 "Shpfy Installer"
{
    Subtype = Install;
    Access = Internal;
    Permissions = tabledata "Retention Policy Setup" = ri;

    trigger OnInstallAppPerCompany()
    begin
        AddRetentionPolicyAllowedTables();
        AddShopifyCueSetup();
    end;

    procedure AddRetentionPolicyAllowedTables()
    begin
        AddRetentionPolicyAllowedTables(false);
    end;

    procedure AddRetentionPolicyAllowedTables(ForceUpdate: Boolean)
    var
        LogEntry: Record "Shpfy Log Entry";
        DataCapture: Record "Shpfy Data Capture";
        RetentionPolicySetup: Codeunit "Retention Policy Setup";
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
        UpgradeTag: Codeunit "Upgrade Tag";
        IsInitialSetup: Boolean;
    begin
        IsInitialSetup := not UpgradeTag.HasUpgradeTag(GetShopifyLogEntryAddedToAllowedListUpgradeTag());
        if not (IsInitialSetup or ForceUpdate) then
            exit;

        RetenPolAllowedTables.AddAllowedTable(Database::"Shpfy Log Entry", LogEntry.FieldNo(SystemCreatedAt));
        RetenPolAllowedTables.AddAllowedTable(Database::"Shpfy Data Capture", DataCapture.FieldNo(SystemModifiedAt));

        if not IsInitialSetup then
            exit;

        CreateRetentionPolicySetup(Database::"Shpfy Log Entry", RetentionPolicySetup.FindOrCreateRetentionPeriod("Retention Period Enum"::"1 Month"));
        CreateRetentionPolicySetup(Database::"Shpfy Data Capture", RetentionPolicySetup.FindOrCreateRetentionPeriod("Retention Period Enum"::"1 Month"));
        UpgradeTag.SetUpgradeTag(GetShopifyLogEntryAddedToAllowedListUpgradeTag());
    end;

    local procedure CreateRetentionPolicySetup(TableId: Integer; RetentionPeriodCode: Code[20])
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
    begin
        if RetentionPolicySetup.Get(TableId) then
            exit;
        RetentionPolicySetup.Validate("Table Id", TableId);
        RetentionPolicySetup.Validate("Apply to all records", true);
        RetentionPolicySetup.Validate("Retention Period", RetentionPeriodCode);
        RetentionPolicySetup.Validate(Enabled, false);
        RetentionPolicySetup.Insert(true);
    end;

    procedure AddShopifyCueSetup()
    var
        ShopifyCue: Record "Shpfy Cue";
        CuesAndKPIs: Codeunit "Cues And KPIs";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetShopifyCueSetupUpgradeTag()) then
            exit;

        CuesAndKPIs.InsertData(
            Database::"Shpfy Cue",
            ShopifyCue.FieldNo("Unmapped Customers"),
            "Cues And KPIs Style"::Favorable,
            1,// Threshold 1
            "Cues And KPIs Style"::Ambiguous,
            5,// Threshold 2
            "Cues And KPIs Style"::Unfavorable);

        CuesAndKPIs.InsertData(
            Database::"Shpfy Cue",
            ShopifyCue.FieldNo("Unmapped Products"),
            "Cues And KPIs Style"::Favorable,
            1,// Threshold 1
            "Cues And KPIs Style"::Ambiguous,
            5,// Threshold 2
            "Cues And KPIs Style"::Unfavorable);

        CuesAndKPIs.InsertData(
            Database::"Shpfy Cue",
            ShopifyCue.FieldNo("Unprocessed Orders"),
            "Cues And KPIs Style"::Favorable,
            1,// Threshold 1
            "Cues And KPIs Style"::Ambiguous,
            5,// Threshold 2
            "Cues And KPIs Style"::Unfavorable);

        CuesAndKPIs.InsertData(
            Database::"Shpfy Cue",
            ShopifyCue.FieldNo("Unprocessed Shipments"),
            "Cues And KPIs Style"::Favorable,
            1,// Threshold 1
            "Cues And KPIs Style"::Ambiguous,
            5,// Threshold 2
            "Cues And KPIs Style"::Unfavorable);

        CuesAndKPIs.InsertData(
            Database::"Shpfy Cue",
            ShopifyCue.FieldNo("Synchronization Errors"),
            "Cues And KPIs Style"::Favorable,
            1,// Threshold 1
            "Cues And KPIs Style"::Ambiguous,
            5,// Threshold 2
            "Cues And KPIs Style"::Unfavorable);

        CuesAndKPIs.InsertData(
            Database::"Shpfy Cue",
            ShopifyCue.FieldNo("Shipment Errors"),
            "Cues And KPIs Style"::Favorable,
            1,// Threshold 1
            "Cues And KPIs Style"::Ambiguous,
            5,// Threshold 2
            "Cues And KPIs Style"::Unfavorable);

        CuesAndKPIs.InsertData(
            Database::"Shpfy Cue",
            ShopifyCue.FieldNo("Unprocessed Order Updates"),
            "Cues And KPIs Style"::Favorable,
            1,// Threshold 1
            "Cues And KPIs Style"::Ambiguous,
            5,// Threshold 2
            "Cues And KPIs Style"::Unfavorable);

        CuesAndKPIs.InsertData(
            Database::"Shpfy Cue",
            ShopifyCue.FieldNo("Unmapped Companies"),
            "Cues And KPIs Style"::Favorable,
            1,// Threshold 1
            "Cues And KPIs Style"::Ambiguous,
            5,// Threshold 2
            "Cues And KPIs Style"::Unfavorable);

        UpgradeTag.SetUpgradeTag(GetShopifyCueSetupUpgradeTag());
    end;

    local procedure GetShopifyCueSetupUpgradeTag(): Code[250]
    begin
        exit('MS-522567-ShopifyCueSetupAdded-20240326');
    end;

    local procedure GetShopifyLogEntryAddedToAllowedListUpgradeTag(): Code[250]
    begin
        exit('MS-474464-ShopifyLogEntryAdded-20230601');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reten. Pol. Allowed Tables", OnRefreshAllowedTables, '', false, false)]
    local procedure AddAllowedTablesOnRefreshAllowedTables()
    begin
        AddRetentionPolicyAllowedTables(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnBeforeOnRun', '', false, false)]
    local procedure AddAllowedTablesOnAfterSystemInitialization()
    begin
        AddRetentionPolicyAllowedTables();
    end;

    [EventSubscriber(ObjectType::Report, Report::"Copy Company", 'OnAfterCreatedNewCompanyByCopyCompany', '', false, false)]
    local procedure ShpfyOnAfterCreatedNewCompanyByCopyCompany(NewCompanyName: Text[30])
    var
        ShpfyShop: Record "Shpfy Shop";
    begin
        ShpfyShop.ChangeCompany(NewCompanyName);
        if ShpfyShop.FindSet() then
            repeat
                ShpfyShop.Validate(Enabled, false);
                ShpfyShop.Modify();
            until ShpfyShop.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", 'OnClearCompanyConfig', '', false, false)]
    local procedure ShpfyOnClearCompanyConfiguration(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    var
        ShpfyShop: Record "Shpfy Shop";
    begin
        if ShpfyShop.FindSet() then
            repeat
                ShpfyShop.Validate(Enabled, false);
                ShpfyShop.Modify();
            until ShpfyShop.Next() = 0;
    end;
}
