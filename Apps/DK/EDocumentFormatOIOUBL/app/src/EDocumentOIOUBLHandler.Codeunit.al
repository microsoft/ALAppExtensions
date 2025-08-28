// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using Microsoft.eServices.EDocument.Processing.Interfaces;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.eServices.EDocument.Service.Participant;
using Microsoft.eServices.EDocument.Helpers;
using Microsoft.Purchases.Vendor;
using System.Utilities;

codeunit 13913 "E-Document OIOUBL Handler" implements IStructuredFormatReader
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        GLNTok: Label 'GLN', Locked = true;
        InvoiceLineTok: Label 'cac:InvoiceLine', Locked = true;
        CreditNoteLineTok: Label 'cac:CreditNoteLine', Locked = true;

    /// <summary>
    /// Reads an OIOUBL format XML document and converts it into a draft purchase document.
    /// This procedure processes Invoice, CreditNote and Reminder document types and populates the E-Document Purchase Header with the extracted data.
    /// </summary>
    /// <param name="EDocument">The E-Document record that contains the document metadata and information.</param>
    /// <param name="TempBlob">A temporary blob containing the XML document stream to be processed.</param>
    /// <returns>Returns an enum indicating that the process resulted in a purchase document draft.</returns>
    internal procedure ReadIntoDraft(EDocument: Record "E-Document"; TempBlob: Codeunit "Temp Blob"): Enum "E-Doc. Process Draft"
    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        OIOUBLXml: XmlDocument;
        XmlNamespaces: XmlNamespaceManager;
        XmlElement: XmlElement;
        CommonAggregateComponentsTok: Label 'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2', Locked = true;
        CommonBasicComponentsTok: Label 'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2', Locked = true;
        DefaultInvoiceTok: Label 'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2', Locked = true;
        DefaultCreditNoteTok: Label 'urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2', Locked = true;
        DefaultReminderTok: Label 'urn:oasis:names:specification:ubl:schema:xsd:Reminder-2', Locked = true;
    begin
        EDocumentPurchaseHeader.InsertForEDocument(EDocument);

        XmlDocument.ReadFrom(TempBlob.CreateInStream(TextEncoding::UTF8), OIOUBLXml);

        XmlNamespaces.AddNamespace('cac', CommonAggregateComponentsTok);
        XmlNamespaces.AddNamespace('cbc', CommonBasicComponentsTok);
        XmlNamespaces.AddNamespace('inv', DefaultInvoiceTok);
        XmlNamespaces.AddNamespace('cn', DefaultCreditNoteTok);
        XmlNamespaces.AddNamespace('rem', DefaultReminderTok);

        OIOUBLXml.GetRoot(XmlElement);
        case UpperCase(XmlElement.LocalName()) of
            'INVOICE':
                PopulateEDocumentForInvoice(OIOUBLXml, XmlNamespaces, EDocumentPurchaseHeader, EDocument);
            'CREDITNOTE':
                PopulateEDocumentForCreditNote(OIOUBLXml, XmlNamespaces, EDocumentPurchaseHeader, EDocument);
            'REMINDER':
                PopulateEDocumentForReminder(OIOUBLXml, XmlNamespaces, EDocumentPurchaseHeader, EDocument);
        end;

        EDocumentPurchaseHeader.Modify(false);
        EDocument.Direction := EDocument.Direction::Incoming;
        exit(Enum::"E-Doc. Process Draft"::"Purchase Document");
    end;

    /// <summary>
    /// Displays a readable view of the processed E-Document purchase information.
    /// This procedure opens a page showing the purchase header and lines in a user-friendly format for review.
    /// </summary>
    /// <param name="EDocument">The E-Document record that contains the document to be displayed.</param>
    /// <param name="TempBlob">A temporary blob containing the document data (not used in current implementation).</param>
    internal procedure View(EDocument: Record "E-Document"; TempBlob: Codeunit "Temp Blob")
    var
        EDocPurchaseHeader: Record "E-Document Purchase Header";
        EDocPurchaseLine: Record "E-Document Purchase Line";
        EDocReadablePurchaseDoc: Page "E-Doc. Readable Purchase Doc.";
    begin
        EDocPurchaseHeader.GetFromEDocument(EDocument);
        EDocPurchaseLine.SetRange("E-Document Entry No.", EDocPurchaseHeader."E-Document Entry No.");
        EDocReadablePurchaseDoc.SetBuffer(EDocPurchaseHeader, EDocPurchaseLine);
        EDocReadablePurchaseDoc.Run();
    end;

    local procedure PopulateEDocumentForInvoice(OIOUBLXml: XmlDocument; XmlNamespaces: XmlNamespaceManager; var EDocumentPurchaseHeader: Record "E-Document Purchase Header"; var EDocument: Record "E-Document")
    var
        EDocumentXMLHelper: Codeunit "EDocument XML Helper";
        VendorNo: Code[20];
    begin
        EDocumentPurchaseHeader."E-Document Type" := "E-Document Type"::"Purchase Invoice";
