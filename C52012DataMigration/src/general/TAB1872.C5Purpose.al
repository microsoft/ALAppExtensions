// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

table 1872 "C5 Purpose"
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
        field(3; Purpose; Code[10])
        {
            Caption = 'Purpose';
        }
        field(4; Name; Text[30])
        {
            Caption = 'Name';
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

