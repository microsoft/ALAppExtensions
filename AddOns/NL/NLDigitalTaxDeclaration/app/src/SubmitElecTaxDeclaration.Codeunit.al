codeunit 11422 "Submit Elec. Tax Declaration"
{
    TableNo = "VAT Report Header";

    var
        ContentNotAvailableErr: Label 'A content for submission is not available. Make sure you specified the correct value in the Content Codeunit ID field on the VAT Reports Configuration page.';

    trigger OnRun()
    var
        ElecTaxDeclarationSetup: Record "Elec. Tax Declaration Setup";
        VATReportArchive: Record "VAT Report Archive";
    begin
        ElecTaxDeclarationSetup.Get();
        ElecTaxDeclarationSetup.TestField("Use Certificate Setup");
        ElecTaxDeclarationSetup.CheckDigipoortSetup();
        if not VATReportArchive.Get("VAT Report Config. Code", "No.") then
            Error(ContentNotAvailableErr);
        VATReportArchive.CalcFields("Submission Message BLOB");
        if not VATReportArchive."Submission Message BLOB".HasValue() then
            exit;

        "Message Id" :=
          CopyStr(SubmitDeclarationLocal(Rec, VATReportArchive), 1, MaxStrLen("Message Id"));
        Status := Status::Submitted;
        Modify(true);
    end;

    [NonDebuggable]
    local procedure SubmitDeclarationLocal(VATReportHeader: Record "VAT Report Header"; VATReportArchive: Record "VAT Report Archive"): Text
    var
        ElecTaxDeclarationMgt: Codeunit "Elec. Tax Declaration Mgt.";
        DotNet_SecureString: Codeunit DotNet_SecureString;
        ClientCertificateBase64: Text;
        ServiceCertificateBase64: Text;
    begin
        ElecTaxDeclarationMgt.InitCertificatesWithPassword(
          ClientCertificateBase64, DotNet_SecureString, ServiceCertificateBase64);
        exit(
            ElecTaxDeclarationMgt.SubmitDeclaration(
                VATReportHeader, VATReportArchive, ClientCertificateBase64, DotNet_SecureString, ServiceCertificateBase64));
    end;
}

