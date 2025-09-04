// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Analysis;

table 688 "Payment Practice Line"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Header No."; Integer)
        {
            TableRelation = "Payment Practice Header"."No.";
        }
        field(2; "Line No."; Integer)
        {

        }
        field(3; "Aggregation Type"; Enum "Paym. Prac. Aggregation Type")
        {

        }
        field(4; "Source Type"; Enum "Paym. Prac. Header Type")
        {

        }
        field(5; "Company Size Code"; Code[20])
        {

        }
        field(6; "Payment Period Code"; Code[20])
        {

        }
        field(7; "Average Agreed Payment Period"; Integer)
        {
            trigger OnValidate()
            begin
                Rec."Modified Manually" := true;
            end;
        }
        field(8; "Average Actual Payment Period"; Integer)
        {
            trigger OnValidate()
            begin
                Rec."Modified Manually" := true;
            end;
        }
        field(9; "Pct Paid on Time"; Decimal)
        {
            AutoFormatType = 0;

            trigger OnValidate()
            begin
                Rec."Modified Manually" := true;
            end;
        }
        field(10; "Pct Paid in Period"; Decimal)
        {
            AutoFormatType = 0;

            trigger OnValidate()
            begin
                Rec."Modified Manually" := true;
            end;
        }
        field(11; "Pct Paid in Period (Amount)"; Decimal)
        {
            AutoFormatType = 0;

            trigger OnValidate()
            begin
                Rec."Modified Manually" := true;
            end;
        }
        field(12; "Payment Period Description"; Text[250])
        {
            trigger OnValidate()
            begin
                Rec."Modified Manually" := true;
            end;
        }
        field(13; "Modified Manually"; Boolean)
        {

        }
    }

    keys
    {
        key(Key1; "Header No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Company Size Code") { }
    }

    trigger OnModify()
    begin
        Rec."Modified Manually" := true;
    end;
}
