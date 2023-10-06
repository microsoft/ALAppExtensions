#if not CLEAN22
pageextension 13409 "Obs. Intrastat - File Setup" extends "Intrastat - File Setup"
{
    trigger OnOpenPage()
    var
        IntrastatReportMgt: Codeunit IntrastatReportManagement;
        IntrastatReportSetup: Page "Intrastat Report Setup";
    begin
        if IntrastatReportMgt.IsFeatureEnabled() then begin
            IntrastatReportMgt.ShowFeatureEnabledMessage(CurrPage.Caption, IntrastatReportSetup.Caption);
            IntrastatReportSetup.Run();
            Error('');
        end else
            IntrastatReportMgt.NotifyUserAboutIntrastatFeature();
    end;
}
#endif