// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.eServices.EDocument.Format;
using Microsoft.eServices.EDocument.Processing.Interfaces;
using Microsoft.eServices.EDocument.Processing.Import;

/// <summary>
/// E-Doc. File Format
/// This enum specifies the file format of the binary data stored in the E-Document Data Storage table.
/// </summary>
enum 6134 "E-Doc. File Format" implements IEDocFileFormat
{
    value(0; "Unspecified")
    {
        Caption = 'Unspecified';
        Implementation = IEDocFileFormat = "E-Doc. Unspecified Impl.";
    }
    value(1; "PDF")
    {
        Caption = 'PDF';
        Implementation = IEDocFileFormat = "E-Doc. PDF File Format";
    }
    value(2; "XML")
    {
        Caption = 'XML';
        Implementation = IEDocFileFormat = "E-Doc. XML File Format";
    }
    value(3; "JSON")
    {
        Caption = 'JSON';
        Implementation = IEDocFileFormat = "E-Doc. JSON File Format";
    }
}