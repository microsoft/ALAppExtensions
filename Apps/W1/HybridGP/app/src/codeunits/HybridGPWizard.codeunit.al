codeunit 4015 "Hybrid GP Wizard"
{
    var
        ProductIdTxt: Label 'DynamicsGP', Locked = true;
        ProductNameTxt: Label 'Dynamics GP', Locked = true;
        ReplicationCompletedServiceTypeTxt: Label 'ReplicationCompleted', Locked = true;
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", 'OnReplicationRunCompleted', '', false, false)]
    local procedure HandleInitializationofGPSynchronization(RunId: Text[50]; SubscriptionId: Text; NotificationText: Text)
    var
        HybridCompany: Record "Hybrid Company";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        JsonManagement: Codeunit "JSON Management";
        ServiceType: Text;
        SesssionID: Integer;
    begin
        if HybridCloudManagement.CanHandleNotification(SubscriptionId, ProductIdTxt) then begin
            // Do not process migration data for a diagnostic run since there should be none
            if HybridReplicationSummary.Get(RunId) and (HybridReplicationSummary.ReplicationType = HybridReplicationSummary.ReplicationType::Diagnostic) then
                exit;

            JsonManagement.InitializeObject(NotificationText);
            JsonManagement.GetStringPropertyValueByName('ServiceType', ServiceType);

            case ServiceType of
                ReplicationCompletedServiceTypeTxt:
                    begin
                        HybridCompany.SetRange(Replicate, true);
                        if HybridCompany.FindSet() then
                            repeat
                                if TaskScheduler.CanCreateTask() then
                                    TaskScheduler.CreateTask(
                                        Codeunit::"GP Cloud Migration", 0, true, HybridCompany.Name, CurrentDateTime() + 5000)
                                else
                                    Session.StartSession(SesssionID, Codeunit::"GP Cloud Migration", HybridCompany.Name)
                            until HybridCompany.Next() = 0;
                    end;
                else
                    if not TaskScheduler.CanCreateTask() then
                        TaskScheduler.CreateTask(
                            Codeunit::"Install GP SmartLists", 0, true, CompanyName(), CurrentDateTime() + 1000)
                    else
                        Session.StartSession(SesssionID, Codeunit::"Install GP SmartLists", CompanyName())
            end;
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
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        if not (IntelligentCloudSetup.Get() and CanHandle(IntelligentCloudSetup."Product ID")) then
            exit;

        Enabled := true;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Intelligent Cloud Management", 'CanRunDiagnostic', '', false, false)]
    local procedure OnCanRunDiagnostic(var CanRun: Boolean)
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        if not (IntelligentCloudSetup.Get() and CanHandle(IntelligentCloudSetup."Product ID")) then
            exit;

        CanRun := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", 'OnCanSetupAdlMigration', '', false, false)]
    local procedure OnCanSetupAdlMigration(var CanSetup: Boolean)
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        if not (IntelligentCloudSetup.Get() and CanHandle(IntelligentCloudSetup."Product ID")) then
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
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        if not (IntelligentCloudSetup.Get() and CanHandle(IntelligentCloudSetup."Product ID")) then
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
}