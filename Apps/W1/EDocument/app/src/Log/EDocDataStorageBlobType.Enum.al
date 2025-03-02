// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.Processing.Interfaces;
using Microsoft.EServices.EDocument.Format;

/// <summary>
/// E-Document Data Storage Blob Type
/// This enum specifies the type of the binary data stored in the E-Document Data Storage table.
/// </summary>
enum 6109 "E-Doc. Data Storage Blob Type" implements IBlobType
{
    Access = Public;
    Extensible = true;
    DefaultImplementation = IBlobType = "E-Doc. Default Blob Type";

    value(0; "Unspecified")
    {
        Caption = 'Unspecified';
    }
    value(1; "PDF")
    {
        Caption = 'PDF';
        Implementation = IBlobType = "E-Document ADI Handler";
    }
    value(2; "XML")
    {
        Caption = 'XML';
    }
    value(3; "JSON")
    {
        Caption = 'JSON';
    }
}