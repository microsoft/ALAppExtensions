// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

table 1870 "C5 UnitCode"
{
    fields
    {
        field(1;RecId;Integer) 
        {
            Caption='Row number';
            AutoIncrement=true;
        }
        field(2;LastChanged;Date) 
        {
            Caption='Last changed';
        }
        field(3;UnitCode;Code[10]) 
        {
            Caption='Unit';
        }
        field(4;Txt;Text[30]) 
        {
            Caption='Text';
        }
    }

    keys
    {
        key(PK;RecId)
        {
            Clustered = true;
        }
    }
}

