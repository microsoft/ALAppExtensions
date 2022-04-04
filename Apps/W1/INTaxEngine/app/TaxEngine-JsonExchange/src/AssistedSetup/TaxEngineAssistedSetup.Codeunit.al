codeunit 20366 "Tax Engine Assisted Setup"
{
    Permissions = tabledata "Tax Engine Notification" = rmi;

    var
        Info: ModuleInfo;
        SetupWizardTxt: Label 'Set up Tax Engine';
        TaxEngineNotificationMsg: Label 'You don''t have Tax Configurations due to which transactions will not calculate tax. but you can import it manually or from Assisted Setup.';
        TaxConfigUpgradeMsg: Label 'We have upgraded tax configurations; this includes bug fix''s or regulatory changes. we reconmmend you to upgrade it now or else it will be imported when you create documents.';
        UpgradeUseCasesNotificationMsg: Label 'We have upgraded some use cases which were modified by you. you can export these use cases and apply your changes manually.';
        UpgradeTaxTypesNotificationMsg: Label 'We have upgraded some Tax Types which were modified by you. you can export these Tax Types and apply your changes manually.';
        ImportItNowLbl: Label 'Import it now.';
        ShowUseCasesLbl: Label 'Show Modified Use Cases';
        ShowTaxTypesLbl: Label 'Show Modified Tax Types';
        DontAskAgainLbl: Label 'Don''t ask again';
        UseCaseConfigNotFoundErr: Label 'Use Case configuration does not exist for Tax Type: %1, and Case ID : %2', Comment = '%1 - Tax Type,%2 - Case ID';
        TaxTypeConfigNotFoundErr: Label 'Tax Type configuration does not exist for Tax Type: %1', Comment = '%1 - Tax Type';
        TaxConfigUpgradeNotificationLbl: Label '53d46ef5-5057-40ac-848c-6fdcb07188c4', Locked = true;
        TaxEngineNotificationLbl: Label '67173147-288c-4e51-87ba-cbd5f1a1261c', Locked = true;
        UpgradeTaxTypesNotificationLbl: Label 'a7957d72-b5c4-4c36-88dd-b23ce9184221', Locked = true;
        UpgradeUseCaseNotificationLbl: Label 'a81af8c6-f3a6-4b70-8721-4d3badd1f8b9', Locked = true;

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

    [EventSubscriber(ObjectType::Page, Page::"Tax Engine Setup Wizard", 'OnAfterFinishTaxEngineAssistedSetup', '', false, false)]
    local procedure OnAfterFinishTaxEngineAssistedSetup()
    var
        TaxEngineNotification: Record "Tax Engine Notification";
        Notification: Notification;
    begin
        TaxEngineNotification.SetRange(Hide, false);
        if TaxEngineNotification.FindSet() then
            repeat
                Notification.Id := TaxEngineNotification.Id;

                case TaxEngineNotification.Id of
                    TaxConfigUpgradeNotificationLbl, TaxEngineNotificationLbl:
                        RecallNotification(Notification);
                end;
            until TaxEngineNotification.Next() = 0;
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
        TaxJsonDeserialization.SkipVersionCheck(true);
        TaxJsonDeserialization.ImportUseCases(JsonText);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Use Case Execution", 'OnUpdateUseCaseRecord', '', false, false)]
    local procedure OnUpdateUseCaseRecord(TaxType: Code[20]; CaseID: Guid; MajorVersion: Integer; var UseCaseUpdated: Boolean)
    var
        TaxJsonDeserialization: Codeunit "Tax Json Deserialization";
        JsonText: Text;
    begin
        OnGetUpdatedUseCaseConfig(TaxType, CaseID, MajorVersion, JsonText, UseCaseUpdated);
        if not UseCaseUpdated then
            exit;

        TaxJsonDeserialization.HideDialog(true);
        TaxJsonDeserialization.SkipUseCaseIndentation(true);
        TaxJsonDeserialization.SkipVersionCheck(true);
        TaxJsonDeserialization.ImportUseCases(JsonText);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Use Case Execution", 'OnUpdateTaxTypeRecord', '', false, false)]
    local procedure OnUpdateTaxTypeRecord(TaxType: Code[20]; MajorVersion: Integer; var TaxTypeUpdated: Boolean)
    var
        TaxJsonDeserialization: Codeunit "Tax Json Deserialization";
        JsonText: Text;
    begin
        OnGetUpdatedTaxTypeConfig(TaxType, MajorVersion, JsonText, TaxTypeUpdated);
        if not TaxTypeUpdated then
            exit;

        TaxJsonDeserialization.HideDialog(true);
        TaxJsonDeserialization.SkipVersionCheck(true);
        TaxJsonDeserialization.ImportTaxTypes(JsonText);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterAssistedSetup', '', false, false)]
    local procedure Initialize()
    var
        GuidedExperience: Codeunit "Guided Experience";
        Language: Codeunit Language;
        GuidedExperienceType: Enum "Guided Experience Type";
        CurrentGlobalLanguage: Integer;
    begin
        CurrentGlobalLanguage := GlobalLanguage;

        GuidedExperience.InsertAssistedSetup(
            SetupWizardTxt, CopyStr(SetupWizardTxt, 1, 50), '', 5, ObjectType::Page,
            Page::"Tax Engine Setup Wizard", "Assisted Setup Group"::GettingStarted,
            '', "Video Category"::GettingStarted, '');

        GlobalLanguage(Language.GetDefaultApplicationLanguageId());
        GuidedExperience.AddTranslationForSetupObjectTitle(GuidedExperienceType::"Assisted Setup", ObjectType::Page,
            Page::"Tax Engine Setup Wizard", Language.GetDefaultApplicationLanguageId(), SetupWizardTxt);
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

        ShowNotifications();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Tax Types", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenTaxTypes()
    begin
        SendNotificationForEmptyTaxConfig();
    end;

    procedure SendNotificationForconfigUpgrade()
    begin
        InsertNotification(TaxConfigUpgradeNotificationLbl, TaxConfigUpgradeMsg);
    end;

    procedure PushTaxEngineNotifications()
    begin
        ResetTaxEngineAssistedSetup();
        SendNotificationForEmptyTaxConfig();
        SendNotificationForUpgradeTaxTypes();
        SendNotificationForUpgradeUseCases();
    end;

    local procedure ResetTaxEngineAssistedSetup()
    var
        GuidedExpericence: Codeunit "Guided Experience";
    begin
        if GuidedExpericence.IsAssistedSetupComplete(ObjectType::Page, Page::"Tax Engine Setup Wizard") then
            GuidedExpericence.ResetAssistedSetup(ObjectType::Page, Page::"Tax Engine Setup Wizard");
    end;

    local procedure InsertNotification(Id: Guid; MessageTxt: Text[250])
    var
        TaxEngineNotification: Record "Tax Engine Notification";
    begin
        if TaxEngineNotification.Get(Id) then begin
            TaxEngineNotification.Hide := false;
            TaxEngineNotification.Modify();
        end else begin
            TaxEngineNotification.Id := Id;
            TaxEngineNotification.Message := MessageTxt;
            TaxEngineNotification.Insert();
        end;
    end;

    local procedure ShowNotifications()
    var
        TaxEngineNotification: Record "Tax Engine Notification";
        Notification: Notification;
    begin
        TaxEngineNotification.SetRange(Hide, false);
        if TaxEngineNotification.FindSet() then
            repeat
                Notification.Id := TaxEngineNotification.Id;
                Notification.Scope := Notification.Scope::LocalScope;
                Notification.Message(TaxEngineNotification.Message);

                case TaxEngineNotification.Id of
                    TaxConfigUpgradeNotificationLbl, TaxEngineNotificationLbl:
                        begin
                            Notification.AddAction(ImportItNowLbl, Codeunit::"Tax Engine Assisted Setup", 'RunTaxEngineAssitedSetup');
                            Notification.AddAction(DontAskAgainLbl, Codeunit::"Tax Engine Assisted Setup", 'DoNotShowNotification');
                        end;
                    UpgradeTaxTypesNotificationLbl:
                        begin
                            Notification.AddAction(ShowTaxTypesLbl, Codeunit::"Tax Engine Assisted Setup", 'ShowModifiedTaxTypes');
                            Notification.AddAction(DontAskAgainLbl, Codeunit::"Tax Engine Assisted Setup", 'CompleteTaxTypeConfigUpgrade');
                        end;
                    UpgradeUseCaseNotificationLbl:
                        begin
                            Notification.AddAction(ShowUseCasesLbl, Codeunit::"Tax Engine Assisted Setup", 'ShowModifiedUseCases');
                            Notification.AddAction(DontAskAgainLbl, Codeunit::"Tax Engine Assisted Setup", 'CompleteTaxConfigUpgrade');
                        end;
                end;

                Notification.Send();
            until TaxEngineNotification.Next() = 0;
    end;

    procedure SendNotificationForEmptyTaxConfig()
    var
        TaxType: Record "Tax Type";
        GuidedExperience: Codeunit "Guided Experience";
        ShowUpgradeNotification: Boolean;
    begin
        if GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, Page::"Tax Engine Setup Wizard") then
            exit;

        if not TaxType.IsEmpty() then begin
            OnBeforeShowTaxConfigUpgradedNotification(ShowUpgradeNotification);

            if ShowUpgradeNotification then
                SendNotificationForconfigUpgrade();

            exit;
        end;

        InsertNotification(TaxEngineNotificationLbl, TaxEngineNotificationMsg);
    end;

    procedure SendNotificationForUpgradeUseCases()
    var
        TaxType: Record "Tax Type";
        UpgradedUseCases: Record "Upgraded Use Cases";
    begin
        if TaxType.IsEmpty() then
            exit;

        if UpgradedUseCases.IsEmpty() then
            exit;

        InsertNotification(UpgradeUseCaseNotificationLbl, UpgradeUseCasesNotificationMsg);
    end;

    procedure SendNotificationForUpgradeTaxTypes()
    var
        TaxType: Record "Tax Type";
        UpgradedTaxTypes: Record "Upgraded Tax Types";
    begin
        if TaxType.IsEmpty() then
            exit;

        if UpgradedTaxTypes.IsEmpty() then
            exit;

        InsertNotification(UpgradeTaxTypesNotificationLbl, UpgradeTaxTypesNotificationMsg);
    end;

    procedure RunTaxEngineAssitedSetup(TaxConfigNotification: Notification)
    var
        TaxEngineSetupWizard: page "Tax Engine Setup Wizard";
    begin
        TaxEngineSetupWizard.Run();
    end;

    procedure DoNotShowNotification(TaxConfigNotification: Notification)
    begin
        RecallNotification(TaxConfigNotification);
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

        RecallNotification(TaxConfigNotification);
    end;

    procedure CompleteTaxTypeConfigUpgrade(TaxConfigNotification: Notification)
    var
        UpgradedTaxTypes: Record "Upgraded Tax Types";
    begin
        if not UpgradedTaxTypes.IsEmpty() then
            UpgradedTaxTypes.DeleteAll();

        RecallNotification(TaxConfigNotification);
    end;

    local procedure RecallNotification(TaxConfigNotification: Notification)
    var
        TaxEngineNotification: Record "Tax Engine Notification";
    begin
        TaxEngineNotification.Get(TaxConfigNotification.Id);
        TaxEngineNotification.Hide := true;
        TaxEngineNotification.Modify();
        TaxConfigNotification.Recall();
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

    [IntegrationEvent(false, false)]
    local procedure OnGetUpdatedUseCaseConfig(TaxType: Code[20]; CaseID: Guid; MajorVersion: Integer; var ConfigText: Text; var UseCaseUpdated: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetUpdatedTaxTypeConfig(TaxType: Code[20]; MajorVersion: Integer; var ConfigText: Text; var TaxTypeUpdated: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowTaxConfigUpgradedNotification(var ShowUpgradeNotification: Boolean)
    begin
    end;
}