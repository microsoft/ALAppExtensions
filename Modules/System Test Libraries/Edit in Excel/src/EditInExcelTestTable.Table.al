// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.Integration.Excel;
table 132525 "Edit In Excel Test Table"
{
    DataClassification = SystemMetadata;
    ReplicateData = false;

    fields
    {
        field(1; "No."; Code[20])
        {
        }

        field(2; MyField; Blob)
        {
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }
}