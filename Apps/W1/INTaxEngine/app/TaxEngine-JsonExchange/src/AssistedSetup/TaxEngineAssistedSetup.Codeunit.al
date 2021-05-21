codeunit 20366 "Tax Engine Assisted Setup"
{
    var
        Info: ModuleInfo;
        SetupWizardTxt: Label 'Set up Tax Engine';
        TaxEngineNotificationMsg: Label 'You don''t have Tax Configurations due to which transactions will not calculate tax. but you can import it manually or from Assisted Setup.';
        ImportFromWizardLbl: Label 'Import From Wizard';
        DontAskAgainLbl: Label 'Don''t ask again';

    procedure SetupTaxEngine()
    begin
        OnSetupTaxPeriod();
        OnSetupTaxTypes();
        OnSetupUseCases();
        OnSetupUseCaseTree();
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
    begin
        SetupTaxEngine();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Role Center Notification Mgt.", 'OnBeforeShowNotifications', '', false, false)]
    local procedure OnBeforeShowNotifications()
    begin
        SendNotificationForEmptyTaxConfig();
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

    local procedure GetAppId(): Guid
    var
        EmptyGuid: Guid;
    begin
        if Info.Id() = EmptyGuid then
            NavApp.GetCurrentModuleInfo(Info);
        exit(Info.Id());
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
}