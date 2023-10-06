// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using System.Environment.Configuration;
using System.Globalization;
using System.Media;

codeunit 11504 "Swiss QR - Setup Mgt."
{
    var
        AssistedSetupTitleTxt: Label 'Set up QR-Bills';
        AssistedSetupShortTitleTxt: Label 'QR-Bill Setup';
        AssistedSetupDescriptionTxt: Label 'Easily generate, send, and import QR-bills. QR-bills enable easier processing and payment of received invoices from vendors. Set it up now.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterAssistedSetup', '', true, true)]
    local procedure InsertIntoAssistedSetupOnRegisterAssistedSetup()
    var
        GuidedExperience: Codeunit "Guided Experience";
        Language: Codeunit Language;
        CurrentGlobalLanguage: Integer;
    begin
        GuidedExperience.InsertAssistedSetup(AssistedSetupTitleTxt, CopyStr(AssistedSetupShortTitleTxt, 1, 50), AssistedSetupDescriptionTxt, 10, ObjectType::Page, Page::"Swiss QR-Bill Setup Wizard", "Assisted Setup Group"::FirstInvoice,
                                            '', "Video Category"::FirstInvoice, '', true);

        CurrentGlobalLanguage := GlobalLanguage();
        GlobalLanguage(Language.GetDefaultApplicationLanguageId());
        GuidedExperience.AddTranslationForSetupObjectTitle("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"Swiss QR-Bill Setup Wizard", Language.GetDefaultApplicationLanguageId(), AssistedSetupTitleTxt);
        GuidedExperience.AddTranslationForSetupObjectDescription("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"Swiss QR-Bill Setup Wizard", Language.GetDefaultApplicationLanguageId(), AssistedSetupDescriptionTxt);
        GlobalLanguage(CurrentGlobalLanguage);
    end;
}
