codeunit 20114 "AMC Bank Imp.STMT. Hndl"
{
    Permissions = TableData "AMC Banking Setup" = r;
    TableNo = "Data Exch.";

    trigger OnRun()
    var
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
    begin
        "File Name" :=
          CopyStr(FileManagement.BLOBImportWithFilter(TempBlob, ImportBankStmtTxt, '', FileFilterTxt, FileFilterExtensionTxt), 1, 250);
        if "File Name" = '' then
            exit;

        ConvertBankStatementToFormat(TempBlob, Rec);
    end;

    var
        AMCBankServiceRequestMgt: Codeunit "AMC Bank Service Request Mgt.";
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
        NoRequestBodyErr: Label 'The request body is not set.';
        FileFilterTxt: Label 'All Files(*.*)|*.*|XML Files(*.xml)|*.xml|Text Files(*.txt;*.csv;*.asc)|*.txt;*.csv;*.asc';
        FileFilterExtensionTxt: Label 'txt,csv,asc,xml', Locked = true;
        FinstaNotCollectedErr: Label 'The AMC Banking has not returned any statement transactions.\\For more information, go to %1.', comment = '%1=Support URl';
        ImportBankStmtTxt: Label 'Select a file to import.';
        BankDataConvServSysErr: Label 'The AMC Banking has returned the following error message:';
        AddnlInfoTxt: Label 'For more information, go to %1.', Comment = '%1=Support URL';

    [Scope('OnPrem')]
    procedure ConvertBankStatementToFormat(var BankStatementTempBlob: Codeunit "Temp Blob"; var DataExch: Record "Data Exch.")
    var
        ResultTempBlob: Codeunit "Temp Blob";
        RecordRef: RecordRef;
    begin
        SendReportExportRequestToWebService(ResultTempBlob, BankStatementTempBlob, AMCBankingMgt.GetAppCaller());
        RecordRef.GetTable(DataExch);
        ResultTempBlob.ToRecordRef(RecordRef, DataExch.FieldNo("File Content"));
        RecordRef.SetTable(DataExch);
    end;

    local procedure SendReportExportRequestToWebService(var BankStatementTempBlob: Codeunit "Temp Blob"; var BodyTempBlob: Codeunit "Temp Blob"; AppCaller: text[30])
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        ReportExportHttpRequestMessage: HttpRequestMessage;
        ReportExportHttpResponseMessage: HttpResponseMessage;
        Handled: Boolean;
        Result: Text;
    begin
        if not BodyTempBlob.HasValue() then
            Error(NoRequestBodyErr);

        AMCBankingMgt.CheckCredentials();
        AMCBankingSetup.Get();

        AMCBankServiceRequestMgt.InitializeHttp(ReportExportHttpRequestMessage, AMCBankingSetup."Service URL", 'POST');

        PrepareSOAPRequestBody(ReportExportHttpRequestMessage, BodyTempBlob);

        //Set Content-Type header
        AMCBankServiceRequestMgt.SetHttpContentsDefaults(ReportExportHttpRequestMessage);

        //Send Request to webservice
        Handled := false;
        AMCBankServiceRequestMgt.OnBeforeExecuteWebServiceRequest(Handled, ReportExportHttpRequestMessage, ReportExportHttpResponseMessage, AMCBankServiceRequestMgt.GetReportExportTag(), AppCaller); //For mockup testing
        AMCBankServiceRequestMgt.ExecuteWebServiceRequest(Handled, ReportExportHttpRequestMessage, ReportExportHttpResponseMessage, AMCBankServiceRequestMgt.GetReportExportTag(), AppCaller, true);
        AMCBankServiceRequestMgt.GetWebServiceResponse(ReportExportHttpResponseMessage, BankStatementTempBlob, AMCBankServiceRequestMgt.GetReportExportTag() + AMCBankServiceRequestMgt.GetResponseTag(), true);
        if (AMCBankServiceRequestMgt.HasResponseErrors(BankStatementTempBlob, AMCBankServiceRequestMgt.GetHeaderXPath(), AMCBankServiceRequestMgt.GetReportExportTag() + AMCBankServiceRequestMgt.GetResponseTag(), Result, AppCaller)) then
            DisplayErrorFromResponse(BankStatementTempBlob)
        else
            ReadContentFromResponse(BankStatementTempBlob);
    end;

    [NonDebuggable]
    local procedure PrepareSOAPRequestBody(var ReportExportHttpRequestMessage: HttpRequestMessage; var TempBlob: Codeunit "Temp Blob")
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
        AMCBankServiceRequestMgt.AddElement(BodyXMLElement, AMCBankingMgt.GetNamespace(), AMCBankServiceRequestMgt.GetReportExportTag(), '', HeaderXmlElement, '', '', '');
        AMCBankServiceRequestMgt.AddElement(HeaderXmlElement, '', 'amcreportreq', '', AmcReportReqXMLElement, '', '', '');
        AMCBankServiceRequestMgt.AddElement(AmcReportReqXMLElement, '', 'clientcode', AMCBankingMgt.GetAMCClientCode(), ChildXmlElement, '', '', '');
        AMCBankServiceRequestMgt.AddElement(AmcReportReqXMLElement, '', 'pack', '', PackXmlElement, '', '', '');

        AMCBankServiceRequestMgt.AddElement(PackXmlElement, '', 'journalnumber', DelChr(LowerCase(Format(CreateGuid())), '=', '{}'), ChildXmlElement, '', '', '');
        AMCBankServiceRequestMgt.AddElement(PackXmlElement, '', 'data', EncodeBankStatementFile(TempBlob), ChildXmlElement, '', '', '');
        AMCBankServiceRequestMgt.AddElement(HeaderXmlElement, '', 'messagetype', 'finsta', ChildXmlElement, '', '', '');

        BodyContentXmlDoc.WriteTo(TempXmlDocText);
        AMCBankServiceRequestMgt.RemoveUTF16(TempXmlDocText);
        contentHttpContent.WriteFrom(TempXmlDocText);
        ReportExportHttpRequestMessage.Content(contentHttpContent);
    end;

    local procedure EncodeBankStatementFile(TempBlob: Codeunit "Temp Blob"): Text
    var
        FileManagement: Codeunit "File Management";
        Convert: DotNet Convert;
        File: DotNet File;
        FileName: Text;
    begin
        FileName := FileManagement.ServerTempFileName('txt');
        FileManagement.IsAllowedPath(FileName, false);
        FileManagement.BLOBExportToServerFile(TempBlob, FileName);
        exit(Convert.ToBase64String(File.ReadAllBytes(FileName)));
    end;

    local procedure DisplayErrorFromResponse(BankStatementTempBlob: Codeunit "Temp Blob")
    var
        ResponseXmlDoc: XmlDocument;
        SysLogXMLNodeList: XmlNodeList;
        SyslogXmlNode: XmlNode;
        DataInStream: InStream;
        Found: Boolean;
        ErrorText: Text;
        i: Integer;
    begin

        BankStatementTempBlob.CreateInStream(DataInStream);
        XmlDocument.ReadFrom(DataInStream, ResponseXmlDoc);

        Found := ResponseXmlDoc.SelectNodes(AMCBankServiceRequestMgt.GetSysErrXPath(), SysLogXMLNodeList);
        if Found then begin
            ErrorText := BankDataConvServSysErr;
            for i := 1 to SysLogXMLNodeList.Count() do begin
                SysLogXMLNodeList.Get(i, SyslogXmlNode);
                ErrorText += '\\' + CopyStr(AMCBankServiceRequestMgt.getNodeValue(SyslogXmlNode, 'text'), 1, 250) + '\' +
                  CopyStr(AMCBankServiceRequestMgt.getNodeValue(SyslogXmlNode, 'hinttext'), 1, 250) + '\\' +
                  StrSubstNo(AddnlInfoTxt, AMCBankingMgt.GetSupportURL(ResponseXmlDoc));
            end;
            Error(ErrorText);
        end;
    end;

    local procedure ReadContentFromResponse(var TempBlob: Codeunit "Temp Blob")
    var
        ResponseInStream: InStream;
        FinstaXmlNode: XmlNode;
        ResponseXmlDoc: XmlDocument;
        Found: Boolean;
    begin
        TempBlob.CreateInStream(ResponseInStream);
        XmlDocument.ReadFrom(ResponseInStream, ResponseXmlDoc);

        Found := ResponseXmlDoc.SelectSingleNode(STRSUBSTNO(AMCBankServiceRequestMgt.GetFinstaXPath()), FinstaXmlNode);
        if not Found then
            Error(FinstaNotCollectedErr, AMCBankingMgt.GetSupportURL(ResponseXmlDoc));

    end;

}

