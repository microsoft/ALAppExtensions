// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.Email;

table 134684 "Email Related Record Test"
{
    ReplicateData = false;

    fields
    {
        field(1; "No."; Integer)
        {
            AutoIncrement = true;
            DataClassification = SystemMetadata;
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