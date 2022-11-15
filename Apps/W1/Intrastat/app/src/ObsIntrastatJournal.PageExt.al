pageextension 4821 "Obs. Intrastat Journal" extends "Intrastat Journal"
{
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