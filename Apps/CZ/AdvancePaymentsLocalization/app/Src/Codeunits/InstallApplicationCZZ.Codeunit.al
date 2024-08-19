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
using Microsoft.Foundation.Enums;
using Microsoft.Foundation.Reporting;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using System.Reflection;
using System.Upgrade;
using Microsoft.Finance.CashDesk;

#pragma warning disable AL0432
codeunit 31087 "Install Application CZZ"
{
    Subtype = Install;
    Permissions = tabledata "Advance Letter Line Relation" = d,
                  tabledata "Advance Letter Template CZZ" = i,
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
        VATPostingSetup: Record "VAT Posting Setup";
        InstallApplicationsMgtCZL: Codeunit "Install Applications Mgt. CZL";
        AppInfo: ModuleInfo;

    trigger OnInstallAppPerDatabase()
    begin
        CopyPermission();
    end;

    trigger OnInstallAppPerCompany()
    begin
        if not InitializeDone() then begin
            BindSubscription(InstallApplicationsMgtCZL);
            CopyUsage();
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

    local procedure CopyPermission();
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Purchase Adv. Payment Template", Database::"Advance Letter Template CZZ");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Purch. Advance Letter Header", Database::"Purch. Adv. Letter Header CZZ");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Purch. Advance Letter Line", Database::"Purch. Adv. Letter Line CZZ");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Purch. Advance Letter Entry", Database::"Purch. Adv. Letter Entry CZZ");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Sales Adv. Payment Template", Database::"Advance Letter Template CZZ");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Sales Advance Letter Header", Database::"Sales Adv. Letter Header CZZ");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Sales Advance Letter Line", Database::"Sales Adv. Letter Line CZZ");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Sales Advance Letter Entry", Database::"Sales Adv. Letter Entry CZZ");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Advance Link", Database::"Advance Letter Application CZZ");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Advance Letter Line Relation", Database::"Advance Letter Application CZZ");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Advance Link Buffer", Database::"Advance Letter Link Buffer CZZ");
    end;

    local procedure CopyUsage();
    begin
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Purchase Adv. Payment Template", Database::"Advance Letter Template CZZ");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Purch. Advance Letter Header", Database::"Purch. Adv. Letter Header CZZ");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Purch. Advance Letter Line", Database::"Purch. Adv. Letter Line CZZ");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Purch. Advance Letter Entry", Database::"Purch. Adv. Letter Entry CZZ");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Sales Adv. Payment Template", Database::"Advance Letter Template CZZ");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Sales Advance Letter Header", Database::"Sales Adv. Letter Header CZZ");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Sales Advance Letter Line", Database::"Sales Adv. Letter Line CZZ");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Sales Advance Letter Entry", Database::"Sales Adv. Letter Entry CZZ");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Advance Link", Database::"Advance Letter Application CZZ");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Advance Letter Line Relation", Database::"Advance Letter Application CZZ");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Advance Link Buffer", Database::"Advance Letter Link Buffer CZZ");
    end;

    procedure CopyData()
    var
        PurchaseAdvPaymentTemplate: Record "Purchase Adv. Payment Template";
        SalesAdvPaymentTemplate: Record "Sales Adv. Payment Template";
    begin
        if PurchaseAdvPaymentTemplate.IsEmpty() and SalesAdvPaymentTemplate.IsEmpty() then
            exit;

        CopyPurchaseAdvanceTemplates();
        CopySalesAdvanceTemplates();
        CopyPurchaseAdvances();
        CopySalesAdvances();
        CopyVATPostingSetup();
        CopyVATEntries();
        CopyCustomerLedgerEntries();
        CopyVendorLedgerEntries();
        CopyGenJournalLines();
        CopyCashDocumentLinesCZP();
        CopyPaymentOrderLinesCZB();
        CopyIssPaymentOrderLinesCZB();
        CopyCashFlowSetup();
        CopyAccScheduleExtension();
        MoveIncomingDocument();
        ModifyReportSelections();
    end;

    local procedure CopyPurchaseAdvanceTemplates()
    var
        PurchaseAdvPaymentTemplate: Record "Purchase Adv. Payment Template";
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        VendorPostingGroup: Record "Vendor Posting Group";
    begin
        if PurchaseAdvPaymentTemplate.FindSet() then
            repeat
                if not AdvanceLetterTemplateCZZ.Get('N_' + PurchaseAdvPaymentTemplate.Code) then begin
                    AdvanceLetterTemplateCZZ.Init();
                    AdvanceLetterTemplateCZZ.Code := 'N_' + PurchaseAdvPaymentTemplate.Code;
                    AdvanceLetterTemplateCZZ.Description := CopyStr(PurchaseAdvPaymentTemplate.Description, 1, MaxStrLen(AdvanceLetterTemplateCZZ.Description));
                    AdvanceLetterTemplateCZZ."Sales/Purchase" := AdvanceLetterTemplateCZZ."Sales/Purchase"::Purchase;
                    if VendorPostingGroup.Get(PurchaseAdvPaymentTemplate."Vendor Posting Group") then
                        AdvanceLetterTemplateCZZ."Advance Letter G/L Account" := VendorPostingGroup."Advance Account";
                    AdvanceLetterTemplateCZZ."Advance Letter Document Nos." := PurchaseAdvPaymentTemplate."Advance Letter Nos.";
                    AdvanceLetterTemplateCZZ."Advance Letter Invoice Nos." := PurchaseAdvPaymentTemplate."Advance Invoice Nos.";
                    AdvanceLetterTemplateCZZ."Advance Letter Cr. Memo Nos." := PurchaseAdvPaymentTemplate."Advance Credit Memo Nos.";
                    AdvanceLetterTemplateCZZ."Automatic Post VAT Document" := true;
                    AdvanceLetterTemplateCZZ.SystemId := PurchaseAdvPaymentTemplate.SystemId;
                    AdvanceLetterTemplateCZZ.Insert(false, true);
                end;
            until PurchaseAdvPaymentTemplate.Next() = 0;
    end;

    local procedure CopySalesAdvanceTemplates()
    var
        SalesAdvPaymentTemplate: Record "Sales Adv. Payment Template";
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        if SalesAdvPaymentTemplate.FindSet() then
            repeat
                if not AdvanceLetterTemplateCZZ.Get('P_' + SalesAdvPaymentTemplate.Code) then begin
                    AdvanceLetterTemplateCZZ.Init();
                    AdvanceLetterTemplateCZZ.Code := 'P_' + SalesAdvPaymentTemplate.Code;
                    AdvanceLetterTemplateCZZ.Description := CopyStr(SalesAdvPaymentTemplate.Description, 1, MaxStrLen(AdvanceLetterTemplateCZZ.Description));
                    AdvanceLetterTemplateCZZ."Sales/Purchase" := AdvanceLetterTemplateCZZ."Sales/Purchase"::Sales;
                    if CustomerPostingGroup.Get(SalesAdvPaymentTemplate."Customer Posting Group") then
                        AdvanceLetterTemplateCZZ."Advance Letter G/L Account" := CustomerPostingGroup."Advance Account";
                    AdvanceLetterTemplateCZZ."Advance Letter Document Nos." := SalesAdvPaymentTemplate."Advance Letter Nos.";
                    AdvanceLetterTemplateCZZ."Advance Letter Invoice Nos." := SalesAdvPaymentTemplate."Advance Invoice Nos.";
                    AdvanceLetterTemplateCZZ."Advance Letter Cr. Memo Nos." := SalesAdvPaymentTemplate."Advance Credit Memo Nos.";
                    AdvanceLetterTemplateCZZ."Automatic Post VAT Document" := true;
                    AdvanceLetterTemplateCZZ.SystemId := SalesAdvPaymentTemplate.SystemId;
                    AdvanceLetterTemplateCZZ.Insert(false, true);
                end;
            until SalesAdvPaymentTemplate.Next() = 0;
    end;

    local procedure CopyPurchaseAdvances()
    var
        PurchAdvanceLetterHeader: Record "Purch. Advance Letter Header";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvanceLetterLine: Record "Purch. Advance Letter Line";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
    begin
        if PurchAdvanceLetterHeader.FindSet() then
            repeat
                if not PurchAdvLetterHeaderCZZ.Get(PurchAdvanceLetterHeader."No.") then begin
                    PurchAdvLetterHeaderCZZ.Init();
                    PurchAdvLetterHeaderCZZ."No." := PurchAdvanceLetterHeader."No.";
                    if PurchAdvanceLetterHeader."Template Code" <> '' then
                        PurchAdvLetterHeaderCZZ."Advance Letter Code" := 'N_' + PurchAdvanceLetterHeader."Template Code";
                    PurchAdvLetterHeaderCZZ."Pay-to Vendor No." := PurchAdvanceLetterHeader."Pay-to Vendor No.";
                    PurchAdvLetterHeaderCZZ."Pay-to Name" := PurchAdvanceLetterHeader."Pay-to Name";
                    PurchAdvLetterHeaderCZZ."Pay-to Name 2" := PurchAdvanceLetterHeader."Pay-to Name 2";
                    PurchAdvLetterHeaderCZZ."Pay-to Address" := PurchAdvanceLetterHeader."Pay-to Address";
                    PurchAdvLetterHeaderCZZ."Pay-to Address 2" := PurchAdvanceLetterHeader."Pay-to Address 2";
                    PurchAdvLetterHeaderCZZ."Pay-to City" := PurchAdvanceLetterHeader."Pay-to City";
                    PurchAdvLetterHeaderCZZ."Pay-to Post Code" := PurchAdvanceLetterHeader."Pay-to Post Code";
                    PurchAdvLetterHeaderCZZ."Pay-to County" := PurchAdvanceLetterHeader."Pay-to County";
                    PurchAdvLetterHeaderCZZ."Pay-to Country/Region Code" := PurchAdvanceLetterHeader."Pay-to Country/Region Code";
                    PurchAdvLetterHeaderCZZ."Language Code" := PurchAdvanceLetterHeader."Language Code";
                    PurchAdvLetterHeaderCZZ."Format Region" := PurchAdvanceLetterHeader."Format Region";
                    PurchAdvLetterHeaderCZZ."Pay-to Contact" := PurchAdvanceLetterHeader."Pay-to Contact";
                    PurchAdvLetterHeaderCZZ."Purchaser Code" := PurchAdvanceLetterHeader."Purchaser Code";
                    PurchAdvLetterHeaderCZZ."Shortcut Dimension 1 Code" := PurchAdvanceLetterHeader."Shortcut Dimension 1 Code";
                    PurchAdvLetterHeaderCZZ."Shortcut Dimension 2 Code" := PurchAdvanceLetterHeader."Shortcut Dimension 2 Code";
                    PurchAdvLetterHeaderCZZ."VAT Bus. Posting Group" := PurchAdvanceLetterHeader."VAT Bus. Posting Group";
                    PurchAdvLetterHeaderCZZ."Posting Date" := PurchAdvanceLetterHeader."Posting Date";
                    PurchAdvLetterHeaderCZZ."Advance Due Date" := PurchAdvanceLetterHeader."Advance Due Date";
                    PurchAdvLetterHeaderCZZ."Document Date" := PurchAdvanceLetterHeader."Document Date";
                    PurchAdvLetterHeaderCZZ."VAT Date" := PurchAdvanceLetterHeader."VAT Date";
                    PurchAdvLetterHeaderCZZ."Posting Description" := PurchAdvanceLetterHeader."Posting Description";
                    PurchAdvLetterHeaderCZZ."Payment Method Code" := PurchAdvanceLetterHeader."Payment Method Code";
                    PurchAdvLetterHeaderCZZ."Payment Terms Code" := PurchAdvanceLetterHeader."Payment Terms Code";
                    PurchAdvLetterHeaderCZZ."Registration No." := PurchAdvanceLetterHeader."Registration No.";
                    PurchAdvLetterHeaderCZZ."Tax Registration No." := PurchAdvanceLetterHeader."Tax Registration No.";
                    PurchAdvLetterHeaderCZZ."VAT Registration No." := PurchAdvanceLetterHeader."VAT Registration No.";
                    PurchAdvLetterHeaderCZZ."No. Printed" := PurchAdvanceLetterHeader."No. Printed";
                    PurchAdvLetterHeaderCZZ."Order No." := PurchAdvanceLetterHeader."Order No.";
                    PurchAdvLetterHeaderCZZ."Vendor Adv. Letter No." := PurchAdvanceLetterHeader."Vendor Adv. Payment No.";
                    PurchAdvLetterHeaderCZZ."No. Series" := PurchAdvanceLetterHeader."No. Series";
                    PurchAdvLetterHeaderCZZ."Bank Account Code" := PurchAdvanceLetterHeader."Bank Account Code";
                    PurchAdvLetterHeaderCZZ."Bank Account No." := PurchAdvanceLetterHeader."Bank Account No.";
                    PurchAdvLetterHeaderCZZ."Bank Branch No." := PurchAdvanceLetterHeader."Bank Branch No.";
                    PurchAdvLetterHeaderCZZ."Specific Symbol" := PurchAdvanceLetterHeader."Specific Symbol";
                    PurchAdvLetterHeaderCZZ."Variable Symbol" := PurchAdvanceLetterHeader."Variable Symbol";
                    PurchAdvLetterHeaderCZZ."Constant Symbol" := PurchAdvanceLetterHeader."Constant Symbol";
                    PurchAdvLetterHeaderCZZ.IBAN := PurchAdvanceLetterHeader.IBAN;
                    PurchAdvLetterHeaderCZZ."SWIFT Code" := PurchAdvanceLetterHeader."SWIFT Code";
                    PurchAdvLetterHeaderCZZ."Bank Name" := PurchAdvanceLetterHeader."Bank Name";
                    PurchAdvLetterHeaderCZZ."Transit No." := PurchAdvanceLetterHeader."Transit No.";
                    PurchAdvLetterHeaderCZZ."Responsibility Center" := PurchAdvanceLetterHeader."Responsibility Center";
                    PurchAdvLetterHeaderCZZ."Currency Code" := PurchAdvanceLetterHeader."Currency Code";
                    PurchAdvLetterHeaderCZZ."Currency Factor" := PurchAdvanceLetterHeader."Currency Factor";
                    PurchAdvLetterHeaderCZZ."VAT Country/Region Code" := PurchAdvanceLetterHeader."VAT Country/Region Code";
                    PurchAdvanceLetterHeader.CalcFields(Status);
                    PurchAdvLetterHeaderCZZ.Status := GetStatus(PurchAdvanceLetterHeader.Status);
                    PurchAdvLetterHeaderCZZ."Automatic Post VAT Usage" := true;
                    PurchAdvLetterHeaderCZZ."Dimension Set ID" := PurchAdvanceLetterHeader."Dimension Set ID";
                    PurchAdvLetterHeaderCZZ."Incoming Document Entry No." := PurchAdvanceLetterHeader."Incoming Document Entry No.";
                    PurchAdvLetterHeaderCZZ.SystemId := PurchAdvanceLetterHeader.SystemId;
                    PurchAdvLetterHeaderCZZ.Insert(false, true);

                    PurchAdvanceLetterLine.SetRange("Letter No.", PurchAdvanceLetterHeader."No.");
                    if PurchAdvanceLetterLine.FindSet() then
                        repeat
                            PurchAdvLetterLineCZZ.Init();
                            PurchAdvLetterLineCZZ."Document No." := PurchAdvanceLetterLine."Letter No.";
                            PurchAdvLetterLineCZZ."Line No." := PurchAdvanceLetterLine."Line No.";
                            PurchAdvLetterLineCZZ.Description := PurchAdvanceLetterLine.Description;
                            PurchAdvLetterLineCZZ."VAT Bus. Posting Group" := PurchAdvanceLetterLine."VAT Bus. Posting Group";
                            PurchAdvLetterLineCZZ."VAT Prod. Posting Group" := PurchAdvanceLetterLine."VAT Prod. Posting Group";
                            PurchAdvLetterLineCZZ.Amount := PurchAdvanceLetterLine.Amount;
                            PurchAdvLetterLineCZZ."VAT Amount" := PurchAdvanceLetterLine."VAT Amount";
                            PurchAdvLetterLineCZZ."Amount Including VAT" := PurchAdvanceLetterLine."Amount Including VAT";
                            if (PurchAdvLetterHeaderCZZ."Currency Factor" = 0) or (PurchAdvLetterHeaderCZZ."Currency Code" = '') then begin
                                PurchAdvLetterLineCZZ."Amount (LCY)" := PurchAdvLetterLineCZZ.Amount;
                                PurchAdvLetterLineCZZ."VAT Amount (LCY)" := PurchAdvLetterLineCZZ."VAT Amount";
                                PurchAdvLetterLineCZZ."Amount Including VAT (LCY)" := PurchAdvLetterLineCZZ."Amount Including VAT";
                            end else begin
                                PurchAdvLetterLineCZZ."Amount Including VAT (LCY)" := Round(PurchAdvLetterLineCZZ."Amount Including VAT" / PurchAdvLetterHeaderCZZ."Currency Factor");
                                PurchAdvLetterLineCZZ."VAT Amount (LCY)" := Round(PurchAdvLetterLineCZZ."VAT Amount" / PurchAdvLetterHeaderCZZ."Currency Factor");
                                PurchAdvLetterLineCZZ."Amount (LCY)" := PurchAdvLetterLineCZZ."Amount Including VAT (LCY)" - PurchAdvLetterLineCZZ."VAT Amount (LCY)";
                            end;
                            PurchAdvLetterLineCZZ."VAT %" := PurchAdvanceLetterLine."VAT %";
                            PurchAdvLetterLineCZZ."VAT Calculation Type" := PurchAdvanceLetterLine."VAT Calculation Type";
                            if VATPostingSetup.Get(PurchAdvLetterLineCZZ."VAT Bus. Posting Group", PurchAdvLetterLineCZZ."VAT Prod. Posting Group") then
                                PurchAdvLetterLineCZZ."VAT Clause Code" := VATPostingSetup."VAT Clause Code";
                            PurchAdvLetterLineCZZ."VAT Calculation Type" := PurchAdvanceLetterLine."VAT Calculation Type";
                            PurchAdvLetterLineCZZ."VAT Identifier" := PurchAdvanceLetterLine."VAT Identifier";
                            PurchAdvLetterLineCZZ.SystemId := PurchAdvanceLetterLine.SystemId;
                            PurchAdvLetterLineCZZ.Insert(false, true);
                        until PurchAdvanceLetterLine.Next() = 0;

                    UpdatePurchEntry(PurchAdvLetterHeaderCZZ);
                    UpdatePurchAdvanceApplication(PurchAdvLetterHeaderCZZ);
                end;
            until PurchAdvanceLetterHeader.Next() = 0;
    end;

    local procedure UpdatePurchEntry(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    var
        AdvanceLink: Record "Advance Link";
        PurchAdvanceLetterEntry1: Record "Purch. Advance Letter Entry";
        PurchAdvanceLetterEntry2: Record "Purch. Advance Letter Entry";
        PurchAdvLetterEntryCZZ1: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        TempPurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ" temporary;
        VATEntry2: Record "VAT Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PurchAdvLetterManagementCZZ: Codeunit "PurchAdvLetterManagement CZZ";
        CurrFactor: Decimal;
        LastClosedDate: Date;
    begin
        if PurchAdvLetterHeaderCZZ.Status.AsInteger() = PurchAdvLetterHeaderCZZ.Status::New.AsInteger() then
            exit;

        PurchAdvLetterEntryCZZ1.LockTable();
        if PurchAdvLetterEntryCZZ1.FindLast() then;

        PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT", "Amount Including VAT (LCY)");
        PurchAdvLetterManagementCZZ.AdvEntryInit(false);
        PurchAdvLetterManagementCZZ.AdvEntryInsert("Advance Letter Entry Type CZZ"::"Initial Entry", PurchAdvLetterHeaderCZZ."No.", PurchAdvLetterHeaderCZZ."Posting Date",
            -PurchAdvLetterHeaderCZZ."Amount Including VAT", -PurchAdvLetterHeaderCZZ."Amount Including VAT (LCY)",
            PurchAdvLetterHeaderCZZ."Currency Code", PurchAdvLetterHeaderCZZ."Currency Factor", PurchAdvLetterHeaderCZZ."No.", '',
            PurchAdvLetterHeaderCZZ."Shortcut Dimension 1 Code", PurchAdvLetterHeaderCZZ."Shortcut Dimension 2 Code", PurchAdvLetterHeaderCZZ."Dimension Set ID", false);

        LastClosedDate := 0D;
        AdvanceLink.Reset();
        AdvanceLink.SetRange(Type, AdvanceLink.Type::Purchase);
        AdvanceLink.SetRange("Document No.", PurchAdvLetterHeaderCZZ."No.");
        AdvanceLink.SetRange("Entry Type", AdvanceLink."Entry Type"::"Link To Letter");
        if AdvanceLink.FindSet(true) then
            repeat
                PurchAdvLetterManagementCZZ.AdvEntryInit(false);
                PurchAdvLetterManagementCZZ.AdvEntryInitVendLedgEntryNo(AdvanceLink."CV Ledger Entry No.");
                if not VendorLedgerEntry.Get(AdvanceLink."CV Ledger Entry No.") then
                    VendorLedgerEntry.Init();
                if LastClosedDate < VendorLedgerEntry."Closed at Date" then
                    LastClosedDate := VendorLedgerEntry."Closed at Date";
                PurchAdvLetterManagementCZZ.AdvEntryInsert("Advance Letter Entry Type CZZ"::Payment, PurchAdvLetterHeaderCZZ."No.", VendorLedgerEntry."Posting Date",
                    -AdvanceLink.Amount, -AdvanceLink."Amount (LCY)",
                    PurchAdvLetterHeaderCZZ."Currency Code", VendorLedgerEntry."Original Currency Factor", VendorLedgerEntry."Document No.", VendorLedgerEntry."External Document No.",
                    VendorLedgerEntry."Global Dimension 1 Code", VendorLedgerEntry."Global Dimension 2 Code", VendorLedgerEntry."Dimension Set ID", false);

                PurchAdvLetterEntryCZZ1.FindLast();

                PurchAdvanceLetterEntry1.Reset();
                PurchAdvanceLetterEntry1.SetRange("Letter No.", PurchAdvLetterHeaderCZZ."No.");
                PurchAdvanceLetterEntry1.SetRange("Letter Line No.", AdvanceLink."Line No.");
                PurchAdvanceLetterEntry1.SetRange("Vendor Entry No.", AdvanceLink."CV Ledger Entry No.");
                PurchAdvanceLetterEntry1.SetRange("Entry Type", PurchAdvanceLetterEntry1."Entry Type"::VAT);
                if PurchAdvanceLetterEntry1.FindSet() then
                    repeat
                        VATEntry2.Get(PurchAdvanceLetterEntry1."VAT Entry No.");
                        PurchAdvLetterManagementCZZ.AdvEntryInit(false);
                        if PurchAdvanceLetterEntry1.Cancelled then
                            PurchAdvLetterManagementCZZ.AdvEntryInitCancel();
                        PurchAdvLetterManagementCZZ.AdvEntryInitRelatedEntry(PurchAdvLetterEntryCZZ1."Entry No.");
                        PurchAdvLetterManagementCZZ.AdvEntryInitVAT(PurchAdvanceLetterEntry1."VAT Bus. Posting Group", PurchAdvanceLetterEntry1."VAT Prod. Posting Group", PurchAdvanceLetterEntry1."VAT Date",
                            PurchAdvanceLetterEntry1."VAT Date", PurchAdvanceLetterEntry1."VAT Entry No.", PurchAdvanceLetterEntry1."VAT %", PurchAdvanceLetterEntry1."VAT Identifier", "TAX Calculation Type"::"Normal VAT",
                            PurchAdvanceLetterEntry1."VAT Amount", PurchAdvanceLetterEntry1."VAT Amount (LCY)", PurchAdvanceLetterEntry1."VAT Base Amount", PurchAdvanceLetterEntry1."VAT Base Amount (LCY)");
                        PurchAdvLetterManagementCZZ.AdvEntryInsert("Advance Letter Entry Type CZZ"::"VAT Payment", PurchAdvLetterHeaderCZZ."No.", PurchAdvanceLetterEntry1."Posting Date",
                            PurchAdvanceLetterEntry1."VAT Base Amount" + PurchAdvanceLetterEntry1."VAT Amount", PurchAdvanceLetterEntry1."VAT Base Amount (LCY)" + PurchAdvanceLetterEntry1."VAT Amount (LCY)",
                            PurchAdvLetterEntryCZZ1."Currency Code", PurchAdvLetterEntryCZZ1."Currency Factor", PurchAdvanceLetterEntry1."Document No.", VATEntry2."External Document No.",
                            PurchAdvLetterEntryCZZ1."Global Dimension 1 Code", PurchAdvLetterEntryCZZ1."Global Dimension 2 Code", PurchAdvLetterEntryCZZ1."Dimension Set ID", false);
                    until PurchAdvanceLetterEntry1.Next() = 0;

                PurchAdvanceLetterEntry1.SetRange("Entry Type", PurchAdvanceLetterEntry1."Entry Type"::Deduction);
                if PurchAdvanceLetterEntry1.FindSet() then
                    repeat
                        if not VendorLedgerEntry.Get(PurchAdvanceLetterEntry1."Vendor Entry No.") then
                            VendorLedgerEntry.Init();
                        CurrFactor := VendorLedgerEntry."Original Currency Factor";
                        if CurrFactor = 0 then
                            CurrFactor := 1;
                        PurchAdvLetterManagementCZZ.AdvEntryInit(false);
                        if PurchAdvanceLetterEntry1.Cancelled then
                            PurchAdvLetterManagementCZZ.AdvEntryInitCancel();
                        PurchAdvLetterManagementCZZ.AdvEntryInitVendLedgEntryNo(PurchAdvanceLetterEntry1."Vendor Entry No.");
                        PurchAdvLetterManagementCZZ.AdvEntryInitRelatedEntry(PurchAdvLetterEntryCZZ1."Entry No.");
                        PurchAdvLetterManagementCZZ.AdvEntryInsert("Advance Letter Entry Type CZZ"::Usage, PurchAdvLetterHeaderCZZ."No.", PurchAdvanceLetterEntry1."Posting Date",
                            PurchAdvanceLetterEntry1.Amount, Round(PurchAdvanceLetterEntry1.Amount / CurrFactor),
                            PurchAdvanceLetterEntry1."Currency Code", VendorLedgerEntry."Original Currency Factor", PurchAdvanceLetterEntry1."Document No.", VendorLedgerEntry."External Document No.",
                            VendorLedgerEntry."Global Dimension 1 Code", VendorLedgerEntry."Global Dimension 2 Code", VendorLedgerEntry."Dimension Set ID", false);

                        PurchAdvLetterEntryCZZ2.FindLast();

                        PurchAdvanceLetterEntry2.Reset();
                        PurchAdvanceLetterEntry2.SetRange("Letter No.", PurchAdvanceLetterEntry1."Letter No.");
                        PurchAdvanceLetterEntry2.SetRange("Letter Line No.", PurchAdvanceLetterEntry1."Letter Line No.");
                        PurchAdvanceLetterEntry2.SetRange("Entry Type", PurchAdvanceLetterEntry2."Entry Type"::"VAT Deduction");
                        PurchAdvanceLetterEntry2.SetRange("Document Type", PurchAdvanceLetterEntry1."Document Type");
                        PurchAdvanceLetterEntry2.SetRange("Document No.", PurchAdvanceLetterEntry1."Document No.");
                        PurchAdvanceLetterEntry2.SetRange("Purchase Line No.", PurchAdvanceLetterEntry1."Purchase Line No.");
                        PurchAdvanceLetterEntry2.SetRange("Deduction Line No.", PurchAdvanceLetterEntry1."Deduction Line No.");
                        PurchAdvanceLetterEntry2.SetRange("Vendor Entry No.", PurchAdvanceLetterEntry1."Vendor Entry No.");
                        if PurchAdvanceLetterEntry2.FindSet() then
                            repeat
                                VATEntry2.Get(PurchAdvanceLetterEntry2."VAT Entry No.");
                                PurchAdvLetterManagementCZZ.AdvEntryInit(false);
                                if PurchAdvanceLetterEntry2.Cancelled then
                                    PurchAdvLetterManagementCZZ.AdvEntryInitCancel();
                                PurchAdvLetterManagementCZZ.AdvEntryInitRelatedEntry(PurchAdvLetterEntryCZZ2."Entry No.");
                                PurchAdvLetterManagementCZZ.AdvEntryInitVAT(PurchAdvanceLetterEntry2."VAT Bus. Posting Group", PurchAdvanceLetterEntry2."VAT Prod. Posting Group", PurchAdvanceLetterEntry2."VAT Date",
                                    PurchAdvanceLetterEntry2."VAT Date", PurchAdvanceLetterEntry2."VAT Entry No.", PurchAdvanceLetterEntry2."VAT %", PurchAdvanceLetterEntry2."VAT Identifier", "TAX Calculation Type"::"Normal VAT",
                                    PurchAdvanceLetterEntry2."VAT Amount", PurchAdvanceLetterEntry2."VAT Amount (LCY)", PurchAdvanceLetterEntry2."VAT Base Amount", PurchAdvanceLetterEntry2."VAT Base Amount (LCY)");
                                PurchAdvLetterManagementCZZ.AdvEntryInsert("Advance Letter Entry Type CZZ"::"VAT Usage", PurchAdvLetterHeaderCZZ."No.", PurchAdvanceLetterEntry2."Posting Date",
                                    PurchAdvanceLetterEntry2."VAT Base Amount" + PurchAdvanceLetterEntry2."VAT Amount", PurchAdvanceLetterEntry2."VAT Base Amount (LCY)" + PurchAdvanceLetterEntry2."VAT Amount (LCY)",
                                    PurchAdvanceLetterEntry2."Currency Code", VendorLedgerEntry."Original Currency Factor", PurchAdvanceLetterEntry2."Document No.", VATEntry2."External Document No.",
                                    VendorLedgerEntry."Global Dimension 1 Code", VendorLedgerEntry."Global Dimension 2 Code", VendorLedgerEntry."Dimension Set ID", false);
                            until PurchAdvanceLetterEntry2.Next() = 0;

                        PurchAdvanceLetterEntry2.SetRange("Entry Type", PurchAdvanceLetterEntry2."Entry Type"::"VAT Rate");
                        if PurchAdvanceLetterEntry2.FindSet() then
                            repeat
                                PurchAdvLetterManagementCZZ.AdvEntryInit(false);
                                if PurchAdvanceLetterEntry2.Cancelled then
                                    PurchAdvLetterManagementCZZ.AdvEntryInitCancel();
                                PurchAdvLetterManagementCZZ.AdvEntryInitRelatedEntry(PurchAdvLetterEntryCZZ2."Entry No.");
                                PurchAdvLetterManagementCZZ.AdvEntryInitVAT(PurchAdvanceLetterEntry2."VAT Bus. Posting Group", PurchAdvanceLetterEntry2."VAT Prod. Posting Group", PurchAdvanceLetterEntry2."VAT Date",
                                    PurchAdvanceLetterEntry2."VAT Date", 0, PurchAdvanceLetterEntry2."VAT %", PurchAdvanceLetterEntry2."VAT Identifier", "TAX Calculation Type"::"Normal VAT",
                                    0, PurchAdvanceLetterEntry2."VAT Amount (LCY)", 0, PurchAdvanceLetterEntry2."VAT Base Amount (LCY)");
                                PurchAdvLetterManagementCZZ.AdvEntryInsert("Advance Letter Entry Type CZZ"::"VAT Rate", PurchAdvLetterHeaderCZZ."No.", PurchAdvanceLetterEntry2."Posting Date",
                                    0, PurchAdvanceLetterEntry2."VAT Base Amount (LCY)" + PurchAdvanceLetterEntry2."VAT Amount (LCY)", '', 0, PurchAdvanceLetterEntry2."Document No.", VendorLedgerEntry."External Document No.",
                                    VendorLedgerEntry."Global Dimension 1 Code", VendorLedgerEntry."Global Dimension 2 Code", VendorLedgerEntry."Dimension Set ID", false);
                            until PurchAdvanceLetterEntry2.Next() = 0;
                    until PurchAdvanceLetterEntry1.Next() = 0;

                AdvanceLink.Amount := 0;
                AdvanceLink."Amount (LCY)" := 0;
                AdvanceLink.Modify(false);
            until AdvanceLink.Next() = 0;

        if PurchAdvLetterHeaderCZZ.Status = PurchAdvLetterHeaderCZZ.Status::Closed then begin
            if LastClosedDate = 0D then
                LastClosedDate := PurchAdvLetterHeaderCZZ."Posting Date";
            PurchAdvLetterHeaderCZZ.CalcFields("To Use", "To Use (LCY)");
            if (PurchAdvLetterHeaderCZZ."To Use" <> 0) or (PurchAdvLetterHeaderCZZ."To Use (LCY)" <> 0) then begin
                PurchAdvanceLetterEntry1.Reset();
                PurchAdvanceLetterEntry1.SetRange("Letter No.", PurchAdvLetterHeaderCZZ."No.");
                PurchAdvanceLetterEntry1.SetRange("Entry Type", PurchAdvanceLetterEntry1."Entry Type"::VAT);
                PurchAdvanceLetterEntry1.SetRange("Document Type", PurchAdvanceLetterEntry1."Document Type"::"Credit Memo");
                if not PurchAdvanceLetterEntry1.FindLast() then
                    PurchAdvanceLetterEntry1."Document No." := PurchAdvLetterHeaderCZZ."No.";

                PurchAdvLetterManagementCZZ.AdvEntryInit(false);
                PurchAdvLetterManagementCZZ.AdvEntryInsert("Advance Letter Entry Type CZZ"::Close, PurchAdvLetterHeaderCZZ."No.", LastClosedDate,
                    -PurchAdvLetterHeaderCZZ."To Use", -PurchAdvLetterHeaderCZZ."To Use (LCY)",
                    PurchAdvLetterHeaderCZZ."Currency Code", PurchAdvLetterHeaderCZZ."Currency Factor", PurchAdvanceLetterEntry1."Document No.", '',
                    PurchAdvLetterHeaderCZZ."Shortcut Dimension 1 Code", PurchAdvLetterHeaderCZZ."Shortcut Dimension 2 Code", PurchAdvLetterHeaderCZZ."Dimension Set ID", false);

                PurchAdvLetterEntryCZZ1.Reset();
                PurchAdvLetterEntryCZZ1.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
                PurchAdvLetterEntryCZZ1.SetFilter("Entry Type", '%1|%2|%3',
                    PurchAdvLetterEntryCZZ1."Entry Type"::"VAT Payment",
                    PurchAdvLetterEntryCZZ1."Entry Type"::"VAT Usage",
                    PurchAdvLetterEntryCZZ1."Entry Type"::"VAT Rate");
                if PurchAdvLetterEntryCZZ1.FindSet() then
                    repeat
                        TempPurchAdvLetterEntryCZZ.SetRange("VAT Bus. Posting Group", PurchAdvLetterEntryCZZ1."VAT Bus. Posting Group");
                        TempPurchAdvLetterEntryCZZ.SetRange("VAT Prod. Posting Group", PurchAdvLetterEntryCZZ1."VAT Prod. Posting Group");
                        if not TempPurchAdvLetterEntryCZZ.FindFirst() then begin
                            TempPurchAdvLetterEntryCZZ.Init();
                            TempPurchAdvLetterEntryCZZ := PurchAdvLetterEntryCZZ1;
                            TempPurchAdvLetterEntryCZZ.Insert();
                        end else begin
                            TempPurchAdvLetterEntryCZZ.Amount += PurchAdvLetterEntryCZZ1.Amount;
                            TempPurchAdvLetterEntryCZZ."Amount (LCY)" += PurchAdvLetterEntryCZZ1."Amount (LCY)";
                            TempPurchAdvLetterEntryCZZ."VAT Amount" += PurchAdvLetterEntryCZZ1."VAT Amount";
                            TempPurchAdvLetterEntryCZZ."VAT Amount (LCY)" += PurchAdvLetterEntryCZZ1."VAT Amount (LCY)";
                            TempPurchAdvLetterEntryCZZ."VAT Base Amount" += PurchAdvLetterEntryCZZ1."VAT Base Amount";
                            TempPurchAdvLetterEntryCZZ."VAT Base Amount (LCY)" += PurchAdvLetterEntryCZZ1."VAT Base Amount (LCY)";
                            TempPurchAdvLetterEntryCZZ.Modify();
                        end;
                    until PurchAdvLetterEntryCZZ1.Next() = 0;

                TempPurchAdvLetterEntryCZZ.Reset();
                if TempPurchAdvLetterEntryCZZ.FindSet() then
                    repeat
                        if (TempPurchAdvLetterEntryCZZ.Amount <> 0) or (TempPurchAdvLetterEntryCZZ."Amount (LCY)" <> 0) or
                           (TempPurchAdvLetterEntryCZZ."VAT Amount" <> 0) or (TempPurchAdvLetterEntryCZZ."VAT Amount (LCY)" <> 0) or
                           (TempPurchAdvLetterEntryCZZ."VAT Base Amount" <> 0) or (TempPurchAdvLetterEntryCZZ."VAT Base Amount (LCY)" <> 0)
                        then begin
                            PurchAdvLetterManagementCZZ.AdvEntryInit(false);
                            PurchAdvLetterManagementCZZ.AdvEntryInitVAT(
                                TempPurchAdvLetterEntryCZZ."VAT Bus. Posting Group", TempPurchAdvLetterEntryCZZ."VAT Prod. Posting Group",
                                LastClosedDate, LastClosedDate, 0, TempPurchAdvLetterEntryCZZ."VAT %", TempPurchAdvLetterEntryCZZ."VAT Identifier", TempPurchAdvLetterEntryCZZ."VAT Calculation Type",
                                -TempPurchAdvLetterEntryCZZ."VAT Amount", -TempPurchAdvLetterEntryCZZ."VAT Amount (LCY)",
                                -TempPurchAdvLetterEntryCZZ."VAT Base Amount", -TempPurchAdvLetterEntryCZZ."VAT Base Amount (LCY)");
                            PurchAdvLetterManagementCZZ.AdvEntryInsert("Advance Letter Entry Type CZZ"::"VAT Close", PurchAdvLetterHeaderCZZ."No.", LastClosedDate,
                                -TempPurchAdvLetterEntryCZZ.Amount, -TempPurchAdvLetterEntryCZZ."Amount (LCY)",
                                PurchAdvLetterHeaderCZZ."Currency Code", PurchAdvLetterHeaderCZZ."Currency Factor", PurchAdvanceLetterEntry1."Document No.", '',
                                PurchAdvLetterHeaderCZZ."Shortcut Dimension 1 Code", PurchAdvLetterHeaderCZZ."Shortcut Dimension 2 Code", PurchAdvLetterHeaderCZZ."Dimension Set ID", false);
                        end;
                    until TempPurchAdvLetterEntryCZZ.Next() = 0;
                PurchAdvLetterManagementCZZ.CancelInitEntry(PurchAdvLetterHeaderCZZ, LastClosedDate, false);
            end;
        end;
    end;

    local procedure UpdatePurchAdvanceApplication(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    var
        AdvanceLetterLineRelation: Record "Advance Letter Line Relation";
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        PurchaseHeader: Record "Purchase Header";
        AmtToDeduct: Decimal;
        Continue: Boolean;
    begin
        if PurchAdvLetterHeaderCZZ.Status = PurchAdvLetterHeaderCZZ.Status::Closed then
            exit;

        AdvanceLetterLineRelation.SetRange(Type, AdvanceLetterLineRelation.Type::Purchase);
        AdvanceLetterLineRelation.SetRange("Letter No.", PurchAdvLetterHeaderCZZ."No.");
        if AdvanceLetterLineRelation.FindSet() then begin
            repeat
                case AdvanceLetterLineRelation."Document Type" of
                    AdvanceLetterLineRelation."Document Type"::Order:
                        Continue := PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, AdvanceLetterLineRelation."Document No.");
                    AdvanceLetterLineRelation."Document Type"::Invoice:
                        Continue := PurchaseHeader.Get(PurchaseHeader."Document Type"::Invoice, AdvanceLetterLineRelation."Document No.");
                    else
                        Continue := false;
                end;
                if Continue then begin
                    AdvanceLetterApplicationCZZ.Init();
                    AdvanceLetterApplicationCZZ."Advance Letter Type" := AdvanceLetterApplicationCZZ."Advance Letter Type"::Purchase;
                    AdvanceLetterApplicationCZZ."Advance Letter No." := AdvanceLetterLineRelation."Letter No.";
                    case AdvanceLetterLineRelation."Document Type" of
                        AdvanceLetterLineRelation."Document Type"::Invoice:
                            AdvanceLetterApplicationCZZ."Document Type" := AdvanceLetterApplicationCZZ."Document Type"::"Purchase Invoice";
                        AdvanceLetterLineRelation."Document Type"::Order:
                            AdvanceLetterApplicationCZZ."Document Type" := AdvanceLetterApplicationCZZ."Document Type"::"Purchase Order";
                    end;
                    AdvanceLetterApplicationCZZ."Document No." := AdvanceLetterLineRelation."Document No.";
                    if AdvanceLetterLineRelation."Primary Link" then
                        AmtToDeduct := AdvanceLetterLineRelation.Amount
                    else
                        AmtToDeduct := AdvanceLetterLineRelation."Amount To Deduct";

                    if AdvanceLetterApplicationCZZ.Find() then begin
                        AdvanceLetterApplicationCZZ.Amount += AmtToDeduct;
                        AdvanceLetterApplicationCZZ.Modify();
                    end else begin
                        AdvanceLetterApplicationCZZ.Amount := AmtToDeduct;
                        AdvanceLetterApplicationCZZ.Insert();
                    end;
                end;
            until AdvanceLetterLineRelation.Next() = 0;

            AdvanceLetterLineRelation.DeleteAll();
        end;
    end;

    local procedure CopySalesAdvances()
    var
        SalesAdvanceLetterHeader: Record "Sales Advance Letter Header";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvanceLetterLine: Record "Sales Advance Letter Line";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
    begin
        if SalesAdvanceLetterHeader.FindSet() then
            repeat
                if not SalesAdvLetterHeaderCZZ.Get(SalesAdvanceLetterHeader."No.") then begin
                    SalesAdvLetterHeaderCZZ.Init();
                    SalesAdvLetterHeaderCZZ."No." := SalesAdvanceLetterHeader."No.";
                    if SalesAdvanceLetterHeader."Template Code" <> '' then
                        SalesAdvLetterHeaderCZZ."Advance Letter Code" := 'P_' + SalesAdvanceLetterHeader."Template Code";
                    SalesAdvLetterHeaderCZZ."Bill-to Customer No." := SalesAdvanceLetterHeader."Bill-to Customer No.";
                    SalesAdvLetterHeaderCZZ."Bill-to Name" := SalesAdvanceLetterHeader."Bill-to Name";
                    SalesAdvLetterHeaderCZZ."Bill-to Name 2" := SalesAdvanceLetterHeader."Bill-to Name 2";
                    SalesAdvLetterHeaderCZZ."Bill-to Address" := SalesAdvanceLetterHeader."Bill-to Address";
                    SalesAdvLetterHeaderCZZ."Bill-to Address 2" := SalesAdvanceLetterHeader."Bill-to Address 2";
                    SalesAdvLetterHeaderCZZ."Bill-to City" := SalesAdvanceLetterHeader."Bill-to City";
                    SalesAdvLetterHeaderCZZ."Bill-to Post Code" := SalesAdvanceLetterHeader."Bill-to Post Code";
                    SalesAdvLetterHeaderCZZ."Bill-to County" := SalesAdvanceLetterHeader."Bill-to County";
                    SalesAdvLetterHeaderCZZ."Bill-to Country/Region Code" := SalesAdvanceLetterHeader."Bill-to Country/Region Code";
                    SalesAdvLetterHeaderCZZ."Language Code" := SalesAdvanceLetterHeader."Language Code";
                    SalesAdvLetterHeaderCZZ."Format Region" := SalesAdvanceLetterHeader."Format Region";
                    SalesAdvLetterHeaderCZZ."Bill-to Contact" := SalesAdvanceLetterHeader."Bill-to Contact";
                    SalesAdvLetterHeaderCZZ."Salesperson Code" := SalesAdvanceLetterHeader."Salesperson Code";
                    SalesAdvLetterHeaderCZZ."Shortcut Dimension 1 Code" := SalesAdvanceLetterHeader."Shortcut Dimension 1 Code";
                    SalesAdvLetterHeaderCZZ."Shortcut Dimension 2 Code" := SalesAdvanceLetterHeader."Shortcut Dimension 2 Code";
                    SalesAdvLetterHeaderCZZ."VAT Bus. Posting Group" := SalesAdvanceLetterHeader."VAT Bus. Posting Group";
                    SalesAdvLetterHeaderCZZ."Posting Date" := SalesAdvanceLetterHeader."Posting Date";
                    SalesAdvLetterHeaderCZZ."Advance Due Date" := SalesAdvanceLetterHeader."Advance Due Date";
                    SalesAdvLetterHeaderCZZ."Document Date" := SalesAdvanceLetterHeader."Document Date";
                    SalesAdvLetterHeaderCZZ."VAT Date" := SalesAdvanceLetterHeader."VAT Date";
                    SalesAdvLetterHeaderCZZ."Posting Description" := SalesAdvanceLetterHeader."Posting Description";
                    SalesAdvLetterHeaderCZZ."Payment Method Code" := SalesAdvanceLetterHeader."Payment Method Code";
                    SalesAdvLetterHeaderCZZ."Payment Terms Code" := SalesAdvanceLetterHeader."Payment Terms Code";
                    SalesAdvLetterHeaderCZZ."Registration No." := SalesAdvanceLetterHeader."Registration No.";
                    SalesAdvLetterHeaderCZZ."Tax Registration No." := SalesAdvanceLetterHeader."Tax Registration No.";
                    SalesAdvLetterHeaderCZZ."VAT Registration No." := SalesAdvanceLetterHeader."VAT Registration No.";
                    SalesAdvLetterHeaderCZZ."No. Printed" := SalesAdvanceLetterHeader."No. Printed";
                    SalesAdvLetterHeaderCZZ."Order No." := SalesAdvanceLetterHeader."Order No.";
                    SalesAdvLetterHeaderCZZ."No. Series" := SalesAdvanceLetterHeader."No. Series";
                    SalesAdvLetterHeaderCZZ."Bank Account Code" := SalesAdvanceLetterHeader."Bank Account Code";
                    SalesAdvLetterHeaderCZZ."Bank Account No." := SalesAdvanceLetterHeader."Bank Account No.";
                    SalesAdvLetterHeaderCZZ."Bank Branch No." := SalesAdvanceLetterHeader."Bank Branch No.";
                    SalesAdvLetterHeaderCZZ."Specific Symbol" := SalesAdvanceLetterHeader."Specific Symbol";
                    SalesAdvLetterHeaderCZZ."Variable Symbol" := SalesAdvanceLetterHeader."Variable Symbol";
                    SalesAdvLetterHeaderCZZ."Constant Symbol" := SalesAdvanceLetterHeader."Constant Symbol";
                    SalesAdvLetterHeaderCZZ.IBAN := SalesAdvanceLetterHeader.IBAN;
                    SalesAdvLetterHeaderCZZ."SWIFT Code" := SalesAdvanceLetterHeader."SWIFT Code";
                    SalesAdvLetterHeaderCZZ."Bank Name" := SalesAdvanceLetterHeader."Bank Name";
                    SalesAdvLetterHeaderCZZ."Transit No." := SalesAdvanceLetterHeader."Transit No.";
                    SalesAdvLetterHeaderCZZ."Responsibility Center" := SalesAdvanceLetterHeader."Responsibility Center";
                    SalesAdvLetterHeaderCZZ."Currency Code" := SalesAdvanceLetterHeader."Currency Code";
                    SalesAdvLetterHeaderCZZ."Currency Factor" := SalesAdvanceLetterHeader."Currency Factor";
                    SalesAdvLetterHeaderCZZ."VAT Country/Region Code" := SalesAdvanceLetterHeader."VAT Country/Region Code";
                    SalesAdvanceLetterHeader.CalcFields(Status);
                    SalesAdvLetterHeaderCZZ.Status := GetStatus(SalesAdvanceLetterHeader.Status);
                    SalesAdvLetterHeaderCZZ."Automatic Post VAT Document" := true;
                    SalesAdvLetterHeaderCZZ."Dimension Set ID" := SalesAdvanceLetterHeader."Dimension Set ID";
                    SalesAdvLetterHeaderCZZ."Incoming Document Entry No." := SalesAdvanceLetterHeader."Incoming Document Entry No.";
                    SalesAdvLetterHeaderCZZ.SystemId := SalesAdvanceLetterHeader.SystemId;
                    SalesAdvLetterHeaderCZZ.Insert(false, true);

                    SalesAdvanceLetterLine.SetRange("Letter No.", SalesAdvanceLetterHeader."No.");
                    if SalesAdvanceLetterLine.FindSet() then
                        repeat
                            SalesAdvLetterLineCZZ.Init();
                            SalesAdvLetterLineCZZ."Document No." := SalesAdvanceLetterLine."Letter No.";
                            SalesAdvLetterLineCZZ."Line No." := SalesAdvanceLetterLine."Line No.";
                            SalesAdvLetterLineCZZ.Description := SalesAdvanceLetterLine.Description;
                            SalesAdvLetterLineCZZ."VAT Bus. Posting Group" := SalesAdvanceLetterLine."VAT Bus. Posting Group";
                            SalesAdvLetterLineCZZ."VAT Prod. Posting Group" := SalesAdvanceLetterLine."VAT Prod. Posting Group";
                            SalesAdvLetterLineCZZ.Amount := SalesAdvanceLetterLine.Amount;
                            SalesAdvLetterLineCZZ."VAT Amount" := SalesAdvanceLetterLine."VAT Amount";
                            SalesAdvLetterLineCZZ."Amount Including VAT" := SalesAdvanceLetterLine."Amount Including VAT";
                            if (SalesAdvLetterHeaderCZZ."Currency Factor" = 0) or (SalesAdvLetterHeaderCZZ."Currency Code" = '') then begin
                                SalesAdvLetterLineCZZ."Amount (LCY)" := SalesAdvLetterLineCZZ.Amount;
                                SalesAdvLetterLineCZZ."VAT Amount (LCY)" := SalesAdvLetterLineCZZ."VAT Amount";
                                SalesAdvLetterLineCZZ."Amount Including VAT (LCY)" := SalesAdvLetterLineCZZ."Amount Including VAT";
                            end else begin
                                SalesAdvLetterLineCZZ."Amount Including VAT (LCY)" := Round(SalesAdvLetterLineCZZ."Amount Including VAT" / SalesAdvLetterHeaderCZZ."Currency Factor");
                                SalesAdvLetterLineCZZ."VAT Amount (LCY)" := Round(SalesAdvLetterLineCZZ."VAT Amount" / SalesAdvLetterHeaderCZZ."Currency Factor");
                                SalesAdvLetterLineCZZ."Amount (LCY)" := SalesAdvLetterLineCZZ."Amount Including VAT (LCY)" - SalesAdvLetterLineCZZ."VAT Amount (LCY)";
                            end;
                            SalesAdvLetterLineCZZ."VAT %" := SalesAdvanceLetterLine."VAT %";
                            SalesAdvLetterLineCZZ."VAT Calculation Type" := SalesAdvanceLetterLine."VAT Calculation Type";
                            if VATPostingSetup.Get(SalesAdvLetterLineCZZ."VAT Bus. Posting Group", SalesAdvLetterLineCZZ."VAT Prod. Posting Group") then
                                SalesAdvLetterLineCZZ."VAT Clause Code" := VATPostingSetup."VAT Clause Code";
                            SalesAdvLetterLineCZZ."VAT Calculation Type" := SalesAdvanceLetterLine."VAT Calculation Type";
                            SalesAdvLetterLineCZZ."VAT Identifier" := SalesAdvanceLetterLine."VAT Identifier";
                            SalesAdvLetterLineCZZ.SystemId := SalesAdvanceLetterLine.SystemId;
                            SalesAdvLetterLineCZZ.Insert(false, true);
                        until SalesAdvanceLetterLine.Next() = 0;

                    UpdateSalesEntry(SalesAdvLetterHeaderCZZ);
                    UpdateSalesAdvanceApplication(SalesAdvLetterHeaderCZZ);
                end;
            until SalesAdvanceLetterHeader.Next() = 0;
    end;

    local procedure UpdateSalesEntry(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    var
        AdvanceLink: Record "Advance Link";
        SalesAdvanceLetterEntry1: Record "Sales Advance Letter Entry";
        SalesAdvanceLetterEntry2: Record "Sales Advance Letter Entry";
        SalesAdvLetterEntryCZZ1: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterEntryCZZ2: Record "Sales Adv. Letter Entry CZZ";
        TempSalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ" temporary;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SalesAdvLetterManagementCZZ: Codeunit "SalesAdvLetterManagement CZZ";
        CurrFactor: Decimal;
        LastClosedDate: Date;
    begin
        if SalesAdvLetterHeaderCZZ.Status.AsInteger() = SalesAdvLetterHeaderCZZ.Status::New.AsInteger() then
            exit;

        SalesAdvLetterEntryCZZ1.LockTable();
        if SalesAdvLetterEntryCZZ1.FindLast() then;

        SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT", "Amount Including VAT (LCY)");
        SalesAdvLetterManagementCZZ.AdvEntryInit(false);
        SalesAdvLetterManagementCZZ.AdvEntryInsert("Advance Letter Entry Type CZZ"::"Initial Entry", SalesAdvLetterHeaderCZZ."No.", SalesAdvLetterHeaderCZZ."Posting Date",
            SalesAdvLetterHeaderCZZ."Amount Including VAT", SalesAdvLetterHeaderCZZ."Amount Including VAT (LCY)",
            SalesAdvLetterHeaderCZZ."Currency Code", SalesAdvLetterHeaderCZZ."Currency Factor", SalesAdvLetterHeaderCZZ."No.",
            SalesAdvLetterHeaderCZZ."Shortcut Dimension 1 Code", SalesAdvLetterHeaderCZZ."Shortcut Dimension 2 Code", SalesAdvLetterHeaderCZZ."Dimension Set ID", false);

        LastClosedDate := 0D;
        AdvanceLink.Reset();
        AdvanceLink.SetRange(Type, AdvanceLink.Type::Sale);
        AdvanceLink.SetRange("Document No.", SalesAdvLetterHeaderCZZ."No.");
        AdvanceLink.SetRange("Entry Type", AdvanceLink."Entry Type"::"Link To Letter");
        if AdvanceLink.FindSet(true) then
            repeat
                SalesAdvLetterManagementCZZ.AdvEntryInit(false);
                SalesAdvLetterManagementCZZ.AdvEntryInitCustLedgEntryNo(AdvanceLink."CV Ledger Entry No.");
                if not CustLedgerEntry.Get(AdvanceLink."CV Ledger Entry No.") then
                    CustLedgerEntry.Init();
                if LastClosedDate < CustLedgerEntry."Closed at Date" then
                    LastClosedDate := CustLedgerEntry."Closed at Date";
                SalesAdvLetterManagementCZZ.AdvEntryInsert("Advance Letter Entry Type CZZ"::Payment, SalesAdvLetterHeaderCZZ."No.", CustLedgerEntry."Posting Date",
                    -AdvanceLink.Amount, -AdvanceLink."Amount (LCY)",
                    SalesAdvLetterHeaderCZZ."Currency Code", CustLedgerEntry."Original Currency Factor", CustLedgerEntry."Document No.",
                    CustLedgerEntry."Global Dimension 1 Code", CustLedgerEntry."Global Dimension 2 Code", CustLedgerEntry."Dimension Set ID", false);

                SalesAdvLetterEntryCZZ1.FindLast();

                SalesAdvanceLetterEntry1.Reset();
                SalesAdvanceLetterEntry1.SetRange("Letter No.", SalesAdvLetterHeaderCZZ."No.");
                SalesAdvanceLetterEntry1.SetRange("Letter Line No.", AdvanceLink."Line No.");
                SalesAdvanceLetterEntry1.SetRange("Customer Entry No.", AdvanceLink."CV Ledger Entry No.");
                SalesAdvanceLetterEntry1.SetRange("Entry Type", SalesAdvanceLetterEntry1."Entry Type"::VAT);
                if SalesAdvanceLetterEntry1.FindSet() then
                    repeat
                        SalesAdvLetterManagementCZZ.AdvEntryInit(false);
                        if SalesAdvanceLetterEntry1.Cancelled then
                            SalesAdvLetterManagementCZZ.AdvEntryInitCancel();
                        SalesAdvLetterManagementCZZ.AdvEntryInitRelatedEntry(SalesAdvLetterEntryCZZ1."Entry No.");
                        SalesAdvLetterManagementCZZ.AdvEntryInitVAT(SalesAdvanceLetterEntry1."VAT Bus. Posting Group", SalesAdvanceLetterEntry1."VAT Prod. Posting Group", SalesAdvanceLetterEntry1."VAT Date",
                            SalesAdvanceLetterEntry1."VAT Entry No.", SalesAdvanceLetterEntry1."VAT %", SalesAdvanceLetterEntry1."VAT Identifier", "TAX Calculation Type"::"Normal VAT",
                            SalesAdvanceLetterEntry1."VAT Amount", SalesAdvanceLetterEntry1."VAT Amount (LCY)", SalesAdvanceLetterEntry1."VAT Base Amount", SalesAdvanceLetterEntry1."VAT Base Amount (LCY)");
                        SalesAdvLetterManagementCZZ.AdvEntryInsert("Advance Letter Entry Type CZZ"::"VAT Payment", SalesAdvLetterHeaderCZZ."No.", SalesAdvanceLetterEntry1."Posting Date",
                            SalesAdvanceLetterEntry1."VAT Base Amount" + SalesAdvanceLetterEntry1."VAT Amount", SalesAdvanceLetterEntry1."VAT Base Amount (LCY)" + SalesAdvanceLetterEntry1."VAT Amount (LCY)",
                            SalesAdvLetterEntryCZZ1."Currency Code", SalesAdvLetterEntryCZZ1."Currency Factor", SalesAdvanceLetterEntry1."Document No.",
                            SalesAdvLetterEntryCZZ1."Global Dimension 1 Code", SalesAdvLetterEntryCZZ1."Global Dimension 2 Code", SalesAdvLetterEntryCZZ1."Dimension Set ID", false);
                    until SalesAdvanceLetterEntry1.Next() = 0;

                SalesAdvanceLetterEntry1.SetRange("Entry Type", SalesAdvanceLetterEntry1."Entry Type"::Deduction);
                if SalesAdvanceLetterEntry1.FindSet() then
                    repeat
                        if not CustLedgerEntry.Get(SalesAdvanceLetterEntry1."Customer Entry No.") then
                            CustLedgerEntry.Init();
                        CurrFactor := CustLedgerEntry."Original Currency Factor";
                        if CurrFactor = 0 then
                            CurrFactor := 1;
                        SalesAdvLetterManagementCZZ.AdvEntryInit(false);
                        if SalesAdvanceLetterEntry1.Cancelled then
                            SalesAdvLetterManagementCZZ.AdvEntryInitCancel();
                        SalesAdvLetterManagementCZZ.AdvEntryInitCustLedgEntryNo(SalesAdvanceLetterEntry1."Customer Entry No.");
                        SalesAdvLetterManagementCZZ.AdvEntryInitRelatedEntry(SalesAdvLetterEntryCZZ1."Entry No.");
                        SalesAdvLetterManagementCZZ.AdvEntryInsert("Advance Letter Entry Type CZZ"::Usage, SalesAdvLetterHeaderCZZ."No.", SalesAdvanceLetterEntry1."Posting Date",
                            SalesAdvanceLetterEntry1.Amount, Round(SalesAdvanceLetterEntry1.Amount / CurrFactor),
                            SalesAdvanceLetterEntry1."Currency Code", CustLedgerEntry."Original Currency Factor", SalesAdvanceLetterEntry1."Document No.",
                            CustLedgerEntry."Global Dimension 1 Code", CustLedgerEntry."Global Dimension 2 Code", CustLedgerEntry."Dimension Set ID", false);

                        SalesAdvLetterEntryCZZ2.FindLast();

                        SalesAdvanceLetterEntry2.Reset();
                        SalesAdvanceLetterEntry2.SetRange("Letter No.", SalesAdvanceLetterEntry1."Letter No.");
                        SalesAdvanceLetterEntry2.SetRange("Letter Line No.", SalesAdvanceLetterEntry1."Letter Line No.");
                        SalesAdvanceLetterEntry2.SetRange("Entry Type", SalesAdvanceLetterEntry2."Entry Type"::"VAT Deduction");
                        SalesAdvanceLetterEntry2.SetRange("Document Type", SalesAdvanceLetterEntry1."Document Type");
                        SalesAdvanceLetterEntry2.SetRange("Document No.", SalesAdvanceLetterEntry1."Document No.");
                        SalesAdvanceLetterEntry2.SetRange("Sale Line No.", SalesAdvanceLetterEntry1."Sale Line No.");
                        SalesAdvanceLetterEntry2.SetRange("Deduction Line No.", SalesAdvanceLetterEntry1."Deduction Line No.");
                        SalesAdvanceLetterEntry2.SetRange("Customer Entry No.", SalesAdvanceLetterEntry1."Customer Entry No.");
                        if SalesAdvanceLetterEntry2.FindSet() then
                            repeat
                                SalesAdvLetterManagementCZZ.AdvEntryInit(false);
                                if SalesAdvanceLetterEntry2.Cancelled then
                                    SalesAdvLetterManagementCZZ.AdvEntryInitCancel();
                                SalesAdvLetterManagementCZZ.AdvEntryInitRelatedEntry(SalesAdvLetterEntryCZZ2."Entry No.");
                                SalesAdvLetterManagementCZZ.AdvEntryInitVAT(SalesAdvanceLetterEntry2."VAT Bus. Posting Group", SalesAdvanceLetterEntry2."VAT Prod. Posting Group", SalesAdvanceLetterEntry2."VAT Date",
                                    SalesAdvanceLetterEntry2."VAT Entry No.", SalesAdvanceLetterEntry2."VAT %", SalesAdvanceLetterEntry2."VAT Identifier", "TAX Calculation Type"::"Normal VAT",
                                    SalesAdvanceLetterEntry2."VAT Amount", SalesAdvanceLetterEntry2."VAT Amount (LCY)", SalesAdvanceLetterEntry2."VAT Base Amount", SalesAdvanceLetterEntry2."VAT Base Amount (LCY)");
                                SalesAdvLetterManagementCZZ.AdvEntryInsert("Advance Letter Entry Type CZZ"::"VAT Usage", SalesAdvLetterHeaderCZZ."No.", SalesAdvanceLetterEntry2."Posting Date",
                                    SalesAdvanceLetterEntry2."VAT Base Amount" + SalesAdvanceLetterEntry2."VAT Amount", SalesAdvanceLetterEntry2."VAT Base Amount (LCY)" + SalesAdvanceLetterEntry2."VAT Amount (LCY)",
                                    SalesAdvanceLetterEntry2."Currency Code", CustLedgerEntry."Original Currency Factor", SalesAdvanceLetterEntry2."Document No.",
                                    CustLedgerEntry."Global Dimension 1 Code", CustLedgerEntry."Global Dimension 2 Code", CustLedgerEntry."Dimension Set ID", false);
                            until SalesAdvanceLetterEntry2.Next() = 0;

                        SalesAdvanceLetterEntry2.SetRange("Entry Type", SalesAdvanceLetterEntry2."Entry Type"::"VAT Rate");
                        if SalesAdvanceLetterEntry2.FindSet() then
                            repeat
                                SalesAdvLetterManagementCZZ.AdvEntryInit(false);
                                if SalesAdvanceLetterEntry2.Cancelled then
                                    SalesAdvLetterManagementCZZ.AdvEntryInitCancel();
                                SalesAdvLetterManagementCZZ.AdvEntryInitRelatedEntry(SalesAdvLetterEntryCZZ2."Entry No.");
                                SalesAdvLetterManagementCZZ.AdvEntryInitVAT(SalesAdvanceLetterEntry2."VAT Bus. Posting Group", SalesAdvanceLetterEntry2."VAT Prod. Posting Group", SalesAdvanceLetterEntry2."VAT Date",
                                    0, SalesAdvanceLetterEntry2."VAT %", SalesAdvanceLetterEntry2."VAT Identifier", "TAX Calculation Type"::"Normal VAT",
                                    0, SalesAdvanceLetterEntry2."VAT Amount (LCY)", 0, SalesAdvanceLetterEntry2."VAT Base Amount (LCY)");
                                SalesAdvLetterManagementCZZ.AdvEntryInsert("Advance Letter Entry Type CZZ"::"VAT Rate", SalesAdvLetterHeaderCZZ."No.", SalesAdvanceLetterEntry2."Posting Date",
                                    0, SalesAdvanceLetterEntry2."VAT Base Amount (LCY)" + SalesAdvanceLetterEntry2."VAT Amount (LCY)", '', 0, SalesAdvanceLetterEntry2."Document No.",
                                    CustLedgerEntry."Global Dimension 1 Code", CustLedgerEntry."Global Dimension 2 Code", CustLedgerEntry."Dimension Set ID", false);
                            until SalesAdvanceLetterEntry2.Next() = 0;
                    until SalesAdvanceLetterEntry1.Next() = 0;

                AdvanceLink.Amount := 0;
                AdvanceLink."Amount (LCY)" := 0;
                AdvanceLink.Modify(false);
            until AdvanceLink.Next() = 0;

        if SalesAdvLetterHeaderCZZ.Status = SalesAdvLetterHeaderCZZ.Status::Closed then begin
            if LastClosedDate = 0D then
                LastClosedDate := SalesAdvLetterHeaderCZZ."Posting Date";
            SalesAdvLetterHeaderCZZ.CalcFields("To Use", "To Use (LCY)");
            if (SalesAdvLetterHeaderCZZ."To Use" <> 0) or (SalesAdvLetterHeaderCZZ."To Use (LCY)" <> 0) then begin
                SalesAdvanceLetterEntry1.Reset();
                SalesAdvanceLetterEntry1.SetRange("Letter No.", SalesAdvLetterHeaderCZZ."No.");
                SalesAdvanceLetterEntry1.SetRange("Entry Type", SalesAdvanceLetterEntry1."Entry Type"::VAT);
                SalesAdvanceLetterEntry1.SetRange("Document Type", SalesAdvanceLetterEntry1."Document Type"::"Credit Memo");
                if not SalesAdvanceLetterEntry1.FindLast() then
                    SalesAdvanceLetterEntry1."Document No." := SalesAdvLetterHeaderCZZ."No.";

                SalesAdvLetterManagementCZZ.AdvEntryInit(false);
                SalesAdvLetterManagementCZZ.AdvEntryInsert("Advance Letter Entry Type CZZ"::Close, SalesAdvLetterHeaderCZZ."No.", LastClosedDate,
                    SalesAdvLetterHeaderCZZ."To Use", SalesAdvLetterHeaderCZZ."To Use (LCY)",
                    SalesAdvLetterHeaderCZZ."Currency Code", SalesAdvLetterHeaderCZZ."Currency Factor", SalesAdvanceLetterEntry1."Document No.",
                    SalesAdvLetterHeaderCZZ."Shortcut Dimension 1 Code", SalesAdvLetterHeaderCZZ."Shortcut Dimension 2 Code", SalesAdvLetterHeaderCZZ."Dimension Set ID", false);

                SalesAdvLetterEntryCZZ1.Reset();
                SalesAdvLetterEntryCZZ1.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
                SalesAdvLetterEntryCZZ1.SetFilter("Entry Type", '%1|%2|%3',
                    SalesAdvLetterEntryCZZ1."Entry Type"::"VAT Payment",
                    SalesAdvLetterEntryCZZ1."Entry Type"::"VAT Usage",
                    SalesAdvLetterEntryCZZ1."Entry Type"::"VAT Rate");
                if SalesAdvLetterEntryCZZ1.FindSet() then
                    repeat
                        TempSalesAdvLetterEntryCZZ.SetRange("VAT Bus. Posting Group", SalesAdvLetterEntryCZZ1."VAT Bus. Posting Group");
                        TempSalesAdvLetterEntryCZZ.SetRange("VAT Prod. Posting Group", SalesAdvLetterEntryCZZ1."VAT Prod. Posting Group");
                        if not TempSalesAdvLetterEntryCZZ.FindFirst() then begin
                            TempSalesAdvLetterEntryCZZ.Init();
                            TempSalesAdvLetterEntryCZZ := SalesAdvLetterEntryCZZ1;
                            TempSalesAdvLetterEntryCZZ.Insert();
                        end else begin
                            TempSalesAdvLetterEntryCZZ.Amount += SalesAdvLetterEntryCZZ1.Amount;
                            TempSalesAdvLetterEntryCZZ."Amount (LCY)" += SalesAdvLetterEntryCZZ1."Amount (LCY)";
                            TempSalesAdvLetterEntryCZZ."VAT Amount" += SalesAdvLetterEntryCZZ1."VAT Amount";
                            TempSalesAdvLetterEntryCZZ."VAT Amount (LCY)" += SalesAdvLetterEntryCZZ1."VAT Amount (LCY)";
                            TempSalesAdvLetterEntryCZZ."VAT Base Amount" += SalesAdvLetterEntryCZZ1."VAT Base Amount";
                            TempSalesAdvLetterEntryCZZ."VAT Base Amount (LCY)" += SalesAdvLetterEntryCZZ1."VAT Base Amount (LCY)";
                            TempSalesAdvLetterEntryCZZ.Modify();
                        end;
                    until SalesAdvLetterEntryCZZ1.Next() = 0;

                TempSalesAdvLetterEntryCZZ.Reset();
                if TempSalesAdvLetterEntryCZZ.FindSet() then
                    repeat
                        if (TempSalesAdvLetterEntryCZZ.Amount <> 0) or (TempSalesAdvLetterEntryCZZ."Amount (LCY)" <> 0) or
                           (TempSalesAdvLetterEntryCZZ."VAT Amount" <> 0) or (TempSalesAdvLetterEntryCZZ."VAT Amount (LCY)" <> 0) or
                           (TempSalesAdvLetterEntryCZZ."VAT Base Amount" <> 0) or (TempSalesAdvLetterEntryCZZ."VAT Base Amount (LCY)" <> 0)
                        then begin
                            SalesAdvLetterManagementCZZ.AdvEntryInit(false);
                            SalesAdvLetterManagementCZZ.AdvEntryInitVAT(
                                TempSalesAdvLetterEntryCZZ."VAT Bus. Posting Group", TempSalesAdvLetterEntryCZZ."VAT Prod. Posting Group",
                                LastClosedDate, 0, TempSalesAdvLetterEntryCZZ."VAT %", TempSalesAdvLetterEntryCZZ."VAT Identifier", TempSalesAdvLetterEntryCZZ."VAT Calculation Type",
                                -TempSalesAdvLetterEntryCZZ."VAT Amount", -TempSalesAdvLetterEntryCZZ."VAT Amount (LCY)",
                                -TempSalesAdvLetterEntryCZZ."VAT Base Amount", -TempSalesAdvLetterEntryCZZ."VAT Base Amount (LCY)");
                            SalesAdvLetterManagementCZZ.AdvEntryInsert("Advance Letter Entry Type CZZ"::"VAT Close", SalesAdvLetterHeaderCZZ."No.", LastClosedDate,
                                -TempSalesAdvLetterEntryCZZ.Amount, -TempSalesAdvLetterEntryCZZ."Amount (LCY)",
                                SalesAdvLetterHeaderCZZ."Currency Code", SalesAdvLetterHeaderCZZ."Currency Factor", SalesAdvanceLetterEntry1."Document No.",
                                SalesAdvLetterHeaderCZZ."Shortcut Dimension 1 Code", SalesAdvLetterHeaderCZZ."Shortcut Dimension 2 Code", SalesAdvLetterHeaderCZZ."Dimension Set ID", false);
                        end;
                    until TempSalesAdvLetterEntryCZZ.Next() = 0;
                SalesAdvLetterManagementCZZ.CancelInitEntry(SalesAdvLetterHeaderCZZ, LastClosedDate, false);
            end;
        end;
    end;

    local procedure UpdateSalesAdvanceApplication(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    var
        AdvanceLetterLineRelation: Record "Advance Letter Line Relation";
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        SalesHeader: Record "Sales Header";
        AmtToDeduct: Decimal;
        Continue: Boolean;
    begin
        if SalesAdvLetterHeaderCZZ.Status = SalesAdvLetterHeaderCZZ.Status::Closed then
            exit;

        AdvanceLetterLineRelation.SetRange(Type, AdvanceLetterLineRelation.Type::Sale);
        AdvanceLetterLineRelation.SetRange("Letter No.", SalesAdvLetterHeaderCZZ."No.");
        if AdvanceLetterLineRelation.FindSet() then begin
            repeat
                case AdvanceLetterLineRelation."Document Type" of
                    AdvanceLetterLineRelation."Document Type"::Order:
                        Continue := SalesHeader.Get(SalesHeader."Document Type"::Order, AdvanceLetterLineRelation."Document No.");
                    AdvanceLetterLineRelation."Document Type"::Invoice:
                        Continue := SalesHeader.Get(SalesHeader."Document Type"::Invoice, AdvanceLetterLineRelation."Document No.");
                    else
                        Continue := false;
                end;
                if Continue then begin
                    AdvanceLetterApplicationCZZ.Init();
                    AdvanceLetterApplicationCZZ."Advance Letter Type" := AdvanceLetterApplicationCZZ."Advance Letter Type"::Sales;
                    AdvanceLetterApplicationCZZ."Advance Letter No." := AdvanceLetterLineRelation."Letter No.";
                    case AdvanceLetterLineRelation."Document Type" of
                        AdvanceLetterLineRelation."Document Type"::Invoice:
                            AdvanceLetterApplicationCZZ."Document Type" := AdvanceLetterApplicationCZZ."Document Type"::"Sales Invoice";
                        AdvanceLetterLineRelation."Document Type"::Order:
                            AdvanceLetterApplicationCZZ."Document Type" := AdvanceLetterApplicationCZZ."Document Type"::"Sales Order";
                    end;
                    AdvanceLetterApplicationCZZ."Document No." := AdvanceLetterLineRelation."Document No.";
                    if AdvanceLetterLineRelation."Primary Link" then
                        AmtToDeduct := AdvanceLetterLineRelation.Amount
                    else
                        AmtToDeduct := AdvanceLetterLineRelation."Amount To Deduct";

                    if AdvanceLetterApplicationCZZ.Find() then begin
                        AdvanceLetterApplicationCZZ.Amount += AmtToDeduct;
                        AdvanceLetterApplicationCZZ.Modify();
                    end else begin
                        AdvanceLetterApplicationCZZ.Amount := AmtToDeduct;
                        AdvanceLetterApplicationCZZ.Insert();
                    end;
                end;
            until AdvanceLetterLineRelation.Next() = 0;

            AdvanceLetterLineRelation.DeleteAll();
        end;
    end;

    local procedure CopyVATPostingSetup()
    var
        RecModify: Boolean;
    begin
        VATPostingSetup.SetLoadFields("Sales Adv. Letter Account CZZ", "Sales Advance Offset VAT Acc.", "Sales Advance VAT Account", "Purch. Advance Offset VAT Acc.", "Purch. Advance VAT Account");
        if VATPostingSetup.FindSet() then
            repeat
                RecModify := false;
                if VATPostingSetup."Sales Adv. Letter Account CZZ" = '' then begin
                    VATPostingSetup."Sales Adv. Letter Account CZZ" := VATPostingSetup."Sales Advance Offset VAT Acc.";
                    RecModify := true;
                end;
                if VATPostingSetup."Sales Adv. Letter VAT Acc. CZZ" = '' then begin
                    VATPostingSetup."Sales Adv. Letter VAT Acc. CZZ" := VATPostingSetup."Sales Advance VAT Account";
                    RecModify := true;
                end;
                if VATPostingSetup."Purch. Adv. Letter Account CZZ" = '' then begin
                    VATPostingSetup."Purch. Adv. Letter Account CZZ" := VATPostingSetup."Purch. Advance Offset VAT Acc.";
                    RecModify := true;
                end;
                if VATPostingSetup."Purch. Adv.Letter VAT Acc. CZZ" = '' then begin
                    VATPostingSetup."Purch. Adv.Letter VAT Acc. CZZ" := VATPostingSetup."Purch. Advance VAT Account";
                    RecModify := true;
                end;
                if RecModify then
                    VATPostingSetup.Modify();
            until VATPostingSetup.Next() = 0;
    end;

    local procedure GetStatus(OldStatus: Option Open,"Pending Payment","Pending Invoice","Pending Final Invoice",Closed,"Pending Approval"): Enum "Advance Letter Doc. Status CZZ"
    begin
        case OldStatus of
            OldStatus::Open:
                exit("Advance Letter Doc. Status CZZ"::New);
            OldStatus::"Pending Payment", OldStatus::"Pending Approval":
                exit("Advance Letter Doc. Status CZZ"::"To Pay");
            OldStatus::"Pending Invoice", OldStatus::"Pending Final Invoice":
                exit("Advance Letter Doc. Status CZZ"::"To Use");
            OldStatus::Closed:
                exit("Advance Letter Doc. Status CZZ"::Closed);
        end;
    end;

    local procedure CopyVATEntries()
    var
        VATEntry: Record "VAT Entry";
        VATEntry2: Record "VAT Entry";
    begin
        VATEntry.SetRange("Prepayment Type", VATEntry."Prepayment Type"::Advance);
        VATEntry.SetFilter("Advance Base", '<>0');
        if VATEntry.FindSet() then
            repeat
                VATEntry2 := VATEntry;
                VATEntry2.Base := VATEntry2."Advance Base";
                VATEntry2."Advance Base" := 0;
                VATEntry2."Advance Letter No. CZZ" := VATEntry2."Advance Letter No.";
                VATEntry2.Modify();
            until VATEntry.Next() = 0;
    end;

    local procedure CopyCustomerLedgerEntries()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SalesAdvanceLetterEntry: Record "Sales Advance Letter Entry";
        SalesAdvanceLetterHeader: Record "Sales Advance Letter Header";
        AdvanceLink: Record "Advance Link";
        AppliedCustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetLoadFields("Entry No.", "Advance Letter No. CZZ", "Adv. Letter Template Code CZZ", "Closed by Entry No.");
        CustLedgerEntry.SetRange(Prepayment, true);
        CustLedgerEntry.SetRange("Prepayment Type", CustLedgerEntry."Prepayment Type"::Advance);
        if CustLedgerEntry.FindSet(true) then
            repeat
                SalesAdvanceLetterEntry.SetLoadFields("Letter No.", "Template Name");
                SalesAdvanceLetterEntry.SetRange("Customer Entry No.", CustLedgerEntry."Entry No.");
                if SalesAdvanceLetterEntry.FindFirst() then begin
                    CustLedgerEntry.Validate("Advance Letter No. CZZ", SalesAdvanceLetterEntry."Letter No.");
                    CustLedgerEntry."Adv. Letter Template Code CZZ" := 'P_' + SalesAdvanceLetterEntry."Template Name";
                end else begin
                    AdvanceLink.SetLoadFields("Document No.");
                    AdvanceLink.SetRange("CV Ledger Entry No.", CustLedgerEntry."Entry No.");
                    AdvanceLink.SetRange(Type, AdvanceLink.Type::Sale);
                    AdvanceLink.SetRange("Entry Type", AdvanceLink."Entry Type"::"Link To Letter");
                    if AdvanceLink.FindFirst() and (AdvanceLink.Count() = 1) then begin
                        SalesAdvanceLetterHeader.Get(AdvanceLink."Document No.");
                        CustLedgerEntry.Validate("Advance Letter No. CZZ", SalesAdvanceLetterHeader."No.");
                        CustLedgerEntry."Adv. Letter Template Code CZZ" := 'P_' + SalesAdvanceLetterHeader."Template Code";
                    end;
                end;
                CustLedgerEntry.Modify();

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
        PurchAdvanceLetterEntry: Record "Purch. Advance Letter Entry";
        PurchAdvanceLetterHeader: Record "Purch. Advance Letter Header";
        AdvanceLink: Record "Advance Link";
        AppliedVendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendorLedgerEntry.SetLoadFields("Entry No.", "Advance Letter No. CZZ", "Adv. Letter Template Code CZZ", "Closed by Entry No.");
        VendorLedgerEntry.SetRange(Prepayment, true);
        VendorLedgerEntry.SetRange("Prepayment Type", VendorLedgerEntry."Prepayment Type"::Advance);
        if VendorLedgerEntry.FindSet(true) then
            repeat
                PurchAdvanceLetterEntry.SetRange("Vendor Entry No.", VendorLedgerEntry."Entry No.");
                if PurchAdvanceLetterEntry.FindFirst() then begin
                    VendorLedgerEntry.Validate("Advance Letter No. CZZ", PurchAdvanceLetterEntry."Letter No.");
                    VendorLedgerEntry."Adv. Letter Template Code CZZ" := 'N_' + PurchAdvanceLetterEntry."Template Name";
                end else begin
                    AdvanceLink.SetRange("CV Ledger Entry No.", VendorLedgerEntry."Entry No.");
                    AdvanceLink.SetRange(Type, AdvanceLink.Type::Purchase);
                    AdvanceLink.SetRange("Entry Type", AdvanceLink."Entry Type"::"Link To Letter");
                    if AdvanceLink.FindFirst() and (AdvanceLink.Count() = 1) then begin
                        PurchAdvanceLetterHeader.Get(AdvanceLink."Document No.");
                        VendorLedgerEntry.Validate("Advance Letter No. CZZ", PurchAdvanceLetterHeader."No.");
                        VendorLedgerEntry."Adv. Letter Template Code CZZ" := 'N_' + PurchAdvanceLetterHeader."Template Code";
                    end;
                end;
                VendorLedgerEntry.Modify();

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

    local procedure CopyGenJournalLines()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalLine2: Record "Gen. Journal Line";
    begin
        GenJournalLine.SetFilter("Advance Letter Link Code", '<>%1', '');
        if GenJournalLine.FindSet() then
            repeat
                GenJournalLine2 := GenJournalLine;
                GenJournalLine2.Validate("Advance Letter Link Code", '');
                GenJournalLine2.Validate(Prepayment, false);
                GenJournalLine2.Validate("Prepayment Type", GenJournalLine2."Prepayment Type"::" ");
                GenJournalLine2.Modify();
            until GenJournalLine.Next() = 0;
    end;

    local procedure CopyCashDocumentLinesCZP()
    var
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        CashDocumentLineCZP2: Record "Cash Document Line CZP";
    begin
        CashDocumentLineCZP.SetFilter("Advance Letter Link Code", '<>%1', '');
        if CashDocumentLineCZP.FindSet() then
            repeat
                CashDocumentLineCZP2 := CashDocumentLineCZP;
                CashDocumentLineCZP2.Validate("Advance Letter Link Code", '');
                CashDocumentLineCZP2.Modify();
            until CashDocumentLineCZP.Next() = 0;
    end;

    local procedure CopyPaymentOrderLinesCZB()
    var
        PaymentOrderLine: Record "Payment Order Line";
        PaymentOrderLineCZB: Record "Payment Order Line CZB";
    begin
        PaymentOrderLine.SetLoadFields("No.", "Line No.", "Letter No.");
        PaymentOrderLine.SetFilter("Letter No.", '<>%1', '');
        if PaymentOrderLine.FindSet() then
            repeat
                if PaymentOrderLineCZB.Get(PaymentOrderLine."Payment Order No.", PaymentOrderLine."Line No.") then begin
                    PaymentOrderLineCZB."Purch. Advance Letter No. CZZ" := PaymentOrderLine."Letter No.";
                    PaymentOrderLineCZB.Modify(false);
                end;
            until PaymentOrderLine.Next() = 0;
    end;

    local procedure CopyIssPaymentOrderLinesCZB()
    var
        IssuedPaymentOrderLine: Record "Issued Payment Order Line";
        IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB";
    begin
        IssuedPaymentOrderLine.SetLoadFields("No.", "Line No.", "Letter No.");
        IssuedPaymentOrderLine.SetFilter("Letter No.", '<>%1', '');
        if IssuedPaymentOrderLine.FindSet() then
            repeat
                if IssPaymentOrderLineCZB.Get(IssuedPaymentOrderLine."Payment Order No.", IssuedPaymentOrderLine."Line No.") then begin
                    IssPaymentOrderLineCZB."Purch. Advance Letter No. CZZ" := IssuedPaymentOrderLine."Letter No.";
                    IssPaymentOrderLineCZB.Modify(false);
                end;
            until IssuedPaymentOrderLine.Next() = 0;
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

    local procedure CopyCashFlowSetup()
    var
        CashFlowSetup: Record "Cash Flow Setup";
    begin
        CashFlowSetup.SetLoadFields("S. Adv. Letter CF Account No.", "P. Adv. Letter CF Account No.");
        if CashFlowSetup.Get() then begin
            CashFlowSetup."S. Adv. Letter CF Acc. No. CZZ" := CashFlowSetup."S. Adv. Letter CF Account No.";
            CashFlowSetup."P. Adv. Letter CF Acc. No. CZZ" := CashFlowSetup."P. Adv. Letter CF Account No.";
            CashFlowSetup.Modify(false);
        end;
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
                IncomingDocument."Related Record ID" := GetRelatedRecordId(IncomingDocument);
                IncomingDocument."Document Type" := GetDocumentType(IncomingDocument);
                if (IncomingDocument."Related Record ID" <> PrevIncomingDocument."Related Record ID") or
                   (IncomingDocument."Document Type" <> PrevIncomingDocument."Document Type")
                then
                    IncomingDocument.Modify(false);
            until IncomingDocument.Next() = 0;
    end;

    local procedure GetRelatedRecordId(IncomingDocument: Record "Incoming Document"): RecordId
    var
        PurchAdvanceLetterHeader: Record "Purch. Advance Letter Header";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        SalesAdvanceLetterHeader: Record "Sales Advance Letter Header";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        DataTypeManagement: Codeunit "Data Type Management";
        RelatedRecordRef, NewRelatedRecordRef : RecordRef;
        RelatedRecordVariant: Variant;
    begin
        if not IncomingDocument.GetRecord(RelatedRecordVariant) then
            exit(IncomingDocument."Related Record ID");

        DataTypeManagement.GetRecordRef(RelatedRecordVariant, RelatedRecordRef);
        case RelatedRecordRef.Number of
            Database::"Purch. Advance Letter Header":
                begin
                    RelatedRecordRef.SetTable(PurchAdvanceLetterHeader);
                    if PurchAdvLetterHeaderCZZ.Get(PurchAdvanceLetterHeader."No.") then begin
                        NewRelatedRecordRef.GetTable(PurchAdvLetterHeaderCZZ);
                        exit(NewRelatedRecordRef.RecordId);
                    end;
                end;
            Database::"Sales Advance Letter Header":
                begin
                    RelatedRecordRef.SetTable(SalesAdvanceLetterHeader);
                    if SalesAdvLetterHeaderCZZ.Get(SalesAdvanceLetterHeader."No.") then begin
                        NewRelatedRecordRef.GetTable(SalesAdvLetterHeaderCZZ);
                        exit(NewRelatedRecordRef.RecordId);
                    end;
                end;
            else
                exit(IncomingDocument."Related Record ID");
        end;
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
