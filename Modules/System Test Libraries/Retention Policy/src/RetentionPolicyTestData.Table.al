// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.DataAdministration;

table 138700 "Retention Policy Test Data"
{
    DataClassification = SystemMetadata;
    ReplicateData = false;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Date Field"; Date)
        {
        }
        field(3; "DateTime Field"; DateTime)
        {
        }
        field(4; Description; Text[100])
        {
        }
        field(5; "Description 2"; Text[100])
        {
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
