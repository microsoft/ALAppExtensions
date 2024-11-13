// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47030 "SL Migration Errors"
{
    Access = Internal;
    Caption = 'SL Migration Errors';
    DataClassification = SystemMetadata;
    DataPerCompany = false;
    ReplicateData = false;
    fields
    {
        field(1; PrimaryKey; Code[10])
        {
        }
        field(2; MigrationErrorCount; Integer)
        {
        }
        field(3; PostingErrorCount; Integer)
        {
        }
    }

    keys
    {
        key(Key1; PrimaryKey)
        {
            Clustered = true;
        }
    }
}