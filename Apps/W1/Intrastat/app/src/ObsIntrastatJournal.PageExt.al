#if not CLEAN22
pageextension 4821 "Obs. Intrastat Journal" extends "Intrastat Journal"
{

    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
    ObsoleteReason = 'Intrastat related functionalities are moving to Intrastat extension.';

    trigger OnOpenPage()
    var
        IntrastatReportMgt: Codeunit IntrastatReportManagement;
        IntrastatReportList: Page "Intrastat Report List";
    begin
        if IntrastatReportMgt.IsFeatureEnabled() then begin
            IntrastatReportMgt.ShowFeatureEnabledMessage(CurrPage.Caption, IntrastatReportList.Caption);
            IntrastatReportList.Run();
            Error('');
        end else
            IntrastatReportMgt.NotifyUserAboutIntrastatFeature();
    end;
}
#endif