#pragma warning disable AA0247
codeunit 19011 "India Migartion Assisted Setup"
{
    var
        SetupWizardTxt: Label 'Finalize data migration';


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterAssistedSetup', '', false, false)]
    local procedure Initialize()
    var
        AssistedSetup: Codeunit "Guided Experience";
        Language: Codeunit Language;
        CurrentGlobalLanguage: Integer;
    begin
        CurrentGlobalLanguage := GlobalLanguage;

        AssistedSetup.InsertAssistedSetup(
            SetupWizardTxt,
            SetupWizardTxt,
            SetupWizardTxt,
            0,
            ObjectType::Page,
            Page::"Finalize India Migration",
            "Assisted Setup Group"::GettingStarted,
            '',
            "Video Category"::GettingStarted,
            '');


        GlobalLanguage(Language.GetDefaultApplicationLanguageId());
        AssistedSetup.AddTranslationForSetupObjectDescription(
            "Guided Experience Type"::"Assisted Setup",
            ObjectType::Page,
            Page::"Finalize India Migration",
            Language.GetDefaultApplicationLanguageId(),
            SetupWizardTxt);

        GlobalLanguage(CurrentGlobalLanguage);
    end;
}
