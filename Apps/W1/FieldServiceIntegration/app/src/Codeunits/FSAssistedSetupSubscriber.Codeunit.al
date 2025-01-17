// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using System.Environment.Configuration;
using System.Globalization;
using System.Media;
using Microsoft.Integration.D365Sales;

codeunit 6613 "FS Assisted Setup Subscriber"
{
    var
        CRMConnectionSetupTitleTxt: Label 'Set up an integration to %1', Comment = '%1 = CRM product name';
        CRMConnectionSetupShortTitleTxt: Label 'Connect to %1', Comment = '%1 = CRM product name', MaxLength = 32;
        FSConnectionSetupHelpTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2270903', Locked = true;
        CRMConnectionSetupDescriptionTxt: Label 'Connect your Dynamics 365 services for better insights. Data is exchanged between the apps for better productivity.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterAssistedSetup', '', false, false)]
    local procedure RegisterFSAssistedSetup()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if not ApplicationAreaMgmtFacade.IsBasicOnlyEnabled() then
            RegisterAssistedSetup();
    end;

    internal procedure RegisterAssistedSetup()
    var
        GuidedExperience: Codeunit "Guided Experience";
        Language: Codeunit Language;
        CRMProductName: Codeunit "CRM Product Name";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        GuidedExperienceType: Enum "Guided Experience Type";
        CurrentGlobalLanguage: Integer;
    begin
        CurrentGlobalLanguage := GlobalLanguage;
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"FS Connection Setup Wizard") then begin
            GuidedExperience.InsertAssistedSetup(StrSubstNo(CRMConnectionSetupTitleTxt, CRMProductName.FSServiceName()),
                StrSubstNo(CRMConnectionSetupShortTitleTxt, CRMProductName.FSServiceName()), CRMConnectionSetupDescriptionTxt, 10, ObjectType::Page,
                Page::"FS Connection Setup Wizard", AssistedSetupGroup::Connect, '', VideoCategory::Connect, FSConnectionSetupHelpTxt);
            GlobalLanguage(Language.GetDefaultApplicationLanguageId());
            GuidedExperience.AddTranslationForSetupObjectTitle(GuidedExperienceType::"Assisted Setup", ObjectType::Page,
                Page::"FS Connection Setup Wizard", Language.GetDefaultApplicationLanguageId(), StrSubstNo(CRMConnectionSetupTitleTxt, CRMProductName.FSServiceName()));
            GlobalLanguage(CurrentGlobalLanguage);
        end;
    end;
}