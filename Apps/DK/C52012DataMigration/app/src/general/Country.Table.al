// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

table 1886 "C5 Country"
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
        field(3; Country; Text[30])
        {
            Caption = 'Country/region';
        }
        field(4; Type; Option)
        {
            Caption = 'Type';
            OptionMembers = Domestic,"EU country","EFTA country","3. country";
        }
        field(5; Currency; Code[3])
        {
            Caption = 'Currency';
        }
        field(6; Language_; Option)
        {
            Caption = 'Language';
            OptionMembers = Default,Danish,English,German,French,Italian,Dutch,Icelandic;
        }
        field(7; PurchVat; Code[10])
        {
            Caption = 'Purch. VAT';
        }
        field(8; SalesVat; Code[10])
        {
            Caption = 'Sales VAT';
        }
        field(9; VatCountryCode; Code[2])
        {
            Caption = 'Country code';
        }
        field(10; IntrastatCode; Code[3])
        {
            Caption = 'Intrastat';
        }
        field(11; ExtCountryName; Text[50])
        {
            Caption = 'Country name';
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

