namespace Microsoft.EServices.EDocumentConnector.ForNAV;
using System.Utilities;
using Microsoft.eServices.EDocument;
using Microsoft.Inventory.Item;
using Microsoft.eServices.EDocument.Integration;

Codeunit 6246279 "ForNAV Peppol Test"
{
    Access = Internal;
    SingleInstance = true;
    local procedure MockOutgoing(Http: Codeunit "Http Message State")
    var
        TempBlob: Codeunit "Temp Blob";
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
    begin
        if StatusCode <> 200 then begin
            HttpClient.Send(Http.GetHttpRequestMessage(), HttpResponseMessage);
            Http.SetHttpResponseMessage(HttpResponseMessage);
        end else
            Http.GetHttpResponseMessage().Content.WriteFrom(StrSubstNo('{"id":"%1"}', MockServiceDocumentId()));
    end;

    local procedure MockInbox(Http: Codeunit "Http Message State")
    var
        IncomingDoc: Codeunit "ForNAV Inbox";
        Incoming: Record "ForNAV Incoming Doc";
        OutStr: OutStream;
        DocLbl: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><Invoice xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2" xmlns:ccts="urn:un:unece:uncefact:documentation:2" xmlns:qdt="urn:oasis:names:specification:ubl:schema:xsd:QualifiedDatatypes-2" xmlns:udt="urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2" xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"><cbc:CustomizationID>urn:cen.eu:en16931:2017#compliant#urn:fdc:peppol.eu:2017:poacc:billing:3.0</cbc:CustomizationID><cbc:ProfileID>urn:fdc:peppol.eu:2017:poacc:billing:01:1.0</cbc:ProfileID><cbc:ID>103058</cbc:ID><cbc:IssueDate>2026-01-22</cbc:IssueDate><cbc:DueDate>2026-01-22</cbc:DueDate><cbc:InvoiceTypeCode>380</cbc:InvoiceTypeCode><cbc:DocumentCurrencyCode>GBP</cbc:DocumentCurrencyCode><cbc:BuyerReference>GU00000735</cbc:BuyerReference><cac:OrderReference><cbc:ID>GU00000734</cbc:ID></cac:OrderReference><cac:ContractDocumentReference><cbc:ID>103058</cbc:ID></cac:ContractDocumentReference><cac:AccountingCustomerParty><cac:Party><cbc:EndpointID schemeID="9932">GB777777771</cbc:EndpointID><cac:PartyName><cbc:Name>CRONUS International Ltd.</cbc:Name></cac:PartyName><cac:PostalAddress><cbc:StreetName>5BvY5uYNuwknrflnSIcLNsY4BKOe5PSodQC0ULPJh8Vw5xYa8ijRLU5bcrmAWIgVTKZqsBIWshcel1ODkCWL4QS8kyN2YemnpySA</cbc:StreetName><cbc:AdditionalStreetName>Westminster</cbc:AdditionalStreetName><cbc:CityName>rQ6InfxcuDECxcoctYvq</cbc:CityName><cbc:PostalZone>O7HMPDX3GPO0SZOJLLPS</cbc:PostalZone><cac:Country><cbc:IdentificationCode>GB</cbc:IdentificationCode></cac:Country></cac:PostalAddress><cac:PartyTaxScheme><cbc:CompanyID>GB777777771</cbc:CompanyID><cac:TaxScheme><cbc:ID>VAT</cbc:ID></cac:TaxScheme></cac:PartyTaxScheme><cac:PartyLegalEntity><cbc:RegistrationName>CRONUS International Ltd.</cbc:RegistrationName><cbc:CompanyID>GB777777771</cbc:CompanyID></cac:PartyLegalEntity></cac:Party></cac:AccountingCustomerParty><cac:AccountingSupplierParty><cac:Party><cbc:EndpointID schemeID="9932">GBVendorVatNo</cbc:EndpointID><cac:PartyIdentification><cbc:ID schemeID="9932">GBVendorVatNo</cbc:ID></cac:PartyIdentification><cac:PartyName><cbc:Name>GL00000090</cbc:Name></cac:PartyName><cac:PostalAddress><cbc:StreetName>GU00000722</cbc:StreetName><cbc:CityName>GU00000723</cbc:CityName><cbc:PostalZone>GU00000724</cbc:PostalZone><cac:Country><cbc:IdentificationCode>GB</cbc:IdentificationCode></cac:Country></cac:PostalAddress><cac:PartyTaxScheme><cbc:CompanyID>VendorNo</cbc:CompanyID><cac:TaxScheme><cbc:ID>VAT</cbc:ID></cac:TaxScheme></cac:PartyTaxScheme><cac:PartyLegalEntity><cbc:RegistrationName>GL00000090</cbc:RegistrationName><cbc:CompanyID>VendorNo</cbc:CompanyID></cac:PartyLegalEntity><cac:Contact><cbc:Name>GL00000090</cbc:Name></cac:Contact></cac:Party></cac:AccountingSupplierParty><cac:Delivery><cbc:ActualDeliveryDate>2026-01-22</cbc:ActualDeliveryDate><cac:DeliveryLocation><cbc:ID schemeID="9932">GB777777771</cbc:ID><cac:Address><cbc:StreetName>GU00000722</cbc:StreetName><cbc:CityName>GU00000723</cbc:CityName><cbc:PostalZone>GU00000724</cbc:PostalZone><cac:Country><cbc:IdentificationCode>GB</cbc:IdentificationCode></cac:Country></cac:Address></cac:DeliveryLocation></cac:Delivery><cac:PaymentMeans><cbc:PaymentMeansCode>31</cbc:PaymentMeansCode><cac:PayeeFinancialAccount><cbc:ID>GB33BUKB20201555555555</cbc:ID><cac:FinancialInstitutionBranch><cbc:ID>1234</cbc:ID></cac:FinancialInstitutionBranch></cac:PayeeFinancialAccount></cac:PaymentMeans><cac:PaymentTerms><cbc:Note>Cash on delivery</cbc:Note></cac:PaymentTerms><cac:TaxTotal><cbc:TaxAmount currencyID="GBP">0.03</cbc:TaxAmount><cac:TaxSubtotal><cbc:TaxableAmount currencyID="GBP">3</cbc:TaxableAmount><cbc:TaxAmount currencyID="GBP">0.03</cbc:TaxAmount><cac:TaxCategory><cbc:ID>S</cbc:ID><cbc:Percent>1</cbc:Percent><cac:TaxScheme><cbc:ID>VAT</cbc:ID></cac:TaxScheme></cac:TaxCategory></cac:TaxSubtotal></cac:TaxTotal><cac:LegalMonetaryTotal><cbc:LineExtensionAmount currencyID="GBP">3</cbc:LineExtensionAmount><cbc:TaxExclusiveAmount currencyID="GBP">3</cbc:TaxExclusiveAmount><cbc:TaxInclusiveAmount currencyID="GBP">3.03</cbc:TaxInclusiveAmount><cbc:AllowanceTotalAmount currencyID="GBP">0</cbc:AllowanceTotalAmount><cbc:PrepaidAmount currencyID="GBP">0.00</cbc:PrepaidAmount><cbc:PayableRoundingAmount currencyID="GBP">0</cbc:PayableRoundingAmount><cbc:PayableAmount currencyID="GBP">3.03</cbc:PayableAmount></cac:LegalMonetaryTotal><cac:InvoiceLine><cbc:ID>10000</cbc:ID><cbc:Note>Item</cbc:Note><cbc:InvoicedQuantity unitCode="PCS">1</cbc:InvoicedQuantity><cbc:LineExtensionAmount currencyID="GBP">3</cbc:LineExtensionAmount><cac:Item><cbc:Name>ItemNo</cbc:Name><cac:SellersItemIdentification><cbc:ID>ItemNo</cbc:ID></cac:SellersItemIdentification><cac:ClassifiedTaxCategory><cbc:ID>S</cbc:ID><cbc:Percent>1</cbc:Percent><cac:TaxScheme><cbc:ID>VAT</cbc:ID></cac:TaxScheme></cac:ClassifiedTaxCategory></cac:Item><cac:Price><cbc:PriceAmount currencyID="GBP">3.00</cbc:PriceAmount><cbc:BaseQuantity unitCode="PCS">1</cbc:BaseQuantity></cac:Price></cac:InvoiceLine></Invoice>', Locked = true;
        JsonDoc, Payload : JsonObject;
        Doc: Text;
        Item: Record Item;
    begin
        JsonDoc.Add('ID', 'INCOMING');
        JsonDoc.Add('Status', 'Received');
        JsonDoc.Add('DocNo', '103058');
        JsonDoc.Add('DocType', 'Invoice');
        JsonDoc.Add('DocCode', 380);
        JsonDoc.Add('Doc', DocLbl);
        Payload.Add('INCOMING', JsonDoc);
        Payload.WriteTo(Doc);
        Item.FindFirst();
        Http.GetHttpResponseMessage().Content.WriteFrom(Doc.Replace('ItemNo', Item."No.").Replace('GBVendorVatNo', 'GB' + VendorNo).Replace('VendorNo', VendorNo));
    end;

    local procedure MockSmp(Http: Codeunit "Http Message State")
    begin
        Error('Not implemented');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ForNAV Peppol Setup", OnBeforeSend, '', false, false)]
    local procedure OnBeforeSend(var HttpClient: HttpClient; Http: Codeunit "Http Message State"; var Handled: Boolean)
    var
        Uri: Codeunit Uri;
        Segments, Parameters : List of [Text];
        Method, Query : Text;
    begin
        Handled := true;
        Uri.Init(Http.GetHttpRequestMessage().GetRequestUri());
        Uri.GetSegments(Segments);
        Method := Segments.Get(Segments.Count);
        Parameters := Uri.GetQuery().TrimEnd('?').Split('@');
        case Method of
            'SMP':
                MockSmp(Http);
            'Outgoing':
                MockOutgoing(Http);
            'Inbox':
                MockInbox(Http);
            else
                Error('Unknown http method', Method);
        end;
        if StatusCode = 500 then begin

        end;
    end;

    internal procedure Init()
    var
        Setup: Record "ForNAV Peppol Setup";
    begin
        if not InitCalled then begin
            Setup.InitSetup();
            Setup.Status := Setup.Status::Published;
            Setup.Authorized := true;
            Setup.Test := True;
            Setup."Identification Code" := '0000';
            Setup."Identification Value" := 'TEST';
            Setup.Modify();
            UnbindSubscription(PeppolSetup);
            if not BindSubscription(PeppolSetup) then
                Error('Failed to bind subscription');
            InitCalled := true;
        end;
    end;

    procedure CreateMockServiceDocumentId()
    begin
        MockGuid := CreateGuid();
    end;

    procedure MockServiceDocumentId(): Text
    begin
        exit('FORNAVMOCKID' + Format(MockGuid));
    end;

    var
        InitCalled: Boolean;
        StatusCode: Integer;
        PeppolSetup: Codeunit "ForNAV Peppol Setup";
        VendorNo: Code[20];
        MockGuid: Guid;

    procedure SetStatusCode(NewStatusCode: Integer)
    begin
        StatusCode := NewStatusCode;
    end;

    procedure SetVendorNo(NewVendorNo: Code[20])
    begin
        VendorNo := NewVendorNo;
    end;

    procedure CreateEvidence(EDocument: Record "E-Document"; Send: Boolean)
    var
        Incoming: Record "ForNAV Incoming Doc";
        OutStr: OutStream;
    begin
        if Incoming.Get(EDocument."ForNAV ID", Incoming.DocType::Evidence) then begin
            Incoming.Delete();
            Incoming.Init();
        end;
        Incoming.ID := EDocument."ForNAV ID";
        Incoming.Status := Send ? Incoming.Status::Send : Incoming.Status::Rejected;
        Incoming.DocNo := EDocument."Document No.";
        Incoming.DocType := Incoming.DocType::Evidence;
        Incoming.DocCode := 0;
        if not Send then begin
            Incoming.Message.CreateOutStream(OutStr, TextEncoding::UTF8);
            OutStr.WriteText('Rejected');
        end;
        Incoming.Insert(false);
    end;
}
