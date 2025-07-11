// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

table 1885 "C5 InvenCustDisc"
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
        field(3; ItemCode; Option)
        {
            Caption = 'Item code';
            OptionMembers = Specific,Group,All;
        }
        field(4; AccountCode; Option)
        {
            Caption = 'Account code';
            OptionMembers = Specific,Group,All;
        }
        field(5; ItemRelation; Code[20])
        {
            Caption = 'Item relation';
        }
        field(6; RESERVED1; Text[10])
        {
            Caption = 'RESERVED1';
        }
        field(7; AccountRelation; Code[10])
        {
            Caption = 'A/c relation';
        }
        field(8; RESERVED2; Text[10])
        {
            Caption = 'RESERVED2';
        }
        field(9; Type; Option)
        {
            Caption = 'Type';
            OptionMembers = Percent,Amount,Price;
        }
        field(10; Qty; Decimal)
        {
            Caption = 'Qty';
        }
        field(11; FromDate; Date)
        {
            Caption = 'From date';
        }
        field(12; ToDate; Date)
        {
            Caption = 'To date';
        }
        field(13; Rate_; Decimal)
        {
            Caption = 'Rate';
        }
        field(14; SearchAgain; Option)
        {
            Caption = 'Search';
            OptionMembers = No,Yes;
        }
        field(15; SearchSimilar; Option)
        {
            Caption = 'Same';
            OptionMembers = No,Yes;
        }
        field(16; Currency; Code[3])
        {
            Caption = 'Currency';
        }
        field(17; PriceUnit; Decimal)
        {
            Caption = 'Price unit';
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

