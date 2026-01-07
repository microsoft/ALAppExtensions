// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;
using Microsoft.Utilities;

table 11721 "VAT Stmt. Calc. Parameters CZL"
{
    Caption = 'VAT Statement Calculation Parameters';
    TableType = Temporary;
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(2; "Start Date"; Date)
        {
            Caption = 'Start Date';
        }
        field(3; "End Date"; Date)
        {
            Caption = 'End Date';
        }
        field(4; "Selection"; Enum "VAT Statement Report Selection")
        {
            Caption = 'Selection';
        }
        field(5; "Period Selection"; Enum "VAT Statement Report Period Selection")
        {
            Caption = 'Period Selection';
        }
        field(6; "Print in Integers"; Boolean)
        {
            Caption = 'Print in Integers';
        }
        field(7; "Use Amounts in Add. Currency"; Boolean)
        {
            Caption = 'Use Amounts in Additional Currency';
        }
        field(8; "Rounding Type"; Enum "Rounding Type")
        {
            Caption = 'Rounding Type';
        }
        field(9; "VAT Settlement No. Filter"; Text[50])
        {
            Caption = 'VAT Settlement No. Filter';
        }
        field(10; "VAT Report No. Filter"; Text[50])
        {
            Caption = 'VAT Report No. Filter';
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    procedure GetRoundingDirection() Direction: Text[1]
    begin
        case "Rounding Type" of
            "Rounding Type"::Nearest:
                Direction := '=';
            "Rounding Type"::Up:
                Direction := '>';
            "Rounding Type"::Down:
                Direction := '<';
        end;
    end;

    procedure GetRoundingTypeAsInteger(): Integer
    begin
        exit("Rounding Type".AsInteger());
    end;

    procedure SetRoundingType(RoundingDirection: Option Nearest,Down,Up)
    begin
        case RoundingDirection of
            RoundingDirection::Nearest:
                "Rounding Type" := "Rounding Type"::Nearest;
            RoundingDirection::Up:
                "Rounding Type" := "Rounding Type"::Up;
            RoundingDirection::Down:
                "Rounding Type" := "Rounding Type"::Down;
        end;
    end;

    procedure SetEndDate(EndDate: Date)
    begin
        "End Date" := EndDate <> 0D ? EndDate : DMY2Date(31, 12, 9999);
    end;
}