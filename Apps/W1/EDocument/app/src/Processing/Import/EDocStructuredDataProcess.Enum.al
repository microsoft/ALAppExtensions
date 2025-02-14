// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;

using Microsoft.eServices.EDocument.Processing.Interfaces;

/// <summary>
/// Enum for E-Document Processing
/// </summary>
enum 6107 "E-Doc. Structured Data Process" implements IProcessStructuredData
{
    Extensible = true;
    value(0; "Purchase Document")
    {
        Caption = 'Purchase Document';
        Implementation = IProcessStructuredData = "Prepare Purchase E-Doc. Draft";
    }
}