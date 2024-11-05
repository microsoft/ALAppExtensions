#pragma warning disable AS0072
codeunit 4786 "Company Creation Wizard"
{
    Permissions = tabledata "Assisted Company Setup Status" = rm;
    ObsoleteTag = '25.0';
    ObsoleteReason = 'Changing the way demo data is generated, for more infromation see https://go.microsoft.com/fwlink/?linkid=2288084';
    ObsoleteState = Pending;

    [EventSubscriber(ObjectType::Page, Page::"Company Creation Wizard", 'OnOpenPageCheckAdditionalDemoData', '', false, false)]
    local procedure SetAdditionalDemoDataVisible(var AdditionalDemoDataVisible: Boolean)
    begin
        AdditionalDemoDataVisible := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assisted Company Setup", 'OnAfterAssistedCompanySetupStatusEnabled', '', false, false)]
    local procedure ConfigureAdditionalDemoDataInstallation(NewCompanyName: Text[30]; InstallAdditionalDemoData: Boolean)
    begin
        if AssistedCompanySetupStatus.Get(NewCompanyName) then begin
            AssistedCompanySetupStatus.InstallAdditionalDemoData := InstallAdditionalDemoData;
            AssistedCompanySetupStatus.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Import Config. Package Files", 'OnAfterImportConfigurationPackage', '', false, false)]
    local procedure InstallContosoDemoData()
    var
        ContosoDemoTool: Codeunit "Contoso Demo Tool";
    begin
        if not AssistedCompanySetupStatus.Get(CompanyName()) then
            exit;

        if AssistedCompanySetupStatus.InstallAdditionalDemoData then begin
            Telemetry.LogMessage('0000H74', StrSubstNo(ContosoCoffeeDemoDatasetInitilizationTok, ContosoCoffeeDemoDatasetFeatureNameTok), Verbosity::Normal, DataClassification::SystemMetadata);
            ContosoDemoTool.CreateAllDemoData();
        end;
    end;

    var
        AssistedCompanySetupStatus: Record "Assisted Company Setup Status";
        Telemetry: Codeunit Telemetry;
        ContosoCoffeeDemoDatasetFeatureNameTok: Label 'ContosoCoffeeDemoDataset', Locked = true;
        ContosoCoffeeDemoDatasetInitilizationTok: Label '%1: installation initialized from Company Creation wizard', Locked = true;
}
#pragma warning restore AS0072