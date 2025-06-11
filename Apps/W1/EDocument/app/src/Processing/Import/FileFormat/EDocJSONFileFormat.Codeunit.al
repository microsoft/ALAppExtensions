// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Format;

using System.Utilities;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.Processing.Interfaces;

codeunit 6194 "E-Doc. JSON File Format" implements IEDocFileFormat
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure FileExtension(): Text
    begin
        exit('json');
    end;

    procedure PreviewContent(FileName: Text; TempBlob: Codeunit "Temp Blob")
    var
        ContentCantBePreviewedErr: Label 'Content can''t be previewed';
    begin
        Error(ContentCantBePreviewedErr);
    end;

    procedure PreferredStructureDataImplementation(): Enum "Structure Received E-Doc."
    begin
        exit("Structure Received E-Doc."::"Already Structured");
    end;
}