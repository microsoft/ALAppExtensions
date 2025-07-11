namespace Microsoft.eServices.EDocument.IO.Peppol;

using Microsoft.eServices.EDocument;
using Microsoft.Sales.Customer;
using Microsoft.Sales.History;
using System.Utilities;
using Microsoft.Sales.Peppol;
using Microsoft.eServices.EDocument.Formats;
using Microsoft.Sales.Document;
using Microsoft.Purchases.Document;

codeunit 11035 "EDoc PEPPOL BIS 3.0 DE" implements "E-Document"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Sales Invoice Header" = rm,
        tabledata "Sales Cr.Memo Header" = rm;

    var
        EDocPEPPOLBIS30: Codeunit "EDoc PEPPOL BIS 3.0";
        UBLInvoiceNamespaceTxt: Label 'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2', Locked = true;
        UBLCrMemoNamespaceTxt: Label 'urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2', Locked = true;
        UBLCACNamespaceTxt: Label 'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2', Locked = true;
        UBLCBCNamespaceTxt: Label 'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2', Locked = true;

    procedure Check(var SourceDocumentHeader: RecordRef; EDocumentService: Record "E-Document Service"; EDocumentProcessingPhase: Enum "E-Document Processing Phase")
    begin
        CheckBuyerReferenceMandatory(EDocumentService, SourceDocumentHeader);
        EDocPEPPOLBIS30.Check(SourceDocumentHeader, EDocumentService, EDocumentProcessingPhase);
    end;

    procedure Create(EDocumentService: Record "E-Document Service"; var EDocument: Record "E-Document"; var SourceDocumentHeader: RecordRef; var SourceDocumentLines: RecordRef; var TempBlob: Codeunit "Temp Blob")
    begin
        // initialize Buyer Reference for sales document - it will be written to XML in OnAfterGetBuyerReference subscriber
        InitBuyerReference(EDocumentService."Buyer Reference", SourceDocumentHeader);

        EDocPEPPOLBIS30.Create(EDocumentService, EDocument, SourceDocumentHeader, SourceDocumentLines, TempBlob);

        RemoveSchemeIDAttributes(EDocument."Document Type", TempBlob);
    end;

    local procedure RemoveSchemeIDAttributes(EDocumentType: Enum "E-Document Type"; var TempBlob: Codeunit "Temp Blob")
    var
        XMLDoc: XmlDocument;
        XmlNSManager: XmlNamespaceManager;
        AttributeNodeList: XmlNodeList;
        XmlNode: XmlNode;
        InStream: InStream;
        OutStream: OutStream;
        DefaultNamespaceUri: Text;
        XmlDocText: Text;
    begin
        TempBlob.CreateInStream(InStream);
        XmlDocument.ReadFrom(InStream, XMLDoc);
        XmlNSManager.NameTable(XMLDoc.NameTable());

        case EDocumentType of
            Enum::"E-Document Type"::"Sales Invoice":
                DefaultNamespaceUri := UBLInvoiceNamespaceTxt;
            Enum::"E-Document Type"::"Sales Credit Memo":
                DefaultNamespaceUri := UBLCrMemoNamespaceTxt;
        end;
        XmlNSManager.AddNamespace('', DefaultNamespaceUri);
        XmlNSManager.AddNamespace('cac', UBLCACNamespaceTxt);
        XmlNSManager.AddNamespace('cbc', UBLCBCNamespaceTxt);

        // find all elements with the attribute "schemeID"
        XMLDoc.SelectNodes('//*[@*[local-name()=''schemeID'']]', XmlNSManager, AttributeNodeList);

        if AttributeNodeList.Count() = 0 then
            exit;

        // remove the "schemeID" attribute from each found element
        foreach XmlNode in AttributeNodeList do
            XmlNode.AsXmlElement().RemoveAttribute('schemeID');

        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        XMLDoc.WriteTo(XMLDocText);
        OutStream.WriteText(XMLDocText);
    end;

    procedure CreateBatch(EDocService: Record "E-Document Service"; var EDocument: Record "E-Document"; var SourceDocumentHeaders: RecordRef; var SourceDocumentsLines: RecordRef; var TempBlob: codeunit "Temp Blob");
    begin
    end;

    procedure GetBasicInfoFromReceivedDocument(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob")
    begin
        EDocPEPPOLBIS30.GetBasicInfoFromReceivedDocument(EDocument, TempBlob);
    end;

    procedure GetCompleteInfoFromReceivedDocument(var EDocument: Record "E-Document"; var CreatedDocumentHeader: RecordRef; var CreatedDocumentLines: RecordRef; var TempBlob: Codeunit "Temp Blob")
    var
        PurchaseHeader: Record "Purchase Header";
        BuyerReferenceFieldRef: FieldRef;
        BuyerReferenceValue: Text;
    begin
        EDocPEPPOLBIS30.GetCompleteInfoFromReceivedDocument(EDocument, CreatedDocumentHeader, CreatedDocumentLines, TempBlob);

        // extract BuyerReference from the XML
        BuyerReferenceValue := GetBuyerReferenceFromXml(EDocument."Document Type", TempBlob);
        if BuyerReferenceValue <> '' then begin
            BuyerReferenceFieldRef := CreatedDocumentHeader.Field(PurchaseHeader.FieldNo("Your Reference"));
            BuyerReferenceFieldRef.Validate(BuyerReferenceValue);
            CreatedDocumentHeader.Modify(true);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"E-Document Service", 'OnAfterValidateEvent', 'Document Format', false, false)]
    local procedure OnAfterValidateDocumentFormat(var Rec: Record "E-Document Service"; var xRec: Record "E-Document Service"; CurrFieldNo: Integer)
    var
        EDocServiceSupportedType: Record "E-Doc. Service Supported Type";
    begin
        if Rec."Document Format" <> Enum::"E-Document Format"::"PEPPOL BIS 3.0 DE" then
            exit;

        EDocServiceSupportedType.SetRange("E-Document Service Code", Rec.Code);
        if not EDocServiceSupportedType.IsEmpty() then
            exit;

        EDocServiceSupportedType.Init();
        EDocServiceSupportedType."E-Document Service Code" := Rec.Code;
        EDocServiceSupportedType."Source Document Type" := Enum::"E-Document Type"::"Sales Invoice";
        EDocServiceSupportedType.Insert();

        EDocServiceSupportedType."Source Document Type" := Enum::"E-Document Type"::"Sales Credit Memo";
        EDocServiceSupportedType.Insert();
    end;

    local procedure CheckBuyerReferenceMandatory(EDocumentService: Record "E-Document Service"; SourceDocumentHeader: RecordRef)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        CustomerNoFieldRef: FieldRef;
        YourReferenceFieldRef: FieldRef;
    begin
        if EDocumentService."Document Format" <> EDocumentService."Document Format"::"PEPPOL BIS 3.0 DE" then
            exit;

        if not EDocumentService."Buyer Reference Mandatory" then
            exit;

        case EDocumentService."Buyer Reference" of
            Enum::"E-Document Buyer Reference"::"Customer Reference":
                begin
                    CustomerNoFieldRef := SourceDocumentHeader.Field(SalesInvoiceHeader.FieldNo("Sell-to Customer No."));
                    Customer.Get(Format(CustomerNoFieldRef.Value));
                    Customer.TestField("E-Invoice Routing No.");
                end;
            Enum::"E-Document Buyer Reference"::"Your Reference":
                begin
                    YourReferenceFieldRef := SourceDocumentHeader.Field(SalesInvoiceHeader.FieldNo("Your Reference"));
                    YourReferenceFieldRef.TestField();
                end;
            else
                OnCheckBuyerReferenceOnElseCase(SourceDocumentHeader, EDocumentService);
        end;
    end;

    local procedure InitBuyerReference(BuyerReferenceType: Enum "E-Document Buyer Reference"; SourceDocumentHeader: RecordRef)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        Customer: Record Customer;
        CustomerNoFieldRef: FieldRef;
        YourReferenceFieldRef: FieldRef;
        BuyerReference: Text;
    begin
        case BuyerReferenceType of
            Enum::"E-Document Buyer Reference"::"Customer Reference":
                begin
                    CustomerNoFieldRef := SourceDocumentHeader.Field(SalesInvoiceHeader.FieldNo("Sell-to Customer No."));
                    Customer.Get(Format(CustomerNoFieldRef.Value));
                    BuyerReference := Customer."E-Invoice Routing No.";
                end;
            Enum::"E-Document Buyer Reference"::"Your Reference":
                begin
                    YourReferenceFieldRef := SourceDocumentHeader.Field(SalesInvoiceHeader.FieldNo("Your Reference"));
                    BuyerReference := Format(YourReferenceFieldRef.Value);
                end;
        end;

        case SourceDocumentHeader.Number() of
            Database::"Sales Invoice Header":
                begin
                    SourceDocumentHeader.SetTable(SalesInvoiceHeader);
                    SalesInvoiceHeader.Validate("Buyer Reference", BuyerReference);
                    SalesInvoiceHeader.Modify(true);
                end;
            Database::"Sales Cr.Memo Header":
                begin
                    SourceDocumentHeader.SetTable(SalesCrMemoHeader);
                    SalesCrMemoHeader.Validate("Buyer Reference", BuyerReference);
                    SalesCrMemoHeader.Modify(true);
                end;
        end;
    end;

    local procedure GetBuyerReferenceFromXml(EDocumentType: Enum "E-Document Type"; var TempBlob: Codeunit "Temp Blob") BuyerReference: Text
    var
        XMLDoc: XmlDocument;
        XmlNSManager: XmlNamespaceManager;
        BuyerReferenceNode: XmlNode;
        InStream: InStream;
        DefaultNamespaceUri: Text;
    begin
        TempBlob.CreateInStream(InStream);
        XmlDocument.ReadFrom(InStream, XMLDoc);
        XmlNSManager.NameTable(XMLDoc.NameTable());

        case EDocumentType of
            Enum::"E-Document Type"::"Sales Invoice":
                DefaultNamespaceUri := UBLInvoiceNamespaceTxt;
            Enum::"E-Document Type"::"Sales Credit Memo":
                DefaultNamespaceUri := UBLCrMemoNamespaceTxt;
        end;
        XmlNSManager.AddNamespace('', DefaultNamespaceUri);
        XmlNSManager.AddNamespace('cac', UBLCACNamespaceTxt);
        XmlNSManager.AddNamespace('cbc', UBLCBCNamespaceTxt);

        if XMLDoc.SelectSingleNode('//cbc:BuyerReference', XmlNSManager, BuyerReferenceNode) then
            BuyerReference := BuyerReferenceNode.AsXmlElement().InnerText()
        else
            BuyerReference := '';
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckBuyerReferenceOnElseCase(var SourceDocumentHeader: RecordRef; EDocumentService: Record "E-Document Service")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"PEPPOL Validation", 'OnCheckSalesDocumentOnBeforeCheckYourReference', '', false, false)]
    local procedure SkipCheckOnCheckSalesDocumentOnBeforeCheckYourReference(SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"PEPPOL Management", 'OnAfterGetBuyerReference', '', false, false)]
    local procedure SetReferenceOnAfterGetBuyerReference(SalesHeader: Record "Sales Header"; var BuyerReference: Text)
    begin
        BuyerReference := SalesHeader."Buyer Reference";
    end;
}