#pragma warning disable AA0139
        EDocumentXMLHelper.SetStringValueInField(OIOUBLXml, XmlNamespaces, '/inv:Invoice/cbc:ID', MaxStrLen(EDocumentPurchaseHeader."Sales Invoice No."), EDocumentPurchaseHeader."Sales Invoice No.");
        EDocumentXMLHelper.SetDateValueInField(OIOUBLXml, XmlNamespaces, '/inv:Invoice/cbc:IssueDate', EDocumentPurchaseHeader."Document Date");
        EDocumentXMLHelper.SetDateValueInField(OIOUBLXml, XmlNamespaces, '/inv:Invoice/cbc:DueDate', EDocumentPurchaseHeader."Due Date");
        EDocumentXMLHelper.SetCurrencyValueInField(OIOUBLXml, XmlNamespaces, '/inv:Invoice/cbc:DocumentCurrencyCode', MaxStrLen(EDocumentPurchaseHeader."Currency Code"), EDocumentPurchaseHeader."Currency Code");
        EDocumentXMLHelper.SetStringValueInField(OIOUBLXml, XmlNamespaces, '/inv:Invoice/cac:OrderReference/cbc:ID', MaxStrLen(EDocumentPurchaseHeader."Purchase Order No."), EDocumentPurchaseHeader."Purchase Order No.");
#pragma warning restore AA0139
        EDocumentXMLHelper.SetNumberValueInField(OIOUBLXml, XmlNamespaces, '/inv:Invoice/cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount', EDocumentPurchaseHeader."Sub Total");
        EDocumentXMLHelper.SetNumberValueInField(OIOUBLXml, XmlNamespaces, '/inv:Invoice/cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount', EDocumentPurchaseHeader.Total);
        EDocumentXMLHelper.SetNumberValueInField(OIOUBLXml, XmlNamespaces, '/inv:Invoice/cac:LegalMonetaryTotal/cbc:PayableAmount', EDocumentPurchaseHeader."Amount Due");
        EDocumentPurchaseHeader."Total VAT" := EDocumentPurchaseHeader."Total" - EDocumentPurchaseHeader."Sub Total" - EDocumentPurchaseHeader."Total Discount";
        VendorNo := ParseAccountingSupplierParty(OIOUBLXml, XmlNamespaces, EDocumentPurchaseHeader, EDocument, 'inv:Invoice');
        ParseAccountingCustomerParty(OIOUBLXml, XmlNamespaces, EDocumentPurchaseHeader, 'inv:Invoice');
        if VendorNo <> '' then
            EDocumentPurchaseHeader."[BC] Vendor No." := VendorNo;
        InsertOIOUBLPurchaseLines(OIOUBLXml, XmlNamespaces, EDocumentPurchaseHeader."E-Document Entry No.", EDocumentPurchaseHeader."E-Document Type");
    end;

    local procedure PopulateEDocumentForCreditNote(OIOUBLXml: XmlDocument; XmlNamespaces: XmlNamespaceManager; var EDocumentPurchaseHeader: Record "E-Document Purchase Header"; var EDocument: Record "E-Document")
    var
        EDocumentXMLHelper: Codeunit "EDocument XML Helper";
        VendorNo: Code[20];
    begin
        EDocumentPurchaseHeader."E-Document Type" := "E-Document Type"::"Purchase Credit Memo";
