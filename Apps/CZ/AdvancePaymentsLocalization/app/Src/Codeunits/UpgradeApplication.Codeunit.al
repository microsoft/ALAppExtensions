codeunit 31088 "Upgrade Application CZZ"
{
    Subtype = Upgrade;

    var
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitionsCZZ: Codeunit "Upgrade Tag Definitions CZZ";
        InstallApplicationsMgtCZL: Codeunit "Install Applications Mgt. CZL";

    trigger OnUpgradePerDatabase()
    begin
        DataUpgradeMgt.SetUpgradeInProgress();
        SetDatabaseUpgradeTags();
    end;

    trigger OnUpgradePerCompany()
    begin
        DataUpgradeMgt.SetUpgradeInProgress();
        BindSubscription(InstallApplicationsMgtCZL);
        UpgradeData();
        UnbindSubscription(InstallApplicationsMgtCZL);
        SetCompanyUpgradeTags();
    end;

    local procedure UpgradeData()
    begin
        UpgradeReportSelections();
    end;

    local procedure UpgradeReportSelections();
    var
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        ReportSelectionHandlerCZZ: Codeunit "Report Selection Handler CZZ";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZZ.GetDataVersion200PerCompanyUpgradeTag()) then
            exit;

        AdvanceLetterTemplateCZZ.SetRange("Sales/Purchase", AdvanceLetterTemplateCZZ."Sales/Purchase"::Purchase);
        AdvanceLetterTemplateCZZ.SetFilter("Document Report ID", '<>0');
        if AdvanceLetterTemplateCZZ.FindFirst() then
            ReportSelectionHandlerCZZ.InsertRepSelection(Enum::"Report Selection Usage"::"Purchase Advance Letter CZZ", '1', AdvanceLetterTemplateCZZ."Document Report ID")
        else
            ReportSelectionHandlerCZZ.InsertRepSelection(Enum::"Report Selection Usage"::"Purchase Advance Letter CZZ", '1', Report::"Purchase - Advance Letter CZZ");
        AdvanceLetterTemplateCZZ.SetRange("Document Report ID");
        AdvanceLetterTemplateCZZ.SetFilter("Invoice/Cr. Memo Report ID", '<>0');
        if AdvanceLetterTemplateCZZ.FindFirst() then
            ReportSelectionHandlerCZZ.InsertRepSelection(Enum::"Report Selection Usage"::"Purchase Advance VAT Document CZZ", '1', AdvanceLetterTemplateCZZ."Invoice/Cr. Memo Report ID")
        else
            ReportSelectionHandlerCZZ.InsertRepSelection(Enum::"Report Selection Usage"::"Purchase Advance VAT Document CZZ", '1', Report::"Purchase - Advance VAT Doc.CZZ");

        AdvanceLetterTemplateCZZ.Reset();
        AdvanceLetterTemplateCZZ.SetRange("Sales/Purchase", AdvanceLetterTemplateCZZ."Sales/Purchase"::Sales);
        AdvanceLetterTemplateCZZ.SetFilter("Document Report ID", '<>0');
        if AdvanceLetterTemplateCZZ.FindFirst() then
            ReportSelectionHandlerCZZ.InsertRepSelection(Enum::"Report Selection Usage"::"Sales Advance Letter CZZ", '1', AdvanceLetterTemplateCZZ."Document Report ID")
        else
            ReportSelectionHandlerCZZ.InsertRepSelection(Enum::"Report Selection Usage"::"Sales Advance Letter CZZ", '1', Report::"Sales - Advance Letter CZZ");
        AdvanceLetterTemplateCZZ.SetRange("Document Report ID");
        AdvanceLetterTemplateCZZ.SetFilter("Invoice/Cr. Memo Report ID", '<>0');
        if AdvanceLetterTemplateCZZ.FindFirst() then
            ReportSelectionHandlerCZZ.InsertRepSelection(Enum::"Report Selection Usage"::"Sales Advance VAT Document CZZ", '1', AdvanceLetterTemplateCZZ."Invoice/Cr. Memo Report ID")
        else
            ReportSelectionHandlerCZZ.InsertRepSelection(Enum::"Report Selection Usage"::"Sales Advance VAT Document CZZ", '1', Report::"Sales - Advance VAT Doc. CZZ");
    end;

    local procedure SetDatabaseUpgradeTags();
    begin
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZZ.GetDataVersion190PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZZ.GetDataVersion190PerDatabaseUpgradeTag());
    end;

    local procedure SetCompanyUpgradeTags();
    begin
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZZ.GetDataVersion190PerCompanyUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZZ.GetDataVersion190PerCompanyUpgradeTag());
    end;
}
