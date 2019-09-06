codeunit 20115 "AMC Bank Imp.BankList Hndl"
{
    Permissions = TableData "AMC Bank Banks" = rimd,
                  TableData "AMC Banking Setup" = r;

    trigger OnRun()
    begin
        GetBankListFromWebService(true, '', 5000);
    end;

    var
        AMCBankServMgt: Codeunit "AMC Banking Mgt.";
        AddnlInfoTxt: Label 'For more information, go to %1.';
        ResponseNodeTxt: Label 'bankListResponse', Locked = true;
        AMCBankServSysErr: Label 'The AMC Banking has returned the following error message:';

    [Scope('OnPrem')]
    procedure GetBankListFromWebService(ShowErrors: Boolean; CountryFilter: Text; Timeout: Integer)
    var
        TempBlobRequestBody: Codeunit "Temp Blob";
    begin
        SendRequestToWebService(TempBlobRequestBody, ShowErrors, Timeout, CountryFilter);
        InsertBankData(TempBlobRequestBody, CountryFilter);
    end;

    local procedure SendRequestToWebService(var TempBlobBody: Codeunit "Temp Blob"; EnableUI: Boolean; Timeout: Integer; CountryFilter: Text)
    var
        AMCBankServiceSetup: Record "AMC Banking Setup";
        SOAPWebServiceRequestMgt: Codeunit "SOAP Web Service Request Mgt.";
        ResponseInStream: InStream;
        InStream: InStream;
        ResponseOutStream: OutStream;
    begin
        AMCBankServMgt.CheckCredentials();

        PrepareSOAPRequestBody(TempBlobBody, CountryFilter);

        AMCBankServiceSetup.Get();
        TempBlobBody.CreateInStream(InStream);
        SOAPWebServiceRequestMgt.SetGlobals(InStream,
          AMCBankServiceSetup."Service URL", AMCBankServiceSetup.GetUserName(), AMCBankServiceSetup.GetPassword());
        SOAPWebServiceRequestMgt.SetTimeout(Timeout);
        if not EnableUI then
            SOAPWebServiceRequestMgt.DisableProgressDialog();

        if SOAPWebServiceRequestMgt.SendRequestToWebService() then begin
            SOAPWebServiceRequestMgt.GetResponseContent(ResponseInStream);

            if EnableUI then
                CheckIfErrorsOccurred(ResponseInStream);

            TempBlobBody.CreateOutStream(ResponseOutStream);
            CopyStream(ResponseOutStream, ResponseInStream);
        end else
            if EnableUI then
                SOAPWebServiceRequestMgt.ProcessFaultResponse(StrSubstNo(AddnlInfoTxt, AMCBankServiceSetup."Support URL"));
    end;

    local procedure PrepareSOAPRequestBody(var TempBlobBody: Codeunit "Temp Blob"; CountryFilter: Text)
    var
        XMLDOMMgt: Codeunit "XML DOM Management";
        BodyContentInputStream: InStream;
        BodyContentOutputStream: OutStream;
        BodyContentXmlDoc: DotNet XmlDocument;
        OperationXmlNode: DotNet XmlNode;
        ElementXmlNode: DotNet XmlNode;
    begin
        TempBlobBody.CreateInStream(BodyContentInputStream);
        BodyContentXmlDoc := BodyContentXmlDoc.XmlDocument();

        XMLDOMMgt.AddRootElementWithPrefix(BodyContentXmlDoc, 'bankList', '', AMCBankServMgt.GetNamespace(), OperationXmlNode);
        XMLDOMMgt.AddElementWithPrefix(OperationXmlNode, 'compressed', 'true', '', '', ElementXmlNode);
        XMLDOMMgt.AddElementWithPrefix(OperationXmlNode, 'filterbycountry', CountryFilter, '', '', ElementXmlNode);

        Clear(TempBlobBody);
        TempBlobBody.CreateOutStream(BodyContentOutputStream);
        BodyContentXmlDoc.Save(BodyContentOutputStream);
    end;

    local procedure InsertBankData(TempBlob: Codeunit "Temp Blob"; CountryFilter: Text)
    var
        AMCBankBank: Record "AMC Bank Banks";
        XMLDOMMgt: Codeunit "XML DOM Management";
        XMLDocOut: DotNet XmlDocument;
        XmlNodeList: DotNet XmlNodeList;
        ChildNode: DotNet XmlNode;
        InStream: InStream;
        index: Integer;
        XPath: Text;
        Found: Boolean;
        ChildCounter: Integer;
    begin
        TempBlob.CreateInStream(InStream);
        XMLDOMMgt.LoadXMLDocumentFromInStream(InStream, XMLDocOut);

        XPath := '/amc:bankListResponse/return/pack/bank';

        Found := XMLDOMMgt.FindNodesWithNamespace(XMLDocOut.DocumentElement(), XPath, 'amc', AMCBankServMgt.GetNamespace(), XmlNodeList);

        if not Found then
            exit;

        if XmlNodeList.Count() > 0 then begin
            if CountryFilter <> '' then
                AMCBankBank.SetRange("Country/Region Code", CountryFilter);
            AMCBankBank.DeleteAll();
            for index := 0 to XmlNodeList.Count() do
                if not IsNull(XmlNodeList.Item(index)) then begin
                    Clear(AMCBankBank);
                    if XmlNodeList.Item(index).HasChildNodes() then begin
                        for ChildCounter := 0 to XmlNodeList.Item(index).ChildNodes().Count() - 1 do begin
                            ChildNode := XmlNodeList.Item(index).ChildNodes().Item(ChildCounter);
                            case ChildNode.Name() of
                                'bank':
                                    AMCBankBank.Bank := ChildNode.InnerText();
                                'bankname':
                                    AMCBankBank."Bank Name" := ChildNode.InnerText();
                                'countryoforigin':
                                    AMCBankBank."Country/Region Code" := ChildNode.InnerText();
                            end;

                            AMCBankBank."Last Update Date" := Today();
                        end;
                        AMCBankBank.Insert();
                    end;
                end;
        end;
    end;

    local procedure CheckIfErrorsOccurred(var ResponseInStream: InStream)
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        ResponseXmlDoc: DotNet XmlDocument;
    begin
        XMLDOMManagement.LoadXMLDocumentFromInStream(ResponseInStream, ResponseXmlDoc);

        if ResponseHasErrors(ResponseXmlDoc) then
            DisplayErrorFromResponse(ResponseXmlDoc);
    end;

    local procedure ResponseHasErrors(ResponseXmlDoc: DotNet XmlDocument): Boolean
    var
        XMLDOMMgt: Codeunit "XML DOM Management";
        XmlNode: DotNet XmlNode;
    begin
        exit(XMLDOMMgt.FindNodeWithNamespace(ResponseXmlDoc.DocumentElement(),
            AMCBankServMgt.GetErrorXPath(ResponseNodeTxt), 'amc', AMCBankServMgt.GetNamespace(), XmlNode));
    end;

    local procedure DisplayErrorFromResponse(ResponseXmlDoc: DotNet XmlDocument)
    var
        XMLDOMMgt: Codeunit "XML DOM Management";
        XMLNodeList: DotNet XmlNodeList;
        Found: Boolean;
        ErrorText: Text;
        i: Integer;
    begin
        Found := XMLDOMMgt.FindNodesWithNamespace(ResponseXmlDoc.DocumentElement(),
            AMCBankServMgt.GetErrorXPath(ResponseNodeTxt), 'amc', AMCBankServMgt.GetNamespace(), XMLNodeList);
        if Found then begin
            ErrorText := AMCBankServSysErr;
            for i := 1 to XMLNodeList.Count() do
                ErrorText += '\\' + XMLDOMMgt.FindNodeText(XMLNodeList.Item(i - 1), 'text') + '\' +
                  XMLDOMMgt.FindNodeText(XMLNodeList.Item(i - 1), 'hinttext') + '\\' +
                  StrSubstNo(AddnlInfoTxt, AMCBankServMgt.GetSupportURL(XMLNodeList.Item(i - 1)));

            Error(ErrorText);
        end;
    end;
}

