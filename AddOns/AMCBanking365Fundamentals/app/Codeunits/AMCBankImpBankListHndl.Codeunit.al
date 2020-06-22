codeunit 20115 "AMC Bank Imp.BankList Hndl"
{
    Permissions = TableData "AMC Bank Banks" = rimd,
                  TableData "AMC Banking Setup" = r;

    trigger OnRun()
    var
    begin
        GetBankListFromWebService(true, '', 5000, AMCBankServMgt.GetAppCaller());
    end;

    var
        AMCBankServiceRequestMgt: Codeunit "AMC Bank Service Request Mgt.";
        AMCBankServMgt: Codeunit "AMC Banking Mgt.";
        AMCBankServSysErr: Label 'The AMC Banking has returned the following error message:';
        AddnlInfoTxt: Label 'For more information, go to %1.', comment = '%1=Support URL';
        BankListWebCallTxt: Label 'bankList', locked = true;

    [Scope('OnPrem')]
    [Obsolete('This method is obsolete. A new GetBankListFromWebService overload is available', '16.2')]
    procedure GetBankListFromWebService(ShowErrors: Boolean; CountryFilter: Text; Timeout: Integer)
    var
    begin
        GetBankListFromWebService(ShowErrors, CountryFilter, Timeout, AMCBankServMgt.GetAppCaller());
    end;

    [Scope('OnPrem')]
    procedure GetBankListFromWebService(ShowErrors: Boolean; CountryFilter: Text; Timeout: Integer; Appcaller: Text[30])
    var
        TempBlobRequestBody: Codeunit "Temp Blob";
    begin
        SendRequestToWebService(TempBlobRequestBody, ShowErrors, Timeout, CountryFilter, Appcaller);
        InsertBankData(TempBlobRequestBody, CountryFilter);
    end;

    local procedure SendRequestToWebService(var TempBlobBody: Codeunit "Temp Blob"; EnableUI: Boolean; Timeout: Integer; CountryFilter: Text; Appcaller: Text[30])
    var
        AMCBankServiceSetup: Record "AMC Banking Setup";
        BankListRequestMessage: HttpRequestMessage;
        BankListResponseMessage: HttpResponseMessage;
        Handled: Boolean;
        Result: Text;
    begin
        AMCBankServMgt.CheckCredentials();
        AMCBankServiceSetup.Get();

        AMCBankServiceRequestMgt.InitializeHttp(BankListRequestMessage, AMCBankServiceSetup."Service URL", 'POST');

        PrepareSOAPRequestBody(BankListRequestMessage, CountryFilter);

        //Set Content-Type header
        AMCBankServiceRequestMgt.SetHttpContentsDefaults(BankListRequestMessage);

        if not EnableUI then
            AMCBankServiceRequestMgt.DisableProgressDialog();

        //Send Request to webservice
        Handled := false;
        AMCBankServiceRequestMgt.SetTimeout(TimeOut);
        AMCBankServiceRequestMgt.ExecuteWebServiceRequest(Handled, BankListRequestMessage, BankListResponseMessage, BankListWebCallTxt, AppCaller, true);
        AMCBankServiceRequestMgt.GetWebServiceResponse(BankListResponseMessage, TempBlobBody, BankListWebCallTxt + AMCBankServiceRequestMgt.GetResponseTag(), true);
        if (AMCBankServiceRequestMgt.HasResponseErrors(TempBlobBody, AMCBankServiceRequestMgt.GetHeaderXPath(), BankListWebCallTxt + AMCBankServiceRequestMgt.GetResponseTag(), Result, AppCaller)) then
            if EnableUI then
                DisplayErrorFromResponse(TempBlobBody);

    end;

    local procedure PrepareSOAPRequestBody(var BankListExchRequestMessage: HttpRequestMessage; CountryFilter: Text)
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        contentHttpContent: HttpContent;
        BodyContentXmlDoc: XmlDocument;
        BodyDeclaration: Xmldeclaration;
        EnvelopeXMLElement: XmlElement;
        BodyXMLElement: XMLElement;
        OperationXmlNode: XMLElement;
        ChildXmlElement: XmlElement;
        TempXmlDocText: Text;
    begin
        BodyContentXmlDoc := XmlDocument.Create();
        BodyDeclaration := XmlDeclaration.Create('1.0', 'UTF-8', 'No');
        BodyContentXmlDoc.SetDeclaration(BodyDeclaration);

        AMCBankingSetup.Get();
        AMCBankServiceRequestMgt.CreateEnvelope(BodyContentXmlDoc, EnvelopeXmlElement, AMCBankingSetup.GetUserName(), AMCBankingSetup.GetPassword(), '');
        AMCBankServiceRequestMgt.AddElement(EnvelopeXMLElement, EnvelopeXMLElement.NamespaceUri(), 'Body', '', BodyXMLElement, '', '', '');
        AMCBankServiceRequestMgt.AddElement(BodyXMLElement, AMCBankServMgt.GetNamespace(), BankListWebCallTxt, '', OperationXmlNode, '', '', '');

        AMCBankServiceRequestMgt.AddElement(OperationXmlNode, '', 'compressed', 'true', ChildXmlElement, '', '', '');
        AMCBankServiceRequestMgt.AddElement(OperationXmlNode, '', 'filterbycountry', CountryFilter, ChildXmlElement, '', '', '');

        BodyContentXmlDoc.WriteTo(TempXmlDocText);
        AMCBankServiceRequestMgt.RemoveUTF16(TempXmlDocText);
        contentHttpContent.WriteFrom(TempXmlDocText);
        BankListExchRequestMessage.Content(contentHttpContent);
    end;

    local procedure InsertBankData(TempBlob: Codeunit "Temp Blob"; CountryFilter: Text)
    var
        AMCBankBank: Record "AMC Bank Banks";
        ResponseXMLDoc: XmlDocument;
        BankListXmlNodeList: XmlNodeList;
        ChildNode: XmlNode;
        InStreamData: InStream;
        index: Integer;
        XPath: Text;
        Found: Boolean;
        ChildCounter: Integer;
    begin
        TempBlob.CreateInStream(InStreamData);
        XmlDocument.ReadFrom(InStreamData, ResponseXmlDoc);

        Found := ResponseXmlDoc.SelectNodes(STRSUBSTNO(AMCBankServiceRequestMgt.GetBankXPath(BankListWebCallTxt + AMCBankServiceRequestMgt.GetResponseTag()),
                                            BankListWebCallTxt + AMCBankServiceRequestMgt.GetResponseTag(), AMCBankServMgt.GetNamespace()), BankListXmlNodeList);

        if BankListXmlNodeList.Count() > 0 then begin
            if CountryFilter <> '' then
                AMCBankBank.SetRange("Country/Region Code", CountryFilter);

            AMCBankBank.DeleteAll();

            for ChildCounter := 1 to BankListXmlNodeList.Count() do begin
                BankListXmlNodeList.Get(ChildCounter, ChildNode);
                Clear(AMCBankBank);

                EVALUATE(AMCBankBank.Bank, COPYSTR(AMCBankServiceRequestMgt.getNodeValue(ChildNode, './bank'), 1, 50));
                EVALUATE(AMCBankBank."Bank Name", COPYSTR(AMCBankServiceRequestMgt.getNodeValue(ChildNode, './bankname'), 1, 50));
                EVALUATE(AMCBankBank."Country/Region Code", COPYSTR(AMCBankServiceRequestMgt.getNodeValue(ChildNode, './countryoforigin'), 1, 50));
                AMCBankBank."Last Update Date" := TODAY();
                AMCBankBank.Insert(true);
            end;
        end;
    end;

    local procedure DisplayErrorFromResponse(TempBlobBankList: Codeunit "Temp Blob")
    var
        ResponseXmlDoc: XmlDocument;
        InStreamData: InStream;
        SysLogXMLNodeList: XmlNodeList;
        SyslogXmlNode: XmlNode;
        Found: Boolean;
        ErrorText: Text;
        i, j : Integer;
    begin
        TempBlobBankList.CreateInStream(InStreamData);
        XmlDocument.ReadFrom(InStreamData, ResponseXmlDoc);

        Found := ResponseXmlDoc.SelectNodes(STRSUBSTNO(AMCBankServiceRequestMgt.GetSysErrXPath(BankListWebCallTxt + AMCBankServiceRequestMgt.GetResponseTag()),
                                            BankListWebCallTxt + AMCBankServiceRequestMgt.GetResponseTag(), AMCBankServMgt.GetNamespace()), SysLogXMLNodeList);
        if Found then begin
            ErrorText := AMCBankServSysErr;
            for j := 1 to SysLogXMLNodeList.Count() do begin
                SysLogXMLNodeList.Get(j, SyslogXmlNode);
                ErrorText += '\\' + CopyStr(AMCBankServiceRequestMgt.getNodeValue(SyslogXmlNode, 'text'), 1, 250) + '\' +
                  CopyStr(AMCBankServiceRequestMgt.getNodeValue(SyslogXmlNode, 'hinttext'), 1, 250) + '\\' +
                  StrSubstNo(AddnlInfoTxt, AMCBankServMgt.GetSupportURL(ResponseXmlDoc));
            end;
            Error(ErrorText);
        end;
    end;
}

