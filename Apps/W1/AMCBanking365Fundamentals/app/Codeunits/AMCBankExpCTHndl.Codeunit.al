codeunit 20113 "AMC Bank Exp. CT Hndl"
{
    Permissions = TableData "Data Exch." = rimd,
                  TableData "AMC Banking Setup" = r;
    TableNo = "Data Exch.";

    trigger OnRun()
    var
        BankAccount: Record "Bank Account";
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        RecordRef: RecordRef;
        BankFileName: Text;
    begin
        PayBankAcountNo := GetBankAccountNo(Rec."Entry No.");
        ConvertPaymentDataToFormat(TempBlob, Rec);

        if (BankAccount.Get(PayBankAcountNo)) then
            BankFileName := BankAccount."AMC Bank Name" + FileExtTxt
        else
            BankFileName := "Data Exch. Def Code" + GetFileExtension();

        if FileMgt.BLOBExport(TempBlob, BankFileName, true) = '' then
            LogInternalError(DownloadFromStreamErr, DataClassification::SystemMetadata, Verbosity::Error);

        Get("Entry No.");
        RecordRef.GetTable(Rec);
        TempBlob.ToRecordRef(RecordRef, FieldNo("File Content"));
        RecordRef.SetTable(Rec);
        Modify();
    end;

    var
        AMCBankServiceRequestMgt: Codeunit "AMC Bank Service Request Mgt.";
        AMCBankServMgt: Codeunit "AMC Banking Mgt.";
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
        FileExtTxt: Label '.txt';

    [Scope('OnPrem')]
    procedure ConvertPaymentDataToFormat(var TempBlobPaymentFile: Codeunit "Temp Blob"; DataExch: Record "Data Exch.")
    var
        TempBlobRequestBody: Codeunit "Temp Blob";
    begin
        if not DataExch."File Content".HasValue() then
            LogInternalError(NoRequestBodyErr, DataClassification::SystemMetadata, Verbosity::Error);

        TempBlobRequestBody.FromRecord(DataExch, DataExch.FieldNo("File Content"));

        SendPaymentRequestToWebService(TempBlobPaymentFile, TempBlobRequestBody, DataExch."Entry No.", AMCBankServMgt.GetAppCaller());

        if not TempBlobPaymentFile.HasValue() then
            LogInternalError(NothingToExportErr, DataClassification::SystemMetadata, Verbosity::Error);
    end;

    local procedure SendPaymentRequestToWebService(var TempBlobPaymentFile: Codeunit "Temp Blob"; var TempBlobBody: Codeunit "Temp Blob"; DataExchEntryNo: Integer; AppCaller: Text[30])
    var
        AMCBankServiceSetup: Record "AMC Banking Setup";
        PaymentRequestMessage: HttpRequestMessage;
        PaymentResponseMessage: HttpResponseMessage;
        Handled: Boolean;
        Result: Text;
    begin
        AMCBankServMgt.CheckCredentials();
        AMCBankServiceSetup.Get();

        AMCBankServiceRequestMgt.InitializeHttp(PaymentRequestMessage, AMCBankServiceSetup."Service URL", 'POST');

        PrepareSOAPRequestBody(PaymentRequestMessage, TempBlobBody);

        //Set Content-Type header
        AMCBankServiceRequestMgt.SetHttpContentsDefaults(PaymentRequestMessage);

        //Send Request to webservice
        Handled := false;
        AMCBankServiceRequestMgt.ExecuteWebServiceRequest(Handled, PaymentRequestMessage, PaymentResponseMessage, PaymentExportWebCallTxt, AppCaller, true);
        AMCBankServiceRequestMgt.GetWebServiceResponse(PaymentResponseMessage, TempBlobPaymentFile, PaymentExportWebCallTxt + AMCBankServiceRequestMgt.GetResponseTag(), true);
        AMCBankServiceRequestMgt.SetUsedXTLJournal(TempBlobPaymentFile, DataExchEntryNo, PaymentExportWebCallTxt);
        if (AMCBankServiceRequestMgt.HasResponseErrors(TempBlobPaymentFile, AMCBankServiceRequestMgt.GetHeaderXPath(), PaymentExportWebCallTxt + AMCBankServiceRequestMgt.GetResponseTag(), Result, AppCaller)) then
            DisplayErrorFromResponse(TempBlobPaymentFile, DataExchEntryNo)
        else
            ReadContentFromResponse(TempBlobPaymentFile);
    end;

    local procedure PrepareSOAPRequestBody(var PaymentRequestMessage: HttpRequestMessage; var TempBlob: Codeunit "Temp Blob")
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        BodyContentInputStream: InStream;
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

        TempBlob.CREATEINSTREAM(BodyContentInputStream);
        XmlDocument.ReadFrom(BodyContentInputStream, BodyContentXmlDoc);

        Found := BodyContentXmlDoc.GetRoot(PaymentExportXmlElement);
        if (Found) then begin
            AMCBankServiceRequestMgt.CreateEnvelope(EnvelopeXmlDoc, EnvelopeXmlElement, AMCBankingSetup.GetUserName(), AMCBankingSetup.GetPassword(), '');
            AMCBankServiceRequestMgt.AddElement(EnvelopeXMLElement, EnvelopeXMLElement.NamespaceUri(), 'Body', '', BodyXMLElement, '', '', '');
            BodyXMLElement.Add(PaymentExportXmlElement);
        end;

        EnvelopeXmlDoc.WriteTo(TempXmlDocText);
        AMCBankServiceRequestMgt.RemoveUTF16(TempXmlDocText);
        contentHttpContent.WriteFrom(TempXmlDocText);
        PaymentRequestMessage.Content(contentHttpContent);
    end;

    local procedure DisplayErrorFromResponse(TempBlobPaymentFile: Codeunit "Temp Blob"; DataExchEntryNo: Integer)
    var
        GenJnlLine: Record "Gen. Journal Line";
        ResponseXmlDoc: XmlDocument;
        InStreamData: InStream;
        SysLogXMLNodeList: XmlNodeList;
        SyslogXmlNode: XmlNode;
        Found: Boolean;
        ErrorText: Text;
        i, j : Integer;
    begin
        TempBlobPaymentFile.CreateInStream(InStreamData);
        XmlDocument.ReadFrom(InStreamData, ResponseXmlDoc);

        Found := ResponseXmlDoc.SelectNodes(STRSUBSTNO(AMCBankServiceRequestMgt.GetConvErrXPath(PaymentExportWebCallTxt + AMCBankServiceRequestMgt.GetResponseTag()),
                                            PaymentExportWebCallTxt + AMCBankServiceRequestMgt.GetResponseTag(), AMCBankServMgt.GetNamespace()), SysLogXMLNodeList);
        if Found then begin
            for i := 1 to SysLogXMLNodeList.Count() do begin
                SysLogXMLNodeList.Get(i, SyslogXmlNode);
                InsertPaymentFileError(SyslogXmlNode, DataExchEntryNo);
            end;
            GenJnlLine.SetRange("Data Exch. Entry No.", DataExchEntryNo);
            GenJnlLine.FindFirst();
            if GenJnlLine.HasPaymentFileErrorsInBatch() then begin
                Commit();
                Error(HasErrorsErr);
            end;
        end;

        Found := ResponseXmlDoc.SelectNodes(STRSUBSTNO(AMCBankServiceRequestMgt.GetSysErrXPath(PaymentExportWebCallTxt + AMCBankServiceRequestMgt.GetResponseTag()),
                                            PaymentExportWebCallTxt + AMCBankServiceRequestMgt.GetResponseTag(), AMCBankServMgt.GetNamespace()), SysLogXMLNodeList);
        if Found then begin
            ErrorText := BankDataConvServSysErr;
            for j := 1 to SysLogXMLNodeList.Count() do begin
                SysLogXMLNodeList.Get(j, SyslogXmlNode);
                ErrorText += '\\' + CopyStr(AMCBankServiceRequestMgt.getNodeValue(SyslogXmlNode, 'text'), 1, 250) + '\' +
                  CopyStr(AMCBankServiceRequestMgt.getNodeValue(SyslogXmlNode, 'hinttext'), 1, 250) + '\\' +
                  StrSubstNo(AddnlInfoTxt, AMCBankServMgt.GetSupportURL(ResponseXmlDoc));
            end;
            Error(ErrorText);
        end;
    end;

    local procedure InsertPaymentFileError(ErrorXmlNode: XmlNode; DataExchEntryNo: Integer)
    var
        PaymentExportData: Record "Payment Export Data";
        GenJnlLine: Record "Gen. Journal Line";
        XmlDoc: XmlDocument;
        PaymentLineId: Text;
        ErrorText: Text;
        HintText: Text;
        SupportURL: Text;
    begin
        ErrorXmlNode.GetDocument(XmlDoc);
        PaymentLineId := CopyStr(AMCBankServiceRequestMgt.getNodeValue(ErrorXmlNode, 'referenceid'), 1, 50);
        ErrorText := CopyStr(AMCBankServiceRequestMgt.getNodeValue(ErrorXmlNode, 'text'), 1, 250);
        HintText := CopyStr(AMCBankServiceRequestMgt.getNodeValue(ErrorXmlNode, 'hinttext'), 1, 250);
        SupportURL := AMCBankServMgt.GetSupportURL(XmlDoc);

        if (ErrorText = '') or (PaymentLineId = '') then
            Error(IncorrectElementErr, PaymentLineId, ErrorText);

        with PaymentExportData do begin
            SetRange("Data Exch Entry No.", DataExchEntryNo);
            SetRange("End-to-End ID", PaymentLineId);
            if FindFirst() then begin
                GenJnlLine.Get("General Journal Template", "General Journal Batch Name", "General Journal Line No.");
                GenJnlLine.InsertPaymentFileErrorWithDetails(ErrorText, HintText, SupportURL);
            end else begin
                SetRange("End-to-End ID");
                SetRange("Payment Information ID", PaymentLineId);
                if not FindFirst() then
                    Error(IncorrectElementErr, PaymentLineId, ErrorText);
                GenJnlLine.Get("General Journal Template", "General Journal Batch Name", "General Journal Line No.");
                GenJnlLine.InsertPaymentFileErrorWithDetails(ErrorText, HintText, SupportURL);
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

        Found := ResponseXmlDoc.SelectSingleNode(STRSUBSTNO(AMCBankServiceRequestMgt.GetDataXPath(PaymentExportWebCallTxt + AMCBankServiceRequestMgt.GetResponseTag())), DataXmlNode);
        if not Found then
            Error(PaymentDataNotCollectedErr, AMCBankServMgt.GetSupportURL(ResponseXmlDoc));

        DecodePaymentData(TempBlob, DataXmlNode.AsXmlElement().InnerText);
    end;

    local procedure DecodePaymentData(var TempBlob: Codeunit "Temp Blob"; Base64String: Text)
    var
        FileMgt: Codeunit "File Management";
        Convert: DotNet Convert;
        File: DotNet File;
        FileName: Text;
    begin
        FileName := FileMgt.ServerTempFileName('txt');
        FileMgt.IsAllowedPath(FileName, false);
        File.WriteAllBytes(FileName, Convert.FromBase64String(Base64String));
        FileMgt.BLOBImportFromServerFile(TempBlob, FileName);
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
