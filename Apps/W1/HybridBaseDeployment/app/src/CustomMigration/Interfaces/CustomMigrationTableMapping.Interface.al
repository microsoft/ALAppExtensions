// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration;

/// <summary>
/// Interface to change the default mapping tables
/// </summary>
interface "Custom Migration Table Mapping"
{
    /// <summary>
    /// Gets the name of the table that is storing mappings of the source tables to destination tables in SaaS instance. This data will be moved during replication phase.
    /// Table name must match the name of the table in SQL database exactly and must have an exact structure as expected by the migration framework, see official documentation for details.
    /// </summary>
    /// <returns>
    /// The name of the replication table mapping.
    /// </returns>
    procedure GetReplicationTableMappingName(): Text;

    /// <summary>
    /// Gets table name of the migration setup table mapping that is used to map the tables from source to destination during cloud migration setup phase.
    /// Table name must match the name of the table in SQL database exactly and must have an exact structure as expected by the migration framework, see official documentation for details.
    /// </summary>
    /// <returns>
    /// The name of the migration setup table mapping.
    /// </returns>
    procedure GetMigrationSetupTableMappingName(): Text;

    /// <summary>
    /// Returns the table name of the companies table. This table is used to get the list of the companies for the cloud migration.
    /// Companies table exists only in the source database. It can have any name, but it must have 2 fields : [Name] [nvarchar] 30, [Display Name] [nvarchar] 250. [Name] must be primary key.
    /// The table must match the SQL table name exactly.
    /// </summary>
    /// <returns>
    /// The name of the companies table in the source database.
    /// </returns>
    procedure GetCompaniesTableName(): Text;

    /// <summary>
    /// Indicates whether to show the "Configure Migration Tables Mapping" step in the cloud migration wizard.
    /// Default value should be to return false, unless there is a need to allow users to change the values provided by the interfaces above.
    /// </summary>
    /// <returns>
    /// True if the "Configure Migration Tables Mapping" step should be shown; otherwise, false.
    /// </returns>
    procedure ShowConfigureMigrationTablesMappingStep(): Boolean;
}