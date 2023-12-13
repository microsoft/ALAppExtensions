// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

table 1873 "C5 Payment"
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
        field(3; Payment; Code[10])
        {
            Caption = 'Payment';
        }
        field(4; Txt; Text[30])
        {
            Caption = 'Text';
        }
        field(5; Method; Option)
        {
            Caption = 'Method';
            OptionMembers = Net,"Cur. month","Cur. quarter","Cur. year","Cur. week";
        }
        field(6; Qty; Integer)
        {
            Caption = 'Qty';
        }
        field(7; UnitCode; Option)
        {
            Caption = 'Unit';
            OptionMembers = Day,Week,Month;
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

