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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterAssistedSetup', '', false, false)]
    local procedure RegisterBankStatementFileSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        Language: Codeunit Language;
        CurrentGlobalLanguage: Integer;
    begin
        GuidedExperience.InsertAssistedSetup(BankFileWizardTxt, BankFileWizardTxt, BankFileWizardDescriptionTxt, 0, ObjectType::Page, Page::"Bank Statement File Wizard", "Assisted Setup Group"::ReadyForBusiness, '', "Video Category"::ReadyForBusiness, '');

        CurrentGlobalLanguage := GlobalLanguage();
        GlobalLanguage(Language.GetDefaultApplicationLanguageId());
        GuidedExperience.AddTranslationForSetupObjectTitle("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"Bank Statement File Wizard", Language.GetDefaultApplicationLanguageId(), BankFileWizardTxt);
        GuidedExperience.AddTranslationForSetupObjectDescription("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"Bank Statement File Wizard", Language.GetDefaultApplicationLanguageId(), BankFileWizardDescriptionTxt);
        GlobalLanguage(CurrentGlobalLanguage);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUploadBankFile(var FileName: Text; var TempBlob: Codeunit "Temp Blob"; var IsHandled: Boolean)
    begin
    end;
}