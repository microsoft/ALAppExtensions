codeunit 8850 "Bank Statement File Wizard"
{
    var
        BankFileWizardTxt: Label 'Set up a bank statement file import format';
        BankFileWizardDescriptionTxt: Label 'Set up a bank statement file import format.';
        UploadDialogTitleLbl: Label 'Upload';
        UploadFilterLbl: Label 'CSV Files|%1', Comment = '%1 = File format, CSV should not be translated.';
        UploadFileFormatLbl: Label '*.csv', Locked = true;

    procedure RunBankStatementFileWizard(SkippedSyncNotification: Notification)
    var
        BankStatementFileWizard: Page "Bank Statement File Wizard";
    begin
        BankStatementFileWizard.Run();
    end;

    procedure UploadBankFile(var TempBlob: Codeunit "Temp Blob"): Text
    var
        FileManagement: Codeunit "File Management";
        FileName: Text;
        IsHandled: Boolean;
    begin
        OnBeforeUploadBankFile(FileName, TempBlob, IsHandled);
        if IsHandled then
            exit(FileName);

        exit(FileManagement.BLOBImportWithFilter(TempBlob, UploadDialogTitleLbl, '', StrSubstNo(UploadFilterLbl, UploadFileFormatLbl), UploadFileFormatLbl));
    end;

    local procedure GetAppId(): Guid
    var
        Info: ModuleInfo;
    begin
        if IsNullGuid(Info.Id()) then
            NavApp.GetCurrentModuleInfo(Info);
        exit(Info.Id());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assisted Setup", 'OnRegister', '', false, false)]
    local procedure RegisterBankStatementFileSetupWizard()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        Language: Codeunit Language;
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        CurrentGlobalLanguage: Integer;
    begin
        CurrentGlobalLanguage := GlobalLanguage();
        AssistedSetup.Add(GetAppId(), Page::"Bank Statement File Wizard", BankFileWizardTxt, AssistedSetupGroup::ReadyForBusiness, '', VideoCategory::ReadyForBusiness, '', BankFileWizardDescriptionTxt);
        GlobalLanguage(Language.GetDefaultApplicationLanguageId());
        AssistedSetup.AddTranslation(Page::"Bank Statement File Wizard", Language.GetDefaultApplicationLanguageId(), BankFileWizardTxt);
        GlobalLanguage(CurrentGlobalLanguage);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUploadBankFile(var FileName: Text; var TempBlob: Codeunit "Temp Blob"; var IsHandled: Boolean)
    begin
    end;
}