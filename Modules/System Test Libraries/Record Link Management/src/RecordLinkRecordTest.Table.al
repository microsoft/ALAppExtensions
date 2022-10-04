﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 132508 "Record Link Record Test"
{
    ReplicateData = false;

    fields
    {
        field(1; PK; Integer)
        {
            AutoIncrement = true;
        }
        field(2; Field; Text[50])
        {
        }
    }
    keys
    {
        key(Key1; PK, Field)
        {
            Clustered = true;
        }
    }
}