#pragma warning disable AA0139
        EDocumentXMLHelper.SetStringValueInField(OIOUBLXml, XmlNamespaces, '/cn:CreditNote/cbc:ID', MaxStrLen(EDocumentPurchaseHeader."Sales Invoice No."), EDocumentPurchaseHeader."Sales Invoice No.");
        EDocumentXMLHelper.SetDateValueInField(OIOUBLXml, XmlNamespaces, '/cn:CreditNote/cbc:IssueDate', EDocumentPurchaseHeader."Document Date");
        EDocumentXMLHelper.SetDateValueInField(OIOUBLXml, XmlNamespaces, '/cn:CreditNote/cbc:DueDate', EDocumentPurchaseHeader."Due Date");
        EDocumentXMLHelper.SetCurrencyValueInField(OIOUBLXml, XmlNamespaces, '/cn:CreditNote/cbc:DocumentCurrencyCode', MaxStrLen(EDocumentPurchaseHeader."Currency Code"), EDocumentPurchaseHeader."Currency Code");
        EDocumentXMLHelper.SetStringValueInField(OIOUBLXml, XmlNamespaces, '/cn:CreditNote/cac:OrderReference/cbc:ID', MaxStrLen(EDocumentPurchaseHeader."Purchase Order No."), EDocumentPurchaseHeader."Purchase Order No.");
        EDocumentXMLHelper.SetStringValueInField(OIOUBLXml, XmlNamespaces, '/cn:CreditNote/cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID', MaxStrLen(EDocumentPurchaseHeader."Applies-to Doc. No."), EDocumentPurchaseHeader."Applies-to Doc. No.");
#pragma warning restore AA0139
        EDocumentXMLHelper.SetNumberValueInField(OIOUBLXml, XmlNamespaces, '/cn:CreditNote/cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount', EDocumentPurchaseHeader."Sub Total");
        EDocumentXMLHelper.SetNumberValueInField(OIOUBLXml, XmlNamespaces, '/cn:CreditNote/cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount', EDocumentPurchaseHeader.Total);
        EDocumentXMLHelper.SetNumberValueInField(OIOUBLXml, XmlNamespaces, '/cn:CreditNote/cac:LegalMonetaryTotal/cbc:PayableAmount', EDocumentPurchaseHeader."Amount Due");
        EDocumentPurchaseHeader."Total VAT" := EDocumentPurchaseHeader."Total" - EDocumentPurchaseHeader."Sub Total" - EDocumentPurchaseHeader."Total Discount";
        VendorNo := ParseAccountingSupplierParty(OIOUBLXml, XmlNamespaces, EDocumentPurchaseHeader, EDocument, 'cn:CreditNote');
        ParseAccountingCustomerParty(OIOUBLXml, XmlNamespaces, EDocumentPurchaseHeader, 'cn:CreditNote');
        if VendorNo <> '' then
            EDocumentPurchaseHeader."[BC] Vendor No." := VendorNo;
        InsertOIOUBLPurchaseLines(OIOUBLXml, XmlNamespaces, EDocumentPurchaseHeader."E-Document Entry No.", EDocumentPurchaseHeader."E-Document Type");
    end;

    local procedure PopulateEDocumentForReminder(OIOUBLXml: XmlDocument; XmlNamespaces: XmlNamespaceManager; var EDocumentPurchaseHeader: Record "E-Document Purchase Header"; var EDocument: Record "E-Document")
    var
        EDocumentXMLHelper: Codeunit "EDocument XML Helper";
        VendorNo: Code[20];
    begin
        EDocumentPurchaseHeader."E-Document Type" := "E-Document Type"::"Issued Reminder";
