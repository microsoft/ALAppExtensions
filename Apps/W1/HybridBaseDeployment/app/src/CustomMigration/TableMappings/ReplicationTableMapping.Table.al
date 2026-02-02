// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration;

/// <summary>
/// <see cref="Replication Table Mappings"/> table is used for defining how the data is copied from source SQL table to the destination SQL table in the cloud environment.
/// The data is copied during the replication phase of the cloud migration. 
/// </summary>
table 40034 "Replication Table Mapping"
{
    DataPerCompany = false;
    DataClassification = SystemMetadata;
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; "Source Sql Table Name"; Text[128])
        {
            Caption = 'Source SQL Table Name';
            ToolTip = 'Specifies the name of the source SQL table to be replicated. The name must match exactly the name of the destination table in SQL.';
        }

        field(2; "Destination Sql Table Name"; Text[128])
        {
            Caption = 'Destination SQL Table Name';
            ToolTip = 'Specifies the name of the destination SQL table in the cloud environment. The name must match exactly the name of the destination table in SQL.';
        }

        field(3; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
            ToolTip = 'Specifies the company name associated with this table mapping. The value should be blank if the table is per-database.';
        }

        field(4; "Table Name"; Text[128])
        {
            Caption = 'Table Name';
            ToolTip = 'Specifies the name of the table. For example, "Customer" or "Sales Header".';
        }

        field(5; "Preserve Cloud Data"; Boolean)
        {
            Caption = 'Preserve Cloud Data';
            ToolTip = 'Specifies whether to preserve existing data in the cloud during replication. If set to true, existing data in the destination table will not be overwritten during replication, only new records will be added. It is recommended to set this to true for per-database table, while it should be false for per-company tables.';
        }
    }

    keys
    {
        key(Key1; "Source Sql Table Name", "Destination Sql Table Name")
        {
            Clustered = true;
        }
        key(Key2; "Destination Sql Table Name")
        {
            Unique = true;
        }
    }
}