// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestTools.CodeCoverage;

table 130472 "AL Code Coverage Map"
{
    DataClassification = SystemMetadata;
    Access = Internal;
    ReplicateData = false;

    fields
    {
        field(1; "Object Type"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Object ID"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(3; "Line No."; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(10; "Test Codeunit ID"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(11; "Test Method"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(Key1; "Object Type", "Object ID", "Line No.", "Test Codeunit ID", "Test Method")
        {
            Clustered = true;
        }
    }
}