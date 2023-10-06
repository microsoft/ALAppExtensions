#if not CLEAN22
#pragma warning disable AL0432
pageextension 31340 "Obs. Intrastat Del. Groups CZ" extends "Intrastat Delivery Groups CZL"
#pragma warning restore AL0432
{
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
    ObsoleteReason = 'Intrastat related functionalities are moving to Intrastat extension.';

    trigger OnOpenPage()
    var
        IntrastatReportMgt: Codeunit IntrastatReportManagement;
        IntrastatDeliveryGroupsCZ: Page "Intrastat Delivery Groups CZ";
    begin
        if IntrastatReportMgt.IsFeatureEnabled() then begin
            IntrastatReportMgt.ShowFeatureEnabledMessage(CurrPage.Caption, IntrastatDeliveryGroupsCZ.Caption);
            IntrastatDeliveryGroupsCZ.Run();
            Error('');
        end else
            IntrastatReportMgt.NotifyUserAboutIntrastatFeature();
    end;
}
#endif