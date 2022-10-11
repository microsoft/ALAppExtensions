pageextension 4817 "Obs. Adv. Intrastat Checklist" extends "Advanced Intrastat Checklist"
{
    trigger OnOpenPage()
    var
        IntrastatReportMgt: Codeunit IntrastatReportManagement;
    begin
        if IntrastatReportMgt.IsFeatureEnabled() then begin
            Page.Run(Page::"Intrastat Report Checklist");
            Error('');
        end;
    end;
}