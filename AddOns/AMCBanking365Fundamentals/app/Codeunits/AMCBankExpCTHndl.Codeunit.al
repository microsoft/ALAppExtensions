codeunit 20113 "AMC Bank Exp. CT Hndl"
{
    Permissions = TableData "Data Exch." = rimd,
                  TableData "AMC Banking Setup" = r;
    TableNo = "Data Exch.";

    trigger OnRun()
    var
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        RecordRef: RecordRef;
        Extension: Text;
    begin
        ConvertPaymentDataToFormat(TempBlob, Rec);

        Extension := GetFileExtension();
        if FileMgt.BLOBExport(TempBlob, "Data Exch. Def Code" + Extension, true) = '' then
            Error(DownloadFromStreamErr);

        Get("Entry No.");
        RecordRef.GetTable(Rec);
        TempBlob.ToRecordRef(RecordRef, FieldNo("File Content"));
        RecordRef.SetTable(Rec);
        Modify();
    end;

    var
        AMCBankServMgt: Codeunit "AMC Banking Mgt.";
        BodyContentErr: Label 'The %1 XML tag was not found, or was found more than once in the body content of the SOAP request.', Comment = '%1=XmlTag';
        DownloadFromStreamErr: Label 'The file has not been saved.';
        NoRequestBodyErr: Label 'The request body is not set.';
        NothingToExportErr: Label 'There is nothing to export.';
        PaymentDataNotCollectedErr: Label 'The AMC Banking has not returned any payment data.\\For more information, go to %1.';
        ResponseNodeTxt: Label 'paymentExportBankResponse', Locked = true;
        HasErrorsErr: Label 'The AMC Banking has found one or more errors.\\For each line to be exported, resolve the errors that are displayed in the FactBox.\\Choose an error to see more information.';
        IncorrectElementErr: Label 'There is an incorrect file conversion error element in the response. Reference: %1, error text: %2.';
        BankDataConvServSysErr: Label 'The AMC Banking has returned the following error message:';
        AddnlInfoTxt: Label 'For more information, go to %1.';

    [Scope('OnPrem')]
    procedure ConvertPaymentDataToFormat(var TempBlobPaymentFile: Codeunit "Temp Blob"; DataExch: Record "Data Exch.")
    var
        TempBlobRequestBody: Codeunit "Temp Blob";
    begin
        if not DataExch."File Content".HasValue() then
            Error(NoRequestBodyErr);

        TempBlobRequestBody.FromRecord(DataExch, DataExch.FieldNo("File Content"));

        SendDataToWebService(TempBlobPaymentFile, TempBlobRequestBody, DataExch."Entry No.");

        if not TempBlobPaymentFile.HasValue() then
            Error(NothingToExportErr);
    end;

    local procedure SendDataToWebService(var TempBlobPaymentFile: Codeunit "Temp Blob"; var TempBlobBody: Codeunit "Temp Blob"; DataExchEntryNo: Integer)
    var
        AMCBankServiceSetup: Record "AMC Banking Setup";
        SOAPWebServiceRequestMgt: Codeunit "SOAP Web Service Request Mgt.";
        BodyInStream: InStream;
        ResponseInStream: InStream;
    begin
        AMCBankServMgt.CheckCredentials();

        PrepareSOAPRequestBody(TempBlobBody);

        TempBlobBody.CreateInStream(BodyInStream);

        AMCBankServiceSetup.Get();

        SOAPWebServiceRequestMgt.SetGlobals(BodyInStream,
          AMCBankServiceSetup."Service URL", AMCBankServiceSetup.GetUserName(), AMCBankServiceSetup.GetPassword());

        if not SOAPWebServiceRequestMgt.SendRequestToWebService() then
            SOAPWebServiceRequestMgt.ProcessFaultResponse(StrSubstNo(AddnlInfoTxt, AMCBankServiceSetup."Support URL"));

        SOAPWebServiceRequestMgt.GetResponseContent(ResponseInStream);

        CheckIfErrorsOccurred(ResponseInStream, DataExchEntryNo);

        ReadContentFromResponse(TempBlobPaymentFile, ResponseInStream);
    end;

    local procedure PrepareSOAPRequestBody(var TempBlob: Codeunit "Temp Blob")
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        BodyContentInputStream: InStream;
        BodyContentOutputStream: OutStream;
        BodyContentXmlDoc: DotNet XmlDocument;
    begin
        TempBlob.CreateInStream(BodyContentInputStream);
        XMLDOMManagement.LoadXMLDocumentFromInStream(BodyContentInputStream, BodyContentXmlDoc);

        AddNamespaceAttribute(BodyContentXmlDoc, 'amcpaymentreq');
        AddNamespaceAttribute(BodyContentXmlDoc, 'bank');
        AddNamespaceAttribute(BodyContentXmlDoc, 'language');

        Clear(TempBlob);
        TempBlob.CreateOutStream(BodyContentOutputStream);
        BodyContentXmlDoc.Save(BodyContentOutputStream);
    end;

    local procedure AddNamespaceAttribute(var XmlDoc: DotNet XmlDocument; ElementTag: Text)
    var
        XMLDOMMgt: Codeunit "XML DOM Management";
        XmlNode: DotNet XmlNode;
        XMLNodeList: DotNet XmlNodeList;
    begin
        XMLNodeList := XmlDoc.GetElementsByTagName(ElementTag);
        if XMLNodeList.Count() <> 1 then
            Error(BodyContentErr, ElementTag);

        XmlNode := XMLNodeList.Item(0);
        if IsNull(XmlNode) then
            Error(BodyContentErr, ElementTag);
        XMLDOMMgt.AddAttribute(XmlNode, 'xmlns', '');
    end;

    local procedure CheckIfErrorsOccurred(var ResponseInStream: InStream; DataExchEntryNo: Integer)
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        ResponseXmlDoc: DotNet XmlDocument;
    begin
        XMLDOMManagement.LoadXMLDocumentFromInStream(ResponseInStream, ResponseXmlDoc);

        if ResponseHasErrors(ResponseXmlDoc) then
            DisplayErrorFromResponse(ResponseXmlDoc, DataExchEntryNo);
    end;

    local procedure ResponseHasErrors(ResponseXmlDoc: DotNet XmlDocument): Boolean
    var
        XMLDOMMgt: Codeunit "XML DOM Management";
        XmlNode: DotNet XmlNode;
    begin
        exit(XMLDOMMgt.FindNodeWithNamespace(ResponseXmlDoc.DocumentElement(),
            AMCBankServMgt.GetHeaderErrXPath(ResponseNodeTxt), 'amc', AMCBankServMgt.GetNamespace(), XmlNode));
    end;

    local procedure DisplayErrorFromResponse(ResponseXmlDoc: DotNet XmlDocument; DataExchEntryNo: Integer)
    var
        GenJnlLine: Record "Gen. Journal Line";
        XMLDOMMgt: Codeunit "XML DOM Management";
        XMLNodeList: DotNet XmlNodeList;
        Found: Boolean;
        ErrorText: Text;
        i: Integer;
    begin
        Found := XMLDOMMgt.FindNodesWithNamespace(ResponseXmlDoc.DocumentElement(),
            AMCBankServMgt.GetConvErrXPath(ResponseNodeTxt), 'amc', AMCBankServMgt.GetNamespace(), XMLNodeList);
        if Found then begin
            for i := 1 to XMLNodeList.Count() do
                InsertPaymentFileError(XMLNodeList.Item(i - 1), DataExchEntryNo);

            GenJnlLine.SetRange("Data Exch. Entry No.", DataExchEntryNo);
            GenJnlLine.FindFirst();
            if GenJnlLine.HasPaymentFileErrorsInBatch() then begin
                Commit();
                Error(HasErrorsErr);
            end;
        end;

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

    local procedure InsertPaymentFileError(XmlNode: DotNet XmlNode; DataExchEntryNo: Integer)
    var
        PaymentExportData: Record "Payment Export Data";
        GenJnlLine: Record "Gen. Journal Line";
        XMLDOMMgt: Codeunit "XML DOM Management";
        PaymentLineId: Text;
        ErrorText: Text;
        HintText: Text;
        SupportURL: Text;
    begin
        PaymentLineId := XMLDOMMgt.FindNodeText(XmlNode, 'referenceid');
        ErrorText := XMLDOMMgt.FindNodeText(XmlNode, 'text');
        HintText := XMLDOMMgt.FindNodeText(XmlNode, 'hinttext');
        SupportURL := AMCBankServMgt.GetSupportURL(XmlNode);

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

    local procedure ReadContentFromResponse(var TempBlob: Codeunit "Temp Blob"; ResponseInStream: InStream)
    var
        XMLDOMMgt: Codeunit "XML DOM Management";
        DataXmlNode: DotNet XmlNode;
        ResponseXmlDoc: DotNet XmlDocument;
        Found: Boolean;
    begin
        XMLDOMMgt.LoadXMLDocumentFromInStream(ResponseInStream, ResponseXmlDoc);

        Found := XMLDOMMgt.FindNodeWithNamespace(ResponseXmlDoc.DocumentElement(),
            AMCBankServMgt.GetDataXPath(ResponseNodeTxt), 'amc', AMCBankServMgt.GetNamespace(), DataXmlNode);
        if not Found then
            Error(PaymentDataNotCollectedErr, AMCBankServMgt.GetSupportURL(DataXmlNode));

        DecodePaymentData(TempBlob, DataXmlNode.Value());
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
}

