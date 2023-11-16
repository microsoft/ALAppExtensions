// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Setup;
using Microsoft.Utilities;
using System.Environment;
using System.Privacy;

codeunit 31242 "Data Class. Eval. Handler CZF"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Class. Eval. Data Country", 'OnAfterClassifyCountrySpecificTables', '', false, false)]
    local procedure ApplyEvaluationClassificationsForPrivacyOnAfterClassifyCountrySpecificTables()
    begin
        ApplyEvaluationClassificationsForPrivacy();
    end;

    procedure ApplyEvaluationClassificationsForPrivacy()
    var
        Company: Record Company;
        DepreciationBook: Record "Depreciation Book";
        FAAllocation: Record "FA Allocation";
        FADepreciationBook: Record "FA Depreciation Book";
        FAPostingGroup: Record "FA Posting Group";
        FASetup: Record "FA Setup";
        FixedAsset: Record "Fixed Asset";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetTableFieldsToNormal(Database::"FA Extended Posting Group CZF");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Classification Code CZF");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"FA History Entry CZF");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Tax Depreciation Group CZF");

        DataClassificationMgt.SetFieldToNormal(Database::"Depreciation Book", DepreciationBook.FieldNo("Check Acq. Appr. bef. Dep. CZF"));
        DataClassificationMgt.SetFieldToNormal(Database::"Depreciation Book", DepreciationBook.FieldNo("All Acquisit. in same Year CZF"));
        DataClassificationMgt.SetFieldToNormal(Database::"Depreciation Book", DepreciationBook.FieldNo("Check Deprec. on Disposal CZF"));
        DataClassificationMgt.SetFieldToNormal(Database::"Depreciation Book", DepreciationBook.FieldNo("Deprec. from 1st Year Day CZF"));
        DataClassificationMgt.SetFieldToNormal(Database::"Depreciation Book", DepreciationBook.FieldNo("Deprec. from 1st Month Day CZF"));
        DataClassificationMgt.SetFieldToNormal(Database::"Depreciation Book", DepreciationBook.FieldNo("Corresp. G/L Entries Disp. CZF"));
        DataClassificationMgt.SetFieldToNormal(Database::"Depreciation Book", DepreciationBook.FieldNo("Corresp. FA Entries Disp. CZF"));
        DataClassificationMgt.SetFieldToNormal(Database::"FA Allocation", FAAllocation.FieldNo("Reason/Maintenance Code CZF"));
        DataClassificationMgt.SetFieldToNormal(Database::"FA Depreciation Book", FADepreciationBook.FieldNo("Deprec. Interrupted up to CZF"));
        DataClassificationMgt.SetFieldToNormal(Database::"FA Depreciation Book", FADepreciationBook.FieldNo("Tax Deprec. Group Code CZF"));
        DataClassificationMgt.SetFieldToNormal(Database::"FA Depreciation Book", FADepreciationBook.FieldNo("Keep Deprec. Ending Date CZF"));
        DataClassificationMgt.SetFieldToNormal(Database::"FA Depreciation Book", FADepreciationBook.FieldNo("Sum. Deprec. Entries From CZF"));
        DataClassificationMgt.SetFieldToNormal(Database::"FA Depreciation Book", FADepreciationBook.FieldNo("Prorated CZF"));
        DataClassificationMgt.SetFieldToNormal(Database::"FA Posting Group", FAPostingGroup.FieldNo("Acq. Cost Bal. Acc. Disp. CZF"));
        DataClassificationMgt.SetFieldToNormal(Database::"FA Posting Group", FAPostingGroup.FieldNo("Book Value Bal. Acc. Disp. CZF"));
        DataClassificationMgt.SetFieldToNormal(Database::"FA Setup", FASetup.FieldNo("Fixed Asset History CZF"));
        DataClassificationMgt.SetFieldToNormal(Database::"FA Setup", FASetup.FieldNo("Fixed Asset History Nos. CZF"));
        DataClassificationMgt.SetFieldToNormal(Database::"FA Setup", FASetup.FieldNo("Tax Depreciation Book CZF"));
        DataClassificationMgt.SetFieldToNormal(Database::"FA Setup", FASetup.FieldNo("FA Acquisition As Custom 2 CZF"));
        DataClassificationMgt.SetFieldToNormal(Database::"Fixed Asset", FixedAsset.FieldNo("Classification Code CZF"));
        DataClassificationMgt.SetFieldToNormal(Database::"Fixed Asset", FixedAsset.FieldNo("Tax Deprec. Group Code CZF"));
    end;
}
