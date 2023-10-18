// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.Utilities;

table 132508 "Record Link Record Test"
{
    ReplicateData = false;
    DataClassification = SystemMetadata;

    fields
    {
        field(1; PK; Integer)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(2; Field; Text[50])
        {
            DataClassification = SystemMetadata;
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
