// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;

using System.Integration;
using System.Utilities;

codeunit 11757 "Unreliable Payer WS CZL"
{
    var
        NamespaceTok: Label 'http://adis.mfcr.cz/rozhraniCRPDPH/', Locked = true;
        GetStatusSoapActionTok: Label 'http://adis.mfcr.cz/rozhraniCRPDPH/getStatusNespolehlivyPlatce', Locked = true;
        GetStatusExtendedSoapActionTok: Label 'http://adis.mfcr.cz/rozhraniCRPDPH/getStatusNespolehlivyPlatceRozsireny', Locked = true;
        GetListSoapActionTok: Label 'http://adis.mfcr.cz/rozhraniCRPDPH/getSeznamNespolehlivyPlatce', Locked = true;

    [TryFunction]
    procedure GetStatus(var VATRegNoList: List of [Code[20]]; var ResponseTempBlob: Codeunit "Temp Blob")
    var
        RequestXmlDocument: XmlDocument;
        RootXmlNode: XmlElement;
        ChildXmlNode: XmlElement;
        VATRegNo: Code[20];
    begin
        CheckInputRecordLimit(VATRegNoList.Count);
        RequestXmlDocument := XmlDocument.Create();
        RootXmlNode := XmlElement.Create('StatusNespolehlivyPlatceRequest', NamespaceTok);
        RequestXmlDocument.Add(RootXmlNode);
        foreach VATRegNo in VATRegNoList do begin
            ChildXmlNode := XmlElement.Create('dic', NamespaceTok, FormatVATRegNo(VATRegNo));
            RootXmlNode.Add(ChildXmlNode);
        end;
        SendHttpRequest(RequestXmlDocument, GetStatusSoapActionTok, ResponseTempBlob);
    end;

    [TryFunction]
    procedure GetStatusExtended(var VATRegNoList: List of [Code[20]]; var ResponseTempBlob: Codeunit "Temp Blob")
    var
        RequestXmlDocument: XmlDocument;
        RootXmlNode: XmlElement;
        ChildXmlNode: XmlElement;
        VATRegNo: Code[20];
    begin
        CheckInputRecordLimit(VATRegNoList.Count);
        RequestXmlDocument := XmlDocument.Create();
        RootXmlNode := XmlElement.Create('StatusNespolehlivyPlatceRozsirenyRequest', NamespaceTok);
        RequestXmlDocument.Add(RootXmlNode);
        foreach VATRegNo in VATRegNoList do begin
            ChildXmlNode := XmlElement.Create('dic', NamespaceTok, FormatVATRegNo(VATRegNo));
            RootXmlNode.Add(ChildXmlNode);
        end;
        SendHttpRequest(RequestXmlDocument, GetStatusExtendedSoapActionTok, ResponseTempBlob);
    end;

    [TryFunction]
    procedure GetList(var ResponseTempBlob: Codeunit "Temp Blob")
    var
        RequestXmlDocument: XmlDocument;
        RootXmlNode: XmlElement;
    begin
        RequestXmlDocument := XmlDocument.Create();
        RootXmlNode := XmlElement.Create('SeznamNespolehlivyPlatceRequest', NamespaceTok);
        RequestXmlDocument.Add(RootXmlNode);
        SendHttpRequest(RequestXmlDocument, GetListSoapActionTok, ResponseTempBlob);
    end;

    procedure GetInputRecordLimit(): Integer
    var
        UnrelPayerServiceSetupCZL: Record "Unrel. Payer Service Setup CZL";
    begin
        UnrelPayerServiceSetupCZL.Get();
        if UnrelPayerServiceSetupCZL."Unr.Payer Request Record Limit" <> 0 then
            exit(UnrelPayerServiceSetupCZL."Unr.Payer Request Record Limit");
        exit(GetDefaultInputRecordLimit());
    end;

    procedure GetDefaultInputRecordLimit(): Integer
    begin
        exit(100);
    end;

    local procedure CheckInputRecordLimit(VatRegNoCount: Integer)
    var
        InputRecordLimit: Integer;
        VATRegNoLimitExceededMsg: Label 'The number of VAT Registration No. has been exceeded. The maximum number of VAT Registration No. is %1 and %2 were sent. The service returns a response for only the first top %1 VAT Registration No.', Comment = '%1 = input record limit; %2 = actual number of sending VAT registration numbers';
    begin
        InputRecordLimit := GetInputRecordLimit();
        if VatRegNoCount > InputRecordLimit then
            if GuiAllowed() then
                Message(VATRegNoLimitExceededMsg, InputRecordLimit, VatRegNoCount);
    end;

    local procedure SendHttpRequest(RequestXmlDocument: XmlDocument; SoapAction: Text; var ResponseTempBlob: Codeunit "Temp Blob")
    var
        SOAPWSRequestManagementCZL: Codeunit "SOAP WS Request Management CZL";
        UnreliablePayerMgtCZL: Codeunit "Unreliable Payer Mgt. CZL";
    begin
        SOAPWSRequestManagementCZL.SetStreamEncoding(TextEncoding::Windows);
        SOAPWSRequestManagementCZL.SetTimeout(10000);
        SOAPWSRequestManagementCZL.SetAction(SoapAction);
        SOAPWSRequestManagementCZL.DisableHttpsCheck();
        if SOAPWSRequestManagementCZL.SendRequestToWebService(UnreliablePayerMgtCZL.GetUnreliablePayerServiceURL(), RequestXmlDocument) then
            SOAPWSRequestManagementCZL.GetResponseContent(ResponseTempBlob)
        else
            SOAPWSRequestManagementCZL.ProcessFaultResponse();
    end;

    local procedure FormatVATRegNo(VATRegNo: Text): Text
    var
        Regex: Codeunit Regex;
    begin
        exit(Regex.Replace(UpperCase(VATRegNo), '[A-Z]', ''));
    end;
}
