// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

table 11747 "Cash Desk Cue CZP"
{
    Caption = 'Cash Desk Cue';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "Open Documents"; Integer)
        {
            CalcFormula = count("Cash Document Header CZP" where("Cash Desk No." = field("Cash Desk Filter"), Status = const(Open)));
            Caption = 'Open Documents';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; "Released Documents"; Integer)
        {
            CalcFormula = count("Cash Document Header CZP" where("Cash Desk No." = field("Cash Desk Filter"), Status = const(Released)));
            Caption = 'Released Documents';
            Editable = false;
            FieldClass = FlowField;
        }
        field(15; "Posted Documents"; Integer)
        {
            CalcFormula = count("Posted Cash Document Hdr. CZP" where("Cash Desk No." = field("Cash Desk Filter"), "Posting Date" = field("Date Filter")));
            Caption = 'Posted Documents';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            Editable = false;
            FieldClass = FlowFilter;
        }
        field(22; "Cash Desk Filter"; Code[20])
        {
            Caption = 'Cash Desk Filter';
            FieldClass = FlowFilter;
            TableRelation = "Cash Desk CZP";
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }
}
