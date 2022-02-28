codeunit 13603 "Install DK Core"
{
    Access = Internal;

    Subtype = Install;
    trigger OnInstallAppPerCompany()
    begin
        SaveExperienceTier();
        SetDefaultReportLayout();
    end;

    local procedure SaveExperienceTier()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        BasicExtTxt: Label 'Basic Ext', Locked = true;
    begin
        ApplicationAreaMgmtFacade.SaveExperienceTierCurrentCompany(BasicExtTxt);
    end;

    local procedure SetDefaultReportLayout()
    var
        TenantReportLayoutSelection: Record "Tenant Report Layout Selection";
        ReportLayoutSelection: Record "Report Layout Selection";
        CompanyInformation: Record "Company Information";
        newLayoutReports: Dictionary of [Integer, Text[250]];
        reportID: Integer;
    begin
        // The layout specified in a report extension will not automatically be used when the report extension is deployed.
        // Change "Report Layout Selection" on install

        // Layouts from reportExt are listed in Table "Report Layout List"
        // Not sure how to query properly, so manualy listed for now
        newLayoutReports.Add(116, './src/Reports/Statement.rdlc');
        newLayoutReports.Add(117, './src/Reports/Reminder.rdlc');
        newLayoutReports.Add(118, './src/Reports/FinanceChargeMemo.rdlc');

        CompanyInformation.Get();

        foreach reportID in newLayoutReports.Keys() do begin
            TenantReportLayoutSelection."Company Name" := CompanyInformation.Name;
            TenantReportLayoutSelection."Layout Name" := newLayoutReports.Get(reportID);
            TenantReportLayoutSelection."Report ID" := reportID;
            if not TenantReportLayoutSelection.Insert() then
                TenantReportLayoutSelection.Modify();

            ReportLayoutSelection.Init();
            ReportLayoutSelection."Report ID" := reportID;
            ReportLayoutSelection."Company Name" := CompanyInformation.Name;
            ReportLayoutSelection.Type := ReportLayoutSelection.Type::"RDLC (built-in)";
            ReportLayoutSelection.Insert();
        end;
    end;
}