reportextension 4824 "Obs. Intrastat - Form" extends "Intrastat - Form"
{
    requestpage
    {
        trigger OnOpenPage()
        var
            IntrastatReportMgt: Codeunit IntrastatReportManagement;
            IntrastatReportList: Page "Intrastat Report List";
        begin
            if IntrastatReportMgt.IsFeatureEnabled() then begin
                Message(NewFeatureEnabledMessageTxt, Caption(), IntrastatReportList.Caption());
                IntrastatReportList.Run();
                Error('');
            end else
                IntrastatReportMgt.NotifyUserAboutIntrastatFeature();
        end;
    }
    var
        NewFeatureEnabledMessageTxt: Label 'The Intrastat Report extension is enabled, which means you can''t use the %1 report. You''ve been redirected to the %2 page for the extension.', Comment = '%1 - old page caption, %2 - new page caption';
}