// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.Media;

table 135038 "My Video Source"
{
    ReplicateData = false;
    DataClassification = SystemMetadata;

    fields
    {
        field(1; PrimaryKey; Integer)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; PrimaryKey)
        {
            Clustered = true;
        }
    }
}