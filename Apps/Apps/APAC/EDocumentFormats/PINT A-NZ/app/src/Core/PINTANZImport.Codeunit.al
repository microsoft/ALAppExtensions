// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Format;

using Microsoft.eServices.EDocument;
using System.Utilities;
using System.IO;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Purchases.Vendor;
using Microsoft.eServices.EDocument.Service.Participant;

codeunit 28007 "PINT A-NZ Import"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure ParseBasicInfo(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob")
    var
        TempXMLBuffer: Record "XML Buffer" temporary;
        GeneralLedgerSetup: Record "General Ledger Setup";
        DueDate, IssueDate : Text;
        DocumentType: Text;
        InvoiceTok: Label '/Invoice', Locked = true;
        CreditNoteTok: Label '/CreditNote', Locked = true;
        Currency: Text[10];
        DocStream: InStream;
    begin
        TempXMLBuffer.DeleteAll();
        TempBlob.CreateInStream(DocStream, TextEncoding::UTF8);
        TempXMLBuffer.LoadFromStream(DocStream);

        if GetDocumentType(TempXMLBuffer) = 'Invoice' then begin
            DocumentType := InvoiceTok;
            EDocument."Document Type" := EDocument."Document Type"::"Purchase Invoice";
        end else begin
            DocumentType := CreditNoteTok;
            EDocument."Document Type" := EDocument."Document Type"::"Purchase Credit Memo";
        end;
        EDocument.Direction := EDocument.Direction::Incoming;
        EDocument."Incoming E-Document No." := CopyStr(GetNodeByPath(TempXMLBuffer, DocumentType + '/cbc:ID'), 1, MaxStrLen(EDocument."Document No."));

        ParseAccountingSupplierParty(EDocument, TempXMLBuffer, DocumentType);
        ParseAccountingCustomerParty(EDocument, TempXMLBuffer, DocumentType);

        DueDate := GetNodeByPath(TempXMLBuffer, DocumentType + '/cbc:DueDate');
        if DueDate <> '' then
            Evaluate(EDocument."Due Date", DueDate, 9);
        IssueDate := GetNodeByPath(TempXMLBuffer, DocumentType + '/cbc:IssueDate');
        if IssueDate <> '' then
            Evaluate(EDocument."Document Date", IssueDate, 9);

        Evaluate(EDocument."Amount Excl. VAT", GetNodeByPath(TempXMLBuffer, DocumentType + '/cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount'), 9);
        Evaluate(EDocument."Amount Incl. VAT", GetNodeByPath(TempXMLBuffer, DocumentType + '/cac:LegalMonetaryTotal/cbc:PayableAmount'), 9);

        EDocument."Order No." := CopyStr(GetNodeByPath(TempXMLBuffer, DocumentType + '/cac:OrderReference/cbc:ID'), 1, MaxStrLen(EDocument."Order No."));

        Currency := CopyStr(GetNodeByPath(TempXMLBuffer, DocumentType + '/cbc:DocumentCurrencyCode'), 1, MaxStrLen(EDocument."Currency Code"));
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."LCY Code" <> Currency then
            EDocument."Currency Code" := Currency;
    end;

    local procedure ParseAccountingSupplierParty(var EDocument: Record "E-Document"; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentType: Text)
    var
        Vendor: Record Vendor;
        EDocumentImportHelper: Codeunit "E-Document Import Helper";
        VendorNo: Code[20];
    begin
        TryMatchVendor(EDocument, TempXMLBuffer, DocumentType, VendorNo);

        Vendor := EDocumentImportHelper.GetVendor(EDocument, VendorNo);
        if Vendor."No." <> '' then begin
            EDocument."Bill-to/Pay-to No." := Vendor."No.";
            EDocument."Bill-to/Pay-to Name" := Vendor.Name;
        end;
    end;

    local procedure TryMatchVendor(EDocument: Record "E-Document"; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentType: Text; var VendorNo: Code[20])
    var
        EDocumentImportHelper: Codeunit "E-Document Import Helper";
        VendorName, VendorAddress, VendorParticipantId : Text;
        VATRegistrationNo: Text[20];
        GLN: Code[13];
        ABN: Code[11];
    begin
        GetVendorRelatedData(TempXMLBuffer, DocumentType, ABN, GLN, VATRegistrationNo, VendorParticipantId, VendorName, VendorAddress);

        if FindVendorByABN(VendorNo, ABN) then
            exit;

        if FindVendorByVATRegNoorGLN(VendorNo, VATRegistrationNo, GLN) then
            exit;

        if FindVendorByParticipantId(VendorNo, EDocument, VendorParticipantId) then
            exit;

        VendorNo := EDocumentImportHelper.FindVendorByNameAndAddress(VendorName, VendorAddress);
    end;

    local procedure GetVendorRelatedData(var TempXMLBuffer: Record "XML Buffer" temporary; DocumentType: Text; var ABN: Code[11]; var GLN: Code[13]; var VATRegistrationNo: Text[20]; VendorParticipantId: Text; VendorName: Text; VendorAddress: Text)
    var
        ABNSchemeIdTok: Label '0151', Locked = true;
        GLNSchemeIdTok: Label '0088', Locked = true;
    begin
        if GetNodeAttributeByPath(TempXMLBuffer, DocumentType + '/cac:AccountingSupplierParty/cac:Party/cbc:EndpointID/@schemeID') = ABNSchemeIdTok then
            ABN := CopyStr(GetNodeByPath(TempXMLBuffer, DocumentType + '/cac:AccountingSupplierParty/cac:Party/cbc:EndpointID'), 1, MaxStrLen(ABN));
        if GetNodeAttributeByPath(TempXMLBuffer, DocumentType + '/cac:AccountingSupplierParty/cac:Party/cbc:EndpointID/@schemeID') = GLNSchemeIdTok then
            GLN := CopyStr(GetNodeByPath(TempXMLBuffer, DocumentType + '/cac:AccountingSupplierParty/cac:Party/cbc:EndpointID'), 1, MaxStrLen(GLN));
        VATRegistrationNo := CopyStr(GetNodeByPath(TempXMLBuffer, DocumentType + '/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID'), 1, MaxStrLen(VATRegistrationNo));
        VendorParticipantId := GetNodeAttributeByPath(TempXMLBuffer, DocumentType + '/cac:AccountingSupplierParty/cac:Party/cbc:EndpointID/@schemeID') + ':';
        VendorParticipantId += this.GetNodeByPath(TempXMLBuffer, DocumentType + '/cac:AccountingSupplierParty/cac:Party/cbc:EndpointID');
        VendorName := GetNodeByPath(TempXMLBuffer, DocumentType + '/cac:AccountingSupplierParty/cac:Party/cac:PartyName/cbc:Name');
        VendorAddress := GetNodeByPath(TempXMLBuffer, DocumentType + '/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:StreetName');
    end;

    local procedure FindVendorByABN(var VendorNo: Code[20]; InputABN: Code[11]): Boolean
    var
        Vendor: Record Vendor;
    begin
        if InputABN = '' then
            exit(false);

        Vendor.SetRange(ABN, InputABN);
        if Vendor.FindFirst() then
            VendorNo := Vendor."No.";
        exit(VendorNo <> '');
    end;

    local procedure FindVendorByVATRegNoorGLN(var VendorNo: Code[20]; VATRegistrationNo: Text[20]; InputGLN: Code[13]): Boolean
    var
        EDocumentImportHelper: Codeunit "E-Document Import Helper";
    begin
        VendorNo := EDocumentImportHelper.FindVendor('', InputGLN, VATRegistrationNo);
        exit(VendorNo <> '');
    end;

    local procedure FindVendorByParticipantId(var VendorNo: Code[20]; EDocument: Record "E-Document"; VendorParticipantId: Text): Boolean
    var
        EDocumentService: Record "E-Document Service";
        ServiceParticipant: Record "Service Participant";
        EDocumentHelper: Codeunit "E-Document Helper";
    begin
        EDocumentHelper.GetEdocumentService(EDocument, EDocumentService);
        ServiceParticipant.SetRange("Participant Type", ServiceParticipant."Participant Type"::Vendor);
        ServiceParticipant.SetRange("Participant Identifier", VendorParticipantId);
        ServiceParticipant.SetRange(Service, EDocumentService.Code);
        if not ServiceParticipant.FindFirst() then begin
            ServiceParticipant.SetRange(Service);
            if ServiceParticipant.FindFirst() then;
        end;

        VendorNo := ServiceParticipant.Participant;
        exit(VendorNo <> '');
    end;

    local procedure ParseAccountingCustomerParty(var EDocument: Record "E-Document"; var TempXMLBuffer: Record "XML Buffer" temporary; DocumentType: Text)
    var
        ReceivingId: Text[250];
    begin
        EDocument."Receiving Company Name" := CopyStr(GetNodeByPath(TempXMLBuffer, DocumentType + '/cac:AccountingCustomerParty/cac:Party/cac:PartyName/cbc:Name'), 1, MaxStrLen(EDocument."Receiving Company Name"));
        EDocument."Receiving Company Address" := CopyStr(GetNodeByPath(TempXMLBuffer, DocumentType + '/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:StreetName'), 1, MaxStrLen(EDocument."Receiving Company Address"));
        EDocument."Receiving Company GLN" := CopyStr(GetNodeByPath(TempXMLBuffer, DocumentType + '/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID'), 1, MaxStrLen(EDocument."Receiving Company GLN"));
        EDocument."Receiving Company VAT Reg. No." := CopyStr(GetNodeByPath(TempXMLBuffer, DocumentType + '/cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID'), 1, MaxStrLen(EDocument."Receiving Company VAT Reg. No."));
        ReceivingId := CopyStr(this.GetNodeAttributeByPath(TempXMLBuffer, DocumentType + '/cac:AccountingCustomerParty/cac:Party/cbc:EndpointID/@schemeID'), 1, (MaxStrLen(EDocument."Receiving Company Id") - 1)) + ':';
        ReceivingId += CopyStr(this.GetNodeByPath(TempXMLBuffer, DocumentType + '/cac:AccountingCustomerParty/cac:Party/cbc:EndpointID'), 1, MaxStrLen(EDocument."Receiving Company Id") - StrLen(ReceivingId));
        EDocument."Receiving Company Id" := ReceivingId;
    end;

    local procedure GetDocumentType(var TempXMLBuffer: Record "XML Buffer" temporary): Text
    var
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.SetRange(Type, TempXMLBuffer.Type::Element);
        TempXMLBuffer.SetRange("Parent Entry No.", 0);

        if not TempXMLBuffer.FindFirst() then
            Error('Invalid XML file');

        TempXMLBuffer.Reset();
        exit(TempXMLBuffer.Name);
    end;

    local procedure GetNodeAttributeByPath(var TempXMLBuffer: Record "XML Buffer" temporary; XPath: Text): Text
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.SetRange(Type, TempXMLBuffer.Type::Attribute);
        TempXMLBuffer.SetRange(Path, XPath);

        if TempXMLBuffer.FindFirst() then
            exit(TempXMLBuffer.Value);
    end;

    local procedure GetNodeByPath(var TempXMLBuffer: Record "XML Buffer" temporary; XPath: Text): Text
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.SetRange(Type, TempXMLBuffer.Type::Element);
        TempXMLBuffer.SetRange(Path, XPath);

        if TempXMLBuffer.FindFirst() then
            exit(TempXMLBuffer.Value);
    end;
}