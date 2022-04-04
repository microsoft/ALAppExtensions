codeunit 4015 "Hybrid GP Wizard"
{
    var
        ProductIdTxt: Label 'DynamicsGP', Locked = true;
        ProductNameTxt: Label 'Dynamics GP', Locked = true;
        TooManySegmentsErr: Label 'You have selected a company that has more than 9 segments. In order to migrate your data you need to reformat your Chart of Accounts in Dynamics GP to have less than 10 segments for these companies: %1', Comment = '%1 - Comma delimited list of companies.';
        AdditionalProcessesInProgressErr: Label 'Cannot start a new migration until the previous migration run and additional/posting processes have completed.';
        ProductDescriptionTxt: Label 'Use this option if you are migrating from Dynamics GP. The migration process transforms the Dynamics GP data to the Dynamics 365 Business Central format.';

    procedure ProductId(): Text[250]
    begin
        exit(CopyStr(ProductIdTxt, 1, 250));
    end;

    procedure ProductName(): Text[250]
    begin
        exit(CopyStr(ProductNameTxt, 1, 250));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", 'OnGetHybridProductDescription', '', false, false)]
    local procedure HandleGetHybridProductDescription(ProductId: Text; var ProductDescription: Text)
    begin
        if ProductId = ProductIdTxt then
            ProductDescription := ProductDescriptionTxt;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", 'OnGetHybridProductType', '', false, false)]
    local procedure OnGetHybridProductType(var HybridProductType: Record "Hybrid Product Type")
    var
        extensionInfo: ModuleInfo;
        extensionId: Guid;
    begin
        NavApp.GetCurrentModuleInfo(extensionInfo);
        extensionId := extensionInfo.Id();
        if not HybridProductType.Get(ProductIdTxt) then begin
            HybridProductType.Init();
            HybridProductType."App ID" := extensionId;
            HybridProductType."Display Name" := CopyStr(ProductNameTxt, 1, 250);
            HybridProductType.ID := CopyStr(ProductIdTxt, 1, 250);
            HybridProductType.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", 'OnGetHybridProductName', '', false, false)]
    local procedure HandleGetHybridProductName(ProductId: Text; var ProductName: Text)
    begin
        if not CanHandle(ProductId) then
            exit;

        ProductName := ProductNameTxt;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Companies IC", 'OnBeforeCreateCompany', '', false, false)]
    local procedure HandleOnBeforeCreateCompany(ProductId: Text; var CompanyDataType: Option "Evaluation Data","Standard Data","None","Extended Data","Full No Data")
    begin
        if not CanHandle(ProductId) then
            exit;

        CompanyDataType := CompanyDataType::"Standard Data";
    end;

    [EventSubscriber(ObjectType::Page, Page::"Intelligent Cloud Management", 'CanMapCustomTables', '', false, false)]
    local procedure OnCanMapCustomTables(var Enabled: Boolean)
    begin
        if not (GetGPMigrationEnabled()) then
            exit;

        Enabled := true;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Intelligent Cloud Management", 'CanRunDiagnostic', '', false, false)]
    local procedure OnCanRunDiagnostic(var CanRun: Boolean)
    begin
        if not (GetGPMigrationEnabled()) then
            exit;

        CanRun := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", 'OnCanSetupAdlMigration', '', false, false)]
    local procedure OnCanSetupAdlMigration(var CanSetup: Boolean)
    begin
        if not (GetGPMigrationEnabled()) then
            exit;

        CanSetup := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 4001, 'OnBeforeShowProductSpecificSettingsPageStep', '', false, false)]
    local procedure BeforeShowProductSpecificSettingsPageStep(var HybridProductType: Record "Hybrid Product Type"; var ShowSettingsStep: Boolean)
    var
        HelperFunctions: Codeunit "Helper Functions";
        CompanyList: List of [Text];
        CompanyName: Text;
        MessageTxt: Text;
    begin
        if not CanHandle(HybridProductType.ID) then
            exit;

        HelperFunctions.AnyCompaniesWithTooManySegments(CompanyList);
        if CompanyList.Count() > 0 then begin
            foreach CompanyName in CompanyList do
                MessageTxt := MessageTxt + ', ' + CompanyName;

            Error(TooManySegmentsErr, MessageTxt.TrimStart(','));
        end;

        ShowSettingsStep := true;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Intelligent Cloud Management", 'CanShowUpdateReplicationCompanies', '', false, false)]
    local procedure OnCanShowUpdateReplicationCompanies(var Enabled: Boolean)
    begin
        if not (GetGPMigrationEnabled()) then
            exit;

        Enabled := false;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Intelligent Cloud Management", 'CheckAdditionalProcesses', '', false, false)]
    local procedure CheckAdditionalProcesses(var AdditionalProcessesRunning: Boolean; var ErrorMessage: Text)
    begin
        AdditionalProcessesRunning := ProcessesAreRunning();

        if AdditionalProcessesRunning then
            ErrorMessage := AdditionalProcessesInProgressErr;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Intelligent Cloud Management", 'OnResetAllCloudData', '', false, false)]
    local procedure OnResetAllCloudData()
    var
        GPCompanyMigrationSettings: Record "GP Company Migration Settings";
    begin
        GPCompanyMigrationSettings.Reset();
        if GPCompanyMigrationSettings.FindSet() then
            GPCompanyMigrationSettings.ModifyAll(ProcessesAreRunning, false);
    end;

    local procedure ProcessesAreRunning(): Boolean
    var
        GPCompanyMigrationSettings: Record "GP Company Migration Settings";
    begin
        GPCompanyMigrationSettings.Reset();
        GPCompanyMigrationSettings.SetRange(Replicate, true);
        GPCompanyMigrationSettings.SetRange(ProcessesAreRunning, true);
        if GPCompanyMigrationSettings.IsEmpty() then
            exit(false);

        exit(true);
    end;

    local procedure CanHandle(productId: Text): Boolean
    begin
        exit(productId = ProductIdTxt);
    end;

    procedure GetGPMigrationEnabled(): Boolean
    var
        InteligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        if not InteligentCloudSetup.Get() then
            exit(false);

        exit(CanHandle(InteligentCloudSetup."Product ID"));
    end;
}