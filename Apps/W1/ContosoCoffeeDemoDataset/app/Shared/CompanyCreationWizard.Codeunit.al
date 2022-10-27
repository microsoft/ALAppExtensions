codeunit 4786 "Company Creation Wizard"
{
    Permissions = tabledata "Assisted Company Setup Status" = rm;

    [EventSubscriber(ObjectType::Page, Page::"Company Creation Wizard", 'OnOpenPageCheckAdditionalDemoData', '', false, false)]
    local procedure SetAdditionalDemoDataVisible(var AdditionalDemoDataVisible: Boolean)
    begin
        AdditionalDemoDataVisible := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assisted Company Setup", 'OnAfterAssistedCompanySetupStatusEnabled', '', false, false)]
    local procedure ConfigureAdditionalDemoDataInstallation(NewCompanyName: Text[30]; InstallAdditionalDemoData: Boolean)
    begin
        if AssistedCompanySetupStatus.Get(NewCompanyName) then begin
            FeatureTelemetry.LogUptake('0000H73', ContosoCoffeeDemoDatasetFeatureNameTok, Enum::"Feature Uptake Status"::Discovered);

            AssistedCompanySetupStatus.InstallAdditionalDemoData := InstallAdditionalDemoData;
            AssistedCompanySetupStatus.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Import Config. Package Files", 'OnAfterImportConfigurationPackage', '', false, false)]
    local procedure InstallContosoDemoData()
    var
        CreateManufacturingDemoData: Codeunit "Create Manufacturing DemoData";
    begin
        if not AssistedCompanySetupStatus.Get(CompanyName()) then
            exit;

        if AssistedCompanySetupStatus.InstallAdditionalDemoData then begin
            Telemetry.LogMessage('0000H74', StrSubstNo(ContosoCoffeeDemoDatasetInitilizationTok, ContosoCoffeeDemoDatasetFeatureNameTok),
                Verbosity::Normal, DataClassification::SystemMetadata);
            CreateManufacturingDemoData.Create();
        end;
    end;

    var
        AssistedCompanySetupStatus: Record "Assisted Company Setup Status";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        Telemetry: Codeunit Telemetry;
        ContosoCoffeeDemoDatasetFeatureNameTok: Label 'ContosoCoffeeDemoDataset', Locked = true;
        ContosoCoffeeDemoDatasetInitilizationTok: Label '%1: installation initialized from Company Creation wizard', Locked = true;
}