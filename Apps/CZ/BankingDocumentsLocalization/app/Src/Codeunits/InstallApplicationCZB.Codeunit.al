// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft;
using Microsoft.Bank.BankAccount;
using Microsoft.Bank.DirectDebit;
using Microsoft.Bank.Payment;
using Microsoft.Bank.Reconciliation;
using Microsoft.Bank.Setup;
using Microsoft.Foundation.Company;
using System.Security.User;
using System.Upgrade;

#pragma warning disable AL0432,AL0603
codeunit 31330 "Install Application CZB"
{
    Subtype = Install;
    Permissions = tabledata "Bank Statement Header CZB" = im,
                  tabledata "Bank Statement Line CZB" = im,
                  tabledata "Payment Order Header CZB" = im,
                  tabledata "Payment Order Line CZB" = im,
                  tabledata "Iss. Bank Statement Header CZB" = im,
                  tabledata "Iss. Bank Statement Line CZB" = im,
                  tabledata "Iss. Payment Order Header CZB" = im,
                  tabledata "Iss. Payment Order Line CZB" = im,
                  tabledata "Bank Export/Import Setup" = im,
                  tabledata "Bank Account" = m,
                  tabledata "Bank Acc. Reconciliation" = m,
                  tabledata "Payment Export Data" = m;

    var
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
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Bank Statement Header", Database::"Bank Statement Header CZB");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Bank Statement Line", Database::"Bank Statement Line CZB");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Issued Bank Statement Header", Database::"Iss. Bank Statement Header CZB");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Issued Bank Statement Line", Database::"Iss. Bank Statement Line CZB");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Payment Order Header", Database::"Payment Order Header CZB");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Payment Order Line", Database::"Payment Order Line CZB");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Issued Payment Order Header", Database::"Iss. Payment Order Header CZB");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Iss. Payment Order Line CZB", Database::"Iss. Payment Order Line CZB");
    end;

    local procedure CopyUsage();
    begin
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Bank Statement Header", Database::"Bank Statement Header CZB");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Bank Statement Line", Database::"Bank Statement Line CZB");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Issued Bank Statement Header", Database::"Iss. Bank Statement Header CZB");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Issued Bank Statement Line", Database::"Iss. Bank Statement Line CZB");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Payment Order Header", Database::"Payment Order Header CZB");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Payment Order Line", Database::"Payment Order Line CZB");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Issued Payment Order Header", Database::"Iss. Payment Order Header CZB");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Iss. Payment Order Line CZB", Database::"Iss. Payment Order Line CZB");
    end;

    local procedure CopyData()
    begin
        CopyBankAccount();
        CopyBankAccReconciliation();
        CopyBankStatementHeader();
        CopyBankStatementLine();
        CopyPaymentOrderHeader();
        CopyPaymentOrderLine();
        CopyIssuedBankStatementHeader();
        CopyIssuedBankStatementLine();
        CopyIssuedPaymentOrderHeader();
        CopyIssuedPaymentOrderLine();
        CopyUserSetup();
        CopyBankExportImportSetup();
        CopyPaymentExportData();
        InitExpLauncherSEPA();
    end;

    local procedure CopyBankAccount();
    var
        BankAccount: Record "Bank Account";
    begin
        if BankAccount.FindSet() then
            repeat
                BankAccount."Default Constant Symbol CZB" := BankAccount."Default Constant Symbol";
                BankAccount."Default Specific Symbol CZB" := BankAccount."Default Specific Symbol";
                BankAccount."Domestic Payment Order ID CZB" := Report::"Iss. Payment Order CZB";
                BankAccount."Foreign Payment Order ID CZB" := Report::"Iss. Payment Order CZB";
                BankAccount."Dimension from Apply Entry CZB" := BankAccount."Dimension from Apply Entry";
                BankAccount."Check Ext. No. Curr. Year CZB" := BankAccount."Check Ext. No. by Current Year";
                BankAccount."Check CZ Format on Issue CZB" := BankAccount."Check Czech Format on Issue";
                BankAccount."Variable S. to Description CZB" := BankAccount."Variable S. to Description";
                BankAccount."Variable S. to Variable S. CZB" := BankAccount."Variable S. to Variable S.";
                BankAccount."Variable S. to Ext.Doc.No. CZB" := BankAccount."Variable S. to Ext. Doc.No.";
                BankAccount."Foreign Payment Orders CZB" := BankAccount."Foreign Payment Orders";
                BankAccount."Post Per Line CZB" := BankAccount."Post Per Line";
                BankAccount."Payment Partial Suggestion CZB" := BankAccount."Payment Partial Suggestion";
                BankAccount."Payment Order Line Descr. CZB" := BankAccount."Payment Order Line Description";
                BankAccount."Non Assoc. Payment Account CZB" := BankAccount."Non Associated Payment Account";
                BankAccount."Base Calendar Code CZB" := BankAccount."Base Calendar Code";
                BankAccount."Payment Jnl. Template Name CZB" := BankAccount."Payment Jnl. Template Name";
                BankAccount."Payment Jnl. Batch Name CZB" := BankAccount."Payment Jnl. Batch Name";
                BankAccount."Foreign Payment Ex. Format CZB" := BankAccount."Foreign Payment Export Format";
                BankAccount."Payment Import Format CZB" := BankAccount."Payment Import Format";
                BankAccount."Payment Order Nos. CZB" := BankAccount."Payment Order Nos.";
                BankAccount."Issued Payment Order Nos. CZB" := BankAccount."Issued Payment Order Nos.";
                BankAccount."Bank Statement Nos. CZB" := BankAccount."Bank Statement Nos.";
                BankAccount."Issued Bank Statement Nos. CZB" := BankAccount."Issued Bank Statement Nos.";
                BankAccount.Modify(false);
            until BankAccount.Next() = 0;
    end;

    local procedure CopyBankAccReconciliation();
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccReconciliationDataTransfer: DataTransfer;
    begin
        BankAccReconciliationDataTransfer.SetTables(Database::"Bank Acc. Reconciliation", Database::"Bank Acc. Reconciliation");
        BankAccReconciliationDataTransfer.AddFieldValue(BankAccReconciliation.FieldNo("Created From Iss. Bank Stat."), BankAccReconciliation.FieldNo("Created From Bank Stat. CZB"));
        BankAccReconciliationDataTransfer.CopyFields();
    end;

    local procedure CopyBankStatementHeader();
    var
        BankStatementHeader: Record "Bank Statement Header";
        BankStatementHeaderCZB: Record "Bank Statement Header CZB";
    begin
        if BankStatementHeader.FindSet() then
            repeat
                if not BankStatementHeaderCZB.Get(BankStatementHeader."No.") then begin
                    BankStatementHeaderCZB.Init();
                    BankStatementHeaderCZB."No." := BankStatementHeader."No.";
                    BankStatementHeaderCZB.SystemId := BankStatementHeader.SystemId;
                    BankStatementHeaderCZB.Insert(false, true);
                end;
                BankStatementHeaderCZB."No. Series" := BankStatementHeader."No. Series";
                BankStatementHeaderCZB."Bank Account No." := BankStatementHeader."Bank Account No.";
                BankStatementHeaderCZB."Account No." := BankStatementHeader."Account No.";
                BankStatementHeaderCZB."Document Date" := BankStatementHeader."Document Date";
                BankStatementHeaderCZB."Currency Code" := BankStatementHeader."Currency Code";
                BankStatementHeaderCZB."Currency Factor" := BankStatementHeader."Currency Factor";
                BankStatementHeaderCZB."Bank Statement Currency Code" := BankStatementHeader."Bank Statement Currency Code";
                BankStatementHeaderCZB."Bank Statement Currency Factor" := BankStatementHeader."Bank Statement Currency Factor";
                BankStatementHeaderCZB."Last Issuing No." := BankStatementHeader."Last Issuing No.";
                BankStatementHeaderCZB."External Document No." := BankStatementHeader."External Document No.";
                BankStatementHeaderCZB."File Name" := BankStatementHeader."File Name";
                BankStatementHeaderCZB."Check Amount" := BankStatementHeader."Check Amount";
                BankStatementHeaderCZB."Check Amount (LCY)" := BankStatementHeader."Check Amount (LCY)";
                BankStatementHeaderCZB."Check Debit" := BankStatementHeader."Check Debit";
                BankStatementHeaderCZB."Check Debit (LCY)" := BankStatementHeader."Check Debit (LCY)";
                BankStatementHeaderCZB."Check Credit" := BankStatementHeader."Check Credit";
                BankStatementHeaderCZB."Check Credit (LCY)" := BankStatementHeader."Check Credit (LCY)";
                BankStatementHeaderCZB.IBAN := BankStatementHeader.IBAN;
                BankStatementHeaderCZB."SWIFT Code" := BankStatementHeader."SWIFT Code";
                BankStatementHeaderCZB.Modify(false);
            until BankStatementHeader.Next() = 0;
    end;

    local procedure CopyBankStatementLine();
    var
        BankStatementLine: Record "Bank Statement Line";
        BankStatementLineCZB: Record "Bank Statement Line CZB";
    begin
        if BankStatementLine.FindSet() then
            repeat
                if not BankStatementLineCZB.Get(BankStatementLine."Bank Statement No.", BankStatementLine."Line No.") then begin
                    BankStatementLineCZB.Init();
                    BankStatementLineCZB."Bank Statement No." := BankStatementLine."Bank Statement No.";
                    BankStatementLineCZB."Line No." := BankStatementLine."Line No.";
                    BankStatementLineCZB.SystemId := BankStatementLine.SystemId;
                    BankStatementLineCZB.Insert(false, true);
                end;
                BankStatementLineCZB.Type := BankStatementLine.Type;
                BankStatementLineCZB."No." := BankStatementLine."No.";
                BankStatementLineCZB."Cust./Vendor Bank Account Code" := BankStatementLine."Cust./Vendor Bank Account Code";
                BankStatementLineCZB.Description := BankStatementLine.Description;
                BankStatementLineCZB."Account No." := BankStatementLine."Account No.";
                BankStatementLineCZB."Variable Symbol" := BankStatementLine."Variable Symbol";
                BankStatementLineCZB."Constant Symbol" := BankStatementLine."Constant Symbol";
                BankStatementLineCZB."Specific Symbol" := BankStatementLine."Specific Symbol";
                BankStatementLineCZB.Amount := BankStatementLine.Amount;
                BankStatementLineCZB."Amount (LCY)" := BankStatementLine."Amount (LCY)";
                BankStatementLineCZB.Positive := BankStatementLine.Positive;
                BankStatementLineCZB."Transit No." := BankStatementLine."Transit No.";
                BankStatementLineCZB."Currency Code" := BankStatementLine."Currency Code";
                BankStatementLineCZB."Bank Statement Currency Code" := BankStatementLine."Bank Statement Currency Code";
                BankStatementLineCZB."Amount (Bank Stat. Currency)" := BankStatementLine."Amount (Bank Stat. Currency)";
                BankStatementLineCZB."Bank Statement Currency Factor" := BankStatementLine."Bank Statement Currency Factor";
                BankStatementLineCZB.IBAN := BankStatementLine.IBAN;
                BankStatementLineCZB."SWIFT Code" := BankStatementLine."SWIFT Code";
                BankStatementLineCZB.Name := BankStatementLine.Name;
                BankStatementLineCZB.Modify(false);
            until BankStatementLine.Next() = 0;
    end;

    local procedure CopyPaymentOrderHeader();
    var
        PaymentOrderHeader: Record "Payment Order Header";
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
    begin
        if PaymentOrderHeader.FindSet() then
            repeat
                if not PaymentOrderHeaderCZB.Get(PaymentOrderHeader."No.") then begin
                    PaymentOrderHeaderCZB.Init();
                    PaymentOrderHeaderCZB."No." := PaymentOrderHeader."No.";
                    PaymentOrderHeaderCZB.SystemId := PaymentOrderHeader.SystemId;
                    PaymentOrderHeaderCZB.Insert(false, true);
                end;
                PaymentOrderHeaderCZB."No. Series" := PaymentOrderHeader."No. Series";
                PaymentOrderHeaderCZB."Bank Account No." := PaymentOrderHeader."Bank Account No.";
                PaymentOrderHeaderCZB."Account No." := PaymentOrderHeader."Account No.";
                PaymentOrderHeaderCZB."Document Date" := PaymentOrderHeader."Document Date";
                PaymentOrderHeaderCZB."Currency Code" := PaymentOrderHeader."Currency Code";
                PaymentOrderHeaderCZB."Currency Factor" := PaymentOrderHeader."Currency Factor";
                PaymentOrderHeaderCZB."Payment Order Currency Code" := PaymentOrderHeader."Payment Order Currency Code";
                PaymentOrderHeaderCZB."Payment Order Currency Factor" := PaymentOrderHeader."Payment Order Currency Factor";
                PaymentOrderHeaderCZB."Last Issuing No." := PaymentOrderHeader."Last Issuing No.";
                PaymentOrderHeaderCZB."External Document No." := PaymentOrderHeader."External Document No.";
                PaymentOrderHeaderCZB."File Name" := PaymentOrderHeader."File Name";
                PaymentOrderHeaderCZB."Foreign Payment Order" := PaymentOrderHeader."Foreign Payment Order";
                PaymentOrderHeaderCZB.IBAN := PaymentOrderHeader.IBAN;
                PaymentOrderHeaderCZB."SWIFT Code" := PaymentOrderHeader."SWIFT Code";
                PaymentOrderHeaderCZB."Unreliable Pay. Check DateTime" := PaymentOrderHeader."Uncertainty Pay.Check DateTime";
                PaymentOrderHeaderCZB.Modify(false);
            until PaymentOrderHeader.Next() = 0;
    end;

    local procedure CopyPaymentOrderLine();
    var
        PaymentOrderLine: Record "Payment Order Line";
        PaymentOrderLineCZB: Record "Payment Order Line CZB";
    begin
        if PaymentOrderLine.FindSet() then
            repeat
                if not PaymentOrderLineCZB.Get(PaymentOrderLine."Payment Order No.", PaymentOrderLine."Line No.") then begin
                    PaymentOrderLineCZB.Init();
                    PaymentOrderLineCZB."Payment Order No." := PaymentOrderLine."Payment Order No.";
                    PaymentOrderLineCZB."Line No." := PaymentOrderLine."Line No.";
                    PaymentOrderLineCZB.SystemId := PaymentOrderLine.SystemId;
                    PaymentOrderLineCZB.Insert(false, true);
                end;
                PaymentOrderLineCZB.Type := PaymentOrderLine.Type;
                PaymentOrderLineCZB."No." := PaymentOrderLine."No.";
                PaymentOrderLineCZB."Cust./Vendor Bank Account Code" := PaymentOrderLine."Cust./Vendor Bank Account Code";
                PaymentOrderLineCZB.Description := PaymentOrderLine.Description;
                PaymentOrderLineCZB."Account No." := PaymentOrderLine."Account No.";
                PaymentOrderLineCZB."Variable Symbol" := PaymentOrderLine."Variable Symbol";
                PaymentOrderLineCZB."Constant Symbol" := PaymentOrderLine."Constant Symbol";
                PaymentOrderLineCZB."Specific Symbol" := PaymentOrderLine."Specific Symbol";
                PaymentOrderLineCZB.Amount := PaymentOrderLine."Amount to Pay";
                PaymentOrderLineCZB."Amount (LCY)" := PaymentOrderLine."Amount (LCY) to Pay";
                PaymentOrderLineCZB."Applies-to Doc. Type" := PaymentOrderLine."Applies-to Doc. Type";
                PaymentOrderLineCZB."Applies-to Doc. No." := PaymentOrderLine."Applies-to Doc. No.";
                PaymentOrderLineCZB."Applies-to C/V/E Entry No." := PaymentOrderLine."Applies-to C/V/E Entry No.";
                PaymentOrderLineCZB.Positive := PaymentOrderLine.Positive;
                PaymentOrderLineCZB."Transit No." := PaymentOrderLine."Transit No.";
                PaymentOrderLineCZB."Currency Code" := PaymentOrderLine."Currency Code";
                PaymentOrderLineCZB."Applied Currency Code" := PaymentOrderLine."Applied Currency Code";
                PaymentOrderLineCZB."Payment Order Currency Code" := PaymentOrderLine."Payment Order Currency Code";
                PaymentOrderLineCZB."Amount (Paym. Order Currency)" := PaymentOrderLine."Amount(Pay.Order Curr.) to Pay";
                PaymentOrderLineCZB."Payment Order Currency Factor" := PaymentOrderLine."Payment Order Currency Factor";
                PaymentOrderLineCZB."Due Date" := PaymentOrderLine."Due Date";
                PaymentOrderLineCZB.IBAN := PaymentOrderLine.IBAN;
                PaymentOrderLineCZB."SWIFT Code" := PaymentOrderLine."SWIFT Code";
                PaymentOrderLineCZB."Amount Must Be Checked" := PaymentOrderLine."Amount Must Be Checked";
                PaymentOrderLineCZB.Name := PaymentOrderLine.Name;
                PaymentOrderLineCZB."Original Amount" := PaymentOrderLine."Original Amount";
                PaymentOrderLineCZB."Original Amount (LCY)" := PaymentOrderLine."Original Amount (LCY)";
                PaymentOrderLineCZB."Orig. Amount(Pay.Order Curr.)" := PaymentOrderLine."Orig. Amount(Pay.Order Curr.)";
                PaymentOrderLineCZB."Original Due Date" := PaymentOrderLine."Original Due Date";
                PaymentOrderLineCZB."Skip Payment" := PaymentOrderLine."Skip Payment";
                PaymentOrderLineCZB."Pmt. Discount Date" := PaymentOrderLine."Pmt. Discount Date";
                PaymentOrderLineCZB."Pmt. Discount Possible" := PaymentOrderLine."Pmt. Discount Possible";
                PaymentOrderLineCZB."VAT Unreliable Payer" := PaymentOrderLine."VAT Uncertainty Payer";
                PaymentOrderLineCZB."Public Bank Account" := PaymentOrderLine."Public Bank Account";
                PaymentOrderLineCZB."Payment Method Code" := PaymentOrderLine."Payment Method Code";
                PaymentOrderLineCZB.Modify(false);
            until PaymentOrderLine.Next() = 0;
    end;

    local procedure CopyIssuedBankStatementHeader();
    var
        IssuedBankStatementHeader: Record "Issued Bank Statement Header";
        IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB";
    begin
        if IssuedBankStatementHeader.FindSet() then
            repeat
                if not IssBankStatementHeaderCZB.Get(IssuedBankStatementHeader."No.") then begin
                    IssBankStatementHeaderCZB.Init();
                    IssBankStatementHeaderCZB."No." := IssuedBankStatementHeader."No.";
                    IssBankStatementHeaderCZB.SystemId := IssuedBankStatementHeader.SystemId;
                    IssBankStatementHeaderCZB.Insert(false, true);
                end;
                IssBankStatementHeaderCZB."No. Series" := IssuedBankStatementHeader."No. Series";
                IssBankStatementHeaderCZB."Bank Account No." := IssuedBankStatementHeader."Bank Account No.";
                IssBankStatementHeaderCZB."Account No." := IssuedBankStatementHeader."Account No.";
                IssBankStatementHeaderCZB."Document Date" := IssuedBankStatementHeader."Document Date";
                IssBankStatementHeaderCZB."Currency Code" := IssuedBankStatementHeader."Currency Code";
                IssBankStatementHeaderCZB."Currency Factor" := IssuedBankStatementHeader."Currency Factor";
                IssBankStatementHeaderCZB."Bank Statement Currency Code" := IssuedBankStatementHeader."Bank Statement Currency Code";
                IssBankStatementHeaderCZB."Bank Statement Currency Factor" := IssuedBankStatementHeader."Bank Statement Currency Factor";
                IssBankStatementHeaderCZB."Pre-Assigned No. Series" := IssuedBankStatementHeader."Pre-Assigned No. Series";
                IssBankStatementHeaderCZB."Pre-Assigned No." := IssuedBankStatementHeader."Pre-Assigned No.";
                IssBankStatementHeaderCZB."Pre-Assigned User ID" := IssuedBankStatementHeader."Pre-Assigned User ID";
                IssBankStatementHeaderCZB."External Document No." := IssuedBankStatementHeader."External Document No.";
                IssBankStatementHeaderCZB."File Name" := IssuedBankStatementHeader."File Name";
                IssBankStatementHeaderCZB."Check Amount" := IssuedBankStatementHeader."Check Amount";
                IssBankStatementHeaderCZB."Check Amount (LCY)" := IssuedBankStatementHeader."Check Amount (LCY)";
                IssBankStatementHeaderCZB."Check Debit" := IssuedBankStatementHeader."Check Debit";
                IssBankStatementHeaderCZB."Check Debit (LCY)" := IssuedBankStatementHeader."Check Debit (LCY)";
                IssBankStatementHeaderCZB."Check Credit" := IssuedBankStatementHeader."Check Credit";
                IssBankStatementHeaderCZB."Check Credit (LCY)" := IssuedBankStatementHeader."Check Credit (LCY)";
                IssBankStatementHeaderCZB.IBAN := IssuedBankStatementHeader.IBAN;
                IssBankStatementHeaderCZB."SWIFT Code" := IssuedBankStatementHeader."SWIFT Code";
                IssBankStatementHeaderCZB."Payment Reconciliation Status" := IssuedBankStatementHeader."Payment Reconciliation Status";
                IssBankStatementHeaderCZB.Modify(false);
            until IssuedBankStatementHeader.Next() = 0;
    end;

    local procedure CopyIssuedBankStatementLine();
    var
        IssuedBankStatementLine: Record "Issued Bank Statement Line";
        IssBankStatementLineCZB: Record "Iss. Bank Statement Line CZB";
    begin
        if IssuedBankStatementLine.FindSet() then
            repeat
                if not IssBankStatementLineCZB.Get(IssuedBankStatementLine."Bank Statement No.", IssuedBankStatementLine."Line No.") then begin
                    IssBankStatementLineCZB.Init();
                    IssBankStatementLineCZB."Bank Statement No." := IssuedBankStatementLine."Bank Statement No.";
                    IssBankStatementLineCZB."Line No." := IssuedBankStatementLine."Line No.";
                    IssBankStatementLineCZB.SystemId := IssuedBankStatementLine.SystemId;
                    IssBankStatementLineCZB.Insert(false, true);
                end;
                IssBankStatementLineCZB.Type := IssuedBankStatementLine.Type;
                IssBankStatementLineCZB."No." := IssuedBankStatementLine."No.";
                IssBankStatementLineCZB."Cust./Vendor Bank Account Code" := IssuedBankStatementLine."Cust./Vendor Bank Account Code";
                IssBankStatementLineCZB.Description := IssuedBankStatementLine.Description;
                IssBankStatementLineCZB."Account No." := IssuedBankStatementLine."Account No.";
                IssBankStatementLineCZB."Variable Symbol" := IssuedBankStatementLine."Variable Symbol";
                IssBankStatementLineCZB."Constant Symbol" := IssuedBankStatementLine."Constant Symbol";
                IssBankStatementLineCZB."Specific Symbol" := IssuedBankStatementLine."Specific Symbol";
                IssBankStatementLineCZB.Amount := IssuedBankStatementLine.Amount;
                IssBankStatementLineCZB."Amount (LCY)" := IssuedBankStatementLine."Amount (LCY)";
                IssBankStatementLineCZB.Positive := IssuedBankStatementLine.Positive;
                IssBankStatementLineCZB."Transit No." := IssuedBankStatementLine."Transit No.";
                IssBankStatementLineCZB."Currency Code" := IssuedBankStatementLine."Currency Code";
                IssBankStatementLineCZB."Bank Statement Currency Code" := IssuedBankStatementLine."Bank Statement Currency Code";
                IssBankStatementLineCZB."Amount (Bank Stat. Currency)" := IssuedBankStatementLine."Amount (Bank Stat. Currency)";
                IssBankStatementLineCZB."Bank Statement Currency Factor" := IssuedBankStatementLine."Bank Statement Currency Factor";
                IssBankStatementLineCZB.IBAN := IssuedBankStatementLine.IBAN;
                IssBankStatementLineCZB."SWIFT Code" := IssuedBankStatementLine."SWIFT Code";
                IssBankStatementLineCZB.Name := IssuedBankStatementLine.Name;
                IssBankStatementLineCZB.Modify(false);
            until IssuedBankStatementLine.Next() = 0;
    end;

    local procedure CopyIssuedPaymentOrderHeader();
    var
        IssuedPaymentOrderHeader: Record "Issued Payment Order Header";
        IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB";
    begin
        if IssuedPaymentOrderHeader.FindSet() then
            repeat
                if not IssPaymentOrderHeaderCZB.Get(IssuedPaymentOrderHeader."No.") then begin
                    IssPaymentOrderHeaderCZB.Init();
                    IssPaymentOrderHeaderCZB."No." := IssuedPaymentOrderHeader."No.";
                    IssPaymentOrderHeaderCZB.SystemId := IssuedPaymentOrderHeader.SystemId;
                    IssPaymentOrderHeaderCZB.Insert(false, true);
                end;
                IssPaymentOrderHeaderCZB."No. Series" := IssuedPaymentOrderHeader."No. Series";
                IssPaymentOrderHeaderCZB."Bank Account No." := IssuedPaymentOrderHeader."Bank Account No.";
                IssPaymentOrderHeaderCZB."Account No." := IssuedPaymentOrderHeader."Account No.";
                IssPaymentOrderHeaderCZB."Document Date" := IssuedPaymentOrderHeader."Document Date";
                IssPaymentOrderHeaderCZB."Currency Code" := IssuedPaymentOrderHeader."Currency Code";
                IssPaymentOrderHeaderCZB."Currency Factor" := IssuedPaymentOrderHeader."Currency Factor";
                IssPaymentOrderHeaderCZB."Payment Order Currency Code" := IssuedPaymentOrderHeader."Payment Order Currency Code";
                IssPaymentOrderHeaderCZB."Payment Order Currency Factor" := IssuedPaymentOrderHeader."Payment Order Currency Factor";
                IssPaymentOrderHeaderCZB."Pre-Assigned No. Series" := IssuedPaymentOrderHeader."Pre-Assigned No. Series";
                IssPaymentOrderHeaderCZB."Pre-Assigned No." := IssuedPaymentOrderHeader."Pre-Assigned No.";
                IssPaymentOrderHeaderCZB."Pre-Assigned User ID" := IssuedPaymentOrderHeader."Pre-Assigned User ID";
                IssPaymentOrderHeaderCZB."External Document No." := IssuedPaymentOrderHeader."External Document No.";
                IssPaymentOrderHeaderCZB."No. Exported" := IssuedPaymentOrderHeader."No. Exported";
                IssPaymentOrderHeaderCZB."File Name" := IssuedPaymentOrderHeader."File Name";
                IssPaymentOrderHeaderCZB."Foreign Payment Order" := IssuedPaymentOrderHeader."Foreign Payment Order";
                IssPaymentOrderHeaderCZB.IBAN := IssuedPaymentOrderHeader.IBAN;
                IssPaymentOrderHeaderCZB."SWIFT Code" := IssuedPaymentOrderHeader."SWIFT Code";
                IssPaymentOrderHeaderCZB."Unreliable Pay. Check DateTime" := IssuedPaymentOrderHeader."Uncertainty Pay.Check DateTime";
                IssPaymentOrderHeaderCZB.Modify(false);
            until IssuedPaymentOrderHeader.Next() = 0;
    end;

    local procedure CopyIssuedPaymentOrderLine();
    var
        IssuedPaymentOrderLine: Record "Issued Payment Order Line";
        IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB";
    begin
        if IssuedPaymentOrderLine.FindSet() then
            repeat
                if not IssPaymentOrderLineCZB.Get(IssuedPaymentOrderLine."Payment Order No.", IssuedPaymentOrderLine."Line No.") then begin
                    IssPaymentOrderLineCZB.Init();
                    IssPaymentOrderLineCZB."Payment Order No." := IssuedPaymentOrderLine."Payment Order No.";
                    IssPaymentOrderLineCZB."Line No." := IssuedPaymentOrderLine."Line No.";
                    IssPaymentOrderLineCZB.SystemId := IssuedPaymentOrderLine.SystemId;
                    IssPaymentOrderLineCZB.Insert(false, true);
                end;
                IssPaymentOrderLineCZB.Type := IssuedPaymentOrderLine.Type;
                IssPaymentOrderLineCZB."No." := IssuedPaymentOrderLine."No.";
                IssPaymentOrderLineCZB."Cust./Vendor Bank Account Code" := IssuedPaymentOrderLine."Cust./Vendor Bank Account Code";
                IssPaymentOrderLineCZB.Description := IssuedPaymentOrderLine.Description;
                IssPaymentOrderLineCZB."Account No." := IssuedPaymentOrderLine."Account No.";
                IssPaymentOrderLineCZB."Variable Symbol" := IssuedPaymentOrderLine."Variable Symbol";
                IssPaymentOrderLineCZB."Constant Symbol" := IssuedPaymentOrderLine."Constant Symbol";
                IssPaymentOrderLineCZB."Specific Symbol" := IssuedPaymentOrderLine."Specific Symbol";
                IssPaymentOrderLineCZB.Amount := IssuedPaymentOrderLine.Amount;
                IssPaymentOrderLineCZB."Amount (LCY)" := IssuedPaymentOrderLine."Amount (LCY)";
                IssPaymentOrderLineCZB."Applies-to Doc. Type" := IssuedPaymentOrderLine."Applies-to Doc. Type";
                IssPaymentOrderLineCZB."Applies-to Doc. No." := IssuedPaymentOrderLine."Applies-to Doc. No.";
                IssPaymentOrderLineCZB."Applies-to C/V/E Entry No." := IssuedPaymentOrderLine."Applies-to C/V/E Entry No.";
                IssPaymentOrderLineCZB.Positive := IssuedPaymentOrderLine.Positive;
                IssPaymentOrderLineCZB."Transit No." := IssuedPaymentOrderLine."Transit No.";
                IssPaymentOrderLineCZB."Currency Code" := IssuedPaymentOrderLine."Currency Code";
                IssPaymentOrderLineCZB."Applied Currency Code" := IssuedPaymentOrderLine."Applied Currency Code";
                IssPaymentOrderLineCZB."Payment Order Currency Code" := IssuedPaymentOrderLine."Payment Order Currency Code";
                IssPaymentOrderLineCZB."Amount(Payment Order Currency)" := IssuedPaymentOrderLine."Amount(Payment Order Currency)";
                IssPaymentOrderLineCZB."Payment Order Currency Factor" := IssuedPaymentOrderLine."Payment Order Currency Factor";
                IssPaymentOrderLineCZB."Due Date" := IssuedPaymentOrderLine."Due Date";
                IssPaymentOrderLineCZB.IBAN := IssuedPaymentOrderLine.IBAN;
                IssPaymentOrderLineCZB."SWIFT Code" := IssuedPaymentOrderLine."SWIFT Code";
                IssPaymentOrderLineCZB.Status := IssuedPaymentOrderLine.Status;
                IssPaymentOrderLineCZB.Name := IssuedPaymentOrderLine.Name;
                IssPaymentOrderLineCZB."VAT Unreliable Payer" := IssuedPaymentOrderLine."VAT Uncertainty Payer";
                IssPaymentOrderLineCZB."Public Bank Account" := IssuedPaymentOrderLine."Public Bank Account";
                IssPaymentOrderLineCZB."Third Party Bank Account" := IssuedPaymentOrderLine."Third Party Bank Account";
                IssPaymentOrderLineCZB."Payment Method Code" := IssuedPaymentOrderLine."Payment Method Code";
                IssPaymentOrderLineCZB.Modify(false);
            until IssuedPaymentOrderLine.Next() = 0;
    end;

    local procedure CopyUserSetup();
    var
        UserSetup: Record "User Setup";
        UserSetupDataTransfer: DataTransfer;
    begin
        UserSetupDataTransfer.SetTables(Database::"User Setup", Database::"User Setup");
        UserSetupDataTransfer.AddFieldValue(UserSetup.FieldNo("Check Payment Orders"), UserSetup.FieldNo("Check Payment Orders CZB"));
        UserSetupDataTransfer.AddFieldValue(UserSetup.FieldNo("Check Bank Statements"), UserSetup.FieldNo("Check Bank Statements CZB"));
        UserSetupDataTransfer.AddFieldValue(UserSetup.FieldNo("Bank Amount Approval Limit"), UserSetup.FieldNo("Bank Amount Approval Limit CZB"));
        UserSetupDataTransfer.AddFieldValue(UserSetup.FieldNo("Unlimited Bank Approval"), UserSetup.FieldNo("Unlimited Bank Approval CZB"));
        UserSetupDataTransfer.CopyFields();
    end;

    local procedure CopyBankExportImportSetup();
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
        BankExportImportSetupDataTransfer: DataTransfer;
    begin
        BankExportImportSetupDataTransfer.SetTables(Database::"Bank Export/Import Setup", Database::"Bank Export/Import Setup");
        BankExportImportSetupDataTransfer.AddFieldValue(BankExportImportSetup.FieldNo("Processing Report ID"), BankExportImportSetup.FieldNo("Processing Report ID CZB"));
        BankExportImportSetupDataTransfer.AddFieldValue(BankExportImportSetup.FieldNo("Default File Type"), BankExportImportSetup.FieldNo("Default File Type CZB"));
        BankExportImportSetupDataTransfer.CopyFields();
    end;

    local procedure CopyPaymentExportData();
    var
        PaymentExportData: Record "Payment Export Data";
        PaymentExportDataDataTransfer: DataTransfer;
    begin
        PaymentExportDataDataTransfer.SetTables(Database::"Payment Export Data", Database::"Payment Export Data");
        PaymentExportDataDataTransfer.AddFieldValue(PaymentExportData.FieldNo("Specific Symbol"), PaymentExportData.FieldNo("Specific Symbol CZB"));
        PaymentExportDataDataTransfer.AddFieldValue(PaymentExportData.FieldNo("Variable Symbol"), PaymentExportData.FieldNo("Variable Symbol CZB"));
        PaymentExportDataDataTransfer.AddFieldValue(PaymentExportData.FieldNo("Constant Symbol"), PaymentExportData.FieldNo("Constant Symbol CZB"));
        PaymentExportDataDataTransfer.CopyFields();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    var
        DataClassEvalHandlerCZB: Codeunit "Data Class. Eval. Handler CZB";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        CreateExpLauncherSEPA();

        DataClassEvalHandlerCZB.ApplyEvaluationClassificationsForPrivacy();
        UpgradeTag.SetAllUpgradeTags();
    end;

    local procedure CreateExpLauncherSEPA()
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
        SEPACZCodeTok: Label 'SEPACZ', Locked = true;
    begin
        if not BankExportImportSetup.Get(SEPACZCodeTok) then
            InitExpLauncherSEPA();
    end;

    local procedure InitExpLauncherSEPA()
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
        SEPACZCodeTok: Label 'SEPACZPAIN00100109', Locked = true;
        SEPACZNameTxt: Label 'SEPA Czech - payment orders pain.001.001.09';
    begin
        if not BankExportImportSetup.Get(SEPACZCodeTok) then begin
            BankExportImportSetup.Init();
            BankExportImportSetup.Code := SEPACZCodeTok;
            BankExportImportSetup.Insert();
        end;
        BankExportImportSetup.Name := SEPACZNameTxt;
        BankExportImportSetup.Direction := BankExportImportSetup.Direction::Export;
        BankExportImportSetup."Processing Codeunit ID" := Codeunit::"Export Launcher SEPA CZB";
        BankExportImportSetup."Processing XMLport ID" := XmlPort::"SEPA CT pain.001.001.09";
        BankExportImportSetup."Check Export Codeunit" := Codeunit::"SEPA CT-Check Line";
        BankExportImportSetup."Preserve Non-Latin Characters" := false;
        BankExportImportSetup.Modify();
    end;
}
