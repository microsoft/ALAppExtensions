codeunit 11757 "Unreliable Payer WS CZL"
{
    var
        NamespaceTok: Label 'http://adis.mfcr.cz/rozhraniCRPDPH/', Locked = true;
        ServiceUrl: Text;

    [TryFunction]
    procedure GetStatus(var VATRegNoList: List of [Code[20]]; var TempBlobResponse: Codeunit "Temp Blob")
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
        SendHttpRequest(RequestXmlDocument, TempBlobResponse);
    end;

    [TryFunction]
    procedure GetStatusExtended(var VATRegNoList: List of [Code[20]]; var TempBlobResponse: Codeunit "Temp Blob")
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
        SendHttpRequest(RequestXmlDocument, TempBlobResponse);
    end;

    [TryFunction]
    procedure GetList(var TempBlobResponse: Codeunit "Temp Blob")
    var
        RequestXmlDocument: XmlDocument;
        RootXmlNode: XmlElement;
    begin
        RequestXmlDocument := XmlDocument.Create();
        RootXmlNode := XmlElement.Create('SeznamNespolehlivyPlatceRequest', NamespaceTok);
        RequestXmlDocument.Add(RootXmlNode);
        SendHttpRequest(RequestXmlDocument, TempBlobResponse);
    end;

    procedure GetInputRecordLimit(): Integer
    begin
        exit(100);
    end;

    local procedure CheckInputRecordLimit(VatRegNoCount: Integer)
    var
        VATRegNoLimitExceededMsg: Label 'The number of VAT Registration No. has been exceeded. The maximum number of VAT Registration No. is 100 and %1 were sent. The service returns a response for only the first top 100 VAT Registration No.', Comment = '%1 = actual number of sending VAT registration numbers';
    begin
        if VatRegNoCount > GetInputRecordLimit() then
            if GuiAllowed() then
                Message(VATRegNoLimitExceededMsg, VatRegNoCount);
    end;

    local procedure SendHttpRequest(RequestXmlDocument: XmlDocument; var TempBlobResponse: Codeunit "Temp Blob")
    var
        SOAPWSRequestManagementCZL: Codeunit "SOAP WS Request Management CZL";
        UnreliablePayerMgtCZL: Codeunit "Unreliable Payer Mgt. CZL";
        TempBlobRequest: Codeunit "Temp Blob";
    begin
        SOAPWSRequestManagementCZL.SetStreamEncoding(TextEncoding::Windows);
        SOAPWSRequestManagementCZL.SetTimeout(10000);
        SOAPWSRequestManagementCZL.DisableHttpsCheck();
        SOAPWSRequestManagementCZL.SendRequestToWebService(UnreliablePayerMgtCZL.GetUnreliablePayerServiceURL(), RequestXmlDocument);
        if not SOAPWSRequestManagementCZL.HasResponseFaultResult() then
            SOAPWSRequestManagementCZL.GetResponseContent(TempBlobResponse);
        SOAPWSRequestManagementCZL.ProcessFaultResponse();
    end;

    local procedure FormatVATRegNo(VATRegNo: Text): Text
    var
        DotNetRegex: Codeunit DotNet_Regex;
    begin
        DotNetRegex.Regex('[A-Z]');
        exit(DotNetRegex.Replace(UpperCase(VATRegNo), ''));
    end;
}
