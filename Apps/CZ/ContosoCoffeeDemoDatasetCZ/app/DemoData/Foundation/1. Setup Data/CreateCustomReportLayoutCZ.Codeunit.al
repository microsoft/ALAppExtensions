// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.Foundation.Reporting;
using System.Reflection;
using Microsoft.Sales.Reminder;
using Microsoft.Purchases.Document;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;

codeunit 31294 "Create Custom Report Layout CZ"
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
        UpdateReportLayout(Enum::"Report Selection Usage"::Reminder, '1', Report::"Reminder CZL");
        UpdateReportLayout(Enum::"Report Selection Usage"::"P.Order", '1', Report::"Purchase Order CZL");
        UpdateReportLayout(Enum::"Report Selection Usage"::"S.Quote", '1', Report::"Sales Quote CZL");
        UpdateReportLayout(Enum::"Report Selection Usage"::"S.Order", '1', Report::"Sales Order Confirmation CZL");
        UpdateReportLayout(Enum::"Report Selection Usage"::"S.Invoice", '1', Report::"Sales Invoice CZL");
        UpdateReportLayout(Enum::"Report Selection Usage"::"S.Cr.Memo", '1', Report::"Sales Credit Memo CZL");
    end;

    local procedure UpdateEmailBodySelections()
    begin
        AddEmailBodyLayout(Report::"Reminder CZL", CZ31182EmailTok);
        AddEmailBodyLayout(Report::"Purchase Order CZL", CZ31185EmailTok);
        AddEmailBodyLayout(Report::"Sales Quote CZL", CZ31186EmailTok);
        AddEmailBodyLayout(Report::"Sales Order Confirmation CZL", CZ31187EmailTok);
        AddEmailBodyLayout(Report::"Sales Invoice CZL", CZ31189EmailTok);
        AddEmailBodyLayout(Report::"Sales Credit Memo CZL", CZ31190EmailTok);
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
        CZ31182EmailTok: Label 'ReminderEmail.docx', Locked = true;
        CZ31185EmailTok: Label 'PurchaseOrderEmail.docx', Locked = true;
        CZ31186EmailTok: Label 'SalesQuoteEmail.docx', Locked = true;
        CZ31187EmailTok: Label 'SalesOrderConfirmationEmail.docx', Locked = true;
        CZ31189EmailTok: Label 'SalesInvoiceEmail.docx', Locked = true;
        CZ31190EmailTok: Label 'SalesCreditMemoEmail.docx', Locked = true;
}
