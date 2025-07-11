// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

using Microsoft.Finance.TaxEngine.TaxTypeHandler;

table 18549 "Tax Accounting Period"
{
    Caption = 'Tax Accounting Period';
    Access = Public;
    Extensible = true;

    fields
    {
        field(1; "Tax Type Code"; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = "Tax Acc. Period Setup";
            Editable = false;
        }
        field(2; "Starting Date"; Date)
        {
            NotBlank = true;
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            var
                MonthTextLbl: Label '<Month Text>', Locked = true;
            begin
                Name := Format("Starting Date", 0, MonthTextLbl);
            end;
        }
        field(3; Name; Text[10])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(4; "New Fiscal Year"; Boolean)
        {
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                TestField("Date Locked", false);
            end;
        }
        field(5; Closed; Boolean)
        {
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
        field(6; "Date Locked"; Boolean)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(7; "Financial Year"; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
        field(8; Quarter; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(9; "Ending Date"; Date)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(Key1; "Tax Type Code", "Starting Date")
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

    fieldgroups
    {
        fieldgroup(Brick; "Tax Type Code", "Starting Date", Name, "New Fiscal Year", Closed)
        {
        }
    }

    trigger OnDelete()
    begin
        TestField("Date Locked", false);
    end;

    trigger OnInsert()
    var
        TaxAccountingPeriod: Record "Tax Accounting Period";
    begin
        TaxAccountingPeriod := Rec;
        if TaxAccountingPeriod.Find('>') then
            TaxAccountingPeriod.TestField("Date Locked", false);
    end;

    trigger OnRename()
    var
        TaxAccountingPeriod: Record "Tax Accounting Period";
    begin
        TestField("Date Locked", false);
        TaxAccountingPeriod := Rec;
        if TaxAccountingPeriod.Find('>') then
            TaxAccountingPeriod.TestField("Date Locked", false);
    end;
}
