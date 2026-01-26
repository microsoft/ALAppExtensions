#pragma warning disable AA0247
codeunit 31473 "Create Custom Rep. Layout CZZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Access = Internal;

    trigger OnRun()
    begin
        UpdateReportSelections();
        UpdateEmailBodySelections();
    end;

    local procedure UpdateReportSelections()
    begin
        UpdateReportLayout(Enum::"Report Selection Usage"::"Sales Advance Letter CZZ", '1', Report::"Sales - Advance Letter CZZ");
        UpdateReportLayout(Enum::"Report Selection Usage"::"Sales Advance VAT Document CZZ", '1', Report::"Sales - Advance VAT Doc. CZZ");
        UpdateReportLayout(Enum::"Report Selection Usage"::"S.Invoice", '1', Report::"Sales - Invoice with Adv. CZZ");
    end;

    local procedure UpdateEmailBodySelections()
    begin
        AddEmailBodyLayout(Report::"Sales - Advance Letter CZZ", CZ31014EmailTok);
        AddEmailBodyLayout(Report::"Sales - Advance VAT Doc. CZZ", CZ31015EmailTok);
        AddEmailBodyLayout(Report::"Sales - Invoice with Adv. CZZ", CZ31018EmailTok);
    end;

    local procedure UpdateReportLayout(Usage: Enum "Report Selection Usage"; Sequence: Code[10]; ReportID: Integer)
    var
        ReportSelections: Record "Report Selections";
    begin
        if not ReportSelections.Get(Usage, Sequence) then
            exit;

        ReportSelections.Validate("Report ID", ReportID);
        ReportSelections.Modify(true);
    end;

    local procedure AddEmailBodyLayout(ReportID: Integer; ReportLayoutName: Text[250])
    var
        ReportSelections: Record "Report Selections";
        ReportLayoutList: Record "Report Layout List";
    begin
        ReportLayoutList.SetRange("Report ID", ReportID);
        ReportLayoutList.SetRange(Name, ReportLayoutName);
        if ReportLayoutList.IsEmpty() then
            exit;

        ReportSelections.SetRange("Report ID", ReportID);
        if ReportSelections.FindFirst() then begin
            ReportSelections.Validate("Use for Email Body", true);
            ReportSelections.Validate("Email Body Layout Name", CopyStr(ReportLayoutName, 1, MaxStrLen(ReportSelections."Email Body Layout Name")));
            ReportSelections.Modify(true);
        end;
    end;

    var
        CZ31014EmailTok: Label 'SalesAdvanceLetterEmail.docx', Locked = true;
        CZ31015EmailTok: Label 'SalesAdvanceVATDocEmail.docx', Locked = true;
        CZ31018EmailTok: Label 'SalesInvoicewithAdvEmail.docx', Locked = true;
}