#pragma warning disable AA0139 // false positive: overflow handled by SetStringValueInField
        EDocumentXMLHelper.SetStringValueInField(OIOUBLXml, XmlNamespaces, '/rem:Reminder/cbc:ID', MaxStrLen(EDocumentPurchaseHeader."Sales Invoice No."), EDocumentPurchaseHeader."Sales Invoice No.");
        EDocumentXMLHelper.SetDateValueInField(OIOUBLXml, XmlNamespaces, '/rem:Reminder/cbc:IssueDate', EDocumentPurchaseHeader."Document Date");
        EDocumentXMLHelper.SetDateValueInField(OIOUBLXml, XmlNamespaces, '/rem:Reminder/cac:PaymentMeans/cbc:PaymentDueDate', EDocumentPurchaseHeader."Due Date");
        EDocumentXMLHelper.SetCurrencyValueInField(OIOUBLXml, XmlNamespaces, '/rem:Reminder/cbc:DocumentCurrencyCode', MaxStrLen(EDocumentPurchaseHeader."Currency Code"), EDocumentPurchaseHeader."Currency Code");
#pragma warning restore AA0139
        EDocumentXMLHelper.SetNumberValueInField(OIOUBLXml, XmlNamespaces, '/rem:Reminder/cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount', EDocumentPurchaseHeader."Sub Total");
        EDocumentXMLHelper.SetNumberValueInField(OIOUBLXml, XmlNamespaces, '/rem:Reminder/cac:LegalMonetaryTotal/cbc:PayableAmount', EDocumentPurchaseHeader.Total);
        EDocumentPurchaseHeader."Total VAT" := EDocumentPurchaseHeader."Total" - EDocumentPurchaseHeader."Sub Total" - EDocumentPurchaseHeader."Total Discount";
        VendorNo := ParseAccountingSupplierParty(OIOUBLXml, XmlNamespaces, EDocumentPurchaseHeader, EDocument, 'rem:Reminder');
        ParseAccountingCustomerParty(OIOUBLXml, XmlNamespaces, EDocumentPurchaseHeader, 'rem:Reminder');
        if VendorNo <> '' then
            EDocumentPurchaseHeader."[BC] Vendor No." := VendorNo;
        InsertOIOUBLPurchaseLines(OIOUBLXml, XmlNamespaces, EDocumentPurchaseHeader."E-Document Entry No.", EDocumentPurchaseHeader."E-Document Type");
    end;

    local procedure ParseAccountingSupplierParty(OIOUBLXml: XmlDocument; XmlNamespaces: XmlNamespaceManager; var EDocumentPurchaseHeader: Record "E-Document Purchase Header"; var EDocument: Record "E-Document"; DocumentType: Text) VendorNo: Code[20]
    var
        EDocumentXMLHelper: Codeunit "EDocument XML Helper";
        EDocumentImportHelper: Codeunit "E-Document Import Helper";
        DKCVRTok: Label 'DK:CVR', Locked = true;
        VendorName, VendorAddress, VendorParticipantId : Text;
        VATRegistrationNo: Text[20];
        EndpointID, SchemeID : Text;
        GLN: Code[13];
        BasePathTxt: Text;
        XMLNode: XmlNode;
    begin
