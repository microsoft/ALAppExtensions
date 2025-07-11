// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47000 "SL Account Staging"
{
    Access = Internal;
    DataClassification = CustomerContent;
    ReplicateData = false;

    fields
    {
        field(1; AcctNum; Text[10])
        {
            Caption = 'Account Number';
        }
        field(2; Name; Text[30])
        {
            Caption = 'Name';
        }
        field(3; SearchName; Text[30])
        {
            Caption = 'Search Name';
        }
        field(4; AccountCategory; Integer)
        {
            Caption = 'Account Category';
        }
        field(5; IncomeBalance; Boolean)
        {
            Caption = 'Income/Balance';
        }
        field(6; DebitCredit; Integer)
        {
            Caption = 'Debit/Credit';
        }
        field(7; Active; Boolean)
        {
            Caption = 'Blocked';
        }
    }

    keys
    {
        key(Key1; AcctNum)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; AcctNum, Name)
        {
        }
    }
}
