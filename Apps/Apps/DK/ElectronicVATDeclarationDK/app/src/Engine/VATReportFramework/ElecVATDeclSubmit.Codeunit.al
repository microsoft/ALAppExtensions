namespace Microsoft.Finance.VAT.Reporting;

using System.Telemetry;
using System.Utilities;

codeunit 13613 "Elec. VAT Decl. Submit"
{
    TableNo = "VAT Report Header";

    var
        ElecVATDeclArchiving: Codeunit "Elec. VAT Decl. Archiving";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        SubmissionSuccessfulMsg: Label 'VAT Return draft submitted successfully. You need confirm the draft as final on skat.dk website.';
        FeatureNameTxt: Label 'Electronic VAT Declaration DK', Locked = true;
        VATReturnSubmittedTxt: Label 'VAT Return Created', Locked = true;

    trigger OnRun()
    var
        ElecVATDeclSKATAPI: Codeunit "Elec. VAT Decl. SKAT API";
        SubmissionTempBlob: Codeunit "Temp Blob";
        HttpResponse: Interface "Elec. VAT Decl. Response";
    begin
        HttpResponse := ElecVATDeclSKATAPI.SubmitVATReturn(Rec, SubmissionTempBlob);
        GetDeeplink(HttpResponse);
        ElecVATDeclArchiving.ArchiveSubmissionMessageBlob(SubmissionTempBlob, Rec);
        FeatureTelemetry.LogUsage('0000LRB', FeatureNameTxt, VATReturnSubmittedTxt);
    end;

    local procedure GetDeeplink(HttpResponse: Interface "Elec. VAT Decl. Response")
    var
        ElecVATDeclXml: Codeunit "Elec. VAT Decl. Xml";
        DeepLinkNode: XmlNode;
        DeepLink: Text;
    begin
        DeepLinkNode := ElecVATDeclXml.GetDeeplinkNodeFromResponseText(HttpResponse.GetResponseBodyAsText());
        DeepLink := DeepLinkNode.AsXmlElement().InnerText();
        if (DeepLink <> '') and GuiAllowed() then
            Message(SubmissionSuccessfulMsg);
    end;
}