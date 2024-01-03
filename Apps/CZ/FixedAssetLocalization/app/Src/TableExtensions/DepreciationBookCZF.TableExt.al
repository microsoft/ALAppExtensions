// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.Posting;

tableextension 31246 "Depreciation Book CZF" extends "Depreciation Book"
{
    fields
    {
        field(31241; "Check Acq. Appr. bef. Dep. CZF"; Boolean)
        {
            Caption = 'Check Acqusition and Appreciation before Depreciation';
            DataClassification = CustomerContent;
        }
        field(31242; "All Acquisit. in same Year CZF"; Boolean)
        {
            Caption = 'All Acquisition in same Year';
            DataClassification = CustomerContent;
        }
        field(31243; "Check Deprec. on Disposal CZF"; Boolean)
        {
            Caption = 'Check Depreciation on Disposal';
            DataClassification = CustomerContent;
        }
        field(310244; "Deprec. from 1st Year Day CZF"; Boolean)
        {
            Caption = 'Depreciation from 1st Year Day';
            DataClassification = CustomerContent;
        }
        field(31245; "Deprec. from 1st Month Day CZF"; Boolean)
        {
            Caption = 'Depreciation from 1st Month Day';
            DataClassification = CustomerContent;
        }
        field(31250; "Corresp. G/L Entries Disp. CZF"; Boolean)
        {
            Caption = 'Corresp. G/L Entries on Disposal';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Corresp. G/L Entries Disp. CZF" then
                    TestField("Disposal Calculation Method", "Disposal Calculation Method"::Gross)
                else
                    TestField("Corresp. FA Entries Disp. CZF", false);
            end;
        }
        field(31251; "Corresp. FA Entries Disp. CZF"; Boolean)
        {
            Caption = 'Corresp. FA Entries on Disposal';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Corresp. FA Entries Disp. CZF" then
                    TestField("Corresp. G/L Entries Disp. CZF", true);
            end;
        }
    }

    trigger OnAfterInsert()
    begin
        if FAPostingTypeSetup.Get(Code, Enum::"FA Posting Type Setup Type"::Appreciation) then begin
            FAPostingTypeSetup."Include in Gain/Loss Calc." := true;
            FAPostingTypeSetup.Modify();
        end;
        if FAPostingTypeSetup.Get(Code, Enum::"FA Posting Type Setup Type"::"Write-Down") then begin
            FAPostingTypeSetup."Part of Depreciable Basis" := true;
            FAPostingTypeSetup.Modify();
        end;
        if FAPostingTypeSetup.Get(Code, Enum::"FA Posting Type Setup Type"::"Custom 1") then begin
            FAPostingTypeSetup.Init();
            FAPostingTypeSetup."Include in Gain/Loss Calc." := true;
            FAPostingTypeSetup.Sign := FAPostingTypeSetup.Sign::Credit;
            FAPostingTypeSetup.Modify();
        end;
        if FAPostingTypeSetup.Get(Code, Enum::"FA Posting Type Setup Type"::"Custom 2") then begin
            FAPostingTypeSetup.Init();
            FAPostingTypeSetup."Include in Gain/Loss Calc." := true;
            FAPostingTypeSetup."Acquisition Type" := true;
            FAPostingTypeSetup.Sign := FAPostingTypeSetup.Sign::Debit;
            FAPostingTypeSetup.Modify();
        end;
    end;
}
