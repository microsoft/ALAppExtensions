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
        AMCBankServiceRequestMgt: Codeunit "AMC Bank Service Request Mgt.";
        AMCBankServMgt: Codeunit "AMC Banking Mgt.";
        NoRequestBodyErr: Label 'The request body is not set.';
        FileFilterTxt: Label 'All Files(*.*)|*.*|XML Files(*.xml)|*.xml|Text Files(*.txt;*.csv;*.asc)|*.txt;*.csv;*.asc';
        FileFilterExtensionTxt: Label 'txt,csv,asc,xml', Locked = true;
        FinstaNotCollectedErr: Label 'The AMC Banking has not returned any statement transactions.\\For more information, go to %1.', comment = '%1=Support URl';
        ImportBankStmtTxt: Label 'Select a file to import.';
        BankDataConvServSysErr: Label 'The AMC Banking has returned the following error message:';
        AddnlInfoTxt: Label 'For more information, go to %1.', Comment = '%1=Support URL';
        ReportExportWebCallTxt: Label 'reportExport', locked = true;

    [Scope('OnPrem')]
    procedure ConvertBankStatementToFormat(var TempBlobBankStatement: Codeunit "Temp Blob"; var DataExch: Record "Data Exch.")
    var
        TempBlobResult: Codeunit "Temp Blob";
        RecordRef: RecordRef;
    begin
        SendReportExportRequestToWebService(TempBlobResult, TempBlobBankStatement, AMCBankServMgt.GetAppCaller());
        RecordRef.GetTable(DataExch);
        TempBlobResult.ToRecordRef(RecordRef, DataExch.FieldNo("File Content"));
        RecordRef.SetTable(DataExch);
    end;

    local procedure SendReportExportRequestToWebService(var TempBlobStatement: Codeunit "Temp Blob"; var TempBlobBody: Codeunit "Temp Blob"; AppCaller: text[30])
    var
        AMCBankServiceSetup: Record "AMC Banking Setup";
        ReportExportRequestMessage: HttpRequestMessage;
        ReportExportResponseMessage: HttpResponseMessage;
        Handled: Boolean;
        Result: Text;
    begin
        if not TempBlobBody.HasValue() then
            Error(NoRequestBodyErr);

        AMCBankServMgt.CheckCredentials();
        AMCBankServiceSetup.Get();

        AMCBankServiceRequestMgt.InitializeHttp(ReportExportRequestMessage, AMCBankServiceSetup."Service URL", 'POST');

        PrepareSOAPRequestBody(ReportExportRequestMessage, TempBlobBody);

        //Set Content-Type header
        AMCBankServiceRequestMgt.SetHttpContentsDefaults(ReportExportRequestMessage);

        //Send Request to webservice
        Handled := false;
        AMCBankServiceRequestMgt.ExecuteWebServiceRequest(Handled, ReportExportRequestMessage, ReportExportResponseMessage, ReportExportWebCallTxt, AppCaller, true);
        AMCBankServiceRequestMgt.GetWebServiceResponse(ReportExportResponseMessage, TempBlobStatement, ReportExportWebCallTxt + AMCBankServiceRequestMgt.GetResponseTag(), true);
        if (AMCBankServiceRequestMgt.HasResponseErrors(TempBlobStatement, AMCBankServiceRequestMgt.GetHeaderXPath(), ReportExportWebCallTxt + AMCBankServiceRequestMgt.GetResponseTag(), Result, AppCaller)) then
            DisplayErrorFromResponse(TempBlobStatement)
        else
            ReadContentFromResponse(TempBlobStatement);
    end;

    local procedure PrepareSOAPRequestBody(var ReportExportRequestMessage: HttpRequestMessage; var TempBlob: Codeunit "Temp Blob")
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        ContentHttpContent: HttpContent;
        BodyContentXmlDoc: XmlDocument;
        BodyDeclaration: Xmldeclaration;
        EnvelopeXmlElement: XmlElement;
        HeaderXmlElement: XmlElement;
        AmcReportReqXMLElement: XmlElement;
        BodyXMLElement: XmlElement;
        ChildXmlElement: XmlElement;
        PackXmlElement: XmlElement;
        TempXmlDocText: Text;
    begin

        BodyContentXmlDoc := XmlDocument.Create();
        BodyDeclaration := XmlDeclaration.Create('1.0', 'UTF-8', 'No');
        BodyContentXmlDoc.SetDeclaration(BodyDeclaration);

        AMCBankingSetup.Get();
        AMCBankServiceRequestMgt.CreateEnvelope(BodyContentXmlDoc, EnvelopeXmlElement, AMCBankingSetup.GetUserName(), AMCBankingSetup.GetPassword(), '');
        AMCBankServiceRequestMgt.AddElement(EnvelopeXMLElement, EnvelopeXMLElement.NamespaceUri(), 'Body', '', BodyXMLElement, '', '', '');
        AMCBankServiceRequestMgt.AddElement(BodyXMLElement, AMCBankServMgt.GetNamespace(), ReportExportWebCallTxt, '', HeaderXmlElement, '', '', '');
        AMCBankServiceRequestMgt.AddElement(HeaderXmlElement, '', 'amcreportreq', '', AmcReportReqXMLElement, '', '', '');
        AMCBankServiceRequestMgt.AddElement(AmcReportReqXMLElement, '', 'clientcode', AMCBankServMgt.GetAMCClientCode(), ChildXmlElement, '', '', '');
        AMCBankServiceRequestMgt.AddElement(AmcReportReqXMLElement, '', 'pack', '', PackXmlElement, '', '', '');

        AMCBankServiceRequestMgt.AddElement(PackXmlElement, '', 'journalnumber', DelChr(LowerCase(Format(CreateGuid())), '=', '{}'), ChildXmlElement, '', '', '');
        AMCBankServiceRequestMgt.AddElement(PackXmlElement, '', 'data', EncodeBankStatementFile(TempBlob), ChildXmlElement, '', '', '');
        AMCBankServiceRequestMgt.AddElement(HeaderXmlElement, '', 'messagetype', 'finsta', ChildXmlElement, '', '', '');

        BodyContentXmlDoc.WriteTo(TempXmlDocText);
        AMCBankServiceRequestMgt.RemoveUTF16(TempXmlDocText);
        contentHttpContent.WriteFrom(TempXmlDocText);
        ReportExportRequestMessage.Content(contentHttpContent);
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

    local procedure DisplayErrorFromResponse(TempBlobStatementFile: Codeunit "Temp Blob")
    var
        ResponseXmlDoc: XmlDocument;
        SysLogXMLNodeList: XmlNodeList;
        SyslogXmlNode: XmlNode;
        InStreamData: InStream;
        Found: Boolean;
        ErrorText: Text;
        i: Integer;
    begin

        TempBlobStatementFile.CreateInStream(InStreamData);
        XmlDocument.ReadFrom(InStreamData, ResponseXmlDoc);

        Found := ResponseXmlDoc.SelectNodes(STRSUBSTNO(AMCBankServiceRequestMgt.GetSysErrXPath(ReportExportWebCallTxt + AMCBankServiceRequestMgt.GetResponseTag()),
                                                       ReportExportWebCallTxt + AMCBankServiceRequestMgt.GetResponseTag(), AMCBankServMgt.GetNamespace()), SysLogXMLNodeList);
        if Found then begin
            ErrorText := BankDataConvServSysErr;
            for i := 1 to SysLogXMLNodeList.Count() do begin
                SysLogXMLNodeList.Get(i, SyslogXmlNode);
                ErrorText += '\\' + CopyStr(AMCBankServiceRequestMgt.getNodeValue(SyslogXmlNode, 'text'), 1, 250) + '\' +
                  CopyStr(AMCBankServiceRequestMgt.getNodeValue(SyslogXmlNode, 'hinttext'), 1, 250) + '\\' +
                  StrSubstNo(AddnlInfoTxt, AMCBankServMgt.GetSupportURL(ResponseXmlDoc));
            end;
            Error(ErrorText);
        end;
    end;

    local procedure ReadContentFromResponse(var TempBlob: Codeunit "Temp Blob")
    var
        ResponseInStream: InStream;
        FinstaXmlNode: XmlNode;
        ResponseXmlDoc: XmlDocument;
        ResponseOutStream: OutStream;
        Found: Boolean;
    begin
        TempBlob.CreateInStream(ResponseInStream);
        XmlDocument.ReadFrom(ResponseInStream, ResponseXmlDoc);

        Found := ResponseXmlDoc.SelectSingleNode(STRSUBSTNO(AMCBankServiceRequestMgt.GetFinstaXPath(ReportExportWebCallTxt + AMCBankServiceRequestMgt.GetResponseTag())), FinstaXmlNode);
        if not Found then
            Error(FinstaNotCollectedErr, AMCBankServMgt.GetSupportURL(ResponseXmlDoc));

    end;

}

