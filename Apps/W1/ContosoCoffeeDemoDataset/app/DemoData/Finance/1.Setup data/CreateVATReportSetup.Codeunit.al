codeunit 5233 "Create VAT Report Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        VATReportSetup: Record "VAT Report Setup";
        CreateNoSeries: Codeunit "Create No. Series";
        VATReportSetupRecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        VATReportSetup.Get();

        VATReportSetup.Validate("No. Series", CreateNoSeries.ECSL());
        VATReportSetup.Validate("VAT Return Period No. Series", CreateNoSeries.VATReturnPeriods());
        VATReportSetup.Modify(true);

        // field(4; "VAT Return No. Series"; Code[20]) does not exist in IT nor DE
        VATReportSetupRecRef.GetTable(VATReportSetup);
        if VATReportSetupRecRef.FieldExist(4) then begin
            FieldRef := VATReportSetupRecRef.Field(4);
            FieldRef.Validate(CreateNoSeries.VATReturnsReports());
            VATReportSetupRecRef.Modify(true);
        end;

        CreateVATReportsConfiguration();
    end;

    local procedure CreateVATReportsConfiguration()
    var
        ContosoVATStatement: Codeunit "Contoso VAT Statement";
    begin
        ContosoVATStatement.InsertVATReportConfiguration(Enum::"VAT Report Configuration"::"EC Sales List", CurrentVersion(), Codeunit::"EC Sales List Suggest Lines", Codeunit::"ECSL Report Validate");
        ContosoVATStatement.InsertVATReportConfiguration(Enum::"VAT Report Configuration"::"VAT Return", CurrentVersion(), Codeunit::"VAT Report Suggest Lines", Codeunit::"VAT Report Validate");
    end;

    procedure CurrentVersion(): Code[10]
    begin
        exit(CurrentVersionTok);
    end;

    var
        CurrentVersionTok: Label 'CURRENT', MaxLength = 10;
}