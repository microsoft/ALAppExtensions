#if not CLEAN22
pageextension 4822 "Obs. Intrastat Setup" extends "Intrastat Setup"
{

    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
    ObsoleteReason = 'Intrastat related functionalities are moving to Intrastat extension.';

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