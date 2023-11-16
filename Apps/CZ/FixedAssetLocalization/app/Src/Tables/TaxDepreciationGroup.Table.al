// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

table 31249 "Tax Depreciation Group CZF"
{
    Caption = 'Tax Depreciation Group';
    LookupPageID = "Tax Depreciation Groups CZF";

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(12; "Depreciation Group"; Text[10])
        {
            Caption = 'Depreciation Group';
            DataClassification = CustomerContent;
        }
        field(15; "Depreciation Type"; Enum "Tax Depreciation Type CZF")
        {
            Caption = 'Depreciation Type';
            DataClassification = CustomerContent;
        }
        field(21; "No. of Depreciation Years"; Integer)
        {
            Caption = 'No. of Depreciation Years';
            BlankZero = true;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "No. of Depreciation Months" := Round("No. of Depreciation Years" * 12, 0.00000001);
            end;
        }
        field(22; "No. of Depreciation Months"; Decimal)
        {
            Caption = 'No. of Depreciation Months';
            BlankZero = true;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "No. of Depreciation Years" := Round("No. of Depreciation Months" / 12, 1);
            end;
        }
        field(23; "Min. Months After Appreciation"; Decimal)
        {
            Caption = 'Min. Months After Appreciation';
            BlankZero = true;
            DataClassification = CustomerContent;
        }
        field(31; "Straight First Year"; Decimal)
        {
            Caption = 'Straight First Year';
            DecimalPlaces = 2 : 5;
            BlankZero = true;
            DataClassification = CustomerContent;
        }
        field(32; "Straight Next Years"; Decimal)
        {
            Caption = 'Straight Next Years';
            DecimalPlaces = 2 : 5;
            BlankZero = true;
            DataClassification = CustomerContent;
        }
        field(33; "Straight Appreciation"; Decimal)
        {
            Caption = 'Straight Appreciation';
            DecimalPlaces = 2 : 5;
            BlankZero = true;
            DataClassification = CustomerContent;
        }
        field(41; "Declining First Year"; Decimal)
        {
            Caption = 'Declining First Year';
            DecimalPlaces = 2 : 5;
            BlankZero = true;
            DataClassification = CustomerContent;
        }
        field(42; "Declining Next Years"; Decimal)
        {
            Caption = 'Declining Next Years';
            DecimalPlaces = 2 : 5;
            BlankZero = true;
            DataClassification = CustomerContent;
        }
        field(43; "Declining Appreciation"; Decimal)
        {
            Caption = 'Declining Appreciation';
            DecimalPlaces = 2 : 5;
            BlankZero = true;
            DataClassification = CustomerContent;
        }
        field(44; "Declining Depr. Increase %"; Decimal)
        {
            Caption = 'Declining Depr. Increase %';
            DecimalPlaces = 2 : 5;
            BlankZero = true;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Code, "Starting Date")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Code, "Starting Date", Description, "Depreciation Type", "No. of Depreciation Years", "No. of Depreciation Months")
        {
        }
    }
}
