// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Utilities;

interface "VAT Control Report Export CZL"
{
    /// <summary>
    /// Export VAT Control Report to XML file.
    /// </summary>
    /// <param name="VATCtrlReportHeaderCZL">Record "VAT Ctrl. Report Header CZL" which will be exported.</param>
    /// <returns>Exported file name.</returns>
    procedure ExportToXMLFile(VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL"): Text

    /// <summary>
    /// Export VAT Control Report to TempBlob.
    /// </summary>
    /// <param name="VATCtrlReportHeaderCZL">Record "VAT Ctrl. Report Header CZL" which will be exported.</param>
    /// <param name="TempBlob">Pointer of type Codeunit "Temp Blob" into which the XML export output is filled.</param>
    procedure ExportToXMLBlob(VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL"; var TempBlob: Codeunit "Temp Blob")
}
