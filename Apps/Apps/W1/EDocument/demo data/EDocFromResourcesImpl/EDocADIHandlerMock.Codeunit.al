// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Format;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Processing.Interfaces;
using Microsoft.eServices.EDocument.Processing.Import;
using System.Utilities;

codeunit 5428 "E-Doc ADI Handler Mock" implements IStructureReceivedEDocument, IStructuredFormatReader, IStructuredDataType
{
    Access = Internal;

    var
        StructuredData: Text;
        NoDataFoundInBlobErr: Label 'No data found in the blob.';
        NoSubscriberToOnBeforeGetADIJsonInStreamErr: Label 'No subscriber to OnBeforeGetADIJsonInStream event.';


    procedure StructureReceivedEDocument(EDocumentDataStorage: Record "E-Doc. Data Storage"): Interface IStructuredDataType
    var
        InStr: InStream;
        FileName: Text;
        IsHandled: Boolean;
    begin
        FileName := EDocumentDataStorage.Name.Replace('pdf', 'json');
        OnBeforeGetADIJsonInStream(InStr, FileName, IsHandled);
        if not IsHandled then
            error(NoSubscriberToOnBeforeGetADIJsonInStreamErr);
        if InStr.Length = 0 then
            error(NoDataFoundInBlobErr);
        InStr.ReadText(StructuredData);
        exit(this);
    end;

    procedure GetFileFormat(): Enum "E-Doc. File Format";
    begin
        exit("E-Doc. File Format"::PDF);
    end;

    procedure GetContent(): Text
    begin
        exit(this.StructuredData);
    end;

    procedure GetReadIntoDraftImpl(): Enum "E-Doc. Read into Draft"
    begin
        exit(Enum::"E-Doc. Read into Draft"::ADI);
    end;

    procedure ReadIntoDraft(EDocument: Record "E-Document"; TempBlob: Codeunit "Temp Blob"): Enum "E-Doc. Process Draft";
    var
        IStructuredFormatReader: Interface IStructuredFormatReader;
    begin
        IStructuredFormatReader := Enum::"E-Doc. Read into Draft"::ADI;
        IStructuredFormatReader.ReadIntoDraft(EDocument, TempBlob);
    end;

    procedure View(EDocument: Record "E-Document"; TempBlob: Codeunit "Temp Blob");
    var
        IStructuredFormatReader: Interface IStructuredFormatReader;
    begin
        IStructuredFormatReader := Enum::"E-Doc. Read into Draft"::ADI;
        IStructuredFormatReader.View(EDocument, TempBlob);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetADIJsonInStream(var InStr: InStream; FileName: Text; var IsHandled: Boolean)
    begin
    end;

}