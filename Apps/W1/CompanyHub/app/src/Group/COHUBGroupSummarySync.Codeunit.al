codeunit 1162 "COHUB Group Summary Sync"
{
    Access = Internal;

    trigger OnRun()
    var
        COHUBGroup: Record "COHUB Group";
        COHUBCompanyKPI: Record "COHUB Company KPI";
        COHUBGroupCompanySummary: Record "COHUB Group Company Summary";
        SortOrder: Integer;
    begin
        // Groups should get inserted into temp table with indentation 0.
        // Group Line rows should get inserted into temp table with indentation 1.
        COHUBGroupCompanySummary.DeleteAll();
        COHUBGroup.Reset();
        COHUBGroup.SetFilter(Code, '<>%1', '');
        if COHUBGroup.FindSet() then
            repeat
                // fill up group company summary with groups
                Clear(COHUBGroupCompanySummary);
                COHUBGroupCompanySummary."Group Code" := COHUBGroup.Code;
                COHUBGroupCompanySummary.Indent := 0;
                COHUBGroupCompanySummary."Enviroment No." := '';
                COHUBGroupCompanySummary."Company Display Name" := COHUBGroup.Code;
                COHUBGroupCompanySummary."Company Name" := '';
                SortOrder := SortOrder + 1;
                COHUBGroupCompanySummary.GroupSortOrder := SortOrder;
                COHUBGroupCompanySummary.Insert();

                // Find any tenant KPI assigned to this group
                Clear(COHUBCompanyKPI);
                COHUBCompanyKPI.SetRange("Group Code", COHUBGroup.Code);
                if COHUBCompanyKPI.FindSet() then
                    repeat
                        Clear(COHUBGroupCompanySummary);
                        COHUBGroupCompanySummary."Group Code" := COHUBCompanyKPI."Group Code";
                        COHUBGroupCompanySummary.Indent := 1;
                        COHUBGroupCompanySummary."Enviroment No." := COHUBCompanyKPI."Enviroment No.";
                        if COHUBGroupCompanySummary."Company Display Name" = '' then
                            COHUBGroupCompanySummary."Company Display Name" := COHUBGroupCompanySummary."Company Name";
                        COHUBGroupCompanySummary."Company Name" := COHUBCompanyKPI."Company Name";
                        SortOrder := SortOrder + 1;
                        COHUBGroupCompanySummary.GroupSortOrder := SortOrder;
                        COHUBGroupCompanySummary."Assigned To" := COHUBCompanyKPI."Assigned To";
                        COHUBGroupCompanySummary.Insert();
                    until COHUBCompanyKPI.Next() <= 0;
            until COHUBGroup.Next() = 0;

        // Find all ungrouped tenants
        Clear(COHUBCompanyKPI);
        COHUBCompanyKPI.SetRange("Group Code", '');
        if COHUBCompanyKPI.FindSet() then
            repeat
                Clear(COHUBGroupCompanySummary);
                COHUBGroupCompanySummary."Group Code" := '';
                COHUBGroupCompanySummary.Indent := 0;
                COHUBGroupCompanySummary."Enviroment No." := COHUBCompanyKPI."Enviroment No.";
                COHUBGroupCompanySummary."Company Display Name" := COHUBCompanyKPI."Company Display Name";
                if COHUBGroupCompanySummary."Company Display Name" = '' then
                    COHUBGroupCompanySummary."Company Display Name" := COHUBGroupCompanySummary."Company Name";

                COHUBGroupCompanySummary."Company Name" := COHUBCompanyKPI."Company Name";
                SortOrder := SortOrder + 1;
                COHUBGroupCompanySummary.GroupSortOrder := SortOrder;
                COHUBGroupCompanySummary."Assigned To" := COHUBCompanyKPI."Assigned To";
                COHUBGroupCompanySummary.Insert();
            until COHUBCompanyKPI.Next() <= 0;
    end;
}