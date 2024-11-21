codeunit 11185 "Create Vat Report Setup AT"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateNoseries: Codeunit "Create No. Series";
    begin
        InsertVatReportSetup(CreateNoseries.ECSL(), CreateNoseries.VATReturnsReports(), CreateNoseries.VATReturnPeriods());
    end;

    local procedure InsertVatReportSetup(NoSeries: Code[20]; VatReturnNoSeries: Code[20]; VatReturnPeriodNoSeries: Code[20])
    var
        VatReportSetup: Record "VAT Report Setup";
    begin
        if not VatReportSetup.Get() then begin
            VatReportSetup.Init();
            VatReportSetup.Insert(true);
        end;

        VatReportSetup.Get();
        VatReportSetup.Validate("No. Series", NoSeries);
        VatReportSetup.Validate("VAT Return No. Series", VatReturnNoSeries);
        VatReportSetup.Validate("VAT Return Period No. Series", VatReturnPeriodNoSeries);
        VatReportSetup.Modify(true);
    end;
}