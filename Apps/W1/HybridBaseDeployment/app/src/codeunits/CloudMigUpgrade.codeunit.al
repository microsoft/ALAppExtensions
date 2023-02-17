codeunit 40010 "Cloud Mig. Upgrade"
{
    Subtype = Upgrade;
    trigger OnRun()
    begin

    end;

    trigger OnUpgradePerCompany()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetSendCloudMigrationUpgradeTelemetryTag()) then
            exit;

        SendUsageTelemetry();

        UpgradeTag.SetUpgradeTag(GetSendCloudMigrationUpgradeTelemetryTag());
    end;

    local procedure SendUsageTelemetry()
    var
        IntelligentCloud: Record "Intelligent Cloud";
        HybridCompany: Record "Hybrid Company";
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        if not IntelligentCloud.Get() then
            exit;

        Clear(HybridCompany);
        FeatureTelemetry.LogUptake('0000JMQ', HybridCloudManagement.GetFeatureTelemetryName(), Enum::"Feature Uptake Status"::Used);

        TelemetryDimensions.Add('Category', HybridCloudManagement.GetTelemetryCategory());
        TelemetryDimensions.Add('NumberOfCompanies', Format(HybridCompany.Count(), 0, 9));
        TelemetryDimensions.Add('TotalMigrationSize', Format(HybridCompany.GetTotalMigrationSize(), 0, 9));
        TelemetryDimensions.Add('TotalOnPremSize', Format(HybridCompany.GetTotalOnPremSize(), 0, 9));
        IntelligentCloudSetup."Product ID" := 'Unknown';
        if IntelligentCloudSetup.Get() then;
        TelemetryDimensions.Add('Product', IntelligentCloudSetup."Product ID");
        TelemetryDimensions.Add('MigrationDateTime', Format(IntelligentCloud.SystemModifiedAt, 0, 9));
        FeatureTelemetry.LogUsage('0000JMR', HybridCloudManagement.GetFeatureTelemetryName(), 'Tenant was cloud migrated', TelemetryDimensions);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterUpgradeTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetSendCloudMigrationUpgradeTelemetryTag());
    end;

    local procedure GetSendCloudMigrationUpgradeTelemetryTag(): Text[250]
    begin
        exit('MS-456494-CloudMigrationUptake-20220130');
    end;
}