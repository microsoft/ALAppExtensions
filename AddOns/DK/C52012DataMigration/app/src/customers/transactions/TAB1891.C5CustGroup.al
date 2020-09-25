// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

table 1891 "C5 CustGroup"
{
    ReplicateData = false;

    fields
    {
        field(1; RecId; Integer)
        {
            Caption = 'Row number';
        }
        field(2; LastChanged; Date)
        {
            Caption = 'Last changed';
        }
        field(3; Group; Code[10])
        {
            Caption = 'Customer group';
        }
        field(4; GroupName; Text[30])
        {
            Caption = 'Group name';
        }
        field(5; SalesAcc; Text[10])
        {
            Caption = 'Sales a/c';
        }
        field(6; COGSAcc; Text[10])
        {
            Caption = 'COGS a/c';
        }
        field(7; InvoiceDisc; Text[10])
        {
            Caption = 'Invoice disc.';
        }
        field(8; FeeTaxable; Text[10])
        {
            Caption = 'Fee taxable';
        }
        field(9; FeeTaxfree; Text[10])
        {
            Caption = 'Fee tax free';
        }
        field(10; GroupAccount; Text[10])
        {
            Caption = 'Group a/c';
        }
        field(11; CashPayment; Text[10])
        {
            Caption = 'Cash payment';
        }
        field(12; LineDisc; Text[10])
        {
            Caption = 'Line disc.';
        }
    }

    keys
    {
        key(PK; RecId)
        {
            Clustered = true;
        }
    }
}