#pragma warning disable AA0139 // false positive: overflow handled by SetStringValueInField
        BasePathTxt := '/' + DocumentType + '/cac:AccountingSupplierParty/cac:Party';
        EDocumentXMLHelper.SetStringValueInField(OIOUBLXml, XmlNamespaces, BasePathTxt + '/cac:PartyName/cbc:Name', MaxStrLen(EDocumentPurchaseHeader."Vendor Company Name"), EDocumentPurchaseHeader."Vendor Company Name");
        EDocumentXMLHelper.SetStringValueInField(OIOUBLXml, XmlNamespaces, BasePathTxt + '/cac:PostalAddress/cbc:StreetName', MaxStrLen(EDocumentPurchaseHeader."Vendor Address"), EDocumentPurchaseHeader."Vendor Address");
        EDocumentXMLHelper.SetStringValueInField(OIOUBLXml, XmlNamespaces, BasePathTxt + '/cac:PostalAddress/cbc:AdditionalStreetName', MaxStrLen(EDocumentPurchaseHeader."Vendor Address Recipient"), EDocumentPurchaseHeader."Vendor Address Recipient");
        EDocumentXMLHelper.SetStringValueInField(OIOUBLXml, XmlNamespaces, BasePathTxt + '/cac:PartyTaxScheme/cbc:CompanyID', MaxStrLen(EDocumentPurchaseHeader."Vendor VAT Id"), EDocumentPurchaseHeader."Vendor VAT Id");
        EDocumentXMLHelper.SetStringValueInField(OIOUBLXml, XmlNamespaces, BasePathTxt + '/cac:Contact/cbc:Name', MaxStrLen(EDocumentPurchaseHeader."Vendor Contact Name"), EDocumentPurchaseHeader."Vendor Contact Name");
#pragma warning restore AA0139
        if OIOUBLXml.SelectSingleNode(BasePathTxt + '/cbc:EndpointID/@schemeID', XmlNamespaces, XMLNode) then begin
            SchemeID := XMLNode.AsXmlAttribute().Value();
            EndpointID := EDocumentXMLHelper.GetNodeValue(OIOUBLXml, XmlNamespaces, BasePathTxt + '/cbc:EndpointID');
            case SchemeID of
                DKCVRTok:
                    VATRegistrationNo := CopyStr(EndpointID, 1, MaxStrLen(VATRegistrationNo));
                GLNTok:
                    begin
                        GLN := CopyStr(EndpointID, 1, MaxStrLen(GLN));
                        EDocumentPurchaseHeader."Vendor GLN" := GLN;
                    end;
            end;
            VendorParticipantId := SchemeID + ':' + EndpointID;
        end;
        VATRegistrationNo := CopyStr(EDocumentPurchaseHeader."Vendor VAT Id", 1, MaxStrLen(VATRegistrationNo));
        VendorName := EDocumentPurchaseHeader."Vendor Company Name";
        VendorAddress := EDocumentPurchaseHeader."Vendor Address";
        if not FindVendorByVATRegNoOrGLN(VendorNo, VATRegistrationNo, GLN) then
            if not FindVendorByParticipantId(VendorNo, EDocument, VendorParticipantId) then
                VendorNo := EDocumentImportHelper.FindVendorByNameAndAddress(VendorName, VendorAddress);
    end;

    local procedure ParseAccountingCustomerParty(OIOUBLXml: XmlDocument; XmlNamespaces: XmlNamespaceManager; var EDocumentPurchaseHeader: Record "E-Document Purchase Header"; DocumentType: Text)
    var
        EDocumentXMLHelper: Codeunit "EDocument XML Helper";
        BasePathTxt: Text;
        XMLNode: XmlNode;
        SchemeID, EndpointID : Text;
    begin
