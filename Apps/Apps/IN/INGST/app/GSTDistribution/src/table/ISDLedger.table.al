// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Distribution;

using Microsoft.Finance.GST.Base;

table 18206 "ISD Ledger"
{
    Caption = 'ISD Ledger';

    fields
    {
        field(1; "GST Reg. No."; Code[20])
        {
            Caption = 'GST Reg. No.';
            TableRelation = "GST Registration Nos.";
            DataClassification = CustomerContent;
        }
        field(2; "Period Month"; Integer)
        {
            Caption = 'Period Month';
            DataClassification = CustomerContent;
        }
        field(3; "Period Year"; Integer)
        {
            Caption = 'Period Year';
            DataClassification = CustomerContent;
        }
        field(4; "GST Component Code"; Code[10])
        {
            Caption = 'GST Component Code';
            DataClassification = CustomerContent;
        }
        field(5; "Opening Balance"; Decimal)
        {
            Caption = 'Opening Balance';
            DataClassification = CustomerContent;
        }
        field(6; "ITC Received"; Decimal)
        {
            Caption = 'ITC Received';
            DataClassification = CustomerContent;
        }
        field(7; "ITC Reversal"; Decimal)
        {
            Caption = 'ITC Reversal';
            DataClassification = CustomerContent;
        }
        field(8; "Distributed as Component 1"; Decimal)
        {
            Caption = 'Distributed as Component 1';
            DataClassification = CustomerContent;
        }
        field(9; "Distributed as Component 2"; Decimal)
        {
            Caption = 'Distributed as Component 2';
            DataClassification = CustomerContent;
        }
        field(10; "Distributed as Component 3"; Decimal)
        {
            Caption = 'Distributed as Component 3';
            DataClassification = CustomerContent;
        }
        field(11; "Distributed as Component 4"; Decimal)
        {
            Caption = 'Distributed as Component 4';
            DataClassification = CustomerContent;
        }
        field(12; "Distributed as Component 5"; Decimal)
        {
            Caption = 'Distributed as Component 5';
            DataClassification = CustomerContent;
        }
        field(13; "Distributed as Component 6"; Decimal)
        {
            Caption = 'Distributed as Component 6';
            DataClassification = CustomerContent;
        }
        field(14; "Distributed as Component 7"; Decimal)
        {
            Caption = 'Distributed as Component 7';
            DataClassification = CustomerContent;
        }
        field(15; "Distributed as Component 8"; Decimal)
        {
            Caption = 'Distributed as Component 8';
            DataClassification = CustomerContent;
        }
        field(16; "Closing Balance"; Decimal)
        {
            Caption = 'Closing Balance';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "GST Reg. No.", "Period Month", "Period Year", "GST Component Code")
        {
            Clustered = true;
        }
        key(Key2; "GST Reg. No.", "GST Component Code", "Period Year", "Period Month")
        {
        }
    }
}
