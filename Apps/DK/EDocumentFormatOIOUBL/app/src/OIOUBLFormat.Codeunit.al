// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using Microsoft.Foundation.Company;
using Microsoft.Purchases.Document;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Service.Document;
using Microsoft.Service.History;
using Microsoft.Sales.FinanceCharge;
using Microsoft.Sales.Reminder;
using System.Utilities;
using System.IO;

codeunit 13910 "OIOUBL Format" implements "E-Document"
{
    procedure Check(var SourceDocumentHeader: RecordRef; EDocumentService: Record "E-Document Service"; EDocumentProcessingPhase: Enum "E-Document Processing Phase")
    var
        SalesHeader: Record "Sales Header";
        ServiceHeader: Record "Service Header";
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        if StrLen(CompanyInformation."Bank Branch No.") > 4 then
            Error(CompanyBankBranchNoErr); // OIOUBL schematron verification for FinancialInstitutionBranch/ID (Registreringsnummer)

        case SourceDocumentHeader.Number of
            Database::"Sales Header":
                case EDocumentProcessingPhase of
                    EDocumentProcessingPhase::Release:
                        begin
                            SourceDocumentHeader.Field(SalesHeader.FieldNo("External Document No.")).TestField();
                            SourceDocumentHeader.Field(SalesHeader.FieldNo("Your Reference")).TestField();
                        end;
                    EDocumentProcessingPhase::Post:
                        begin
                            SourceDocumentHeader.Field(SalesHeader.FieldNo("External Document No.")).TestField();
                            SourceDocumentHeader.Field(SalesHeader.FieldNo("Your Reference")).TestField();
                        end;
                end;
            Database::"Service Header":
                case EDocumentProcessingPhase of
                    EDocumentProcessingPhase::Release:
                        SourceDocumentHeader.Field(ServiceHeader.FieldNo("Your Reference")).TestField();
                    EDocumentProcessingPhase::Post:
                        SourceDocumentHeader.Field(ServiceHeader.FieldNo("Your Reference")).TestField();
                end;
        end;
    end;

    procedure Create(EDocumentService: Record "E-Document Service"; var EDocument: Record "E-Document"; var SourceDocumentHeader: RecordRef; var SourceDocumentLines: RecordRef; var TempBlob: Codeunit "Temp Blob")
    begin
        CreateSourceDocumentBlob(SourceDocumentHeader, TempBlob);
    end;

    procedure CreateBatch(EDocumentService: Record "E-Document Service"; var EDocuments: Record "E-Document"; var SourceDocumentHeaders: RecordRef; var SourceDocumentsLines: RecordRef; var TempBlob: Codeunit "Temp Blob")
    begin

    end;

    procedure GetBasicInfoFromReceivedDocument(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob")
    begin
        ImportOIOUBL.ParseBasicInfo(EDocument, TempBlob);
    end;

    procedure GetCompleteInfoFromReceivedDocument(var EDocument: Record "E-Document"; var CreatedDocumentHeader: RecordRef; var CreatedDocumentLines: RecordRef; var TempBlob: Codeunit "Temp Blob")
    var
        TempPurchaseHeader: Record "Purchase Header" temporary;
        TempPurchaseLine: Record "Purchase Line" temporary;
    begin
        ImportOIOUBL.ParseCompleteInfo(EDocument, TempPurchaseHeader, TempPurchaseLine, TempBlob);

        CreatedDocumentHeader.GetTable(TempPurchaseHeader);
        CreatedDocumentLines.GetTable(TempPurchaseLine);
    end;

    local procedure CreateSourceDocumentBlob(DocumentRecordRef: RecordRef; var TempBlob: Codeunit "Temp Blob")
    var
        TempRecordExportBuffer: Record "Record Export Buffer" temporary;
        IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header";
        IssuedReminderHeader: Record "Issued Reminder Header";
        OIOUBLExpIssuedFinChrg: Codeunit "OIOUBL-Exp. Issued Fin. Chrg";
        OIOUBLExportIssuedReminder: Codeunit "OIOUBL-Export Issued Reminder";
        InStreamXML: InStream;
    begin
        if DocumentRecordRef.Number in [Database::"Issued Fin. Charge Memo Header", Database::"Issued Reminder Header"] then
            case DocumentRecordRef.Number of
                Database::"Issued Fin. Charge Memo Header":
                    begin
                        DocumentRecordRef.SetTable(IssuedFinChargeMemoHeader);
                        OIOUBLExpIssuedFinChrg.GenerateTempBlob(IssuedFinChargeMemoHeader, TempBlob);
                    end;
                Database::"Issued Reminder Header":
                    begin
                        DocumentRecordRef.SetTable(IssuedReminderHeader);
                        OIOUBLExportIssuedReminder.GenerateTempBlob(IssuedReminderHeader, TempBlob);
                    end;
            end
        else begin
        TempRecordExportBuffer.RecordID := DocumentRecordRef.RecordId;
        TempRecordExportBuffer.Insert();

        case DocumentRecordRef.Number of
            Database::"Sales Invoice Header":
                Codeunit.Run(Codeunit::"OIOUBL-Export Sales Invoice", TempRecordExportBuffer);
            Database::"Sales Cr.Memo Header":
                Codeunit.Run(Codeunit::"OIOUBL-Export Sales Cr. Memo", TempRecordExportBuffer);
            Database::"Service Invoice Header":
                Codeunit.Run(Codeunit::"OIOUBL-Export Service Invoice", TempRecordExportBuffer);
            Database::"Service Cr.Memo Header":
                Codeunit.Run(Codeunit::"OIOUBL-Export Service Cr.Memo", TempRecordExportBuffer);
        end;

        if not TempRecordExportBuffer."File Content".HasValue() then
            exit;

        TempRecordExportBuffer."File Content".CreateInStream(InStreamXML);
        TempBlob.FromRecord(TempRecordExportBuffer, TempRecordExportBuffer.FieldNo("File Content"));
    end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"E-Document Service", 'OnAfterValidateEvent', 'Document Format', false, false)]
    local procedure OnAfterValidateDocumentFormat(var Rec: Record "E-Document Service"; var xRec: Record "E-Document Service"; CurrFieldNo: Integer)
    var
        EDocServiceSupportedType: Record "E-Doc. Service Supported Type";
    begin
        if Rec."Document Format" = Rec."Document Format"::OIOUBL then begin
            EDocServiceSupportedType.SetRange("E-Document Service Code", Rec.Code);
            if EDocServiceSupportedType.IsEmpty() then begin
                EDocServiceSupportedType.Init();
                EDocServiceSupportedType."E-Document Service Code" := Rec.Code;
                EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Sales Invoice";
                EDocServiceSupportedType.Insert();

                EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Sales Credit Memo";
                EDocServiceSupportedType.Insert();

                EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Service Invoice";
                EDocServiceSupportedType.Insert();

                EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Service Credit Memo";
                EDocServiceSupportedType.Insert();

                EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Issued Finance Charge Memo";
                EDocServiceSupportedType.Insert();

                EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Issued Reminder";
                EDocServiceSupportedType.Insert();
            end;
        end;
    end;

    var
        ImportOIOUBL: Codeunit "EDoc Import OIOUBL";
        CompanyBankBranchNoErr: Label 'Bank Branch No. must be no more than 4 numerical characters.';
}