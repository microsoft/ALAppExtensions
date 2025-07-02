// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Format;

using System.Utilities;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.Processing.Interfaces;

codeunit 6191 "E-Doc. PDF File Format" implements IEDocFileFormat
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure PreviewContent(FileName: Text; TempBlob: Codeunit "Temp Blob")
    begin
        File.ViewFromStream(TempBlob.CreateInStream(), FileName, true)
    end;

    procedure PreferredStructureDataImplementation(): Enum "Structure Received E-Doc."
    begin
        exit("Structure Received E-Doc."::ADI);
    end;

    procedure FileExtension(): Text
    begin
        exit('pdf');
    end;
}