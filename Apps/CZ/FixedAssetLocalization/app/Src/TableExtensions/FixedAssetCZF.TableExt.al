// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;

tableextension 31248 "Fixed Asset CZF" extends "Fixed Asset"
{
    fields
    {
        field(31243; "Tax Deprec. Group Code CZF"; Code[20])
        {
            Caption = 'Tax Depreciation Group Code';
            Editable = false;
            TableRelation = "Tax Depreciation Group CZF".Code;
            DataClassification = CustomerContent;

        }
        field(31245; "Classification Code CZF"; Code[20])
        {
            Caption = 'Clasification Code';
            TableRelation = "Classification Code CZF";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ClassificationCodeCZF: Record "Classification Code CZF";
                FADepreciationBook: Record "FA Depreciation Book";
                TaxDepreciationGroupCZF: Record "Tax Depreciation Group CZF";
                DeprecGroupMismatchMsg: Label 'The depreciation group (%1) associated with classification code %2 doesn''t correspond to depreciation group (%3) associated with tax depreciation group code %4.', Comment = '%1 = Classification Code Depreciation Group, %2 = Fixed Asset Clasification Code, %3 = Tax Depreciation Group Code, %4 = Tax Deprec. Group Code';
            begin
                if "Classification Code CZF" = '' then
                    exit;

                FADepreciationBook.SetRange("FA No.", "No.");
                FADepreciationBook.SetFilter("Tax Deprec. Group Code CZF", '<>%1', '');
                if FADepreciationBook.FindSet() then begin
                    ClassificationCodeCZF.Get("Classification Code CZF");
                    repeat
                        TaxDepreciationGroupCZF.SetRange(Code, FADepreciationBook."Tax Deprec. Group Code CZF");
                        TaxDepreciationGroupCZF.SetRange("Starting Date", 0D, WorkDate());
                        if TaxDepreciationGroupCZF.FindLast() then
                            if ClassificationCodeCZF."Depreciation Group" <> TaxDepreciationGroupCZF."Depreciation Group" then
                                Message(DeprecGroupMismatchMsg,
                                  ClassificationCodeCZF."Depreciation Group", "Classification Code CZF", TaxDepreciationGroupCZF."Depreciation Group", "Tax Deprec. Group Code CZF");
                    until FADepreciationBook.Next() = 0;
                end;
            end;
        }
    }

    keys
    {
        key(FALocationCZF; "FA Location Code", "Responsible Employee")
        {
        }
        key(ResponsibleEmployeeCZF; "Responsible Employee", "FA Location Code")
        {
        }
        key(TaxDeprecGroupCZF; "Tax Deprec. Group Code CZF")
        {
        }
    }
}
