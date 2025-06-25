namespace Microsoft.EServices.EDocumentConnector.ForNAV;

using Microsoft.Foundation.Company;
using Microsoft.Purchases.Vendor;
using Microsoft.Foundation.Address;
using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Send;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Purchases.Document;

codeunit 6415 "ForNAV Application Response"
{
    Access = Internal;
    procedure ApproveEDocument(EDocument: Record "E-Document")
    var
        EDocumentService: Record "E-Document Service";
        EDocumentServiceStatus: Record "E-Document Service Status";
        ForNAVAPIRequests: Codeunit "ForNAV API Requests";
        SendContext: Codeunit SendContext;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        SendApproveRejectCheckStatusErr: Label 'You cannot send %1 response with the E-Socument in this current status %2. You can send response when E-document status is ''Imported Document Created''.', Comment = '%1 - Action response, %2 - Status', Locked = true;
    begin
        if not EDocumentService.Get('FORNAV') then
            exit;

        EDocumentServiceStatus.Get(EDocument."Entry No", EDocumentService.Code);
        if not (EDocumentServiceStatus.Status in
            [
                EDocumentServiceStatus.Status::"Imported Document Created",
                EDocumentServiceStatus.Status::"Order Linked",
                EDocumentServiceStatus.Status::"Order Updated"
            ]) then
            Error(SendApproveRejectCheckStatusErr, 'Approve', EDocumentServiceStatus.Status);

        Init(EDocument, true);
        PrepareResponse(SendContext);

        ForNAVAPIRequests.SendFilePostRequest(EDocument, SendContext);
        EDocumentLogHelper.InsertIntegrationLog(EDocument, EDocumentService, HttpRequest, HttpResponse);

        if HttpResponse.IsSuccessStatusCode then begin
            EDocumentServiceStatus.Status := EDocumentServiceStatus.Status::Approved;
            EDocumentServiceStatus.Modify();
        end;
    end;

    procedure RejectEDocument(EDocument: Record "E-Document")
    var
        EDocumentService: Record "E-Document Service";
        EDocumentServiceStatus: Record "E-Document Service Status";
        ReasonCode: Record "Reason Code";
        SendContext: Codeunit SendContext;
        ForNAVAPIRequests: Codeunit "ForNAV API Requests";
        ReasonCodes: Page "Reason Codes";
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
    begin
        if not EDocumentService.Get('FORNAV') then
            exit;

        EDocumentServiceStatus.Get(EDocument."Entry No", EDocumentService.Code);

        ReasonCodes.LookupMode(true);
        if ReasonCodes.RunModal() = Action::LookupOK then
            ReasonCodes.GetRecord(ReasonCode);

        Init(EDocument, false);
        PrepareResponse(SendContext);

        ForNAVAPIRequests.SendFilePostRequest(EDocument, SendContext);
        EDocumentLogHelper.InsertIntegrationLog(EDocument, EDocumentService, HttpRequest, HttpResponse);

        if HttpResponse.IsSuccessStatusCode then begin
            EDocumentServiceStatus.Status := EDocumentServiceStatus.Status::Rejected;
            EDocumentServiceStatus.Modify();
            DeleteRelatedDocument(EDocument);
        end;
    end;

    local procedure Init(EDocument: Record "E-Document"; ApproveValue: Boolean);
    begin
        DocumentId := EDocument."ForNAV Edoc. ID";
        ResponseId := EDocument."Incoming E-Document No.";
        DocumentReference := EDocument."Incoming E-Document No.";
        VendorNo := EDocument."Bill-to/Pay-to No.";
        Note := (ApproveValue ? 'Approve' : 'Reject') + ' ' + EDocument."Incoming E-Document No.";
        Approve := ApproveValue;
        RejectReason := RejectReason;
        "Document Type" := EDocument."Document Type";
    end;

    local procedure DeleteRelatedDocument(EDocument: Record "E-Document")
    var
        PurchaseHeader: Record "Purchase Header";
        RelatedRecordID: RecordID;
        RelatedRecordRef: RecordRef;
    begin
        RelatedRecordID := EDocument."Document Record ID";
        RelatedRecordRef := RelatedRecordID.GetRecord();
        RelatedRecordRef.Get(RelatedRecordID);

        case RelatedRecordRef.Number of
            database::"Purchase Header":
                begin
                    RelatedRecordRef.SetTable(PurchaseHeader);
                    Clear(PurchaseHeader."E-Document Link");
                    PurchaseHeader.Delete(true);
                end;
        end;
    end;

    local procedure PrepareResponse(SendContext: Codeunit SendContext)
    var
        XMLDocOut: XmlDocument;
        XMLCurrNode: XmlElement;
        FileOutstream: Outstream;
    begin
        XmlDocument.ReadFrom(GetAppResponseHeader(), XMLDocOut);
        XMLDocOut.GetRoot(XMLCurrNode);
        InitResponse();
        XMLCurrNode.Add(XmlElement.Create('CustomizationID', DocNameSpaceCBC, 'urn:ForNAV.com:puf:invoice_response:1.0'));
        XMLCurrNode.Add(XmlElement.Create('ProfileID', DocNameSpaceCBC, 'urn:ForNAV.com:puf:invoice_response:1.0'));
        XMLCurrNode.Add(XmlElement.Create('ID', DocNameSpaceCBC, ResponseId)); // Response Identifier
        XMLCurrNode.Add(XmlElement.Create('IssueDate', DocNameSpaceCBC, FormatDate(WorkDate())));
        XMLCurrNode.Add(XmlElement.Create('IssueTime', DocNameSpaceCBC, '12:00:00'));
        XMLCurrNode.Add(XmlElement.Create('Note', DocNameSpaceCBC, Note)); // Response Note

        // SenderParty
        InsertSenderParty(XMLCurrNode);

        // ReceiverParty
        InsertReceiverParty(XMLCurrNode);

        // DocumentResponse
        InsertDocumentResponse(XMLCurrNode);

        SendContext.GetTempBlob().CreateOutStream(FileOutStream);
        XMLDocOut.WriteTo(FileOutstream);
    end;

    local procedure InsertSenderParty(var SenderPartyElement: XmlElement);
    var
        CompanyInformation: Record "Company Information";
        Country: Record "Country/Region";
        ChildElement: XmlElement;
    begin
        CompanyInformation.Get();
        if not CompanyInformation."Use GLN in Electronic Document" then
            if not Country.Get(CompanyInformation.GetCompanyCountryRegionCode()) or (StrLen(Country."VAT Scheme") <> 4) then
                Error(InvalidVATSchemeErr, CompanyInformation.TableCaption(), CompanyInformation."Country/Region Code", Country."VAT Scheme");

        ChildElement := XmlElement.Create('SenderParty', DocNameSpaceCAC);
        if CompanyInformation."Use GLN in Electronic Document" then
            ChildElement.Add(XmlElement.Create('EndpointID', DocNameSpaceCBC, XmlAttribute.Create('schemeID', '0088'), CompanyInformation.GLN))
        else
            ChildElement.Add(XmlElement.Create('EndpointID', DocNameSpaceCBC, XmlAttribute.Create('schemeID', Country."VAT Scheme"), CompanyInformation."VAT Registration No."));
        InsertPartyLegalEntity(ChildElement, CompanyInformation.Name);
        SenderPartyElement.Add(ChildElement);
    end;

    local procedure InsertReceiverParty(var ReceiverPartyElement: XmlElement);
    var
        Country: Record "Country/Region";
        Vendor: Record Vendor;
        ChildElement: XmlElement;
        "VAT Registration No.": Text;
        InvalidIsoCodeErr: Label '%1 %2 does not have a valid ISO Code', Comment = '%1 = Table Caption, %2 = "Country/Region Code"';
    begin
        VendorNo := CopyStr(VendorNo, 1, MaxStrLen(Vendor."No."));
        Vendor.Get(VendorNo);
        if not Country.Get(Vendor."Country/Region Code") or (StrLen(Country."VAT Scheme") <> 4) then
            Error(InvalidVATSchemeErr, Vendor.TableCaption(), Vendor."Country/Region Code", Country."VAT Scheme");

        "VAT Registration No." := Vendor."VAT Registration No.";
        if (Country."ISO Code" = '') then
            Error(InvalidIsoCodeErr, Vendor.TableCaption(), Vendor."Country/Region Code")
        else
            if not "VAT Registration No.".ToLower().StartsWith(Format(Country."ISO Code").ToLower()) then
                "VAT Registration No." := Country."ISO Code" + "VAT Registration No.";

        ChildElement := XmlElement.Create('ReceiverParty', DocNameSpaceCAC);
        ChildElement.Add(XmlElement.Create('EndpointID', DocNameSpaceCBC, XmlAttribute.Create('schemeID', Country."VAT Scheme"), "VAT Registration No."));
        InsertPartyLegalEntity(ChildElement, Vendor.Name);

        ReceiverPartyElement.Add(ChildElement);
    end;

    local procedure InsertPartyLegalEntity(var ParentElement: XmlElement; Name: Text);
    var
        ChildElement: XmlElement;
    begin
        ChildElement := XmlElement.Create('PartyLegalEntity', DocNameSpaceCAC);
        ChildElement.Add(XmlElement.Create('RegistrationName', DocNameSpaceCBC, Name));

        ParentElement.Add(ChildElement);
    end;

    local procedure InsertDocumentResponse(var ParentElement: XmlElement);
    var
        DocumentResponseChildElement: XmlElement;
        ReasonCodeElement: XmlElement;
        ResponseChildElement: XmlElement;
    begin
        DocumentResponseChildElement := XmlElement.Create('DocumentResponse', DocNameSpaceCAC);
        ParentElement.Add(DocumentResponseChildElement);

        ResponseChildElement := XmlElement.Create('Response', DocNameSpaceCAC);
        DocumentResponseChildElement.Add(ResponseChildElement);

        if Approve then
            ResponseChildElement.Add(XmlElement.Create('ResponseCode', DocNameSpaceCBC, 'AP')) // Invoice status code (UNCL4343 Subset)
        else begin
            ResponseChildElement.Add(XmlElement.Create('ResponseCode', DocNameSpaceCBC, 'RE'));  // Invoice status code (UNCL4343 Subset)
            ReasonCodeElement := XmlElement.Create('Status', DocNameSpaceCAC);
            ReasonCodeElement.Add(
                XmlElement.Create('StatusReasonCode', DocNameSpaceCBC, XmlAttribute.Create('listID', 'OPStatusReason'), 'OTH')); // Status Clarification Reason (OpenPEPPOL)
            ReasonCodeElement.Add(XmlElement.Create('StatusReason', DocNameSpaceCBC, RejectReason));
            ResponseChildElement.Add(ReasonCodeElement);
        end;

        InsertDocReference(DocumentResponseChildElement);
    end;

    local procedure InsertDocReference(var ParentElement: XmlElement);
    var
        ChildElement: XmlElement;
    begin
        ChildElement := XmlElement.Create('DocumentReference', DocNameSpaceCAC);
        ChildElement.Add(XmlElement.Create('ID', DocNameSpaceCBC, DocumentReference));
        ChildElement.Add(XmlElement.Create('DocumentTypeCode', DocNameSpaceCBC, "Document Type" = "E-Document Type"::"Purchase Credit Memo" ? '381' : '380'));
        ParentElement.Add(ChildElement);
    end;

    local procedure GetAppResponseHeader(): Text;
    begin
        exit('<?xml version="1.0" encoding="UTF-8" ?>' +
        '<ApplicationResponse xmlns="urn:oasis:names:specification:ubl:schema:xsd:ApplicationResponse-2" ' +
        'xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" ' +
        'xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2" ' +
        'xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2" ' +
        '/>');
    end;

    local procedure InitResponse()
    begin
        DocNameSpaceCBC := 'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2';
        DocNameSpaceCAC := 'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2';
    end;

    local procedure FormatDate(InputDate: Date): Text;
    begin
        if InputDate = 0D then
            exit('');
        exit(Format(InputDate, 0, 9));
    end;

    var
        EDocumentLogHelper: Codeunit "E-Document Log Helper";
        DocNameSpaceCBC, DocNameSpaceCAC : Text[250];
        InvalidVATSchemeErr: Label '%1 %2 does not have a valid four digit VAT Scheme %3', Comment = '%1 = Table Caption, %2 = "Country/Region Code", %3 = "VAT Scheme"';
        DocumentId, ResponseId, DocumentReference, VendorNo, Note, RejectReason : Text;
        Approve: Boolean;
        "Document Type": Enum "E-Document Type";
}