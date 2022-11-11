pageextension 4818 "Obs. Int. Jnl. Template List" extends "Intrastat Jnl. Template List"
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