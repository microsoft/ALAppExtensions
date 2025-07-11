// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using System.Utilities;

interface "Audit File Export Data Handling"
{
    /// <summary>
    /// Loads list of standard general ledger accounts to Standard Account table.
    /// </summary>
    /// <param name="StandardAccountType">Standard G/L Account Type</param>
    /// <returns>true if all G/L accounts were uploaded.</returns>
    procedure LoadStandardAccounts(StandardAccountType: enum "Standard Account Type") Result: Boolean;

    /// <summary>
    /// Creates lines for the selected audit file export document.
    /// </summary>
    /// <param name="AuditFileExportHeader">Header of a document for which lines are created.</param>
    procedure CreateAuditFileExportLines(var AuditFileExportHeader: Record "Audit File Export Header")

    /// <summary>
    /// Generates audit file content for the selected audit file export line.
    /// </summary>
    /// <param name="AuditFileExportLine">Audit export line for which file content is generated.</param>
    /// <param name="TempBlob">Generated file content must be returned as TempBlob.</param>
    procedure GenerateFileContentForAuditFileExportLine(var AuditFileExportLine: Record "Audit File Export Line"; var TempBlob: Codeunit "Temp Blob")

    /// <summary>
    /// Creates a string which will be used as a file name when an audit file is created from the audit file export line.
    /// </summary>
    /// <param name="AuditFileExportLine">Audit export line for which file name is created.</param>
    /// <returns>A string with full file name like abc.txt or SIE.se.</returns>
    procedure GetFileNameForAuditFileExportLine(var AuditFileExportLine: Record "Audit File Export Line") FileName: Text[1024]

    /// <summary>
    /// Removes the existing records and create new default records in the Audit Export Data Type Setup table.
    /// </summary>
    procedure InitAuditExportDataTypeSetup()

}
