codeunit 20113 "AMC Bank Exp. CT Hndl"
{
    Permissions = TableData "Data Exch." = rimd,
                  TableData "AMC Banking Setup" = r;
    TableNo = "Data Exch.";

    trigger OnRun()
    var
        BankAccount: Record "Bank Account";
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        RecordRef: RecordRef;
        BankFileName: Text;
    begin
        PayBankAcountNo := GetBankAccountNo(Rec."Entry No.");
        ConvertPaymentDataToFormat(TempBlob, Rec);

        if (BankAccount.Get(PayBankAcountNo)) then
            BankFileName := AMCBankingMgt.GetBankFileName(BankAccount)
        else
            BankFileName := "Data Exch. Def Code" + GetFileExtension();

        if FileManagement.BLOBExport(TempBlob, BankFileName, true) = '' then
            LogInternalError(DownloadFromStreamErr, DataClassification::SystemMetadata, Verbosity::Error);

        Get("Entry No.");
        RecordRef.GetTable(Rec);
        TempBlob.ToRecordRef(RecordRef, FieldNo("File Content"));
        RecordRef.SetTable(Rec);
        Modify();
    end;

    var
        AMCBankServiceRequestMgt: Codeunit "AMC Bank Service Request Mgt.";
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
        DownloadFromStreamErr: Label 'The file has not been saved.';
        NoRequestBodyErr: Label 'The request body is not set.';
        NothingToExportErr: Label 'There is nothing to export.';
        PaymentDataNotCollectedErr: Label 'The AMC Banking has not returned any payment data.\\For more information, go to %1.', Comment = '%1=Support URL';
        HasErrorsErr: Label 'The AMC Banking has found one or more errors.\\For each line to be exported, resolve the errors that are displayed in the FactBox.\\Choose an error to see more information.';
        IncorrectElementErr: Label 'There is an incorrect file conversion error element in the response. Reference: %1, error text: %2.', Comment = '%1=Reference to payment, %2=Error text';
        BankDataConvServSysErr: Label 'The AMC Banking has returned the following error message:';
        AddnlInfoTxt: Label 'For more information, go to %1.', Comment = '%1=Support URL';
        PaymentExportWebCallTxt: Label 'paymentExportBank', locked = true;
        PayBankAcountNo: Code[20];

    [Scope('OnPrem')]
    procedure ConvertPaymentDataToFormat(var PaymentFileTempBlob: Codeunit "Temp Blob"; DataExch: Record "Data Exch.")
    var
        RequestBodyTempBlob: Codeunit "Temp Blob";
    begin
        if not DataExch."File Content".HasValue() then
            LogInternalError(NoRequestBodyErr, DataClassification::SystemMetadata, Verbosity::Error);

        RequestBodyTempBlob.FromRecord(DataExch, DataExch.FieldNo("File Content"));

        SendPaymentRequestToWebService(PaymentFileTempBlob, RequestBodyTempBlob, DataExch."Entry No.", AMCBankingMgt.GetAppCaller());

        if not PaymentFileTempBlob.HasValue() then
            LogInternalError(NothingToExportErr, DataClassification::SystemMetadata, Verbosity::Error);
    end;

    local procedure SendPaymentRequestToWebService(var PaymentFileTempBlob: Codeunit "Temp Blob"; var BodyTempBlob: Codeunit "Temp Blob"; DataExchEntryNo: Integer; AppCaller: Text[30])
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        PaymentHttpRequestMessage: HttpRequestMessage;
        PaymentHttpResponseMessage: HttpResponseMessage;
        Handled: Boolean;
        Result: Text;
    begin
        AMCBankingMgt.CheckCredentials();
        AMCBankingSetup.Get();

        AMCBankServiceRequestMgt.InitializeHttp(PaymentHttpRequestMessage, AMCBankingSetup."Service URL", 'POST');

        PrepareSOAPRequestBody(PaymentHttpRequestMessage, BodyTempBlob);

        //Set Content-Type header
        AMCBankServiceRequestMgt.SetHttpContentsDefaults(PaymentHttpRequestMessage);

        //Send Request to webservice
        Handled := false;
        AMCBankServiceRequestMgt.OnBeforeExecuteWebServiceRequest(Handled, PaymentHttpRequestMessage, PaymentHttpResponseMessage, PaymentExportWebCallTxt, AppCaller); //For mockup testing
        AMCBankServiceRequestMgt.ExecuteWebServiceRequest(Handled, PaymentHttpRequestMessage, PaymentHttpResponseMessage, PaymentExportWebCallTxt, AppCaller, true);
        AMCBankServiceRequestMgt.GetWebServiceResponse(PaymentHttpResponseMessage, PaymentFileTempBlob, PaymentExportWebCallTxt + AMCBankServiceRequestMgt.GetResponseTag(), true);
        AMCBankServiceRequestMgt.SetUsedXTLJournal(PaymentFileTempBlob, DataExchEntryNo, PaymentExportWebCallTxt);
        if (AMCBankServiceRequestMgt.HasResponseErrors(PaymentFileTempBlob, AMCBankServiceRequestMgt.GetHeaderXPath(), PaymentExportWebCallTxt + AMCBankServiceRequestMgt.GetResponseTag(), Result, AppCaller)) then
            DisplayErrorFromResponse(PaymentFileTempBlob, DataExchEntryNo)
        else
            ReadContentFromResponse(PaymentFileTempBlob);
    end;

    [NonDebuggable]
    local procedure PrepareSOAPRequestBody(var PaymentHttpRequestMessage: HttpRequestMessage; var TempBlob: Codeunit "Temp Blob")
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        BodyContentInStream: InStream;
        EnvelopeXmlDoc: XmlDocument;
        BodyContentXmlDoc: XmlDocument;
        PaymentExportXmlElement: XmlElement;
        EnvelopeXmlElement: XmlElement;
        BodyXMLElement: XmlElement;
        Found: Boolean;
        TempXmlDocText: text;
        contentHttpContent: HttpContent;
    begin
        AMCBankingSetup.Get();

        TempBlob.CREATEINSTREAM(BodyContentInStream);
        XmlDocument.ReadFrom(BodyContentInStream, BodyContentXmlDoc);

        Found := BodyContentXmlDoc.GetRoot(PaymentExportXmlElement);
        if (Found) then begin
            AMCBankServiceRequestMgt.CreateEnvelope(EnvelopeXmlDoc, EnvelopeXmlElement, AMCBankingSetup.GetUserName(), AMCBankingSetup.GetPassword(), '');
            AMCBankServiceRequestMgt.AddElement(EnvelopeXMLElement, EnvelopeXMLElement.NamespaceUri(), 'Body', '', BodyXMLElement, '', '', '');
            BodyXMLElement.Add(PaymentExportXmlElement);
        end;

        EnvelopeXmlDoc.WriteTo(TempXmlDocText);
        AMCBankServiceRequestMgt.RemoveUTF16(TempXmlDocText);
        contentHttpContent.WriteFrom(TempXmlDocText);
        PaymentHttpRequestMessage.Content(contentHttpContent);
    end;

    local procedure DisplayErrorFromResponse(PaymentFileTempBlob: Codeunit "Temp Blob"; DataExchEntryNo: Integer)
    var
        GenJournalLine: Record "Gen. Journal Line";
        ResponseXmlDoc: XmlDocument;
        DataInStream: InStream;
        SysLogXMLNodeList: XmlNodeList;
        SyslogXmlNode: XmlNode;
        Found: Boolean;
        ErrorText: Text;
        i, j : Integer;
    begin
        PaymentFileTempBlob.CreateInStream(DataInStream);
        XmlDocument.ReadFrom(DataInStream, ResponseXmlDoc);

        Found := ResponseXmlDoc.SelectNodes(AMCBankServiceRequestMgt.GetConvErrXPath(), SysLogXMLNodeList); //V17.5
        if Found then begin
            for i := 1 to SysLogXMLNodeList.Count() do begin
                SysLogXMLNodeList.Get(i, SyslogXmlNode);
                InsertPaymentFileError(SyslogXmlNode, DataExchEntryNo);
            end;
            GenJournalLine.SetRange("Data Exch. Entry No.", DataExchEntryNo);
            GenJournalLine.FindFirst();
            if GenJournalLine.HasPaymentFileErrorsInBatch() then begin
                Commit();
                Error(HasErrorsErr);
            end;
        end;

        Found := ResponseXmlDoc.SelectNodes(AMCBankServiceRequestMgt.GetSysErrXPath(), SysLogXMLNodeList); //V17.5
        if Found then begin
            ErrorText := BankDataConvServSysErr;
            for j := 1 to SysLogXMLNodeList.Count() do begin
                SysLogXMLNodeList.Get(j, SyslogXmlNode);
                ErrorText += '\\' + CopyStr(AMCBankServiceRequestMgt.getNodeValue(SyslogXmlNode, AMCBankServiceRequestMgt.GetSyslogHintTextXPath()), 1, 250) + '\' +
                  CopyStr(AMCBankServiceRequestMgt.getNodeValue(SyslogXmlNode, AMCBankServiceRequestMgt.GetSyslogHintTextXPath()), 1, 250) + '\\' +
                  StrSubstNo(AddnlInfoTxt, AMCBankingMgt.GetSupportURL(ResponseXmlDoc));
            end;
            Error(ErrorText);
        end;
    end;

    local procedure InsertPaymentFileError(ErrorXmlNode: XmlNode; DataExchEntryNo: Integer)
    var
        PaymentExportData: Record "Payment Export Data";
        GenJournalLine: Record "Gen. Journal Line";
        XmlDoc: XmlDocument;
        PaymentLineId: Text;
        ErrorText: Text;
        HintText: Text;
        SupportURL: Text;
    begin
        ErrorXmlNode.GetDocument(XmlDoc);
        PaymentLineId := CopyStr(AMCBankServiceRequestMgt.getNodeValue(ErrorXmlNode, AMCBankServiceRequestMgt.GetSyslogReferenceIdXPath()), 1, 50);
        ErrorText := CopyStr(AMCBankServiceRequestMgt.getNodeValue(ErrorXmlNode, AMCBankServiceRequestMgt.GetSyslogTextXPath()), 1, 250);
        HintText := CopyStr(AMCBankServiceRequestMgt.getNodeValue(ErrorXmlNode, AMCBankServiceRequestMgt.GetSyslogHintTextXPath()), 1, 250);
        SupportURL := AMCBankingMgt.GetSupportURL(XmlDoc);

        if (ErrorText = '') or (PaymentLineId = '') then
            Error(IncorrectElementErr, PaymentLineId, ErrorText);

        with PaymentExportData do begin
            SetRange("Data Exch Entry No.", DataExchEntryNo);
            SetRange("End-to-End ID", PaymentLineId);
            if FindFirst() then begin
                GenJournalLine.Get("General Journal Template", "General Journal Batch Name", "General Journal Line No.");
                GenJournalLine.InsertPaymentFileErrorWithDetails(ErrorText, HintText, SupportURL);
            end else begin
                SetRange("End-to-End ID");
                SetRange("Payment Information ID", PaymentLineId);
                if not FindFirst() then
                    Error(IncorrectElementErr, PaymentLineId, ErrorText);
                GenJournalLine.Get("General Journal Template", "General Journal Batch Name", "General Journal Line No.");
                GenJournalLine.InsertPaymentFileErrorWithDetails(ErrorText, HintText, SupportURL);
            end;
        end;
    end;

    local procedure ReadContentFromResponse(var TempBlob: Codeunit "Temp Blob")
    var
        ResponseInStream: InStream;
        DataXmlNode: XmlNode;
        ResponseXmlDoc: XmlDocument;
        Found: Boolean;
    begin
        TempBlob.CreateInStream(ResponseInStream);
        XmlDocument.ReadFrom(ResponseInStream, ResponseXmlDoc);

        Found := ResponseXmlDoc.SelectSingleNode(AMCBankServiceRequestMgt.GetDataXPath(), DataXmlNode); //V17.5
        if not Found then
            Error(PaymentDataNotCollectedErr, AMCBankingMgt.GetSupportURL(ResponseXmlDoc));

        DecodePaymentData(TempBlob, DataXmlNode.AsXmlElement().InnerText);
    end;

    local procedure DecodePaymentData(var TempBlob: Codeunit "Temp Blob"; Base64String: Text)
    var
        FileManagement: Codeunit "File Management";
        Convert: DotNet Convert;
        File: DotNet File;
        FileName: Text;
    begin
        FileName := FileManagement.ServerTempFileName('txt');
        FileManagement.IsAllowedPath(FileName, false);
        File.WriteAllBytes(FileName, Convert.FromBase64String(Base64String));
        FileManagement.BLOBImportFromServerFile(TempBlob, FileName);
    end;

    local procedure GetBankAccountNo(DataExchEntryNo: Integer): Code[20];
    var
        PaymentExportData: Record "Payment Export Data";
    begin
        PaymentExportData.SETFILTER("Data Exch Entry No.", '%1', DataExchEntryNo);
        if (PaymentExportData.FINDFIRST()) then
            exit(PaymentExportData."Sender Bank Account Code");

        exit('');
    end;


}
