// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Processing.Interfaces;
using System.Utilities;

/// <summary>
/// Default implementations for E-Document interfaces.
/// </summary>
codeunit 6116 "E-Doc. Unspecified Impl." implements IStructureReceivedEDocument, IEDocumentFinishDraft, IStructuredFormatReader, IEDocFileFormat
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure ApplyDraftToBC(EDocument: Record "E-Document"; EDocImportParameters: Record "E-Doc. Import Parameters"): RecordId
    var
        NoMethodSpecifiedErr: Label 'The E-Document type %1 is not supported.', Comment = '%1 - Document type';
    begin
        Error(NoMethodSpecifiedErr, EDocument."Document Type");
    end;

    procedure RevertDraftActions(EDocument: Record "E-Document")
    begin
        // No actions to revert
    end;

    procedure StructureReceivedEDocument(EDocumentDataStorage: Record "E-Doc. Data Storage"): Interface IStructuredDataType
    var
        NoMethodSpecifiedErr: Label 'No method to structure the received e-document has been provided.';
    begin
        Error(NoMethodSpecifiedErr);
    end;

    procedure ReadIntoDraft(EDocument: Record "E-Document"; TempBlob: Codeunit "Temp Blob"): Enum "E-Doc. Process Draft"
    begin
        Error(EDocumentNoReadSpecifiedErr);
    end;

    procedure View(EDocument: Record "E-Document"; TempBlob: Codeunit "Temp Blob")
    begin
        Error(EDocumentNoReadSpecifiedErr);
    end;

    procedure FileExtension(): Text
    begin
    end;

    procedure PreviewContent(FileName: Text; TempBlob: Codeunit "Temp Blob")
    var
        ContentCantBePreviewedErr: Label 'Content can''t be previewed';
    begin
        Error(ContentCantBePreviewedErr);
    end;

    procedure PreferredStructureDataImplementation(): Enum "Structure Received E-Doc."
    begin
    end;

    var
        EDocumentNoReadSpecifiedErr: Label 'No method to read the e-document has been provided.';
}