#if not CLEAN22
pageextension 4820 "Obs. Intrastat Jnl. Batches" extends "Intrastat Jnl. Batches"
{

    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
    ObsoleteReason = 'Intrastat related functionalities are moving to Intrastat extension.';

    trigger OnOpenPage()
    var
        IntrastatReportMgt: Codeunit IntrastatReportManagement;
    begin
        if IntrastatReportMgt.IsFeatureEnabled() then begin
            Page.Run(Page::"Intrastat Report List");
            Error('');
        end;
    end;
}
#endif