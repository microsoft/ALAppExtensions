// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;

using Microsoft.eServices.EDocument;
using System.Utilities;

codeunit 10970 "E-Reporting FR Format" implements "E-Document"
{
    Access = Internal;

    procedure Check(var SourceDocumentHeader: RecordRef; EDocumentService: Record "E-Document Service"; EDocumentProcessingPhase: Enum "E-Document Processing Phase")
    begin
    end;

    /// <summary>
    /// Creates the e-reporting XML for a single E-Document by delegating to the Export E-Reporting FR codeunit.
    /// </summary>
    /// <param name="EDocumentService">The E-Document Service record.</param>
    /// <param name="EDocument">The E-Document record to export.</param>
    /// <param name="SourceDocumentHeader">The source document header reference.</param>
    /// <param name="SourceDocumentLines">The source document lines reference.</param>
    /// <param name="TempBlob">The Temp Blob to write the generated XML to.</param>
    procedure Create(EDocumentService: Record "E-Document Service"; var EDocument: Record "E-Document"; var SourceDocumentHeader: RecordRef; var SourceDocumentLines: RecordRef; var TempBlob: Codeunit "Temp Blob")
    var
        EDocumentSingle: Record "E-Document";
        ExportEReportingFR: Codeunit "Export E-Reporting FR";
    begin
        EDocumentSingle.SetRange("Entry No", EDocument."Entry No");
        ExportEReportingFR.CreateBatchXML(EDocumentSingle, TempBlob);
    end;

    /// <summary>
    /// Creates the e-reporting batch XML for multiple E-Documents by delegating to the Export E-Reporting FR codeunit.
    /// </summary>
    /// <param name="EDocumentService">The E-Document Service record.</param>
    /// <param name="EDocuments">The E-Document records to include in the batch export.</param>
    /// <param name="SourceDocumentHeaders">The source document headers reference.</param>
    /// <param name="SourceDocumentsLines">The source document lines reference.</param>
    /// <param name="TempBlob">The Temp Blob to write the generated XML to.</param>
    procedure CreateBatch(EDocumentService: Record "E-Document Service"; var EDocuments: Record "E-Document"; var SourceDocumentHeaders: RecordRef; var SourceDocumentsLines: RecordRef; var TempBlob: Codeunit "Temp Blob")
    var
        ExportEReportingFR: Codeunit "Export E-Reporting FR";
    begin
        ExportEReportingFR.CreateBatchXML(EDocuments, TempBlob);
    end;

    procedure GetBasicInfoFromReceivedDocument(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob")
    begin
    end;

    procedure GetCompleteInfoFromReceivedDocument(var EDocument: Record "E-Document"; var CreatedDocumentHeader: RecordRef; var CreatedDocumentLines: RecordRef; var TempBlob: Codeunit "Temp Blob")
    begin
        Error(GetCompleteInfoNotSupportedErr);
    end;

    [EventSubscriber(ObjectType::Table, Database::"E-Document Service", 'OnAfterValidateEvent', 'Document Format', false, false)]
    local procedure OnAfterValidateDocumentFormat(var Rec: Record "E-Document Service"; var xRec: Record "E-Document Service"; CurrFieldNo: Integer)
    var
        EDocServiceSupportedType: Record "E-Doc. Service Supported Type";
    begin
        if Rec."Document Format" <> Rec."Document Format"::"E-Reporting FR" then
            exit;

        EDocServiceSupportedType.SetRange("E-Document Service Code", Rec.Code);
        if not EDocServiceSupportedType.IsEmpty() then
            exit;

        EDocServiceSupportedType.Init();
        EDocServiceSupportedType."E-Document Service Code" := Rec.Code;
        EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Sales Invoice";
        EDocServiceSupportedType.Insert();

        EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Sales Credit Memo";
        EDocServiceSupportedType.Insert();

        EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Purchase Invoice";
        EDocServiceSupportedType.Insert();

        EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Purchase Credit Memo";
        EDocServiceSupportedType.Insert();

        EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Service Invoice";
        EDocServiceSupportedType.Insert();

        EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Service Credit Memo";
        EDocServiceSupportedType.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"E-Document", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SetClearanceDateOnModify(var Rec: Record "E-Document"; var xRec: Record "E-Document"; RunTrigger: Boolean)
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocumentService: Record "E-Document Service";
    begin
        if Rec.Service = '' then
            exit;

        EDocumentService.SetLoadFields("Document Format");
        if not EDocumentService.Get(Rec.Service) then
            exit;

        if EDocumentService."Document Format" <> EDocumentService."Document Format"::"E-Reporting FR" then
            exit;

        if not EDocumentServiceStatus.Get(Rec."Entry No", Rec.Service) then
            exit;

        case EDocumentServiceStatus.Status of
            EDocumentServiceStatus.Status::Approved,
            EDocumentServiceStatus.Status::Cleared:
                Rec."Clearance Date" := CurrentDateTime();
            EDocumentServiceStatus.Status::Rejected,
            EDocumentServiceStatus.Status::"Not Cleared":
                Rec."Clearance Date" := 0DT;
        end;
    end;

    var
        GetCompleteInfoNotSupportedErr: Label 'Getting complete info from received document is not supported for this e-document format.';
}
