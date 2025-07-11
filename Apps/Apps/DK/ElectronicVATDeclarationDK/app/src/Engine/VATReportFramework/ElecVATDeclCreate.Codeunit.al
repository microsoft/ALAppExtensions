namespace Microsoft.Finance.VAT.Reporting;

using System.Telemetry;
using System.Utilities;

codeunit 13606 "Elec. VAT Decl. Create"
{
    TableNo = "VAT Report Header";

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        FeatureNameTxt: Label 'Electronic VAT Declaration DK', Locked = true;
        VATReturnCreatedTxt: Label 'VAT Return Created', Locked = true;
        VATReturnCreateRunTxt: Label 'VAT Return Create OnRun', Locked = true;

    trigger OnRun()
    var
        ElecVATDeclArchiving: Codeunit "Elec. VAT Decl. Archiving";
        TempBlobSubmission: Codeunit "Temp Blob";
        VATReturnSubmissionDoc: XmlDocument;
        OutStreamSubmission: OutStream;
    begin
        FeatureTelemetry.LogUsage('0000LR7', FeatureNameTxt, VATReturnCreateRunTxt);
        VATReturnSubmissionDoc := GenerateSubmissionDocument(Rec);
        TempBlobSubmission.CreateOutStream(OutStreamSubmission);
        VATReturnSubmissionDoc.WriteTo(OutStreamSubmission);
        ElecVATDeclArchiving.ArchiveSubmissionMessageBlob(TempBlobSubmission, Rec);
        FeatureTelemetry.LogUsage('0000LR8', FeatureNameTxt, VATReturnCreatedTxt);
    end;

    local procedure GenerateSubmissionDocument(VATReportHeader: Record "VAT Report Header") SubmissionDocument: XmlDocument
    var
        ElecVATDeclXml: Codeunit "Elec. VAT Decl. Xml";
        ElecVATDeclSKATAPI: Codeunit "Elec. VAT Decl. SKAT API";
        TransactionID: Code[100];
    begin
        ElecVATDeclXml.PrepareRequest("Elec. VAT Decl. Request Type"::"Submit VAT Return", ElecVATDeclSKATAPI.PrepareParametersForSubmit(VATReportHeader), SubmissionDocument, TransactionID);
    end;
}