codeunit 20114 "AMC Bank Imp.STMT. Hndl"
{
    Permissions = TableData "AMC Banking Setup" = r;
    TableNo = "Data Exch.";

    trigger OnRun()
    var
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
    begin
        "File Name" :=
          CopyStr(FileMgt.BLOBImportWithFilter(TempBlob, ImportBankStmtTxt, '', FileFilterTxt, FileFilterExtensionTxt), 1, 250);
        if "File Name" = '' then
            exit;

        ConvertBankStatementToFormat(TempBlob, Rec);
    end;

    var
        AMCBankServMgt: Codeunit "AMC Banking Mgt.";
        NoRequestBodyErr: Label 'The request body is not set.';
        FileFilterTxt: Label 'All Files(*.*)|*.*|XML Files(*.xml)|*.xml|Text Files(*.txt;*.csv;*.asc)|*.txt;*.csv;*.asc';
        FileFilterExtensionTxt: Label 'txt,csv,asc,xml', Locked = true;
        FinstaNotCollectedErr: Label 'The AMC Banking has not returned any statement transactions.\\For more information, go to %1.';
        ResponseNodeTxt: Label 'reportExportResponse', Locked = true;
        ImportBankStmtTxt: Label 'Select a file to import.';
        BankDataConvServSysErr: Label 'The AMC Banking has returned the following error message:';
        AddnlInfoTxt: Label 'For more information, go to %1.';
        ContentTypeTxt: Label 'text/xml; charset=utf-8', Locked = true;

    [Scope('OnPrem')]
    procedure ConvertBankStatementToFormat(var TempBlobBankStatement: Codeunit "Temp Blob"; var DataExch: Record "Data Exch.")
    var
        TempBlobResult: Codeunit "Temp Blob";
        RecordRef: RecordRef;
    begin
        SendDataToWebService(TempBlobResult, TempBlobBankStatement);
        RecordRef.GetTable(DataExch);
        TempBlobResult.ToRecordRef(RecordRef, DataExch.FieldNo("File Content"));
        RecordRef.SetTable(DataExch);
    end;

    local procedure SendDataToWebService(var TempBlobStatement: Codeunit "Temp Blob"; var TempBlobBody: Codeunit "Temp Blob")
    var
        AMCBankServiceSetup: Record "AMC Banking Setup";
        SOAPWebServiceRequestMgt: Codeunit "SOAP Web Service Request Mgt.";
        ResponseInStream: InStream;
        InStream: InStream;
    begin
        AMCBankServMgt.CheckCredentials();

        if not TempBlobBody.HasValue() then
            Error(NoRequestBodyErr);

        PrepareSOAPRequestBody(TempBlobBody);

        AMCBankServiceSetup.Get();

        TempBlobBody.CreateInStream(InStream);

        SOAPWebServiceRequestMgt.SetGlobals(InStream,
          AMCBankServiceSetup."Service URL", AMCBankServiceSetup.GetUserName(), AMCBankServiceSetup.GetPassword());
        SOAPWebServiceRequestMgt.SetContentType(ContentTypeTxt);

        if not SOAPWebServiceRequestMgt.SendRequestToWebService() then
            SOAPWebServiceRequestMgt.ProcessFaultResponse(StrSubstNo(AddnlInfoTxt, AMCBankServiceSetup."Support URL"));

        SOAPWebServiceRequestMgt.GetResponseContent(ResponseInStream);

        CheckIfErrorsOccurred(ResponseInStream);

        ReadContentFromResponse(TempBlobStatement, ResponseInStream);
    end;

    local procedure PrepareSOAPRequestBody(var TempBlob: Codeunit "Temp Blob")
    var
        XMLDOMMgt: Codeunit "XML DOM Management";
        BodyContentOutputStream: OutStream;
        BodyContentXmlDoc: DotNet XmlDocument;
        EnvelopeXmlNode: DotNet XmlNode;
        HeaderXmlNode: DotNet XmlNode;
        ClientCodeXmlNode: DotNet XmlNode;
        PackXmlNode: DotNet XmlNode;
        DataXmlNode: DotNet XmlNode;
        MsgTypeXmlNode: DotNet XmlNode;
    begin
        BodyContentXmlDoc := BodyContentXmlDoc.XmlDocument();

        with XMLDOMMgt do begin
            AddRootElementWithPrefix(BodyContentXmlDoc, 'reportExport', '', AMCBankServMgt.GetNamespace(), EnvelopeXmlNode);

            AddElementWithPrefix(EnvelopeXmlNode, 'amcreportreq', '', '', '', HeaderXmlNode);
            AddAttribute(HeaderXmlNode, 'xmlns', '');

            AddElementWithPrefix(HeaderXmlNode, 'clientcode', AMCBankServMgt.GetAMCClientCode(), '', '', ClientCodeXmlNode);
            AddElementWithPrefix(HeaderXmlNode, 'pack', '', '', '', PackXmlNode);

            AddNode(PackXmlNode, 'journalnumber', DelChr(LowerCase(Format(CreateGuid())), '=', '{}'));
            AddElementWithPrefix(PackXmlNode, 'data', EncodeBankStatementFile(TempBlob), '', '', DataXmlNode);

            AddElementWithPrefix(EnvelopeXmlNode, 'messagetype', 'finsta', '', '', MsgTypeXmlNode);
        end;

        Clear(TempBlob);
        TempBlob.CreateOutStream(BodyContentOutputStream);
        BodyContentXmlDoc.Save(BodyContentOutputStream);
    end;

    local procedure EncodeBankStatementFile(TempBlob: Codeunit "Temp Blob"): Text
    var
        FileMgt: Codeunit "File Management";
        Convert: DotNet Convert;
        File: DotNet File;
        FileName: Text;
    begin
        FileName := FileMgt.ServerTempFileName('txt');
        FileMgt.IsAllowedPath(FileName, false);
        FileMgt.BLOBExportToServerFile(TempBlob, FileName);
        exit(Convert.ToBase64String(File.ReadAllBytes(FileName)));
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
            ErrorText := BankDataConvServSysErr;
            for i := 1 to XMLNodeList.Count() do
                ErrorText += '\\' + XMLDOMMgt.FindNodeText(XMLNodeList.Item(i - 1), 'text') + '\' +
                  XMLDOMMgt.FindNodeText(XMLNodeList.Item(i - 1), 'hinttext') + '\\' +
                  StrSubstNo(AddnlInfoTxt, AMCBankServMgt.GetSupportURL(XMLNodeList.Item(i - 1)));

            Error(ErrorText);
        end;
    end;

    local procedure ReadContentFromResponse(var TempBlob: Codeunit "Temp Blob"; ResponseInStream: InStream)
    var
        XMLDOMMgt: Codeunit "XML DOM Management";
        FinstaXmlNode: DotNet XmlNode;
        ResponseXmlDoc: DotNet XmlDocument;
        ResponseOutStream: OutStream;
        Found: Boolean;
    begin
        XMLDOMMgt.LoadXMLDocumentFromInStream(ResponseInStream, ResponseXmlDoc);

        Found := XMLDOMMgt.FindNodeWithNamespace(ResponseXmlDoc.DocumentElement(),
            AMCBankServMgt.GetFinstaXPath(ResponseNodeTxt), 'amc', AMCBankServMgt.GetNamespace(), FinstaXmlNode);
        if not Found then
            Error(FinstaNotCollectedErr, AMCBankServMgt.GetSupportURL(FinstaXmlNode));

        TempBlob.CreateOutStream(ResponseOutStream);
        CopyStream(ResponseOutStream, ResponseInStream);
    end;
}

