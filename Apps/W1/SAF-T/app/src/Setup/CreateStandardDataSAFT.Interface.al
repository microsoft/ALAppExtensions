// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

interface CreateStandardDataSAFT
{
    /// <summary>
    /// Loads list of standard general ledger accounts to Standard Account table.
    /// </summary>
    /// <param name="StandardAccountType">Standard G/L Account Type</param>
    /// <returns>true if all G/L accounts were uploaded.</returns>
    procedure LoadStandardAccounts(StandardAccountType: Enum "Standard Account Type") Result: Boolean

    /// <summary>
    /// Loads list of standard tax codes to VAT Reporting Code table.
    /// </summary>
    /// <returns>true if all G/L accounts were uploaded.</returns>
    procedure LoadStandardTaxCodes() Result: Boolean

    /// <summary>
    /// Removes the existing records and create new default records in the Audit Export Data Type Setup table.
    /// </summary>
    procedure InitAuditExportDataTypeSetup()
}
