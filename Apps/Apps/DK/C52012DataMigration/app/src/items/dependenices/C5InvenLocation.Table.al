// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

table 1896 "C5 InvenLocation"
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
        field(3; InvenLocation; Text[10])
        {
            Caption = 'Location';
        }
        field(4; Name; Text[30])
        {
            Caption = 'Name';
        }
        field(5; RESERVED1; Text[10])
        {
            Caption = 'RESERVED1';
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

