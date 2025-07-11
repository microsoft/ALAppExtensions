// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using System.Environment.Configuration;

codeunit 31244 "Guided Experience Handler CZF"
{
    Access = Internal;

    var
        GuidedExperience: Codeunit "Guided Experience";
        ManualSetupCategory: Enum "Manual Setup Category";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterManualSetup', '', false, false)]
    local procedure OnRegisterManualSetup()
    begin
        RegisterDepreciationGroup();
        RegisterClassificationCode();
    end;

    local procedure RegisterDepreciationGroup()
    var
        DepreciationGroupNameTxt: Label 'Tax Depreciation Groups';
        DepreciationGroupDescriptionTxt: Label 'Set up Tax Depreciation Groups for Fixes Assets. These groups determine minimal depreciation periods and parameters used for calculating tax depreciation.';
        DepreciationGroupKeywordsTxt: Label 'FA, Fixed Assets, Tax Depreciations';
    begin
        GuidedExperience.InsertManualSetup(DepreciationGroupNameTxt, DepreciationGroupNameTxt, DepreciationGroupDescriptionTxt,
          20, ObjectType::Page, Page::"Tax Depreciation Groups CZF", ManualSetupCategory::"Fixed Assets", DepreciationGroupKeywordsTxt);
    end;

    local procedure RegisterClassificationCode()
    var
        ClassificationCodeNameTxt: Label 'Classification Codes';
        ClassificationCodeDescriptionTxt: Label 'Set up Classification Codes for Fixed Assets. Production Classification marked CZ-CPA, Classification building operations marked CZ-CC else DNM).';
        ClassificationCodeKeywordsTxt: Label 'FA, Fixed Assets, Classification';
    begin
        GuidedExperience.InsertManualSetup(ClassificationCodeNameTxt, ClassificationCodeNameTxt, ClassificationCodeDescriptionTxt,
          10, ObjectType::Page, Page::"Classification Codes CZF", ManualSetupCategory::"Fixed Assets", ClassificationCodeKeywordsTxt);
    end;
}
