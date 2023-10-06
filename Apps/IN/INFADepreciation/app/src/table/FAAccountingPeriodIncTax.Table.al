// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.FADepreciation;

table 18631 "FA Accounting Period Inc. Tax"
{
    Caption = 'FA Accounting Period Inc. Tax';
    LookupPageID = "FA Accounting Periods Inc. Tax";

    fields
    {
        field(1; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
            NotBlank = true;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Name := Format("Starting Date", 0, MonthLbl);
            end;
        }
        field(2; Name; Text[10])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(3; "New Fiscal Year"; Boolean)
        {
            Caption = 'New Fiscal Year';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Date Locked", false);
            end;
        }
        field(4; Closed; Boolean)
        {
            Caption = 'Closed';
            Editable = true;
            DataClassification = CustomerContent;
        }
        field(5; "Date Locked"; Boolean)
        {
            Caption = 'Date Locked';
            Editable = true;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Starting Date")
        {
            Clustered = true;
        }
        key(Key2; "New Fiscal Year", "Date Locked")
        {
        }
        key(Key3; Closed)
        {
        }
    }

    trigger OnInsert()
    var
        FAAccountingPeriodIncTax: Record "FA Accounting Period Inc. Tax";
    begin
        FAAccountingPeriodIncTax := Rec;
        if FAAccountingPeriodIncTax.Find('>') then
            FAAccountingPeriodIncTax.TestField("Date Locked", false);
    end;

    trigger OnRename()
    var
        FAAccountingPeriodIncTax: Record "FA Accounting Period Inc. Tax";
    begin
        TestField("Date Locked", false);
        FAAccountingPeriodIncTax := Rec;
        if FAAccountingPeriodIncTax.Find('>') then
            FAAccountingPeriodIncTax.TestField("Date Locked", false);
    end;

    var
        MonthLbl: Label '<Month Text>';
}
