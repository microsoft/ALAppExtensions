// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration;

using Microsoft.Utilities;

/// <summary>
/// Interface for Custom Migration Provider implementations.
/// </summary>
interface "Custom Migration Provider"
{
    /// <summary>
    /// Gets a display name for the migration type. This value is shown in the wizard.
    /// </summary>
    /// <returns>Display name of the migration type</returns>
    procedure GetDisplayName(): Text[250];

    /// <summary>
    /// Gets a description for the migration type. This value is shown in the wizard.
    /// </summary>
    /// <returns>Description of the migration type</returns>
    procedure GetDescription(): Text;

    /// <summary>
    /// Gets the ID of the app that defines the implementation.
    /// </summary>
    /// <returns>ID of the application that is implementing custom migration. If multiple apps are used, this should be the main app.</returns>
    procedure GetAppId(): Guid;

    /// <summary>
    /// Sets up the replication table mappings.
    /// These mappings are used to move the data during the replication phase. This is the default way to move the data.
    /// </summary>
    procedure SetupReplicationTableMappings();

    /// <summary>
    /// Sets up the migration setup table mappings. 
    /// These mappings are used to replicate the data during the setup to SaaS, so the on-premise data can be used to configure the migration.
    /// It is recommended to move a small subset of the tables that do not contain large amounts of data, otherwise the setup will be slow. 
    /// </summary>
    procedure SetupMigrationSetupTableMappings();

    /// <summary>
    /// Returns the demo data type that will be used to create the companies in SaaS. 
    /// Most common types are:
    /// "Production - Setup Data Only" - setup data only - this will populate the setup.
    /// "Create New - No Data" - empty company. In this case you need to ensure that the setup data is created. This option is mostly used if the setup data is migrated.
    /// </summary>
    /// <returns>Demo data type that will be used to configure the new company</returns>
    procedure GetDemoDataType() DemoDataType: Enum "Company Demo Data Type";
}