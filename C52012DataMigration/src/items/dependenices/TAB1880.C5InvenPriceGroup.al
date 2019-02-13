// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

table 1880 "C5 InvenPriceGroup"
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
            Caption = 'Group';
        }
        field(4; GroupName; Text[30])
        {
            Caption = 'Group name';
        }
        field(5; InclVat; Option)
        {
            Caption = 'Incl. VAT';
            OptionMembers = No,Yes;
        }
        field(6; Roundoff1; Decimal)
        {
            Caption = 'Round 1';
        }
        field(7; Roundoff10; Decimal)
        {
            Caption = 'Round 10';
        }
        field(8; Roundoff100; Decimal)
        {
            Caption = 'Round 100';
        }
        field(9; Roundoff1000; Decimal)
        {
            Caption = 'Round 1000';
        }
        field(10; Roundoff1000Plus; Decimal)
        {
            Caption = 'Round 1000 Plus';
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

