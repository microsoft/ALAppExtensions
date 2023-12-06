// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

table 31247 "Classification Code CZF"
{
    Caption = 'Classification Code';
    LookupPageID = "Classification Codes CZF";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Classification Type"; Enum "Classification Code Type CZF")
        {
            BlankZero = true;
            Caption = 'Classification Type';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(40; "Depreciation Group"; Text[10])
        {
            Caption = 'Depreciation Group';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                TaxDepreciationGroupCZF: Record "Tax Depreciation Group CZF";
            begin
                if Page.RunModal(0, TaxDepreciationGroupCZF) = Action::LookupOK then
                    Validate("Depreciation Group", TaxDepreciationGroupCZF."Depreciation Group");
            end;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
        key(Key2; "Classification Type", "Code")
        {
        }
    }
}
