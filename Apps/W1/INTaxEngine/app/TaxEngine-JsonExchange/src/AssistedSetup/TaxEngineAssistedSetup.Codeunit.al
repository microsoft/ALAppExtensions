codeunit 20366 "Tax Engine Assisted Setup"
{
    var
        Info: ModuleInfo;
        SetupWizardTxt: Label 'Set up Tax Engine';
        TaxEngineNotificationMsg: Label 'You don''t have Tax Configurations due to which transactions will not calculate tax. but you can import it manually or from Assisted Setup.';
        UpgradeUseCasesNotificationMsg: Label 'We have upgraded some use cases which were modified by you. you can export these use cases and apply your changes manually.';
        UpgradeTaxTypesNotificationMsg: Label 'We have upgraded some Tax Types which were modified by you. you can export these Tax Types and apply your changes manually.';
        ImportFromWizardLbl: Label 'Import From Wizard';
        ShowUseCasesLbl: Label 'Show Modified Use Cases';
        ShowTaxTypesLbl: Label 'Show Modified Tax Types';
        DontAskAgainLbl: Label 'Don''t ask again';
        UseCaseConfigNotFoundErr: Label 'Use Case configuration does not exist for Tax Type: %1, and Case ID : %2', Comment = '%1 - Tax Type,%2 - Case ID';
        TaxTypeConfigNotFoundErr: Label 'Tax Type configuration does not exist for Tax Type: %1', Comment = '%1 - Tax Type';

    procedure SetupTaxEngine()
    begin
        OnSetupTaxPeriod();
        OnSetupTaxTypes();
        OnSetupUseCaseTree();
    end;

    procedure SetupTaxEngineWithUseCases()
    var
        UseCaseMgmt: Codeunit "Use Case Mgmt.";
        EmptyGuid: Guid;
        PresentationOrder: Integer;
    begin
        OnSetupTaxPeriod();
        OnSetupTaxTypes();
        OnSetupUseCases();
        UseCaseMgmt.IndentUseCases(EmptyGuid, PresentationOrder);
        OnSetupUseCaseTree();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Use Case Execution", 'OnImportUseCaseOnDemand', '', false, false)]
    local procedure OnImportUseCaseOnDemand(TaxType: Code[20]; CaseID: Guid)
    var
        TaxJsonDeserialization: Codeunit "Tax Json Deserialization";
        JsonText: Text;
        IsHandled: Boolean;
    begin
        OnGetUseCaseConfig(TaxType, CaseID, JsonText, IsHandled);
        if not IsHandled then
            Error(UseCaseConfigNotFoundErr, TaxType, CaseID);

        TaxJsonDeserialization.HideDialog(true);
        TaxJsonDeserialization.SkipUseCaseIndentation(true);
        TaxJsonDeserialization.ImportUseCases(JsonText);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assisted Setup", 'OnRegister', '', false, false)]
    local procedure Initialize()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        Language: Codeunit Language;
        CurrentGlobalLanguage: Integer;
    begin
        CurrentGlobalLanguage := GlobalLanguage;

        AssistedSetup.Add(
            GetAppId(),
            Page::"Tax Engine Setup Wizard",
            SetupWizardTxt,
            "Assisted Setup Group"::GettingStarted,
            '',
            "Video Category"::GettingStarted,
            '');

        GlobalLanguage(Language.GetDefaultApplicationLanguageId());
        AssistedSetup.AddTranslation(Page::"Tax Engine Setup Wizard", Language.GetDefaultApplicationLanguageId(), SetupWizardTxt);
        GlobalLanguage(CurrentGlobalLanguage);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Import Config. Package Files", 'OnBeforeImportConfigurationFile', '', false, false)]
    local procedure OnBeforeImportConfigurationFile()
    var
        TaxType: Record "Tax Type";
    begin
        if TaxType.IsEmpty() then
            SetupTaxEngineWithUseCases();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Role Center Notification Mgt.", 'OnBeforeShowNotifications', '', false, false)]
    local procedure OnBeforeShowNotifications()
    begin
        if not GuiAllowed then
            exit;

        SendNotificationForEmptyTaxConfig();
        SendNotificationForUpgradeTaxTypes();
        SendNotificationForUpgradeUseCases();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Tax Types", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenTaxTypes()
    begin
        SendNotificationForEmptyTaxConfig();
    end;

    procedure SendNotificationForEmptyTaxConfig()
    var
        TaxType: Record "Tax Type";
        AssistedSetup: Codeunit "Assisted Setup";
        TaxConfigNotification: Notification;
        TaxEngineNotificationLbl: Label '67173147-288c-4e51-87ba-cbd5f1a1261c';
    begin
        if AssistedSetup.IsComplete(page::"Tax Engine Setup Wizard") then
            exit;

        if not TaxType.IsEmpty() then
            exit;

        TaxConfigNotification.Id := TaxEngineNotificationLbl;
        TaxConfigNotification.Scope := NotificationScope::LocalScope;
        TaxConfigNotification.Message(TaxEngineNotificationMsg);
        TaxConfigNotification.AddAction(ImportFromWizardLbl, Codeunit::"Tax Engine Assisted Setup", 'RunTaxEngineAssitedSetup');
        TaxConfigNotification.AddAction(DontAskAgainLbl, Codeunit::"Tax Engine Assisted Setup", 'CompleteTaxEngineAssitedSetup');
        TaxConfigNotification.Send();
    end;

    procedure SendNotificationForUpgradeUseCases()
    var
        TaxType: Record "Tax Type";
        UpgradedUseCases: Record "Upgraded Use Cases";
        UpgradeTaxConfigNotification: Notification;
        UpgradeUseCaseNotificationLbl: Label 'a81af8c6-f3a6-4b70-8721-4d3badd1f8b9';
    begin
        if TaxType.IsEmpty() then
            exit;

        if UpgradedUseCases.IsEmpty() then
            exit;

        UpgradeTaxConfigNotification.Id := UpgradeUseCaseNotificationLbl;
        UpgradeTaxConfigNotification.Scope := NotificationScope::LocalScope;
        UpgradeTaxConfigNotification.Message(UpgradeUseCasesNotificationMsg);
        UpgradeTaxConfigNotification.AddAction(ShowUseCasesLbl, Codeunit::"Tax Engine Assisted Setup", 'ShowModifiedUseCases');
        UpgradeTaxConfigNotification.AddAction(DontAskAgainLbl, Codeunit::"Tax Engine Assisted Setup", 'CompleteTaxConfigUpgrade');
        UpgradeTaxConfigNotification.Send();
    end;

    procedure SendNotificationForUpgradeTaxTypes()
    var
        TaxType: Record "Tax Type";
        UpgradedTaxTypes: Record "Upgraded Tax Types";
        UpgradeTaxConfigNotification: Notification;
        UpgradeTaxTypesNotificationLbl: Label 'a7957d72-b5c4-4c36-88dd-b23ce9184221';
    begin
        if TaxType.IsEmpty() then
            exit;

        if UpgradedTaxTypes.IsEmpty() then
            exit;

        UpgradeTaxConfigNotification.Id := UpgradeTaxTypesNotificationLbl;
        UpgradeTaxConfigNotification.Scope := NotificationScope::LocalScope;
        UpgradeTaxConfigNotification.Message(UpgradeTaxTypesNotificationMsg);
        UpgradeTaxConfigNotification.AddAction(ShowTaxTypesLbl, Codeunit::"Tax Engine Assisted Setup", 'ShowModifiedTaxTypes');
        UpgradeTaxConfigNotification.AddAction(DontAskAgainLbl, Codeunit::"Tax Engine Assisted Setup", 'CompleteTaxTypeConfigUpgrade');
        UpgradeTaxConfigNotification.Send();
    end;

    procedure RunTaxEngineAssitedSetup(TaxConfigNotification: Notification)
    var
        TaxEngineSetupWizard: page "Tax Engine Setup Wizard";
    begin
        TaxEngineSetupWizard.Run();
    end;

    procedure CompleteTaxEngineAssitedSetup(TaxConfigNotification: Notification)
    var
        AssistedSetup: Codeunit "Assisted Setup";
    begin
        AssistedSetup.Complete(page::"Tax Engine Setup Wizard");
    end;

    procedure ShowModifiedUseCases(TaxConfigNotification: Notification)
    var
        TaxJsonSingleInstance: Codeunit "Tax Json Single Instance";
    begin
        TaxJsonSingleInstance.SetHideDialog(true);
        TaxJsonSingleInstance.OpenReplcedTaxUseCases();
    end;

    procedure ShowModifiedTaxTypes(TaxConfigNotification: Notification)
    var
        TaxJsonSingleInstance: Codeunit "Tax Json Single Instance";
    begin
        TaxJsonSingleInstance.SetHideDialog(true);
        TaxJsonSingleInstance.OpenReplacedTaxTypes();
    end;

    procedure CompleteTaxConfigUpgrade(TaxConfigNotification: Notification)
    var
        UpgradedUseCases: Record "Upgraded Use Cases";
    begin
        if not UpgradedUseCases.IsEmpty() then
            UpgradedUseCases.DeleteAll();
    end;

    procedure CompleteTaxTypeConfigUpgrade(TaxConfigNotification: Notification)
    var
        UpgradedTaxTypes: Record "Upgraded Tax Types";
    begin
        if not UpgradedTaxTypes.IsEmpty() then
            UpgradedTaxTypes.DeleteAll();
    end;

    local procedure GetAppId(): Guid
    var
        EmptyGuid: Guid;
    begin
        if Info.Id() = EmptyGuid then
            NavApp.GetCurrentModuleInfo(Info);
        exit(Info.Id());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnImportTaxTypeFromLibrary', '', false, false)]
    local procedure ImportTaxTypeFromLibrary(TaxType: Code[20])
    var
        TaxJsonDeserialization: Codeunit "Tax Json Deserialization";
        JsonText: Text;
        IsHandled: Boolean;
    begin
        OnGetTaxTypeConfig(TaxType, JsonText, IsHandled);
        if not IsHandled then
            Error(TaxTypeConfigNotFoundErr, TaxType);

        TaxJsonDeserialization.HideDialog(true);
        TaxJsonDeserialization.ImportTaxTypes(JsonText);
    end;

    [BusinessEvent(false)]
    local procedure OnSetupTaxPeriod()
    begin
    end;

    [BusinessEvent(false)]
    local procedure OnSetupTaxTypes()
    begin
    end;

    [BusinessEvent(false)]
    local procedure OnSetupUseCases()
    begin
    end;

    [BusinessEvent(false)]
    local procedure OnSetupUseCaseTree()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetUseCaseConfig(TaxType: Code[20]; CaseID: Guid; var ConfigText: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetTaxTypeConfig(TaxType: Code[20]; var ConfigText: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnImportTaxTypeFromLibrary(TaxType: Code[20])
    begin
    end;
}