codeunit 14631 "Create Vat Report IS"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    begin
        UpdateVatReportSetup();
    end;

    local procedure UpdateVatReportSetup()
    var
        VATReportSetup: Record "VAT Report Setup";
        CreateNoSeries: Codeunit "Create No. Series";
    begin
        VATReportSetup.Get();
        VATReportSetup.Validate("VAT Return No. Series", CreateNoSeries.VATReturnsReports());
        VATReportSetup.Modify(true);
    end;
}