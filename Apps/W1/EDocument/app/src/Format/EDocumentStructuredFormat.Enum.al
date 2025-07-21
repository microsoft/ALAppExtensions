#if not CLEAN26
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Format;

using Microsoft.eServices.EDocument.Processing.Interfaces;

/// <summary>
/// Structured formats for E-Documents
/// </summary>
enum 6104 "E-Document Structured Format" implements IStructuredFormatReader
{
    ObsoleteReason = 'Use "Structure Received E-Doc." or "E-Doc. Read into Draft".';
    ObsoleteState = Pending;
    ObsoleteTag = '26.0';
    Extensible = true;

    value(0; "Azure Document Intelligence")
    {
        Caption = 'Azure Document Intelligence';
        Implementation =
            IStructuredFormatReader = "E-Document ADI Handler";
    }
    value(1; "PEPPOL BIS 3.0")
    {
        Caption = 'PEPPOL BIS 3.0';
        Implementation =
            IStructuredFormatReader = "E-Document PEPPOL Handler";
    }
}
#endif