#pragma warning disable AA0139 // false positive: overflow handled by SetStringValueInField
        BasePathTxt := '/' + DocumentType + '/cac:AccountingCustomerParty/cac:Party';
        EDocumentXMLHelper.SetStringValueInField(OIOUBLXml, XmlNamespaces, BasePathTxt + '/cac:PartyName/cbc:Name', MaxStrLen(EDocumentPurchaseHeader."Customer Company Name"), EDocumentPurchaseHeader."Customer Company Name");
        EDocumentXMLHelper.SetStringValueInField(OIOUBLXml, XmlNamespaces, BasePathTxt + '/cac:PostalAddress/cbc:StreetName', MaxStrLen(EDocumentPurchaseHeader."Customer Address"), EDocumentPurchaseHeader."Customer Address");
        EDocumentXMLHelper.SetStringValueInField(OIOUBLXml, XmlNamespaces, BasePathTxt + '/cac:PostalAddress/cbc:AdditionalStreetName', MaxStrLen(EDocumentPurchaseHeader."Customer Address Recipient"), EDocumentPurchaseHeader."Customer Address Recipient");
        EDocumentXMLHelper.SetStringValueInField(OIOUBLXml, XmlNamespaces, BasePathTxt + '/cac:PartyTaxScheme/cbc:CompanyID', MaxStrLen(EDocumentPurchaseHeader."Customer VAT Id"), EDocumentPurchaseHeader."Customer VAT Id");
#pragma warning restore AA0139
        if OIOUBLXml.SelectSingleNode(BasePathTxt + '/cbc:EndpointID/@schemeID', XmlNamespaces, XMLNode) then begin
            SchemeID := XMLNode.AsXmlAttribute().Value();
            EndpointID := EDocumentXMLHelper.GetNodeValue(OIOUBLXml, XmlNamespaces, BasePathTxt + '/cbc:EndpointID');
            if SchemeID = GLNTok then
                EDocumentPurchaseHeader."Customer GLN" := CopyStr(EndpointID, 1, MaxStrLen(EDocumentPurchaseHeader."Customer GLN"));
        end;
    end;

    local procedure InsertOIOUBLPurchaseLines(OIOUBLXml: XmlDocument; XmlNamespaces: XmlNamespaceManager; EDocumentEntryNo: Integer; DocumentType: Enum "E-Document Type")
    var
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        NewLineXML: XmlDocument;
        LineXMLList: XmlNodeList;
        LineXMLNode: XmlNode;
        LineXPath: Text;
        LineElementName: Text;
    begin
        case DocumentType of
            "E-Document Type"::"Purchase Invoice":
                begin
                    LineXPath := '/inv:Invoice/cac:InvoiceLine';
                    LineElementName := InvoiceLineTok;
                end;
            "E-Document Type"::"Purchase Credit Memo":
                begin
                    LineXPath := '/cn:CreditNote/cac:CreditNoteLine';
                    LineElementName := CreditNoteLineTok;
                end;
            "E-Document Type"::"Issued Reminder":
                begin
                    LineXPath := '/rem:Reminder/cac:ReminderLine';
                    LineElementName := 'cac:ReminderLine';
                end;
        end;

        if not OIOUBLXml.SelectNodes(LineXPath, XmlNamespaces, LineXMLList) then
            exit;

        foreach LineXMLNode in LineXMLList do begin
            Clear(EDocumentPurchaseLine);
            EDocumentPurchaseLine.Validate("E-Document Entry No.", EDocumentEntryNo);
            EDocumentPurchaseLine."Line No." := EDocumentPurchaseLine.GetNextLineNo(EDocumentEntryNo);
            NewLineXML.ReplaceNodes(LineXMLNode);

            if LineElementName = 'cac:ReminderLine' then
                PopulateOIOUBLReminderLine(NewLineXML, XmlNamespaces, EDocumentPurchaseLine)
            else
                PopulateOIOUBLPurchaseLine(NewLineXML, XmlNamespaces, EDocumentPurchaseLine, LineElementName);
            EDocumentPurchaseLine.Insert(false);
        end;
    end;

    local procedure PopulateOIOUBLPurchaseLine(LineXML: XmlDocument; XmlNamespaces: XmlNamespaceManager; var EDocumentPurchaseLine: Record "E-Document Purchase Line"; LineElementName: Text)
    var
        EDocumentXMLHelper: Codeunit "EDocument XML Helper";
        LineIdFieldName: Text;
        QuantityFieldName: Text;
    begin
