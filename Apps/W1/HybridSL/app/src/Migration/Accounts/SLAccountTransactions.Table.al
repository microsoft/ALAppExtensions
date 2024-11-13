// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47054 "SL AccountTransactions"
{
    Access = Internal;
    DataClassification = CustomerContent;
    ReplicateData = false;

    fields
    {
        field(1; Id; Integer)
        {
            AutoIncrement = true;
            Caption = 'Id Number';
        }
        field(2; Year; Text[4])
        {
            Caption = 'Year';
        }
        field(3; AcctNum; Text[10])
        {
            Caption = 'Account Number';
        }
        field(4; SubSegment_1; Text[24])
        {
            Caption = 'Account Segment 1';
        }
        field(5; SubSegment_2; Text[24])
        {
            Caption = 'Account Segment 2';
        }
        field(6; SubSegment_3; Text[24])
        {
            Caption = 'Account Segment 3';
        }
        field(7; SubSegment_4; Text[24])
        {
            Caption = 'Account Segment 4';
        }
        field(8; SubSegment_5; Text[24])
        {
            Caption = 'Account Segment 5';
        }
        field(9; SubSegment_6; Text[24])
        {
            Caption = 'Account Segment 6';
        }
        field(10; SubSegment_7; Text[24])
        {
            Caption = 'Account Segment 7';
        }
        field(11; SubSegment_8; Text[24])
        {
            Caption = 'Account Segment 8';
        }
        field(12; Balance; Decimal)
        {
            Caption = 'Balance';
        }
        field(13; DebitAmount; Decimal)
        {
            Caption = 'Debit Amount';
        }
        field(14; CreditAmount; Decimal)
        {
            Caption = 'Credit Amount';
        }
        field(15; Sub; Text[24])
        {
            Caption = 'SubAccount';
        }
        field(16; PERIODID; Integer)
        {
            Caption = 'Fiscal Period';
        }
    }

    keys
    {
        key(Key1; Id)
        {
            Clustered = true;
        }
        key(TrxKey; Year, PERIODID, AcctNum)
        {
        }
    }
}