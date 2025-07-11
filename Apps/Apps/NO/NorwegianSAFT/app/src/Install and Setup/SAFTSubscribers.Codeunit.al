// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using System.Environment.Configuration;
using System.Globalization;
using System.Media;

codeunit 10682 "SAF-T Subscribers"
{
    var
        SAFTSetupTitleTxt: Label 'Set up SAF-T reporting';
        SAFTSetupShortTitleTxt: Label 'SAF-T Reporting';
        SAFTSetupDescriptionTxt: Label 'With a few steps, you can set up Business Central for reporting SAF-T that is required by the Norwegian authorities.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterAssistedSetup', '', true, true)]
    local procedure InsertIntoAssistedSetupOnRegisterAssistedSetup()
    var
        GuidedExperience: Codeunit "Guided Experience";
        Language: Codeunit Language;
        CurrentGlobalLanguage: Integer;
    begin
        GuidedExperience.InsertAssistedSetup(SAFTSetupTitleTxt, CopyStr(SAFTSetupShortTitleTxt, 1, 50), SAFTSetupDescriptionTxt, 15, ObjectType::Page, Page::"SAF-T Setup Wizard", "Assisted Setup Group"::ReadyForBusiness,
                                            '', "Video Category"::ReadyForBusiness, '', true);

        CurrentGlobalLanguage := GlobalLanguage();
        GlobalLanguage(Language.GetDefaultApplicationLanguageId());
        GuidedExperience.AddTranslationForSetupObjectTitle("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"SAF-T Setup Wizard", Language.GetDefaultApplicationLanguageId(), SAFTSetupTitleTxt);
        GuidedExperience.AddTranslationForSetupObjectDescription("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"SAF-T Setup Wizard", Language.GetDefaultApplicationLanguageId(), SAFTSetupDescriptionTxt);
        GlobalLanguage(CurrentGlobalLanguage);
    end;
}
