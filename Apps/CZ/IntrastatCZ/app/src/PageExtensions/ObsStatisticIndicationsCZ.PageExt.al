#if not CLEAN22
#pragma warning disable AL0432
pageextension 31337 "Obs. Statistic Indications CZ" extends "Statistic Indications CZL"
#pragma warning restore AL0432
{
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
    ObsoleteReason = 'Intrastat related functionalities are moving to Intrastat extension.';

    trigger OnOpenPage()
    var
        IntrastatReportMgt: Codeunit IntrastatReportManagement;
        StatisticIndicationsCZ: Page "Statistic Indications CZ";
    begin
        if IntrastatReportMgt.IsFeatureEnabled() then begin
            IntrastatReportMgt.ShowFeatureEnabledMessage(CurrPage.Caption, StatisticIndicationsCZ.Caption);
            StatisticIndicationsCZ.Run();
            Error('');
        end else
            IntrastatReportMgt.NotifyUserAboutIntrastatFeature();
    end;
}
#endif