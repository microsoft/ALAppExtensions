codeunit 5204 "Create Custom Report Layout"
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
        UpdateReportLayout(Enum::"Report Selection Usage"::"S.Order", '1', REPORT::"Standard Sales - Order Conf.");
        UpdateReportLayout(Enum::"Report Selection Usage"::"S.Invoice", '1', REPORT::"Standard Sales - Invoice");
        UpdateReportLayout(Enum::"Report Selection Usage"::"S.Cr.Memo", '1', REPORT::"Standard Sales - Credit Memo");
        UpdateReportLayout(Enum::"Report Selection Usage"::"S.Quote", '1', REPORT::"Standard Sales - Quote");
        UpdateReportLayout(Enum::"Report Selection Usage"::"P.Order", '1', REPORT::"Standard Purchase - Order");
    end;

    local procedure UpdateEmailBodySelections()
    begin
        AddEmailBodyLayout(REPORT::"Standard Sales - Quote", MS1304EmailTok);
        AddEmailBodyLayout(REPORT::"Standard Sales - Order Conf.", MS1305EmailTok);
        AddEmailBodyLayout(REPORT::"Standard Sales - Invoice", MS1306EmailDefTok);
        AddEmailBodyLayout(REPORT::"Standard Sales - Credit Memo", MS1307EmailDefTok);
        AddEmailBodyLayout(REPORT::"Standard Sales - Draft Invoice", MS1303EmailTok);
        AddEmailBodyLayout(REPORT::"Standard Statement", MS1316EmailDefTok);
        AddEmailBodyLayout(REPORT::"Standard Purchase - Order", MS1322EmailDefTok);
        AddEmailBodyLayout(REPORT::Reminder, MS117EmailDefTok);
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
        MS1303EmailTok: Label 'SalesInvoiceSimpleEmail.docx', Locked = true;
        MS1304EmailTok: Label 'StandardSalesQuoteEmail.docx', Locked = true;
        MS1305EmailTok: Label 'StandardOrderConfirmationEmail.docx', Locked = true;
        MS1306EmailDefTok: Label 'StandardSalesInvoiceDefEmail.docx', Locked = true;
        MS1307EmailDefTok: Label 'StandardSalesCreditMemoEmail.docx', Locked = true;
        MS1316EmailDefTok: Label 'StandardCustomerStatementEmail.docx', Locked = true;
        MS1322EmailDefTok: Label 'StandardPurchaseOrderEmail.docx', Locked = true;
        MS117EmailDefTok: Label 'DefaultReminderEmail.docx', Locked = true;
    // MS1303BlueSimple: Label 'StandardDraftSalesInvoiceBlue.docx', Locked = true;
    // MS1304BlueSimple: Label 'StandardSalesQuoteBlue.docx', Locked = true;
    // MS1306BlueSimple: Label 'StandardSalesInvoiceBlueSimple.docx', Locked = true;
    // MS1302Default: Label 'StandardSalesProFormaInv.docx', Locked = true;
    // MS1308BlueSimple: Label 'SimpleSalesShipment.docx', Locked = true;
    // MS1309BlueSimple: Label 'SimpleSalesReturnReceipt.docx', Locked = true;
}
