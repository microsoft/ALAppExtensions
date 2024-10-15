// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Calculation;

table 11713 "Non-Deductible VAT Setup CZL"
{
    Caption = 'Non-Deductible VAT Setup';
    DataClassification = CustomerContent;
    LookupPageId = "Non-Deductible VAT Setup CZL";
    DrillDownPageId = "Non-Deductible VAT Setup CZL";

    fields
    {
        field(1; "From Date"; Date)
        {
            Caption = 'From Date';
        }
        field(2; "To Date"; Date)
        {
            Caption = 'To Date';
        }
        field(3; "Advance Coefficient"; Decimal)
        {
            Caption = 'Advance Coefficient';
            DecimalPlaces = 0 : 1;
            MinValue = 0;
            MaxValue = 100;

            trigger OnValidate()
            begin
                TestField("To Date");
            end;
        }
        field(4; "Settlement Coefficient"; Decimal)
        {
            Caption = 'Settlement Coefficient';
            DecimalPlaces = 0 : 1;
            MinValue = 0;
            MaxValue = 100;

            trigger OnValidate()
            begin
                TestField("To Date");
            end;
        }
    }

    keys
    {
        key(PK; "From Date")
        {
            Clustered = true;
        }
    }

    procedure FindToDate(ToDate: Date): Boolean
    begin
        SetRange("From Date", 0D, ToDate);
        SetFilter("To Date", '%1..', ToDate);
        exit(FindLast());
    end;
}