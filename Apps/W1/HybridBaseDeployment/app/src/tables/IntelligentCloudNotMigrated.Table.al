// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration;

table 4019 "Intelligent Cloud Not Migrated"
{
    DataPerCompany = false;
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; "Company Name"; Text[250])
        {
            Description = 'The name of a company';
            DataClassification = SystemMetadata;
        }
        field(2; "Table Name"; Text[250])
        {
            Description = 'The name of the unmigrated table';
            DataClassification = SystemMetadata;
        }
        field(3; "Table Id"; Integer)
        {
            Description = 'The ID of the unmigrated table';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Company Name", "Table Name")
        {
            Clustered = true;
        }
    }
}