#if not CLEAN22
#pragma warning disable AL0432
pageextension 31341 "Obs. Specific Movements CZ" extends "Specific Movements CZL"
#pragma warning restore AL0432
{
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
    ObsoleteReason = 'Intrastat related functionalities are moving to Intrastat extension.';

    trigger OnOpenPage()
    var
        IntrastatReportMgt: Codeunit IntrastatReportManagement;
        SpecificMovementsCZ: Page "Specific Movements CZ";
    begin
        if IntrastatReportMgt.IsFeatureEnabled() then begin
            IntrastatReportMgt.ShowFeatureEnabledMessage(CurrPage.Caption, SpecificMovementsCZ.Caption);
            SpecificMovementsCZ.Run();
            Error('');
        end else
            IntrastatReportMgt.NotifyUserAboutIntrastatFeature();
    end;
}
#endif