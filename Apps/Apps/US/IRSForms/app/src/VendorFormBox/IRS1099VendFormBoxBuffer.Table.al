// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

table 10044 "IRS 1099 Vend. Form Box Buffer"
{
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Period No."; Code[20])
        {
        }
        field(3; "Vendor No."; Code[20])
        {
        }
        field(4; "Form No."; Code[20])
        {
        }
        field(5; "Form Box No."; Code[20])
        {
        }
        field(7; "Line No"; Integer)
        {

        }
        field(10; "Buffer Type"; Enum "IRS 1099 Form Box Buffer Type")
        {

        }
        field(11; Amount; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
        }
        field(12; "Adjustment Amount"; Decimal)
        {
            CalcFormula = lookup("IRS 1099 Vendor Form Box Adj.".Amount where("Period No." = field("Period No."), "Vendor No." = field("Vendor No."), "Form No." = field("Form No."), "Form Box No." = field("Form Box No.")));
            FieldClass = FlowField;
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
        }
        field(13; "Minimum Reportable Amount"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = lookup("IRS 1099 Form Box"."Minimum Reportable Amount" where("Period No." = field("Period No."), "Form No." = field("Form No."), "No." = field("Form Box No.")));
            Editable = false;
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
        }
        field(14; "Reporting Amount"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
        }
        field(15; "Include In 1099"; Boolean)
        {
        }
        field(16; "Parent Entry No."; Integer)
        {
        }
        field(17; "Vendor Ledger Entry No."; Integer)
        {
        }
        field(100; "Currency Code"; Code[10])
        {
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(ParentEntryNoBufferType; "Parent Entry No.", "Buffer Type")
        {

        }
    }
}