#pragma warning disable AA0139 // false positive: overflow handled by SetStringValueInField
        case LineElementName of
            InvoiceLineTok:
                begin
                    LineIdFieldName := 'cac:InvoiceLine/cac:Item/cac:SellersItemIdentification/cbc:ID';
                    QuantityFieldName := 'cac:InvoiceLine/cbc:InvoicedQuantity';
                end;
            CreditNoteLineTok:
                begin
                    LineIdFieldName := 'cac:CreditNoteLine/cac:Item/cac:SellersItemIdentification/cbc:ID';
                    QuantityFieldName := 'cac:CreditNoteLine/cbc:CreditedQuantity';
                end;
        end;

        EDocumentXMLHelper.SetStringValueInField(LineXML, XmlNamespaces, LineIdFieldName, MaxStrLen(EDocumentPurchaseLine."Product Code"), EDocumentPurchaseLine."Product Code");
        EDocumentXMLHelper.SetStringValueInField(LineXML, XmlNamespaces, LineElementName + '/cac:Item/cbc:Name', MaxStrLen(EDocumentPurchaseLine.Description), EDocumentPurchaseLine.Description);
        EDocumentXMLHelper.SetStringValueInField(LineXML, XmlNamespaces, LineElementName + '/cac:Item/cac:SellersItemIdentification/cbc:ID', MaxStrLen(EDocumentPurchaseLine."Product Code"), EDocumentPurchaseLine."Product Code");
        EDocumentXMLHelper.SetStringValueInField(LineXML, XmlNamespaces, LineElementName + '/cac:Item/cac:StandardItemIdentification/cbc:ID', MaxStrLen(EDocumentPurchaseLine."Product Code"), EDocumentPurchaseLine."Product Code");
        EDocumentXMLHelper.SetNumberValueInField(LineXML, XmlNamespaces, QuantityFieldName, EDocumentPurchaseLine.Quantity);
        EDocumentXMLHelper.SetStringValueInField(LineXML, XmlNamespaces, QuantityFieldName + '/@unitCode', MaxStrLen(EDocumentPurchaseLine."Unit of Measure"), EDocumentPurchaseLine."Unit of Measure");
        EDocumentXMLHelper.SetNumberValueInField(LineXML, XmlNamespaces, LineElementName + '/cac:Price/cbc:PriceAmount', EDocumentPurchaseLine."Unit Price");
        EDocumentXMLHelper.SetNumberValueInField(LineXML, XmlNamespaces, LineElementName + '/cbc:LineExtensionAmount', EDocumentPurchaseLine."Sub Total");
        EDocumentXMLHelper.SetCurrencyValueInField(LineXML, XmlNamespaces, LineElementName + '/cbc:LineExtensionAmount/@currencyID', MaxStrLen(EDocumentPurchaseLine."Currency Code"), EDocumentPurchaseLine."Currency Code");
        EDocumentXMLHelper.SetNumberValueInField(LineXML, XmlNamespaces, LineElementName + '/cac:Item/cac:ClassifiedTaxCategory/cbc:Percent', EDocumentPurchaseLine."VAT Rate");
#pragma warning restore AA0139
    end;

    local procedure PopulateOIOUBLReminderLine(LineXML: XmlDocument; XmlNamespaces: XmlNamespaceManager; var EDocumentPurchaseLine: Record "E-Document Purchase Line")
    var
        EDocumentXMLHelper: Codeunit "EDocument XML Helper";
        DebitAmount, CreditAmount : Decimal;
        DebitAmountText, CreditAmountText : Text;
    begin
#pragma warning disable AA0139
        EDocumentXMLHelper.SetStringValueInField(LineXML, XmlNamespaces, 'cac:ReminderLine/cbc:Note', MaxStrLen(EDocumentPurchaseLine.Description), EDocumentPurchaseLine.Description);
