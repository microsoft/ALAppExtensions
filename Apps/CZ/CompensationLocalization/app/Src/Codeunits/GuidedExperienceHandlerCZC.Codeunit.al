// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

using System.Environment.Configuration;

codeunit 31275 "Guided Experience Handler CZC"
{
    Access = Internal;

    var
        GuidedExperience: Codeunit "Guided Experience";
        ManualSetupCategory: Enum "Manual Setup Category";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterManualSetup', '', false, false)]
    local procedure OnRegisterManualSetup()
    begin
        RegisterCompensationsSetup();
    end;

    local procedure RegisterCompensationsSetup()
    var
        CompensationsSetupNameTxt: Label 'Compensations Setup';
        CompensationsSetupDescriptionTxt: Label 'Set up method, numbering and posting compensation of receivables and payables.';
        CompensationsSetupKeywordsTxt: Label 'Compensations, Credits, Receivables, Payables';
    begin
        GuidedExperience.InsertManualSetup(CompensationsSetupNameTxt, CompensationsSetupNameTxt, CompensationsSetupDescriptionTxt,
          5, ObjectType::Page, Page::"Compensations Setup CZC", ManualSetupCategory::"Compensations CZC", CompensationsSetupKeywordsTxt);
    end;
}
