// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

table 1864 "C5 CN8Code"
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
        field(3; CN8Code; Code[10])
        {
            Caption = 'Item CN8 codes';
        }
        field(4; Txt; Text[30])
        {
            Caption = 'Text';
        }
        field(5; SupplementaryUnits; Text[13])
        {
            Caption = 'Supplementary unit';
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

