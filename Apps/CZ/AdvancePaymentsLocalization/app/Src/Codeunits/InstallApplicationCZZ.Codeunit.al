// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft;
using Microsoft.Bank.Documents;
using Microsoft.CashFlow.Account;
using Microsoft.CashFlow.Forecast;
using Microsoft.CashFlow.Setup;
using Microsoft.CashFlow.Worksheet;
using Microsoft.EServices.EDocument;
using Microsoft.Finance.FinancialReports;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Reporting;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Reporting;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using System.Upgrade;
using Microsoft.Finance.CashDesk;

#pragma warning disable AL0432
codeunit 31087 "Install Application CZZ"
{
    Subtype = Install;
    Permissions = tabledata "Advance Letter Template CZZ" = i,
                  tabledata "Acc. Schedule Extension CZL" = rm,
                  tabledata "Purch. Adv. Letter Header CZZ" = i,
                  tabledata "Purch. Adv. Letter Line CZZ" = i,
                  tabledata "Purch. Adv. Letter Entry CZZ" = i,
                  tabledata "Sales Adv. Letter Header CZZ" = i,
                  tabledata "Sales Adv. Letter Line CZZ" = i,
                  tabledata "Sales Adv. Letter Entry CZZ" = i,
                  tabledata "Advance Letter Application CZZ" = im,
                  tabledata "VAT Posting Setup" = m,
                  tabledata "VAT Entry" = m,
                  tabledata "Cust. Ledger Entry" = m,
                  tabledata "Vendor Ledger Entry" = m,
                  tabledata "VAT Statement Line" = d,
                  tabledata "Gen. Journal Line" = m,
                  tabledata "Cash Document Line CZP" = m,
                  tabledata "Payment Order Line CZB" = m,
                  tabledata "Iss. Payment Order Line CZB" = m,
                  tabledata "Report Selections" = m,
                  tabledata "Cash Flow Account" = m,
                  tabledata "Cash Flow Forecast Entry" = m,
                  tabledata "Cash Flow Setup" = m,
                  tabledata "Cash Flow Worksheet Line" = m,
                  tabledata "Incoming Document" = m;

    var
        InstallApplicationsMgtCZL: Codeunit "Install Applications Mgt. CZL";
        AppInfo: ModuleInfo;

    trigger OnInstallAppPerCompany()
    begin
        if not InitializeDone() then begin
            BindSubscription(InstallApplicationsMgtCZL);
            CopyData();
            UnbindSubscription(InstallApplicationsMgtCZL);
        end;
        CompanyInitialize();
    end;

    local procedure InitializeDone(): boolean
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        exit(AppInfo.DataVersion() <> Version.Create('0.0.0.0'));
    end;

    procedure CopyData()
    begin
        CopyCustomerLedgerEntries();
        CopyVendorLedgerEntries();
        CopyAccScheduleExtension();
        MoveIncomingDocument();
        ModifyReportSelections();
    end;

    local procedure CopyCustomerLedgerEntries()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        AppliedCustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetLoadFields("Entry No.", "Advance Letter No. CZZ", "Adv. Letter Template Code CZZ", "Closed by Entry No.");
        CustLedgerEntry.SetRange(Prepayment, true);
        if CustLedgerEntry.FindSet(true) then
            repeat
                if CustLedgerEntry."Advance Letter No. CZZ" <> '' then begin
                    if CustLedgerEntry."Closed by Entry No." <> 0 then
                        if AppliedCustLedgerEntry.Get(CustLedgerEntry."Closed by Entry No.") then
                            if AppliedCustLedgerEntry."Advance Letter No. CZZ" = '' then begin
                                AppliedCustLedgerEntry.Validate("Advance Letter No. CZZ", CustLedgerEntry."Advance Letter No. CZZ");
                                AppliedCustLedgerEntry."Adv. Letter Template Code CZZ" := CustLedgerEntry."Adv. Letter Template Code CZZ";
                                AppliedCustLedgerEntry.Modify();
                            end;
                    AppliedCustLedgerEntry.SetCurrentKey("Closed by Entry No.");
                    AppliedCustLedgerEntry.SetRange("Closed by Entry No.", CustLedgerEntry."Entry No.");
                    if AppliedCustLedgerEntry.FindSet(true) then
                        repeat
                            if AppliedCustLedgerEntry."Advance Letter No. CZZ" = '' then begin
                                AppliedCustLedgerEntry.Validate("Advance Letter No. CZZ", CustLedgerEntry."Advance Letter No. CZZ");
                                AppliedCustLedgerEntry."Adv. Letter Template Code CZZ" := CustLedgerEntry."Adv. Letter Template Code CZZ";
                                AppliedCustLedgerEntry.Modify();
                            end;
                        until AppliedCustLedgerEntry.Next() = 0;
                end;
            until CustLedgerEntry.Next() = 0;
    end;

    local procedure CopyVendorLedgerEntries()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        AppliedVendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendorLedgerEntry.SetLoadFields("Entry No.", "Advance Letter No. CZZ", "Adv. Letter Template Code CZZ", "Closed by Entry No.");
        VendorLedgerEntry.SetRange(Prepayment, true);
        if VendorLedgerEntry.FindSet(true) then
            repeat
                if VendorLedgerEntry."Advance Letter No. CZZ" <> '' then begin
                    if VendorLedgerEntry."Closed by Entry No." <> 0 then
                        if AppliedVendorLedgerEntry.Get(VendorLedgerEntry."Closed by Entry No.") then
                            if AppliedVendorLedgerEntry."Advance Letter No. CZZ" = '' then begin
                                AppliedVendorLedgerEntry.Validate("Advance Letter No. CZZ", VendorLedgerEntry."Advance Letter No. CZZ");
                                AppliedVendorLedgerEntry."Adv. Letter Template Code CZZ" := VendorLedgerEntry."Adv. Letter Template Code CZZ";
                                AppliedVendorLedgerEntry.Modify();
                            end;
                    AppliedVendorLedgerEntry.SetCurrentKey("Closed by Entry No.");
                    AppliedVendorLedgerEntry.SetRange("Closed by Entry No.", VendorLedgerEntry."Entry No.");
                    if AppliedVendorLedgerEntry.FindSet(true) then
                        repeat
                            if AppliedVendorLedgerEntry."Advance Letter No. CZZ" = '' then begin
                                AppliedVendorLedgerEntry.Validate("Advance Letter No. CZZ", VendorLedgerEntry."Advance Letter No. CZZ");
                                AppliedVendorLedgerEntry."Adv. Letter Template Code CZZ" := VendorLedgerEntry."Adv. Letter Template Code CZZ";
                                AppliedVendorLedgerEntry.Modify();
                            end;
                        until AppliedVendorLedgerEntry.Next() = 0;
                end;
            until VendorLedgerEntry.Next() = 0;
    end;

    local procedure ModifyReportSelections()
    var
        ReportSelections: Record "Report Selections";
    begin
        ReportSelections.SetRange("Report ID", Report::"Purchase - Invoice");
        if ReportSelections.FindSet(true) then
            repeat
                ReportSelections.Validate("Report ID", Report::"Purchase-Invoice with Adv. CZZ");
                ReportSelections.Validate("Use for Email Body", false);
                ReportSelections.Modify();
            until ReportSelections.Next() = 0;
        ReportSelections.SetFilter("Report ID", '%1|%2|%3',
            Report::"Standard Sales - Invoice",
            Report::"Sales Invoice CZL",
            31096);
        if ReportSelections.FindSet(true) then
            repeat
                ReportSelections.Validate("Report ID", Report::"Sales - Invoice with Adv. CZZ");
                ReportSelections.Modify();
            until ReportSelections.Next() = 0;
    end;

    local procedure CopyAccScheduleExtension()
    var
        AccScheduleExtensionCZL: Record "Acc. Schedule Extension CZL";
        AccScheduleExtensionCZLDataTransfer: DataTransfer;
    begin
        AccScheduleExtensionCZLDataTransfer.SetTables(Database::"Acc. Schedule Extension CZL", Database::"Acc. Schedule Extension CZL");
        AccScheduleExtensionCZLDataTransfer.AddFieldValue(AccScheduleExtensionCZL.FieldNo(Prepayment), AccScheduleExtensionCZL.FieldNo("Advance Payments CZZ"));
        AccScheduleExtensionCZLDataTransfer.CopyFields();
    end;

    local procedure MoveIncomingDocument()
    var
        IncomingDocument: Record "Incoming Document";
        PrevIncomingDocument: Record "Incoming Document";
    begin
        IncomingDocument.SetLoadFields("Document Type", "Document No.", "Related Record ID");
        if IncomingDocument.FindSet(true) then
            repeat
                PrevIncomingDocument := IncomingDocument;
                IncomingDocument."Document Type" := GetDocumentType(IncomingDocument);
                if (IncomingDocument."Related Record ID" <> PrevIncomingDocument."Related Record ID") or
                   (IncomingDocument."Document Type" <> PrevIncomingDocument."Document Type")
                then
                    IncomingDocument.Modify(false);
            until IncomingDocument.Next() = 0;
    end;

    local procedure GetDocumentType(IncomingDocument: Record "Incoming Document"): Enum "Incoming Related Document Type"
    begin
        case IncomingDocument."Document Type" of
            Enum::"Incoming Related Document Type".FromInteger(6):
                exit(IncomingDocument."Document Type"::"Sales Advance CZZ");
            Enum::"Incoming Related Document Type".FromInteger(7):
                exit(IncomingDocument."Document Type"::"Purchase Advance CZZ");
            else
                exit(IncomingDocument."Document Type");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    var
        DataClassEvalHandlerCZZ: Codeunit "Data Class. Eval. Handler CZZ";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        InitAdvancePaymentsReportSelections();
        ModifyReportSelections();

        DataClassEvalHandlerCZZ.ApplyEvaluationClassificationsForPrivacy();
        UpgradeTag.SetAllUpgradeTags();
    end;

    local procedure InitAdvancePaymentsReportSelections();
    var
        ReportSelectionHandlerCZZ: Codeunit "Report Selection Handler CZZ";
    begin
        ReportSelectionHandlerCZZ.InsertRepSelection(Enum::"Report Selection Usage"::"Purchase Advance Letter CZZ", '1', Report::"Purchase - Advance Letter CZZ");
        ReportSelectionHandlerCZZ.InsertRepSelection(Enum::"Report Selection Usage"::"Purchase Advance VAT Document CZZ", '1', Report::"Purchase - Advance VAT Doc.CZZ");
        ReportSelectionHandlerCZZ.InsertRepSelection(Enum::"Report Selection Usage"::"Sales Advance Letter CZZ", '1', Report::"Sales - Advance Letter CZZ");
        ReportSelectionHandlerCZZ.InsertRepSelection(Enum::"Report Selection Usage"::"Sales Advance VAT Document CZZ", '1', Report::"Sales - Advance VAT Doc. CZZ");
    end;
}
