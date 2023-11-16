// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using System.Environment.Configuration;

codeunit 31024 "Guided Experience Handler CZZ"
{
    Access = Internal;

    var
        GuidedExperience: Codeunit "Guided Experience";
        ManualSetupCategory: Enum "Manual Setup Category";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterManualSetup', '', false, false)]
    local procedure OnRegisterManualSetup()
    begin
        RegisterAdvanceLetterTemplates();
    end;

    local procedure RegisterAdvanceLetterTemplates()
    var
        AdvanceLetterTemplateNameTxt: Label 'Advance Letter Templates';
        AdvanceLetterTemplateDescriptionTxt: Label 'Set up advance letter templates.';
        AdvanceLetterTemplateKeywordsTxt: Label 'Advance Letter, Template, No. Series, Posting';
    begin
        GuidedExperience.InsertManualSetup(AdvanceLetterTemplateNameTxt, AdvanceLetterTemplateNameTxt, AdvanceLetterTemplateDescriptionTxt,
          15, ObjectType::Page, Page::"Advance Letter Templates CZZ", ManualSetupCategory::"Advance Payments CZZ", AdvanceLetterTemplateKeywordsTxt);
    end;
}
