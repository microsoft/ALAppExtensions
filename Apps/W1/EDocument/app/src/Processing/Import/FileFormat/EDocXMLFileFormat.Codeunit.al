// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Format;

using System.Utilities;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.Processing.Interfaces;

codeunit 6192 "E-Doc. XML File Format" implements IEDocFileFormat
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure PreviewContent(FileName: Text; TempBlob: Codeunit "Temp Blob")
    begin
        Error('Content can''t be previewed');
    end;

    procedure PreferredStructureDataImplementation(): Enum "Structure Received E-Doc."
    begin
        exit("Structure Received E-Doc."::"Already Structured");
    end;

    procedure FileExtension(): Text
    begin
        exit('xml');
    end;
}