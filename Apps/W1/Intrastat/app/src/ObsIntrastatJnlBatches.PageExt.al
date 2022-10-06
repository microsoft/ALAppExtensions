pageextension 4820 "Obs. Intrastat Jnl. Batches" extends "Intrastat Jnl. Batches"
{
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