namespace Microsoft.Finance.VAT.Reporting;

using System.Telemetry;

codeunit 13620 "Elec. VAT Decl. Check Status"
{
    TableNo = "VAT Report Header";

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        NoFeedbackProvidedMsg: Label 'The response for your submission is not ready yet.';
        ReportAcceptedMsg: Label 'The report has been successfully accepted.';
        ReportRejectedMsg: Label 'The report was rejected. To find out why, download the response message and check the attached documents.';
        FeatureNameTxt: Label 'Electronic VAT Declaration DK', Locked = true;
        ElecVATDeclAcceptedTxt: Label 'Electronic VAT Declaration was accepted with this response', Locked = true;
        ElecVATDeclRejectedTxt: Label 'Electronic VAT Declaration was rejected with this response', Locked = true;
        EvelVATDeclResponseRcvdTxt: Label 'Electronic VAT Declaration response received', Locked = true;

    trigger OnRun()
    var
        ElecVATDeclCommunication: Record "Elec. VAT Decl. Communication";
        ElecVATDeclSKATAPI: Codeunit "Elec. VAT Decl. SKAT API";
        ElecVATDeclArchiving: Codeunit "Elec. VAT Decl. Archiving";
        Response: Interface "Elec. VAT Decl. Response";
        ResponseText: Text;
        TransactionID: Code[100];
    begin
        TransactionID := ElecVATDeclCommunication.GetTransactionIDForVATReturn(Rec."No.");
        Response := ElecVATDeclSKATAPI.CheckVATReturnStatus(TransactionID);
        ResponseText := Response.GetResponseBodyAsText();
        FeatureTelemetry.LogUsage('0000LR4', FeatureNameTxt, EvelVATDeclResponseRcvdTxt);
        UpdateStatus(Rec, ResponseText);
        ElecVATDeclArchiving.ArchiveResponseMessageText(ResponseText, Rec);
    end;

    local procedure UpdateStatus(var VATReportHeader: Record "VAT Report Header"; ResponseText: Text)
    var
        ElecVATDeclXml: Codeunit "Elec. VAT Decl. Xml";
        VATReturnStatusNode: XmlNode;
        StatusCode: Integer;
    begin
        VATReturnStatusNode := ElecVATDeclXml.GetVATReturnStatusNodeFromResponseText(ResponseText);
        Evaluate(StatusCode, VATReturnStatusNode.AsXmlElement().InnerText());
        case StatusCode of
            10:
                begin
                    Message(ReportAcceptedMsg);
                    VATReportHeader.Validate(Status, VATReportHeader.Status::Accepted);
                    FeatureTelemetry.LogUsage('0000LR5', FeatureNameTxt, ElecVATDeclAcceptedTxt);
                end;
            20:
                begin
                    Message(ReportRejectedMsg);
                    VATReportHeader.Validate(Status, VATReportHeader.Status::Rejected);
                    FeatureTelemetry.LogUsage('0000LR6', FeatureNameTxt, ElecVATDeclRejectedTxt);
                end;
            else
                Message(NoFeedbackProvidedMsg);
        end;
    end;
}