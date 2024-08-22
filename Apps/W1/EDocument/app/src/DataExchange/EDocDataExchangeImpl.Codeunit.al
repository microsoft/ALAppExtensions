// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.IO.Peppol;

using Microsoft.eServices.EDocument;
using Microsoft.Foundation.Company;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Peppol;
using Microsoft.Service.History;
using System.Text;
using Microsoft.Foundation.Attachment;
using Microsoft.Purchases.Document;
using System.IO;
using System.Reflection;
using System.Utilities;

codeunit 6152 "E-Doc. Data Exchange Impl." implements "E-Document"
{
    Access = Internal;
    procedure Check(var SourceDocumentHeader: RecordRef; EDocumentService: Record "E-Document Service"; EDocumentProcessingPhase: Enum "E-Document Processing Phase")
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        PEPPOLValidation: Codeunit "PEPPOL Validation";
        PEPPOLServiceValidation: Codeunit "PEPPOL Service Validation";
    begin
        case SourceDocumentHeader.Number of
            Database::"Sales Header":
                begin
                    SourceDocumentHeader.SetTable(SalesHeader);
                    PEPPOLValidation.Run(SalesHeader);
                end;
            Database::"Sales Invoice Header":
                begin
                    SourceDocumentHeader.SetTable(SalesInvoiceHeader);
                    PEPPOLValidation.CheckSalesInvoice(SalesInvoiceHeader);
                end;
            Database::"Sales Cr.Memo Header":
                begin
                    SourceDocumentHeader.SetTable(SalesCrMemoHeader);
                    PEPPOLValidation.CheckSalesCreditMemo(SalesCrMemoHeader);
                end;
            Database::"Service Invoice Header":
                begin
                    SourceDocumentHeader.SetTable(ServiceInvoiceHeader);
                    PEPPOLServiceValidation.CheckServiceInvoice(ServiceInvoiceHeader);
                end;
            Database::"Service Cr.Memo Header":
                begin
                    SourceDocumentHeader.SetTable(ServiceCrMemoHeader);
                    PEPPOLServiceValidation.CheckServiceCreditMemo(ServiceCrMemoHeader);
                end;
        end;
    end;

    procedure Create(EDocumentFormat: Record "E-Document Service"; var EDocument: Record "E-Document"; var SourceDocumentHeader: RecordRef; var SourceDocumentLines: RecordRef; var TempBlob: Codeunit "Temp Blob")
    var
        EDocumentDataExchDef: Record "E-Doc. Service Data Exch. Def.";
        DataExchMapping: Record "Data Exch. Mapping";
        DataExchDef: Record "Data Exch. Def";
        DataExch: Record "Data Exch.";
        DataExchTableFilter: Record "Data Exch. Table Filter";
        DocumentAttachment: Record "Document Attachment";
        DocumentAttachmentMgt: Codeunit "Document Attachment Mgmt";
        OutStreamFilters: OutStream;
        ErrorNoDataExchFound: ErrorInfo;
    begin
        ErrorNoDataExchFound.Title := 'E-Doc Service Data Exchange not found';
        ErrorNoDataExchFound.Message := StrSubstNo(EDocServDataExchErr, EDocumentFormat.Code, Format(EDocument."Document Type"));
        ErrorNoDataExchFound.RecordId := EDocumentFormat.RecordId;
        ErrorNoDataExchFound.PageNo := Page::"E-Document Service";
        ErrorNoDataExchFound.AddNavigationAction('Show E-Document Service');

        if not EDocumentDataExchDef.Get(EDocumentFormat.Code, EDocument."Document Type") then
            Error(ErrorNoDataExchFound);

        DataExchMapping.SetRange("Data Exch. Def Code", EDocumentDataExchDef."Expt. Data Exchange Def. Code");
        DataExchMapping.SetRange("Table ID", SourceDocumentLines.Number);
        if not DataExchMapping.FindFirst() then
            Error(NoDataExchMappingErr, DataExchMapping.TableCaption, DataExchDef.TableCaption, EDocumentDataExchDef."Expt. Data Exchange Def. Code");

        DataExch.Init();
        DataExch."Data Exch. Def Code" := DataExchMapping."Data Exch. Def Code";
        DataExch."Data Exch. Line Def Code" := DataExchMapping."Data Exch. Line Def Code";
        DataExch."Table Filters".CreateOutStream(OutStreamFilters);
        OutStreamFilters.WriteText(SourceDocumentLines.GetView());
        if DataExch.Insert(true) then begin
            OnAfterDataExchangeInsert(DataExch, EDocumentFormat, EDocument, SourceDocumentHeader, SourceDocumentLines);

            Clear(OutStreamFilters);
            SourceDocumentHeader.SetRecFilter();

            DataExchTableFilter.Init();
            DataExchTableFilter."Data Exch. No." := DataExch."Entry No.";
            DataExchTableFilter."Table ID" := SourceDocumentHeader.Number;
            DataExchTableFilter."Table Filters".CreateOutStream(OutStreamFilters);
            OutStreamFilters.WriteText(SourceDocumentHeader.GetView());
            DataExchTableFilter.Insert();

            // Create DataExchTableFilter for Document Attachments
            Clear(DataExchTableFilter);
            DataExchTableFilter."Data Exch. No." := DataExch."Entry No.";
            DataExchTableFilter."Table ID" := Database::"Document Attachment";
            DataExchTableFilter."Table Filters".CreateOutStream(OutStreamFilters);
            DocumentAttachmentMgt.SetDocumentAttachmentFiltersForRecRef(DocumentAttachment, SourceDocumentHeader);
            OutStreamFilters.WriteText(DocumentAttachment.GetView());
            DataExchTableFilter.Insert();

            OnBeforeDataExchangeExport(DataExch, EDocumentFormat, EDocument, SourceDocumentHeader, SourceDocumentLines);
            DataExch.ExportFromDataExch(DataExchMapping);
        end;
        DataExch.Modify(true);

        TempBlob.FromFieldRef(DataExch.RecordId.GetRecord().Field(3));
    end;

    procedure CreateBatch(EDocService: Record "E-Document Service"; var EDocument: Record "E-Document"; var SourceDocumentHeaders: RecordRef; var SourceDocumentsLines: RecordRef; var TempBlob: codeunit "Temp Blob");
    begin
        Error(BatchNotSupportedErr);
    end;

    procedure GetBasicInfoFromReceivedDocument(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob")
    var
    begin
        FindDataExchAndDocumentType(EDocument, TempBlob);
        UpdateEDocumentHeaderFields(EDocument, TempBlob);
    end;

    procedure GetCompleteInfoFromReceivedDocument(var EDocument: Record "E-Document"; var CreatedDocumentHeader: RecordRef; var CreatedDocumentLines: RecordRef; var TempBlob: Codeunit "Temp Blob")
    begin
        ProcessWithDataExch(EDocument, CreatedDocumentHeader, CreatedDocumentLines, TempBlob);
        EDocument.Get(EDocument."Entry No");
    end;

    local procedure FindDataExchAndDocumentType(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob")
    var
        DataExch: Record "Data Exch.";
        EDocumentDataExchDef: Record "E-Doc. Service Data Exch. Def.";
        DataExchDef: Record "Data Exch. Def";
        IntermediateDataImport: Record "Intermediate Data Import";
        BestDataExchValue: Integer;
    begin
        // Find the best possible data exchange to be able to retreive info 
        BestDataExchValue := 0;
        EDocumentDataExchDef.SetFilter("Impt. Data Exchange Def. Code", '<>%1', '');
        if EDocumentDataExchDef.FindSet() then
            repeat
                if DataExchDefUsesIntermediate(EDocumentDataExchDef."Impt. Data Exchange Def. Code") then begin
                    DataExchDef.Get(EDocumentDataExchDef."Impt. Data Exchange Def. Code");
                    CreateDataExch(DataExch, DataExchDef, TempBlob);
                    // Create Intermediate table records for each Data Exchange Type
                    if TryCreateIntermediate(DataExch, DataExchDef) then begin
                        IntermediateDataImport.SetRange("Data Exch. No.", DataExch."Entry No.");

                        // Update best result if this one is better
                        if IntermediateDataImport.Count > BestDataExchValue then begin
                            EDocument."Data Exch. Def. Code" := EDocumentDataExchDef."Impt. Data Exchange Def. Code";
                            EDocument."Document Type" := EDocumentDataExchDef."Document Type";
                            BestDataExchValue := IntermediateDataImport.Count();
                        end;

                        IntermediateDataImport.DeleteAll(true); // cleanup
                    end;
                    DataExch.Delete(true); // cleanup
                end;
            until EDocumentDataExchDef.Next() = 0;

        if EDocument."Document Type" = EDocument."Document Type"::None then
            Error(ProcessFailedErr);
    end;

    local procedure DataExchDefUsesIntermediate(DataExchDefCode: Code[20]): Boolean
    var
        DataExchMapping: Record "Data Exch. Mapping";
    begin
        // Ensure that the data exch def uses the intermediate table so we don't just start inserting data into the db.
        DataExchMapping.SetRange("Data Exch. Def Code", DataExchDefCode);
        DataExchMapping.SetRange("Use as Intermediate Table", false);
        exit(DataExchMapping.IsEmpty());
    end;

    local procedure CreateDataExch(var DataExch: Record "Data Exch."; DataExchDef: Record "Data Exch. Def"; var TempBlob: Codeunit "Temp Blob")
    var
        Stream: InStream;
    begin
        TempBlob.CreateInStream(Stream);

        DataExch.Init();
        DataExch.InsertRec('', Stream, DataExchDef.Code);
        DataExch.Modify(true);
    end;

    local procedure TryCreateIntermediate(DataExch: Record "Data Exch."; DataExchDef: Record "Data Exch. Def"): Boolean
    begin
        Commit();
        if DataExchDef."Reading/Writing Codeunit" <> 0 then begin
            if not Codeunit.Run(DataExchDef."Reading/Writing Codeunit", DataExch) then
                exit(false);

            if DataExchDef."Data Handling Codeunit" <> 0 then
                if not Codeunit.Run(DataExchDef."Data Handling Codeunit", DataExch) then
                    exit(false);
            exit(true);
        end;
        exit(false);
    end;

    local procedure UpdateEDocumentHeaderFields(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob")
    var
        xmlDoc: XmlDocument;
        InStream: InStream;
    begin
        TempBlob.CreateInStream(InStream);
        if XmlDocument.ReadFrom(InStream, xmlDoc) then
            ExtractHeaderFields(xmlDoc, EDocument);
    end;

    procedure ExtractHeaderFields(var xmlDoc: XmlDocument; var EDocument: Record "E-Document")
    var
        TempFieldBuffer: Record "Field Buffer" temporary;
    begin
        AddFieldToFieldBuffer(TempFieldBuffer, EDocument.FieldNo("Incoming E-Document No."));
        AddFieldToFieldBuffer(TempFieldBuffer, EDocument.FieldNo("Order No."));
        AddFieldToFieldBuffer(TempFieldBuffer, EDocument.FieldNo("Bill-to/Pay-to No."));
        AddFieldToFieldBuffer(TempFieldBuffer, EDocument.FieldNo("Bill-to/Pay-to Name"));
        AddFieldToFieldBuffer(TempFieldBuffer, EDocument.FieldNo("Document Date"));
        AddFieldToFieldBuffer(TempFieldBuffer, EDocument.FieldNo("Due Date"));
        AddFieldToFieldBuffer(TempFieldBuffer, EDocument.FieldNo("Receiving Company VAT Reg. No."));
        AddFieldToFieldBuffer(TempFieldBuffer, EDocument.FieldNo("Receiving Company GLN"));
        AddFieldToFieldBuffer(TempFieldBuffer, EDocument.FieldNo("Receiving Company Name"));
        AddFieldToFieldBuffer(TempFieldBuffer, EDocument.FieldNo("Receiving Company Address"));
        AddFieldToFieldBuffer(TempFieldBuffer, EDocument.FieldNo("Currency Code"));
        AddFieldToFieldBuffer(TempFieldBuffer, EDocument.FieldNo("Amount Excl. VAT"));
        AddFieldToFieldBuffer(TempFieldBuffer, EDocument.FieldNo("Amount Incl. VAT"));

        TempFieldBuffer.Reset();
        TempFieldBuffer.FindSet();
        repeat
            ExtractHeaderField(xmlDoc, EDocument, TempFieldBuffer."Field ID");
        until TempFieldBuffer.Next() = 0;
    end;

    local procedure ExtractHeaderField(var xmlDoc: XmlDocument; var EDocument: Record "E-Document"; FieldNo: Integer)
    var
        OCRServiceMgt: Codeunit "OCR Service Mgt.";
        ImportXMLFileToDataExch: Codeunit "Import XML File to Data Exch.";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        xmlNsManager: XmlNamespaceManager;
        xmlAttrCollection: XmlAttributeCollection;
        xmlAttribute: XmlAttribute;
        xmlNode: XmlNode;
        xmlElement: XmlElement;
        DateVar: Date;
        DecimalVar: Decimal;
        IntegerVar: Integer;
        GuidVar: Guid;
        XmlValue: Text;
        XPath: Text;
    begin
        XPath := GetDataExchangePath(EDocument, FieldNo);
        if XPath = '' then
            exit;
        XPath := ImportXMLFileToDataExch.EscapeMissingNamespacePrefix(XPath);
        RecRef.GetTable(EDocument);
        FieldRef := RecRef.Field(FieldNo);

        xmlNsManager.NameTable(xmlDoc.NameTable);
        xmlDoc.GetRoot(xmlElement);

        if xmlElement.NamespaceUri <> '' then
            xmlNsManager.AddNamespace('', xmlElement.NamespaceUri);

        xmlAttrCollection := xmlElement.Attributes();
        foreach xmlAttribute in xmlAttrCollection do
            if StrPos(xmlAttribute.Name, 'xmlns:') = 1 then
                xmlNsManager.AddNamespace(DelStr(xmlAttribute.Name, 1, 6), xmlAttribute.Value);

        if xmlDoc.SelectSingleNode(XPath, xmlNsManager, xmlNode) then
            XmlValue := xmlNode.AsXmlElement().InnerText()
        else
            XmlValue := '';

        case FieldRef.Type of
            FieldType::Text, FieldType::Code:
                FieldRef.Value := CopyStr(XmlValue, 1, FieldRef.Length);
            FieldType::Date:
                if Evaluate(DateVar, XmlValue, 9) then
                    FieldRef.Value := DateVar
                else
                    if Evaluate(DateVar, OCRServiceMgt.DateConvertYYYYMMDD2XML(XmlValue), 9) then
                        FieldRef.Value := DateVar;
            FieldType::Integer:
                if Evaluate(IntegerVar, XmlValue, 9) then
                    FieldRef.Value := IntegerVar;
            FieldType::Decimal:
                if Evaluate(DecimalVar, XmlValue, 9) then
                    FieldRef.Value := DecimalVar;
            FieldType::GUID:
                if Evaluate(GuidVar, XmlValue, 9) then
                    FieldRef.Value := GuidVar;
        end;
        RecRef.SetTable(EDocument);
    end;

    procedure AddFieldToFieldBuffer(var TempFieldBuffer: Record "Field Buffer" temporary; FieldID: Integer)
    begin
        TempFieldBuffer.Init();
        TempFieldBuffer.Order += 1;
        TempFieldBuffer."Table ID" := Database::"E-Document";
        TempFieldBuffer."Field ID" := FieldID;
        TempFieldBuffer.Insert();
    end;

    procedure GetDataExchangePath(EDocument: Record "E-Document"; FieldNumber: Integer): Text
    var
        CompanyInformation: Record "Company Information";
        DataExchLineDef: Record "Data Exch. Line Def";
        PurchaseHeader: Record "Purchase Header";
    begin
        DataExchLineDef.SetRange("Data Exch. Def Code", EDocument."Data Exch. Def. Code");
        DataExchLineDef.SetRange("Parent Code", '');
        if not DataExchLineDef.FindFirst() then
            exit('');

        if EDocument."Document Type" in [EDocument."Document Type"::"Purchase Invoice", EDocument."Document Type"::"Purchase Credit Memo"] then
            case FieldNumber of
                EDocument.FieldNo("Incoming E-Document No."):
                    begin
                        if EDocument."Document Type" = EDocument."Document Type"::"Purchase Invoice" then
                            exit(DataExchLineDef.GetPath(Database::"Purchase Header", PurchaseHeader.FieldNo("Vendor Invoice No.")));
                        if EDocument."Document Type" = EDocument."Document Type"::"Purchase Credit Memo" then
                            exit(DataExchLineDef.GetPath(Database::"Purchase Header", PurchaseHeader.FieldNo("Vendor Cr. Memo No.")));
                    end;
                EDocument.FieldNo("Order No."):
                    exit(DataExchLineDef.GetPath(Database::"Purchase Header", PurchaseHeader.FieldNo("Vendor Order No.")));
                EDocument.FieldNo("Bill-to/Pay-to Name"):
                    exit(DataExchLineDef.GetPath(Database::"Purchase Header", PurchaseHeader.FieldNo("Buy-from Vendor Name")));
                EDocument.FieldNo("Bill-to/Pay-to No."):
                    exit(DataExchLineDef.GetPath(Database::"Purchase Header", PurchaseHeader.FieldNo("Buy-from Vendor No.")));
                EDocument.FieldNo("Document Date"):
                    exit(DataExchLineDef.GetPath(Database::"Purchase Header", PurchaseHeader.FieldNo("Document Date")));
                EDocument.FieldNo("Due Date"):
                    exit(DataExchLineDef.GetPath(Database::"Purchase Header", PurchaseHeader.FieldNo("Due Date")));
                EDocument.FieldNo("Currency Code"):
                    exit(DataExchLineDef.GetPath(Database::"Purchase Header", PurchaseHeader.FieldNo("Currency Code")));
                EDocument.FieldNo("Amount Excl. VAT"):
                    exit(DataExchLineDef.GetPath(Database::"Purchase Header", PurchaseHeader.FieldNo(Amount)));
                EDocument.FieldNo("Amount Incl. VAT"):
                    exit(DataExchLineDef.GetPath(Database::"Purchase Header", PurchaseHeader.FieldNo("Amount Including VAT")));
                EDocument.FieldNo("Receiving Company VAT Reg. No."):
                    exit(DataExchLineDef.GetPath(Database::"Company Information", CompanyInformation.FieldNo("VAT Registration No.")));
                EDocument.FieldNo("Receiving Company GLN"):
                    exit(DataExchLineDef.GetPath(Database::"Company Information", CompanyInformation.FieldNo(GLN)));
                EDocument.FieldNo("Receiving Company Name"):
                    exit(DataExchLineDef.GetPath(Database::"Company Information", CompanyInformation.FieldNo(Name)));
                EDocument.FieldNo("Receiving Company Address"):
                    exit(DataExchLineDef.GetPath(Database::"Company Information", CompanyInformation.FieldNo(Address)));
            end;

        exit('');
    end;

    local procedure ProcessWithDataExch(var EDocument: Record "E-Document"; var CreatedDocumentHeader: RecordRef; var CreatedDocumentLines: RecordRef; var TempBlob: Codeunit "Temp Blob")
    var
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        Stream: InStream;
    begin
        DataExchDef.Get(EDocument."Data Exch. Def. Code");
        if DataExchDefUsesIntermediate(DataExchDef.Code) then begin
            TempBlob.CreateInStream(Stream);

            DataExch.Init();
            DataExch.InsertRec('', Stream, DataExchDef.Code);
            DataExch."Related Record" := EDocument.RecordId;
            DataExch.Modify(true);

            if not DataExch.ImportToDataExch(DataExchDef) then
                Error(ProcessFailedErr);

            DataExchDef.ProcessDataExchange(DataExch);

            ProcessIntermediateData(EDocument, DataExch, CreatedDocumentHeader, CreatedDocumentLines);
            DeleteIntermediateData(DataExch);
        end;
    end;

    local procedure ProcessIntermediateData(var EDocument: Record "E-Document"; DataExch: Record "Data Exch."; var CreatedDocumentHeader: RecordRef; var CreatedDocumentLines: RecordRef)
    begin
        ProcessHeaders(EDocument, DataExch, CreatedDocumentHeader, CreatedDocumentLines);
    end;

    local procedure ProcessHeaders(var EDocument: Record "E-Document"; DataExch: Record "Data Exch."; var CreatedDocumentHeader: RecordRef; var CreatedDocumentLines: RecordRef)
    var
        DocumentAttachment: Record "Document Attachment";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        IntermediateDataImport: Record "Intermediate Data Import";
        EDocAttachmentProcessor: Codeunit "E-Doc. Attachment Processor";
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        FldRef: FieldRef;
        CurrRecordNo, LineNo : Integer;
        InStream: InStream;
        OutStream: OutStream;
        FileName, Base64Data : Text;
    begin
        CurrRecordNo := -1;

        if EDocument."Document Type" in [EDocument."Document Type"::"Purchase Invoice", EDocument."Document Type"::"Purchase Credit Memo"] then begin
            IntermediateDataImport.SetRange("Data Exch. No.", DataExch."Entry No.");
            IntermediateDataImport.SetRange("Table ID", Database::"Purchase Header");
            IntermediateDataImport.SetRange("Parent Record No.", 0);
            IntermediateDataImport.SetCurrentKey("Record No.");

            if not IntermediateDataImport.FindSet() then
                exit;

            CreatedDocumentHeader.Init();
            repeat
                FldRef := CreatedDocumentHeader.Field(IntermediateDataImport."Field ID");
                if FldRef.Class = FldRef.Class::Normal then
                    SetFieldValue(FldRef, CopyStr(IntermediateDataImport.GetValue(), 1, 250));
            until IntermediateDataImport.Next() = 0;
            CreatedDocumentHeader.Insert();

            IntermediateDataImport.Reset();
            IntermediateDataImport.SetRange("Data Exch. No.", DataExch."Entry No.");
            IntermediateDataImport.SetRange("Table ID", Database::"Purchase Line");
            IntermediateDataImport.SetCurrentKey("Record No.");

            if not IntermediateDataImport.FindSet() then
                exit;

            repeat
                if CurrRecordNo <> IntermediateDataImport."Record No." then begin
                    if CurrRecordNo <> -1 then
                        CreatedDocumentLines.Insert();
                    LineNo += 10000;
                    CreatedDocumentLines.Init();
                    CreatedDocumentLines.Field(PurchaseLine.FieldNo("Document Type")).Value(CreatedDocumentHeader.Field(PurchaseHeader.FieldNo("Document Type")));
                    CreatedDocumentLines.Field(PurchaseLine.FieldNo("Document No.")).Value(CreatedDocumentHeader.Field(PurchaseHeader.FieldNo("No.")));
                    CreatedDocumentLines.Field(PurchaseLine.FieldNo("Line No.")).Value(LineNo);

                    CurrRecordNo := IntermediateDataImport."Record No.";
                end;

                FldRef := CreatedDocumentLines.Field(IntermediateDataImport."Field ID");
                if FldRef.Class = FldRef.Class::Normal then
                    SetFieldValue(FldRef, CopyStr(IntermediateDataImport.GetValue(), 1, 250));
            until IntermediateDataImport.Next() = 0;
            CreatedDocumentLines.Insert();

            IntermediateDataImport.Reset();
            IntermediateDataImport.SetRange("Data Exch. No.", DataExch."Entry No.");
            IntermediateDataImport.SetRange("Table ID", Database::"Document Attachment");
            IntermediateDataImport.SetCurrentKey("Record No.");

            if not IntermediateDataImport.FindSet() then
                exit;

            CurrRecordNo := -1;
            repeat
                if CurrRecordNo <> IntermediateDataImport."Record No." then begin
                    if CurrRecordNo <> -1 then begin
                        TempBlob.CreateInStream(InStream);
                        EDocAttachmentProcessor.Insert(EDocument, InStream, FileName);
                        FileName := '';
                    end;
                    CurrRecordNo := IntermediateDataImport."Record No.";
                end;

                case IntermediateDataImport."Field ID" of
                    DocumentAttachment.FieldNo("File Name"):
                        FileName := IntermediateDataImport.Value;
                    DocumentAttachment.FieldNo("Document Reference ID"):
                        begin
                            // Read data as Base 64 value, and convert it.
                            IntermediateDataImport.CalcFields("Value BLOB");
                            IntermediateDataImport."Value BLOB".CreateInStream(InStream);
                            InStream.ReadText(Base64Data);
                            TempBlob.CreateOutStream(OutStream);
                            Base64Convert.FromBase64(Base64Data, OutStream);
                        end;
                end;
            until IntermediateDataImport.Next() = 0;

            // Process last attachment if any
            if FileName <> '' then begin
                TempBlob.CreateInStream(InStream);
                EDocAttachmentProcessor.Insert(EDocument, InStream, FileName);
            end;
        end;
    end;

    local procedure DeleteIntermediateData(DataExch: Record "Data Exch.")
    var
        DataExchField: Record "Data Exch. Field";
        IntermediateDataImport: Record "Intermediate Data Import";
    begin
        DataExchField.SetRange("Data Exch. No.", DataExch."Entry No.");
        DataExchField.DeleteAll();
        IntermediateDataImport.SetRange("Data Exch. No.", DataExch."Entry No.");
        IntermediateDataImport.DeleteAll();
    end;

    local procedure SetFieldValue(var FieldRef: FieldRef; Value: Text[250])
    var
        ConfigValidateManagement: Codeunit "Config. Validate Management";
        ErrorText: Text;
    begin
        TruncateValueToFieldLength(FieldRef, Value);
        ErrorText := ConfigValidateManagement.EvaluateValue(FieldRef, Value, false);
        if ErrorText <> '' then
            Error(ErrorText);
    end;

    local procedure TruncateValueToFieldLength(FieldRef: FieldRef; var Value: Text[250])
    begin
        if FieldRef.Type in [FieldType::Code, FieldType::Text] then
            Value := CopyStr(Value, 1, FieldRef.Length);
    end;

    /// <summary>
    /// Allow for empty Data Exch filtering.
    /// Example: Document Attachments might not exist for document, so dont throw error if no record exists.
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Export Mapping", 'OnBeforeCheckRecRefCount', '', true, true)]
    local procedure OnBeforeCheckRecRefCount(var IsHandled: Boolean; DataExchMapping: Record "Data Exch. Mapping")
    var
        EDocServiceDataExchDef: Record "E-Doc. Service Data Exch. Def.";
    begin
        if EDocServiceDataExchDef.FindSet() then
            repeat
                if EDocServiceDataExchDef."Expt. Data Exchange Def. Code" = DataExchMapping."Data Exch. Def Code" then
                    IsHandled := true;
            until EDocServiceDataExchDef.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDataExchangeInsert(var DataExch: Record "Data Exch."; EDocumentFormat: Record "E-Document Service"; var EDocument: Record "E-Document"; var SourceDocumentHeader: RecordRef; var SourceDocumentLines: RecordRef);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDataExchangeExport(var DataExch: Record "Data Exch."; EDocumentFormat: Record "E-Document Service"; var EDocument: Record "E-Document"; var SourceDocumentHeader: RecordRef; var SourceDocumentLines: RecordRef);
    begin
    end;

    var
        NoDataExchMappingErr: Label '%1 for %2 %3 does not exist.', Comment = '%1 - Data Exchange Mapping caption, %2 - Data Exchange Definition caption, %3 - Data Exchange Definition code';
        ProcessFailedErr: Label 'Failed to process the file with data exchange.';
        BatchNotSupportedErr: Label 'Batch processing is not supported with.';
        EDocServDataExchErr: Label 'Data Exchange not defined for E-Document Service %1 and Document Type %2.', Comment = '%1 - E-Document Service code, %2 - E-Document Document Type';
}