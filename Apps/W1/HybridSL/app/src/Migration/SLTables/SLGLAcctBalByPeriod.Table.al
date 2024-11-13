// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47004 SLGLAcctBalByPeriod
{
    Access = Internal;
    Caption = 'SLGLAcctBalByPeriod';
    DataClassification = CustomerContent;

    fields
    {
        field(1; ACCT; Text[10])
        {
            Caption = 'Account';
        }
        field(2; SUB; Text[24])
        {
            Caption = 'Subaccount';
        }
        field(3; FISCYR; Text[4])
        {
            Caption = 'Fiscal Year';
        }
        field(4; PERIODID; Integer)
        {
            Caption = 'Period Id';
        }
        field(5; PERBAL; Decimal)
        {
            Caption = 'Period Balance';
        }
        field(6; DEBITAMT; Decimal)
        {
            Caption = 'Debit Amount';
        }
        field(7; CREDITAMT; Decimal)
        {
            Caption = 'Credit Amount';
        }
    }
    keys
    {
        key(Key1; ACCT, SUB, FISCYR, PERIODID)
        {
            Clustered = true;
        }
    }
}
