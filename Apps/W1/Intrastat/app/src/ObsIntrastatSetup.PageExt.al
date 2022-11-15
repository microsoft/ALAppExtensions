pageextension 4822 "Obs. Intrastat Setup" extends "Intrastat Setup"
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