// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

interface DataUpgradeSAFT
{
    /// <summary>
    /// Defines if data upgrade is required.
    /// </summary>
    /// <returns>True if data upgrade is required, otherwise false</returns>
    procedure IsDataUpgradeRequired(): Boolean

    /// <summary>
    /// Returns a description of what will be upgraded.
    /// </summary>
    procedure GetDataUpgradeDescription(): Text

    /// <summary>
    /// Shows the data which will be upgraded.
    /// </summary>
    procedure ReviewDataToUpgrade()

    /// <summary>
    /// Upgrades the data.
    /// </summary>
    /// <returns>True if data upgrade was successful, otherwise false</returns>
    procedure UpgradeData() Result: Boolean
}
