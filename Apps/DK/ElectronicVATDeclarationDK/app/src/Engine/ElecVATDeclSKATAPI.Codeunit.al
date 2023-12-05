namespace Microsoft.Finance.VAT.Reporting;

using System.Utilities;

codeunit 13612 "Elec. VAT Decl. SKAT API"
{
    Access = Internal;

    procedure GetVATReturnPeriods(FromDate: Date; ToDate: Date) Response: Interface "Elec. VAT Decl. Response"
    var
        SubmissionTempBlob: Codeunit "Temp Blob";
    begin
        Response := PrepareAndSendRequest("Elec. VAT Decl. Request Type"::"Get VAT Return Periods", PrepareParametersForVATReturnPeriods(FromDate, ToDate), SubmissionTempBlob);
    end;

    procedure SubmitVATReturn(VATReportHeader: Record "VAT Report Header"; var SubmissionTempBlob: Codeunit "Temp Blob") Response: Interface "Elec. VAT Decl. Response"
    begin
        Response := PrepareAndSendRequest("Elec. VAT Decl. Request Type"::"Submit VAT Return", PrepareParametersForSubmit(VATReportHeader), SubmissionTempBlob);
    end;

    procedure CheckVATReturnStatus(TransactionID: Text[250]) Response: Interface "Elec. VAT Decl. Response"
    var
        SubmissionTempBlob: Codeunit "Temp Blob";
    begin
        Response := PrepareAndSendRequest("Elec. VAT Decl. Request Type"::"Check VAT Return Status", PrepareParametersForCheckStatus(TransactionID), SubmissionTempBlob);
    end;

    procedure PrepareParametersForVATReturnPeriods(FromDate: Date; ToDate: Date) ElecVATDeclParameters: Record "Elec. VAT Decl. Parameters"
    begin
        ElecVATDeclParameters."From Date" := FromDate;
        ElecVATDeclParameters."To Date" := ToDate;
        ElecVATDeclParameters.Insert();
    end;

    procedure PrepareParametersForSubmit(VATReportHeader: Record "VAT Report Header") ElecVATDeclParameters: Record "Elec. VAT Decl. Parameters"
    begin
        ElecVATDeclParameters."VAT Report Header No." := VATReportHeader."No.";
        ElecVATDeclParameters."VAT Report Config. Code" := VATReportHeader."VAT Report Config. Code";
        ElecVATDeclParameters.Insert();
    end;

    procedure PrepareParametersForCheckStatus(TransactionID: Text[250]) ElecVATDeclParameters: Record "Elec. VAT Decl. Parameters"
    begin
        ElecVATDeclParameters."Transaction ID" := TransactionID;
        ElecVATDeclParameters.Insert();
    end;

    local procedure PrepareAndSendRequest(ElecVATDeclRequestType: Enum "Elec. VAT Decl. Request Type"; ElecVATDeclParameters: Record "Elec. VAT Decl. Parameters"; var SubmissionTempBlob: Codeunit "Temp Blob") Response: Interface "Elec. VAT Decl. Response"
    var
        ElecVATDeclSetup: Record "Elec. VAT Decl. Setup";
        ElecVATDeclHttpComm: Codeunit "Elec. VAT Decl. Http Comm.";
        ElecVATDeclXml: Codeunit "Elec. VAT Decl. Xml";
        SignedXmlInStream: InStream;
        SignedXmlDocument: XmlDocument;
        SignedXmlStream: OutStream;
        TransactionID: Code[100];
    begin
        ElecVATDeclXml.PrepareRequest(ElecVATDeclRequestType, ElecVATDeclParameters, SignedXmlDocument, TransactionID);
        SubmissionTempBlob.CreateOutStream(SignedXmlStream);
        ElecVATDeclXml.XmlDocumentOuterXmlToStream(SignedXmlDocument, SignedXmlStream);
        SubmissionTempBlob.CreateInStream(SignedXmlInStream);
        Response := ElecVATDeclHttpComm.SendMessage(SignedXmlInStream, ElecVATDeclSetup.GetEndpointForType(ElecVATDeclRequestType));
        SaveCommunicationLog(ElecVATDeclRequestType, ElecVATDeclParameters, TransactionID, SubmissionTempBlob, Response);
    end;

    local procedure SaveCommunicationLog(ElecVATDeclRequestType: Enum "Elec. VAT Decl. Request Type"; ElecVATDeclParameters: Record "Elec. VAT Decl. Parameters"; TransactionID: Code[100]; SignedXmlTempBlob: Codeunit "Temp Blob"; Response: Interface "Elec. VAT Decl. Response")
    var
        ElecVATDeclCommunication: Record "Elec. VAT Decl. Communication";
        SignedXmlInStream: InStream;
        ResponseInStream: InStream;
        RequestOutStream: OutStream;
        ResponseOutStream: OutStream;
    begin
        ElecVATDeclCommunication.Init();
        ElecVATDeclCommunication."Request Type" := ElecVATDeclRequestType;
        ElecVATDeclCommunication."Related VAT Return No." := ElecVATDeclParameters."VAT Report Header No.";
        ElecVATDeclCommunication."Transaction ID" := TransactionID;
        if ElecVATDeclRequestType = ElecVATDeclRequestType::"Submit VAT Return" then
            ElecVATDeclCommunication."Response Transaction ID" := GetResponseTransactionID(Response.GetResponseBodyAsText());
        ElecVATDeclCommunication.TimeSent := CurrentDateTime();
        SignedXmlTempBlob.CreateInStream(SignedXmlInStream);
        ElecVATDeclCommunication."SKAT Request BLOB".CreateOutStream(RequestOutStream);
        CopyStream(RequestOutStream, SignedXmlInStream);
        ResponseInStream := Response.GetResponseStream();
        ElecVATDeclCommunication."SKAT Response BLOB".CreateOutStream(ResponseOutStream);
        CopyStream(ResponseOutStream, ResponseInStream);
        ElecVATDeclCommunication.Insert(true);
    end;

    local procedure GetResponseTransactionID(ResponseText: Text) ResponseTransactionID: Code[100]
    var
        ElecVATDeclXml: Codeunit "Elec. VAT Decl. Xml";
        TransactionIDNode: XmlNode;
    begin
        TransactionIDNode := ElecVATDeclXml.GetResponseTransactionNodeFromResponseText(ResponseText);

        ResponseTransactionID := CopyStr(TransactionIDNode.AsXmlElement().InnerText(), 1, 100);
    end;
}