#pragma warning restore AA0139
        DebitAmountText := EDocumentXMLHelper.GetNodeValue(LineXML, XmlNamespaces, 'cac:ReminderLine/cbc:DebitLineAmount');
        if DebitAmountText <> '' then begin
            Evaluate(DebitAmount, DebitAmountText, 9);
            EDocumentPurchaseLine."Unit Price" := DebitAmount;
            EDocumentXMLHelper.SetCurrencyValueInField(LineXML, XmlNamespaces, 'cac:ReminderLine/cbc:DebitLineAmount/@currencyID', MaxStrLen(EDocumentPurchaseLine."Currency Code"), EDocumentPurchaseLine."Currency Code");
        end;
        CreditAmountText := EDocumentXMLHelper.GetNodeValue(LineXML, XmlNamespaces, 'cac:ReminderLine/cbc:CreditLineAmount');
        if CreditAmountText <> '' then begin
            Evaluate(CreditAmount, CreditAmountText, 9);
            EDocumentPurchaseLine."Unit Price" := -CreditAmount;
            if EDocumentPurchaseLine."Currency Code" = '' then
                EDocumentXMLHelper.SetCurrencyValueInField(LineXML, XmlNamespaces, 'cac:ReminderLine/cbc:CreditLineAmount/@currencyID', MaxStrLen(EDocumentPurchaseLine."Currency Code"), EDocumentPurchaseLine."Currency Code");
        end;
        EDocumentPurchaseLine.Quantity := 1;
        EDocumentPurchaseLine."Sub Total" := EDocumentPurchaseLine."Unit Price" * EDocumentPurchaseLine.Quantity;
    end;

    local procedure FindVendorByVATRegNoOrGLN(var VendorNo: Code[20]; VATRegistrationNo: Text[20]; GLN: Code[13]): Boolean
    var
        Vendor: Record Vendor;
    begin
        if VATRegistrationNo <> '' then begin
            Vendor.Reset();
            Vendor.SetLoadFields("VAT Registration No.");
            Vendor.SetRange("VAT Registration No.", VATRegistrationNo);
            if Vendor.FindFirst() then begin
                VendorNo := Vendor."No.";
                exit(true);
            end;
        end;

        // Try to find vendor by GLN
        if GLN <> '' then begin
            Vendor.Reset();
            Vendor.SetLoadFields("GLN");
            Vendor.SetRange("GLN", GLN);
            if Vendor.FindFirst() then begin
                VendorNo := Vendor."No.";
                exit(true);
            end;
        end;

        exit(false);
    end;

    local procedure FindVendorByParticipantId(var VendorNo: Code[20]; EDocument: Record "E-Document"; ParticipantId: Text): Boolean
    var
        EDocServiceParticipant: Record "Service Participant";
        EDocumentService: Record "E-Document Service";
        EDocumentHelper: Codeunit "E-Document Helper";
    begin
        if ParticipantId = '' then
            exit(false);

        EDocumentHelper.GetEdocumentService(EDocument, EDocumentService);
        EDocServiceParticipant.SetRange("Participant Type", EDocServiceParticipant."Participant Type"::Vendor);
        EDocServiceParticipant.SetRange("Participant Identifier", ParticipantId);
        EDocServiceParticipant.SetRange(Service, EDocumentService.Code);
        if not EDocServiceParticipant.FindFirst() then begin
            EDocServiceParticipant.SetRange(Service);
            if not EDocServiceParticipant.FindFirst() then
                exit(false);
        end;

        VendorNo := EDocServiceParticipant.Participant;
        exit(true);
    end;

    procedure ResetDraft(EDocument: Record "E-Document")
    var
        EDocPurchaseHeader: Record "E-Document Purchase Header";
    begin
        EDocPurchaseHeader.GetFromEDocument(EDocument);
        EDocPurchaseHeader.Delete(true);
    end;
}
