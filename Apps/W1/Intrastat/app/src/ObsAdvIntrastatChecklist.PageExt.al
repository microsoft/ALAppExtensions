#if not CLEAN22
pageextension 4817 "Obs. Adv. Intrastat Checklist" extends "Advanced Intrastat Checklist"
{

    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
    ObsoleteReason = 'Intrastat related functionalities are moving to Intrastat extension.';

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
#endif