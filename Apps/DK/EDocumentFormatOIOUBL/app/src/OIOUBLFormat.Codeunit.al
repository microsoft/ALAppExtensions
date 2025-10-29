// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using Microsoft.Foundation.Company;
using Microsoft.Purchases.Document;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Certificate;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Service.Document;
using Microsoft.Service.History;
using Microsoft.Sales.FinanceCharge;
using Microsoft.Sales.Reminder;
using System.Utilities;
using System.IO;
using Microsoft.Sustainability.Setup;
using Microsoft.Inventory.Item;

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
    var
        OIOUBLEDOCExportSession: Record "OIOUBL E-Doc. Export Session";
    begin
        CleanExportSession(EDocument."Entry No", EDocumentService.Code);
        OIOUBLEDOCExportSession."E-Document Entry No." := EDocument."Entry No";
        OIOUBLEDOCExportSession."E-Document Service Code" := EDocumentService.Code;
        if OIOUBLEDOCExportSession.Insert() then;

        CreateSourceDocumentBlob(SourceDocumentHeader, TempBlob);

        CleanExportSession(EDocument."Entry No", EDocumentService.Code);
    end;

    local procedure CleanExportSession(EDocumentEntryNo: Integer; EDocumentServiceCode: Code[20])
    var
        OIOUBLEDOCExportSession: Record "OIOUBL E-Doc. Export Session";
    begin
        OIOUBLEDOCExportSession.ReadIsolation := IsolationLevel::ReadUncommitted;
        OIOUBLEDOCExportSession.SetRange("E-Document Entry No.", EDocumentEntryNo);
        OIOUBLEDOCExportSession.SetRange("E-Document Service Code", EDocumentServiceCode);
        OIOUBLEDOCExportSession.DeleteAll();
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

    local procedure InsertCertificate(var RootElement: XmlElement; Item: Record Item);
    var
        SustainabilityCertificate: Record "Sustainability Certificate";
        SustCertificateArea: Record "Sust. Certificate Area";
        OIOUBLCommonLogic: Codeunit "OIOUBL-Common Logic";
        ItemElement: XmlElement;
        CACNamespace, CBCNamespace : Text[250];
    begin
        if Item."Sust. Cert. No." = '' then
            exit;
        if not SustainabilityCertificate.Get(SustainabilityCertificate.Type::Item, Item."Sust. Cert. No.") then
            exit;

        OIOUBLCommonLogic.init(CACNamespace, CBCNamespace);

        ItemElement := XmlElement.Create('Certificate', CACNamespace);
        ItemElement.Add(XmlElement.Create('ID', CBCNamespace, Item."Sust. Cert. Name"));
        ItemElement.Add(XmlElement.Create('CertificateTypeCode', CBCNamespace, Item."Sust. Cert. No."));
        if SustainabilityCertificate."Area" <> '' then begin
            SustCertificateArea.Get(SustainabilityCertificate."Area");
            ItemElement.Add(XmlElement.Create('CertificateType', CBCNamespace, SustCertificateArea.Name));
        end;
        RootElement.Add(ItemElement);
    end;

    local procedure InsertEmissions(var RootElement: XmlElement; Item: Record Item; Quantity: Decimal; UOMCode: Code[10]);
    var
        SustainabilityAccount: Record "Sustainability Account";
        SustSubAccount: Record "Sustain. Account Subcategory";
        OIOUBLDocumentEncode: Codeunit "OIOUBL-Document Encode";
        OIOUBLCommonLogic: Codeunit "OIOUBL-Common Logic";
        ItemElement: XmlElement;
        CACNamespace, CBCNamespace : Text[250];
    begin
        if Item."Default Sust. Account" = '' then
            exit;

        if not SustainabilityAccount.Get(Item."Default Sust. Account") then
            exit;

        if not SustSubAccount.Get(SustainabilityAccount.Category, SustainabilityAccount.Subcategory) then
            exit;

        OIOUBLCommonLogic.init(CACNamespace, CBCNamespace);

        if SustSubAccount."Import From" <> '' then begin
            ItemElement := XmlElement.Create('ItemSpecificationDocumentReference', CACNamespace);
            ItemElement.Add(XmlElement.Create('ID', CBCNamespace, 'CO2EmissionFactorSource'));
            ItemElement.Add(XmlElement.Create('URI', CBCNamespace, SustSubAccount."Import From"));
            RootElement.Add(ItemElement);
        end;

        ItemElement := XmlElement.Create('AdditionalItemProperty', CACNamespace);
        ItemElement.Add(XmlElement.Create('Name', CBCNamespace, 'EmissionFactor'));
        ItemElement.Add(XmlElement.Create('Value', CBCNamespace, Format(Item."CO2e per Unit", 0, 9)));
        RootElement.Add(ItemElement);

        ItemElement := XmlElement.Create('AdditionalItemProperty', CACNamespace);
        ItemElement.Add(XmlElement.Create('Name', CBCNamespace, 'NetEmissionQuantity'));
        ItemElement.Add(XmlElement.Create('Value', CBCNamespace, Format(Quantity * Item."CO2e per Unit", 0, 9)));
        RootElement.Add(ItemElement);

        ItemElement := XmlElement.Create('AdditionalItemProperty', CACNamespace);
        ItemElement.Add(XmlElement.Create('Name', CBCNamespace, 'EmissionFactorSource'));
        ItemElement.Add(XmlElement.Create('Value', CBCNamespace, 'Database'));
        RootElement.Add(ItemElement);

        ItemElement := XmlElement.Create('AdditionalItemProperty', CACNamespace);
        ItemElement.Add(XmlElement.Create('Name', CBCNamespace, 'EmissionFactorCalculationUnit'));
        ItemElement.Add(XmlElement.Create('Value', CBCNamespace, OIOUBLDocumentEncode.GetUoMCode(UOMCode)));
        RootElement.Add(ItemElement);

    end;


    local procedure InsertClassificationCode(var RootElement: XmlElement; Item: Record Item);
    var
        OIOUBLCommonLogic: Codeunit "OIOUBL-Common Logic";
        ItemElement: XmlElement;
        CACNamespace, CBCNamespace : Text[250];
    begin
        if Item."Product Classification Code" = '' then
            exit;

        OIOUBLCommonLogic.init(CACNamespace, CBCNamespace);

        case Item."Product Classification Type" of
            Item."Product Classification Type"::"UNSPSC":
                begin
                    ItemElement := XmlElement.Create('ItemClassificationCode', CBCNamespace,
                        XmlAttribute.Create('listID', 'TST'),
                        XmlAttribute.Create('listVersionID', ' 19.0501'),
                        Item."Product Classification Code");
                    RootElement.Add(ItemElement);
                end;
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"OIOUBL-Export Sales Invoice", OnExportXMLOnAfterInsertInvoiceLine, '', false, false)]
    local procedure OnExportXMLOnAfterInsertInvoiceLine(var InvoiceLineElement: XmlElement; SalesInvoiceHeader: Record "Sales Invoice Header"; SalesInvoiceLine: Record "Sales Invoice Line"; CurrencyCode: Code[10])
    var
        Item: Record Item;
    begin
        // Add sustainability information to the invoice line element
        if not IsSustainabilityInEDocumentsEnabled(SalesInvoiceHeader) then
            exit;

        if SalesInvoiceLine.Type <> SalesInvoiceLine.Type::Item then
            exit;

        Item.Get(SalesInvoiceLine."No.");

        InsertCertificate(InvoiceLineElement, Item);
        InsertEmissions(InvoiceLineElement, Item, SalesInvoiceLine.Quantity, SalesInvoiceLine."Unit of Measure Code");
        InsertClassificationCode(InvoiceLineElement, Item);
    end;

    local procedure IsSustainabilityInEDocumentsEnabled(SalesInvoiceHeader: Record "Sales Invoice Header"): Boolean
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        OIOUBLEDocExportSession: Record "OIOUBL E-Doc. Export Session";
        SustainabilitySetup: Record "Sustainability Setup";
    begin
        SustainabilitySetup.GetRecordOnce();
        if not SustainabilitySetup."Use Sustainability in E-Doc." then
            exit;

        // Custom logic for handling the invoice line export
        EDocument.SetLoadFields("Entry No", "Document Record ID");
        EDocument.SetRange("Document Record ID", SalesInvoiceHeader.RecordId);
        if not EDocument.FindFirst() then
            exit;

        OIOUBLEDocExportSession.SetRange("E-Document Entry No.", EDocument."Entry No");
        if not OIOUBLEDocExportSession.FindLast() then
            exit;

        if not EDocumentService.Get(OIOUBLEDocExportSession."E-Document Service Code") then
            exit;
        if EDocumentService."Document Format" <> EDocumentService."Document Format"::OIOUBL then
            exit;

        exit(SustainabilitySetup."Use Sustainability in E-Doc.");
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