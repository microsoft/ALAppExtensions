// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Format;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Service.Participant;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Purchases.Vendor;
using System.IO;
using System.Utilities;

codeunit 28007 "PINT A-NZ Import"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure ParseBasicInfo(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        TempXMLBuffer: Record "XML Buffer" temporary;
        DocStream: InStream;
        CreditNoteTok: Label 'CREDITNOTE', Locked = true;
        InvoiceTok: Label 'INVOICE', Locked = true;
        DueDate, IssueDate : Text;
        Currency: Text[10];
        RootPath: Text;
    begin
        TempXMLBuffer.DeleteAll();
        TempBlob.CreateInStream(DocStream, TextEncoding::UTF8);
        TempXMLBuffer.LoadFromStream(DocStream);

        case UpperCase(GetDocumentType(TempXMLBuffer, RootPath)) of
            InvoiceTok:
                EDocument."Document Type" := EDocument."Document Type"::"Purchase Invoice";
            CreditNoteTok:
                EDocument."Document Type" := EDocument."Document Type"::"Purchase Credit Memo";
        end;
        EDocument.Direction := EDocument.Direction::Incoming;
        EDocument."Incoming E-Document No." := CopyStr(GetNodeByPath(TempXMLBuffer, RootPath + '/cbc:ID'), 1, MaxStrLen(EDocument."Document No."));

        ParseAccountingSupplierParty(EDocument, TempXMLBuffer, RootPath);
        ParseAccountingCustomerParty(EDocument, TempXMLBuffer, RootPath);

        DueDate := GetNodeByPath(TempXMLBuffer, RootPath + '/cbc:DueDate');
        if DueDate <> '' then
            Evaluate(EDocument."Due Date", DueDate, 9);
        IssueDate := GetNodeByPath(TempXMLBuffer, RootPath + '/cbc:IssueDate');
        if IssueDate <> '' then
            Evaluate(EDocument."Document Date", IssueDate, 9);

        Evaluate(EDocument."Amount Excl. VAT", GetNodeByPath(TempXMLBuffer, RootPath + '/cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount'), 9);
        Evaluate(EDocument."Amount Incl. VAT", GetNodeByPath(TempXMLBuffer, RootPath + '/cac:LegalMonetaryTotal/cbc:PayableAmount'), 9);

        EDocument."Order No." := CopyStr(GetNodeByPath(TempXMLBuffer, RootPath + '/cac:OrderReference/cbc:ID'), 1, MaxStrLen(EDocument."Order No."));

        Currency := CopyStr(GetNodeByPath(TempXMLBuffer, RootPath + '/cbc:DocumentCurrencyCode'), 1, MaxStrLen(EDocument."Currency Code"));
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."LCY Code" <> Currency then
            EDocument."Currency Code" := Currency;
    end;

    local procedure ParseAccountingSupplierParty(var EDocument: Record "E-Document"; var TempXMLBuffer: Record "XML Buffer" temporary; RootPath: Text)
    var
        Vendor: Record Vendor;
        EDocumentImportHelper: Codeunit "E-Document Import Helper";
        VendorNo: Code[20];
    begin
        TryMatchVendor(EDocument, TempXMLBuffer, RootPath, VendorNo);

        Vendor := EDocumentImportHelper.GetVendor(EDocument, VendorNo);
        if Vendor."No." <> '' then begin
            EDocument."Bill-to/Pay-to No." := Vendor."No.";
            EDocument."Bill-to/Pay-to Name" := Vendor.Name;
        end;
    end;

    local procedure TryMatchVendor(EDocument: Record "E-Document"; var TempXMLBuffer: Record "XML Buffer" temporary; RootPath: Text; var VendorNo: Code[20])
    var
        EDocumentImportHelper: Codeunit "E-Document Import Helper";
        ABN: Code[11];
        GLN: Code[13];
        VendorAddress, VendorName, VendorParticipantId : Text;
        VATRegistrationNo: Text[20];
    begin
        GetVendorRelatedData(TempXMLBuffer, RootPath, ABN, GLN, VATRegistrationNo, VendorParticipantId, VendorName, VendorAddress);

        if FindVendorByABN(VendorNo, ABN) then
            exit;

        if FindVendorByVATRegNoorGLN(VendorNo, VATRegistrationNo, GLN) then
            exit;

        if FindVendorByParticipantId(VendorNo, EDocument, VendorParticipantId) then
            exit;

        VendorNo := EDocumentImportHelper.FindVendorByNameAndAddress(VendorName, VendorAddress);
    end;

    local procedure GetVendorRelatedData(var TempXMLBuffer: Record "XML Buffer" temporary; RootPath: Text; var ABN: Code[11]; var GLN: Code[13]; var VATRegistrationNo: Text[20]; VendorParticipantId: Text; VendorName: Text; VendorAddress: Text)
    var
        ABNSchemeIdTok: Label '0151', Locked = true;
        GLNSchemeIdTok: Label '0088', Locked = true;
    begin
        if GetNodeAttributeByPath(TempXMLBuffer, RootPath + '/cac:AccountingSupplierParty/cac:Party/cbc:EndpointID/@schemeID') = ABNSchemeIdTok then
            ABN := CopyStr(GetNodeByPath(TempXMLBuffer, RootPath + '/cac:AccountingSupplierParty/cac:Party/cbc:EndpointID'), 1, MaxStrLen(ABN));
        if GetNodeAttributeByPath(TempXMLBuffer, RootPath + '/cac:AccountingSupplierParty/cac:Party/cbc:EndpointID/@schemeID') = GLNSchemeIdTok then
            GLN := CopyStr(GetNodeByPath(TempXMLBuffer, RootPath + '/cac:AccountingSupplierParty/cac:Party/cbc:EndpointID'), 1, MaxStrLen(GLN));
        VATRegistrationNo := CopyStr(GetNodeByPath(TempXMLBuffer, RootPath + '/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID'), 1, MaxStrLen(VATRegistrationNo));
        VendorParticipantId := GetNodeAttributeByPath(TempXMLBuffer, RootPath + '/cac:AccountingSupplierParty/cac:Party/cbc:EndpointID/@schemeID') + ':';
        VendorParticipantId += this.GetNodeByPath(TempXMLBuffer, RootPath + '/cac:AccountingSupplierParty/cac:Party/cbc:EndpointID');
        VendorName := GetNodeByPath(TempXMLBuffer, RootPath + '/cac:AccountingSupplierParty/cac:Party/cac:PartyName/cbc:Name');
        VendorAddress := GetNodeByPath(TempXMLBuffer, RootPath + '/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:StreetName');
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

    local procedure ParseAccountingCustomerParty(var EDocument: Record "E-Document"; var TempXMLBuffer: Record "XML Buffer" temporary; RootPath: Text)
    var
        ReceivingId: Text[250];
    begin
        EDocument."Receiving Company Name" := CopyStr(GetNodeByPath(TempXMLBuffer, RootPath + '/cac:AccountingCustomerParty/cac:Party/cac:PartyName/cbc:Name'), 1, MaxStrLen(EDocument."Receiving Company Name"));
        EDocument."Receiving Company Address" := CopyStr(GetNodeByPath(TempXMLBuffer, RootPath + '/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:StreetName'), 1, MaxStrLen(EDocument."Receiving Company Address"));
        EDocument."Receiving Company GLN" := CopyStr(GetNodeByPath(TempXMLBuffer, RootPath + '/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID'), 1, MaxStrLen(EDocument."Receiving Company GLN"));
        EDocument."Receiving Company VAT Reg. No." := CopyStr(GetNodeByPath(TempXMLBuffer, RootPath + '/cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID'), 1, MaxStrLen(EDocument."Receiving Company VAT Reg. No."));
        ReceivingId := CopyStr(this.GetNodeAttributeByPath(TempXMLBuffer, RootPath + '/cac:AccountingCustomerParty/cac:Party/cbc:EndpointID/@schemeID'), 1, (MaxStrLen(EDocument."Receiving Company Id") - 1)) + ':';
        ReceivingId += CopyStr(this.GetNodeByPath(TempXMLBuffer, RootPath + '/cac:AccountingCustomerParty/cac:Party/cbc:EndpointID'), 1, MaxStrLen(EDocument."Receiving Company Id") - StrLen(ReceivingId));
        EDocument."Receiving Company Id" := ReceivingId;
    end;

    local procedure GetDocumentType(var TempXMLBuffer: Record "XML Buffer" temporary; var RootPath: Text): Text
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.SetRange(Type, TempXMLBuffer.Type::Element);
        TempXMLBuffer.SetRange("Parent Entry No.", 0);

        if not TempXMLBuffer.FindFirst() then
            Error('Invalid XML file');

        RootPath := TempXMLBuffer.Path;
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