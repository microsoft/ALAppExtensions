// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.Processing.Interfaces;
using Microsoft.eServices.EDocument;
using System.Utilities;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;

codeunit 6193 "E-Doc. Empty Draft" implements IStructureReceivedEDocument, IStructuredDataType, IStructuredFormatReader
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure StructureReceivedEDocument(EDocumentDataStorage: Record "E-Doc. Data Storage"): Interface IStructuredDataType
    begin
        // Nothing to do to structure: this is used for already structured data or empty drafts
        exit(this);
    end;

    procedure GetFileFormat(): Enum "E-Doc. File Format"
    begin
        Session.LogMessage('0000PIU', 'GetFileFormat should not be called when data is already structured. This implementation should not be used for other IStructureDataType implementations.', Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', 'E-Document');
    end;

    procedure GetContent(): Text
    begin
        Session.LogMessage('0000PIV', 'GetContent should not be called when data is already structured. This implementation should not be used for other IStructureDataType implementations.', Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', 'E-Document');
    end;

    procedure GetReadIntoDraftImpl(): Enum "E-Doc. Read into Draft"
    begin
        // By default we don't specify any way to read into draft.
        // If the data is already structured, the integration should supply the implementation
        exit("E-Doc. Read into Draft"::Unspecified);
    end;

    procedure ReadIntoDraft(EDocument: Record "E-Document"; TempBlob: Codeunit "Temp Blob"): Enum "E-Doc. Process Draft"
    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
    begin
        EDocumentPurchaseHeader.InsertForEDocument(EDocument);
    end;

    procedure View(EDocument: Record "E-Document"; TempBlob: Codeunit "Temp Blob")
    var
        NoDataErr: Label 'There is no data to view.';
    begin
        Error(NoDataErr);
    end;
}