// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.eServices.EDocument.Format;
using Microsoft.eServices.EDocument.Processing.Interfaces;

/// <summary>
/// Structured formats for E-Documents
/// </summary>
enum 6104 "E-Document Structured Format" implements IStructuredFormatReader
{
    Extensible = true;

    value(0; "Azure Document Intelligence")
    {
        Caption = 'Azure Document Intelligence';
        Implementation = IStructuredFormatReader = "E-Document ADI Format";
    }
}
