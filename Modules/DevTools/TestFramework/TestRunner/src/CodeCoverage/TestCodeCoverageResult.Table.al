// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestTools.CodeCoverage;

table 130471 "Test Code Coverage Result"
{
    DataClassification = SystemMetadata;
    Access = Internal;
    ReplicateData = false;

    fields
    {
        field(1; "Test Codeunit ID"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(3; "Test Method"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(4; "CC Result"; Blob)
        {
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(Key1; "Test Codeunit ID", "Test Method")
        {
            Clustered = true;
        }
    }
}