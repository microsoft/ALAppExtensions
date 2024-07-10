// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft;
using Microsoft.Bank.BankAccount;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.Comment;
using Microsoft.Foundation.Company;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Service.Document;
using Microsoft.Service.History;
using System.Security.User;
using System.Upgrade;

#pragma warning disable AL0432,AL0603
codeunit 31054 "Install Application CZP"
{
    Subtype = install;
    Permissions = tabledata "Cash Desk CZP" = im,
                  tabledata "Comment Line" = i,
                  tabledata "Default Dimension" = i,
                  tabledata "Cash Desk User CZP" = im,
                  tabledata "Cash Desk Event CZP" = im,
                  tabledata "Cash Document Header CZP" = im,
                  tabledata "Cash Document Line CZP" = im,
                  tabledata "Posted Cash Document Hdr. CZP" = im,
                  tabledata "Posted Cash Document Line CZP" = im,
                  tabledata "Currency Nominal Value CZP" = i,
                  tabledata "Source Code" = i,
                  tabledata "Cash Desk Rep. Selections CZP" = i,
                  tabledata "Bank Account" = m,
                  tabledata "Payment Method" = m,
                  tabledata "Sales Header" = m,
                  tabledata "Sales Invoice Header" = m,
                  tabledata "Sales Cr.Memo Header" = m,
                  tabledata "Purchase Header" = m,
                  tabledata "Purch. Inv. Header" = m,
                  tabledata "Purch. Cr. Memo Hdr." = m,
                  tabledata "Service Header" = m,
                  tabledata "Service Invoice Header" = m,
                  tabledata "Service Cr.Memo Header" = m,
                  tabledata "Source Code Setup" = m,
                  tabledata "User Setup" = m,
                  tabledata "General Ledger Setup" = m;

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
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Cash Document Header", Database::"Cash Document Header CZP");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Cash Document Line", Database::"Cash Document Line CZP");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Posted Cash Document Header", Database::"Posted Cash Document Hdr. CZP");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Posted Cash Document Line", Database::"Posted Cash Document Line CZP");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Currency Nominal Value", Database::"Currency Nominal Value CZP");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Bank Account", Database::"Cash Desk CZP");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Cash Desk User", Database::"Cash Desk User CZP");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Cash Desk Event", Database::"Cash Desk Event CZP");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Cash Desk Cue", Database::"Cash Desk Cue CZP");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Cash Desk Report Selections", Database::"Cash Desk Rep. Selections CZP");
    end;

    local procedure CopyUsage();
    begin
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Cash Document Header", Database::"Cash Document Header CZP");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Cash Document Line", Database::"Cash Document Line CZP");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Posted Cash Document Header", Database::"Posted Cash Document Hdr. CZP");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Posted Cash Document Line", Database::"Posted Cash Document Line CZP");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Currency Nominal Value", Database::"Currency Nominal Value CZP");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Bank Account", Database::"Cash Desk CZP");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Cash Desk User", Database::"Cash Desk User CZP");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Cash Desk Event", Database::"Cash Desk Event CZP");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Cash Desk Cue", Database::"Cash Desk Cue CZP");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Cash Desk Report Selections", Database::"Cash Desk Rep. Selections CZP");
    end;

    local procedure CopyData()
    begin
        CopyCashDesk();
        CopyCashDeskUser();
        CopyCashDeskEvent();
        CopyCashDocumentHeader();
        CopyCashDocumentLine();
        CopyPostedCashDocumentHeader();
        CopyPostedCashDocumentLine();
        CopyPaymentMethod();
        CopySalesHeader();
        CopySalesInvoiceHeader();
        CopySalesCrMemoHeader();
        CopyPurchaseHeader();
        CopyPurchaseInvoiceHeader();
        CopyPurchaseCrMemoHeader();
        CopyServiceHeader();
        CopyServiceInvoiceHeader();
        CopyServiceCrMemoHeader();
        CopySourceCodeSetup();
        CopyUserSetup();
        CopyGeneralLedgerSetup();
        CopyCurrencyNominalValue();
        InitCashDeskSourceCode();
    end;

    local procedure CopyCashDesk();
    var
        BankAccount: Record "Bank Account";
        CashDeskCZP: Record "Cash Desk CZP";
        BankAccountCommentLine: Record "Comment Line";
        CashDeskCommentLine: Record "Comment Line";
        BankAccountDefaultDimension: Record "Default Dimension";
        CashDeskDefaultDimension: Record "Default Dimension";
    begin
        BankAccount.SetRange("Account Type", BankAccount."Account Type"::"Cash Desk");
        if BankAccount.FindSet(true) then
            repeat
                if not CashDeskCZP.Get(BankAccount."No.") then begin
                    CashDeskCZP.Init();
                    CashDeskCZP."No." := BankAccount."No.";
                    CashDeskCZP.SystemId := BankAccount.SystemId;
                    CashDeskCZP.Insert(false, true);
                end;
                CashDeskCZP.Name := BankAccount.Name;
                CashDeskCZP."Search Name" := BankAccount."Search Name";
                CashDeskCZP."Name 2" := BankAccount."Name 2";
                CashDeskCZP.Address := BankAccount.Address;
                CashDeskCZP."Address 2" := BankAccount."Address 2";
                CashDeskCZP.City := BankAccount.City;
                CashDeskCZP.Contact := BankAccount.Contact;
                CashDeskCZP."Phone No." := BankAccount."Phone No.";
                CashDeskCZP."Global Dimension 1 Code" := BankAccount."Global Dimension 1 Code";
                CashDeskCZP."Global Dimension 2 Code" := BankAccount."Global Dimension 2 Code";
                CashDeskCZP."Bank Acc. Posting Group" := BankAccount."Bank Acc. Posting Group";
                CashDeskCZP."Currency Code" := BankAccount."Currency Code";
                CashDeskCZP."Language Code" := BankAccount."Language Code";
                CashDeskCZP."Country/Region Code" := BankAccount."Country/Region Code";
                CashDeskCZP."Post Code" := BankAccount."Post Code";
                CashDeskCZP.County := BankAccount.County;
                CashDeskCZP."E-Mail" := BankAccount."E-Mail";
                CashDeskCZP.Blocked := BankAccount.Blocked;
                CashDeskCZP."No. Series" := BankAccount."No. Series";
                CashDeskCZP."Min. Balance" := BankAccount."Min. Balance";
                CashDeskCZP."Min. Balance Checking" := BankAccount."Min. Balance Checking";
                CashDeskCZP."Max. Balance" := BankAccount."Max. Balance";
                CashDeskCZP."Max. Balance Checking" := BankAccount."Max. Balance Checking";
                CashDeskCZP."Allow VAT Difference" := BankAccount."Allow VAT Difference";
                CashDeskCZP."Payed To/By Checking" := BankAccount."Payed To/By Checking";
                CashDeskCZP."Reason Code" := BankAccount."Reason Code";
                CashDeskCZP."Amounts Including VAT" := BankAccount."Amounts Including VAT";
                CashDeskCZP."Confirm Inserting of Document" := BankAccount."Confirm Inserting of Document";
                CashDeskCZP."Debit Rounding Account" := BankAccount."Debit Rounding Account";
                CashDeskCZP."Credit Rounding Account" := BankAccount."Credit Rounding Account";
                CashDeskCZP."Rounding Method Code" := BankAccount."Rounding Method Code";
                CashDeskCZP."Responsibility ID (Release)" := BankAccount."Responsibility ID (Release)";
                CashDeskCZP."Responsibility ID (Post)" := BankAccount."Responsibility ID (Post)";
                CashDeskCZP."Responsibility Center" := BankAccount."Responsibility Center";
                CashDeskCZP."Amount Rounding Precision" := BankAccount."Amount Rounding Precision";
                CashDeskCZP."Cash Document Receipt Nos." := BankAccount."Cash Document Receipt Nos.";
                CashDeskCZP."Cash Document Withdrawal Nos." := BankAccount."Cash Document Withdrawal Nos.";
                CashDeskCZP."Cash Receipt Limit" := BankAccount."Cash Receipt Limit";
                CashDeskCZP."Cash Withdrawal Limit" := BankAccount."Cash Withdrawal Limit";
                CashDeskCZP."Exclude from Exch. Rate Adj." := BankAccount."Exclude from Exch. Rate Adj.";
                CashDeskCZP."Cashier No." := BankAccount."Cashier No.";
                CashDeskCZP.Modify(false);

                BankAccount."Account Type CZP" := BankAccount."Account Type CZP"::"Cash Desk";
                BankAccount.Modify(false);

                BankAccountCommentLine.SetRange("Table Name", BankAccountCommentLine."Table Name"::"Bank Account");
                BankAccountCommentLine.SetRange("No.", BankAccount."No.");
                if BankAccountCommentLine.FindSet() then
                    repeat
                        CashDeskCommentLine := BankAccountCommentLine;
                        CashDeskCommentLine."Table Name" := BankAccountCommentLine."Table Name"::"Cash Desk CZP";
                        CashDeskCommentLine.Insert(false);
                    until BankAccountCommentLine.Next() = 0;

                BankAccountDefaultDimension.SetRange("Table ID", Database::"Bank Account");
                BankAccountDefaultDimension.SetRange("No.", BankAccount."No.");
                if BankAccountDefaultDimension.FindSet() then
                    repeat
                        CashDeskDefaultDimension := BankAccountDefaultDimension;
                        CashDeskDefaultDimension."Table ID" := Database::"Cash Desk CZP";
                        CashDeskDefaultDimension.Insert(false);
                    until BankAccountDefaultDimension.Next() = 0;
            until BankAccount.Next() = 0;
    end;

    local procedure CopyCashDeskUser();
    var
        CashDeskUser: Record "Cash Desk User";
        CashDeskUserCZP: Record "Cash Desk User CZP";
    begin
        if CashDeskUser.FindSet() then
            repeat
                if not CashDeskUserCZP.Get(CashDeskUser."Cash Desk No.", CashDeskUser."User ID") then begin
                    CashDeskUserCZP.Init();
                    CashDeskUserCZP."Cash Desk No." := CashDeskUser."Cash Desk No.";
                    CashDeskUserCZP."User ID" := CashDeskUser."User ID";
                    CashDeskUserCZP.SystemId := CashDeskUser.SystemId;
                    CashDeskUserCZP.Insert(false, true);
                end;
                CashDeskUserCZP.Create := CashDeskUser.Create;
                CashDeskUserCZP.Issue := CashDeskUser.Issue;
                CashDeskUserCZP.Post := CashDeskUser.Post;
                CashDeskUserCZP."Post EET Only" := CashDeskUser."Post EET Only";
                CashDeskUserCZP."User Full Name" := CashDeskUser."User Name";
                CashDeskUserCZP.Modify(false);
            until CashDeskUser.Next() = 0;
    end;

    local procedure CopyCashDeskEvent();
    var
        CashDeskEvent: Record "Cash Desk Event";
        CashDeskEventCZP: Record "Cash Desk Event CZP";
    begin
        if CashDeskEvent.FindSet() then
            repeat
                if not CashDeskEventCZP.Get(CashDeskEvent.Code) then begin
                    CashDeskEventCZP.Init();
                    CashDeskEventCZP.Code := CashDeskEvent.Code;
                    CashDeskEventCZP.SystemId := CashDeskEvent.SystemId;
                    CashDeskEventCZP.Insert(false, true);
                end;
                CashDeskEventCZP."Cash Desk No." := CashDeskEvent."Cash Desk No.";
                CashDeskEventCZP."Document Type" := CashDeskEvent."Cash Document Type";
                CashDeskEventCZP.Description := CashDeskEvent.Description;
                CashDeskEventCZP."Account Type" := CashDeskEvent."Account Type";
                CashDeskEventCZP."Account No." := CashDeskEvent."Account No.";
                CashDeskEventCZP."Gen. Document Type" := "Cash Document Gen.Doc.Type CZP".FromInteger(CashDeskEvent."Document Type");
                CashDeskEventCZP."Global Dimension 1 Code" := CashDeskEvent."Global Dimension 1 Code";
                CashDeskEventCZP."Global Dimension 2 Code" := CashDeskEvent."Global Dimension 2 Code";
                CashDeskEventCZP."Gen. Posting Type" := CashDeskEvent."Gen. Posting Type";
                CashDeskEventCZP."EET Transaction" := CashDeskEvent."EET Transaction";
                CashDeskEventCZP."VAT Bus. Posting Group" := CashDeskEvent."VAT Bus. Posting Group";
                CashDeskEventCZP."VAT Prod. Posting Group" := CashDeskEventCZP."VAT Prod. Posting Group";
                CashDeskEventCZP.Modify(false);
            until CashDeskEvent.Next() = 0;
    end;

    local procedure CopyCashDocumentHeader();
    var
        CashDocumentHeader: Record "Cash Document Header";
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
    begin
        if CashDocumentHeader.FindSet() then
            repeat
                if not CashDocumentHeaderCZP.Get(CashDocumentHeader."Cash Desk No.", CashDocumentHeader."No.") then begin
                    CashDocumentHeaderCZP.Init();
                    CashDocumentHeaderCZP."Cash Desk No." := CashDocumentHeader."Cash Desk No.";
                    CashDocumentHeaderCZP."No." := CashDocumentHeader."No.";
                    CashDocumentHeaderCZP.SystemId := CashDocumentHeader.SystemId;
                    CashDocumentHeaderCZP.Insert(false, true);
                end;
                CashDocumentHeaderCZP."Pay-to/Receive-from Name" := CashDocumentHeader."Pay-to/Receive-from Name";
                CashDocumentHeaderCZP."Pay-to/Receive-from Name 2" := CashDocumentHeader."Pay-to/Receive-from Name 2";
                CashDocumentHeaderCZP."Posting Date" := CashDocumentHeader."Posting Date";
                CashDocumentHeaderCZP.Status := CashDocumentHeader.Status;
                CashDocumentHeaderCZP."No. Printed" := CashDocumentHeader."No. Printed";
                CashDocumentHeaderCZP."Created ID" := CashDocumentHeader."Created ID";
                CashDocumentHeaderCZP."Released ID" := CashDocumentHeader."Released ID";
                CashDocumentHeaderCZP."Document Type" := CashDocumentHeader."Cash Document Type";
                CashDocumentHeaderCZP."No. Series" := CashDocumentHeader."No. Series";
                CashDocumentHeaderCZP."Currency Code" := CashDocumentHeader."Currency Code";
                CashDocumentHeaderCZP."Shortcut Dimension 1 Code" := CashDocumentHeader."Shortcut Dimension 1 Code";
                CashDocumentHeaderCZP."Shortcut Dimension 2 Code" := CashDocumentHeader."Shortcut Dimension 2 Code";
                CashDocumentHeaderCZP."Currency Factor" := CashDocumentHeader."Currency Factor";
                CashDocumentHeaderCZP."Document Date" := CashDocumentHeader."Document Date";
                CashDocumentHeaderCZP."VAT Date" := CashDocumentHeader."VAT Date";
                CashDocumentHeaderCZP."Created Date" := CashDocumentHeader."Created Date";
                CashDocumentHeaderCZP.Description := CashDocumentHeader.Description;
                CashDocumentHeaderCZP."Salespers./Purch. Code" := CashDocumentHeader."Salespers./Purch. Code";
                CashDocumentHeaderCZP."Amounts Including VAT" := CashDocumentHeader."Amounts Including VAT";
                CashDocumentHeaderCZP."Released Amount" := CashDocumentHeader."Released Amount";
                CashDocumentHeaderCZP."Reason Code" := CashDocumentHeader."Reason Code";
                CashDocumentHeaderCZP."External Document No." := CashDocumentHeader."External Document No.";
                CashDocumentHeaderCZP."Responsibility Center" := CashDocumentHeader."Responsibility Center";
                CashDocumentHeaderCZP."Payment Purpose" := CashDocumentHeader."Payment Purpose";
                CashDocumentHeaderCZP."Received By" := CashDocumentHeader."Received By";
                CashDocumentHeaderCZP."Identification Card No." := CashDocumentHeader."Identification Card No.";
                CashDocumentHeaderCZP."Paid By" := CashDocumentHeader."Paid By";
                CashDocumentHeaderCZP."Received From" := CashDocumentHeader."Received From";
                CashDocumentHeaderCZP."Paid To" := CashDocumentHeader."Paid To";
                CashDocumentHeaderCZP."Registration No." := CashDocumentHeader."Registration No.";
                CashDocumentHeaderCZP."VAT Registration No." := CashDocumentHeader."VAT Registration No.";
                CashDocumentHeaderCZP."Partner Type" := CashDocumentHeader."Partner Type";
                CashDocumentHeaderCZP."Partner No." := CashDocumentHeader."Partner No.";
                CashDocumentHeaderCZP."Canceled Document" := CashDocumentHeader."Canceled Document";
                CashDocumentHeaderCZP."Dimension Set ID" := CashDocumentHeader."Dimension Set ID";
                CashDocumentHeaderCZP.Modify(false);
            until CashDocumentHeader.Next() = 0;
    end;

    local procedure CopyCashDocumentLine();
    var
        CashDocumentLine: Record "Cash Document Line";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        if CashDocumentLine.FindSet() then
            repeat
                if not CashDocumentLineCZP.Get(CashDocumentLine."Cash Desk No.", CashDocumentLine."Cash Document No.", CashDocumentLine."Line No.") then begin
                    CashDocumentLineCZP.Init();
                    CashDocumentLineCZP."Cash Desk No." := CashDocumentLine."Cash Desk No.";
                    CashDocumentLineCZP."Cash Document No." := CashDocumentLine."Cash Document No.";
                    CashDocumentLineCZP."Line No." := CashDocumentLine."Line No.";
                    CashDocumentLineCZP.SystemId := CashDocumentLine.SystemId;
                    CashDocumentLineCZP.Insert(false, true);
                end;
                CashDocumentLineCZP."Gen. Document Type" := CashDocumentLine."Document Type";
                CashDocumentLineCZP."Account Type" := CashDocumentLine."Account Type";
                CashDocumentLineCZP."Account No." := CashDocumentLine."Account No.";
                CashDocumentLineCZP."External Document No." := CashDocumentLine."External Document No.";
                CashDocumentLineCZP."Posting Group" := CashDocumentLine."Posting Group";
                CashDocumentLineCZP."Applies-To Doc. Type" := CashDocumentLine."Applies-To Doc. Type";
                CashDocumentLineCZP."Applies-To Doc. No." := CashDocumentLine."Applies-To Doc. No.";
                CashDocumentLineCZP.Description := CashDocumentLine.Description;
                CashDocumentLineCZP.Amount := CashDocumentLine.Amount;
                CashDocumentLineCZP."Amount (LCY)" := CashDocumentLine."Amount (LCY)";
                CashDocumentLineCZP."Description 2" := CashDocumentLine."Description 2";
                CashDocumentLineCZP."Shortcut Dimension 1 Code" := CashDocumentLine."Shortcut Dimension 1 Code";
                CashDocumentLineCZP."Shortcut Dimension 2 Code" := CashDocumentLine."Shortcut Dimension 2 Code";
                CashDocumentLineCZP."Document Type" := CashDocumentLine."Cash Document Type";
                CashDocumentLineCZP."Applies-to ID" := CashDocumentLine."Applies-to ID";
                CashDocumentLineCZP."Currency Code" := CashDocumentLine."Currency Code";
                CashDocumentLineCZP."Cash Desk Event" := CashDocumentLine."Cash Desk Event";
                CashDocumentLineCZP."Salespers./Purch. Code" := CashDocumentLine."Salespers./Purch. Code";
                CashDocumentLineCZP."Reason Code" := CashDocumentLine."Reason Code";
                CashDocumentLineCZP."VAT Base Amount" := CashDocumentLine."VAT Base Amount";
                CashDocumentLineCZP."Amount Including VAT" := CashDocumentLine."Amount Including VAT";
                CashDocumentLineCZP."VAT Amount" := CashDocumentLine."VAT Amount";
                CashDocumentLineCZP."VAT Base Amount (LCY)" := CashDocumentLine."VAT Base Amount (LCY)";
                CashDocumentLineCZP."Amount Including VAT (LCY)" := CashDocumentLine."Amount Including VAT (LCY)";
                CashDocumentLineCZP."VAT Amount (LCY)" := CashDocumentLine."VAT Amount (LCY)";
                CashDocumentLineCZP."VAT Difference" := CashDocumentLine."VAT Difference";
                CashDocumentLineCZP."VAT %" := CashDocumentLine."VAT %";
                CashDocumentLineCZP."VAT Identifier" := CashDocumentLine."VAT Identifier";
                CashDocumentLineCZP."System-Created Entry" := CashDocumentLine."System-Created Entry";
                CashDocumentLineCZP."Gen. Posting Type" := CashDocumentLine."Gen. Posting Type";
                CashDocumentLineCZP."VAT Calculation Type" := CashDocumentLine."VAT Calculation Type";
                CashDocumentLineCZP."VAT Bus. Posting Group" := CashDocumentLine."VAT Bus. Posting Group";
                CashDocumentLineCZP."VAT Prod. Posting Group" := CashDocumentLine."VAT Prod. Posting Group";
                CashDocumentLineCZP."Use Tax" := CashDocumentLine."Use Tax";
                CashDocumentLineCZP."FA Posting Type" := CashDocumentLine."FA Posting Type";
                CashDocumentLineCZP."Depreciation Book Code" := CashDocumentLine."Depreciation Book Code";
                CashDocumentLineCZP."Maintenance Code" := CashDocumentLine."Maintenance Code";
                CashDocumentLineCZP."Duplicate in Depreciation Book" := CashDocumentLine."Duplicate in Depreciation Book";
                CashDocumentLineCZP."Use Duplication List" := CashDocumentLine."Use Duplication List";
                CashDocumentLineCZP."Responsibility Center" := CashDocumentLine."Responsibility Center";
                CashDocumentLineCZP."EET Transaction" := CashDocumentLine."EET Transaction";
                CashDocumentLineCZP."Dimension Set ID" := CashDocumentLine."Dimension Set ID";
                CashDocumentLineCZP.Modify(false);
            until CashDocumentLine.Next() = 0;
    end;

    local procedure CopyPostedCashDocumentHeader();
    var
        PostedCashDocumentHeader: Record "Posted Cash Document Header";
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
    begin
        if PostedCashDocumentHeader.FindSet() then
            repeat
                if not PostedCashDocumentHdrCZP.Get(PostedCashDocumentHeader."Cash Desk No.", PostedCashDocumentHeader."No.") then begin
                    PostedCashDocumentHdrCZP.Init();
                    PostedCashDocumentHdrCZP."Cash Desk No." := PostedCashDocumentHeader."Cash Desk No.";
                    PostedCashDocumentHdrCZP."No." := PostedCashDocumentHeader."No.";
                    PostedCashDocumentHdrCZP.SystemId := PostedCashDocumentHeader.SystemId;
                    PostedCashDocumentHdrCZP.Insert(false, true);
                end;
                PostedCashDocumentHdrCZP."Pay-to/Receive-from Name" := PostedCashDocumentHeader."Pay-to/Receive-from Name";
                PostedCashDocumentHdrCZP."Pay-to/Receive-from Name 2" := PostedCashDocumentHeader."Pay-to/Receive-from Name 2";
                PostedCashDocumentHdrCZP."Posting Date" := PostedCashDocumentHeader."Posting Date";
                PostedCashDocumentHdrCZP."No. Printed" := PostedCashDocumentHeader."No. Printed";
                PostedCashDocumentHdrCZP."Created ID" := PostedCashDocumentHeader."Created ID";
                PostedCashDocumentHdrCZP."Released ID" := PostedCashDocumentHeader."Released ID";
                PostedCashDocumentHdrCZP."Document Type" := PostedCashDocumentHeader."Cash Document Type";
                PostedCashDocumentHdrCZP."No. Series" := PostedCashDocumentHeader."No. Series";
                PostedCashDocumentHdrCZP."Currency Code" := PostedCashDocumentHeader."Currency Code";
                PostedCashDocumentHdrCZP."Shortcut Dimension 1 Code" := PostedCashDocumentHeader."Shortcut Dimension 1 Code";
                PostedCashDocumentHdrCZP."Shortcut Dimension 2 Code" := PostedCashDocumentHeader."Shortcut Dimension 2 Code";
                PostedCashDocumentHdrCZP."Currency Factor" := PostedCashDocumentHeader."Currency Factor";
                PostedCashDocumentHdrCZP."Document Date" := PostedCashDocumentHeader."Document Date";
                PostedCashDocumentHdrCZP."VAT Date" := PostedCashDocumentHeader."VAT Date";
                PostedCashDocumentHdrCZP."Created Date" := PostedCashDocumentHeader."Created Date";
                PostedCashDocumentHdrCZP.Description := PostedCashDocumentHeader.Description;
                PostedCashDocumentHdrCZP."Salespers./Purch. Code" := PostedCashDocumentHeader."Salespers./Purch. Code";
                PostedCashDocumentHdrCZP."Amounts Including VAT" := PostedCashDocumentHeader."Amounts Including VAT";
                PostedCashDocumentHdrCZP."Reason Code" := PostedCashDocumentHeader."Reason Code";
                PostedCashDocumentHdrCZP."External Document No." := PostedCashDocumentHeader."External Document No.";
                PostedCashDocumentHdrCZP."Responsibility Center" := PostedCashDocumentHeader."Responsibility Center";
                PostedCashDocumentHdrCZP."Payment Purpose" := PostedCashDocumentHeader."Payment Purpose";
                PostedCashDocumentHdrCZP."Received By" := PostedCashDocumentHeader."Received By";
                PostedCashDocumentHdrCZP."Identification Card No." := PostedCashDocumentHeader."Identification Card No.";
                PostedCashDocumentHdrCZP."Paid By" := PostedCashDocumentHeader."Paid By";
                PostedCashDocumentHdrCZP."Received From" := PostedCashDocumentHeader."Received From";
                PostedCashDocumentHdrCZP."Paid To" := PostedCashDocumentHeader."Paid To";
                PostedCashDocumentHdrCZP."Registration No." := PostedCashDocumentHeader."Registration No.";
                PostedCashDocumentHdrCZP."VAT Registration No." := PostedCashDocumentHeader."VAT Registration No.";
                PostedCashDocumentHdrCZP."Partner Type" := PostedCashDocumentHeader."Partner Type";
                PostedCashDocumentHdrCZP."Partner No." := PostedCashDocumentHeader."Partner No.";
                PostedCashDocumentHdrCZP."Canceled Document" := PostedCashDocumentHeader."Canceled Document";
                PostedCashDocumentHdrCZP."EET Entry No." := PostedCashDocumentHeader."EET Entry No.";
                PostedCashDocumentHdrCZP."Dimension Set ID" := PostedCashDocumentHeader."Dimension Set ID";
                PostedCashDocumentHdrCZP.Modify(false);
            until PostedCashDocumentHeader.Next() = 0;
    end;

    local procedure CopyPostedCashDocumentLine();
    var
        PostedCashDocumentLine: Record "Posted Cash Document Line";
        PostedCashDocumentLineCZP: Record "Posted Cash Document Line CZP";
    begin
        if PostedCashDocumentLine.FindSet() then
            repeat
                if not PostedCashDocumentLineCZP.Get(PostedCashDocumentLine."Cash Desk No.", PostedCashDocumentLine."Cash Document No.", PostedCashDocumentLine."Line No.") then begin
                    PostedCashDocumentLineCZP.Init();
                    PostedCashDocumentLineCZP."Cash Desk No." := PostedCashDocumentLine."Cash Desk No.";
                    PostedCashDocumentLineCZP."Cash Document No." := PostedCashDocumentLine."Cash Document No.";
                    PostedCashDocumentLineCZP."Line No." := PostedCashDocumentLine."Line No.";
                    PostedCashDocumentLineCZP.SystemId := PostedCashDocumentLine.SystemId;
                    PostedCashDocumentLineCZP.Insert(false, true);
                end;
                PostedCashDocumentLineCZP."Gen. Document Type" := PostedCashDocumentLine."Document Type";
                PostedCashDocumentLineCZP."Account Type" := PostedCashDocumentLine."Account Type";
                PostedCashDocumentLineCZP."Account No." := PostedCashDocumentLine."Account No.";
                PostedCashDocumentLineCZP."External Document No." := PostedCashDocumentLine."External Document No.";
                PostedCashDocumentLineCZP."Posting Group" := PostedCashDocumentLine."Posting Group";
                PostedCashDocumentLineCZP.Description := PostedCashDocumentLine.Description;
                PostedCashDocumentLineCZP.Amount := PostedCashDocumentLine.Amount;
                PostedCashDocumentLineCZP."Amount (LCY)" := PostedCashDocumentLine."Amount (LCY)";
                PostedCashDocumentLineCZP."Description 2" := PostedCashDocumentLine."Description 2";
                PostedCashDocumentLineCZP."Shortcut Dimension 1 Code" := PostedCashDocumentLine."Shortcut Dimension 1 Code";
                PostedCashDocumentLineCZP."Shortcut Dimension 2 Code" := PostedCashDocumentLine."Shortcut Dimension 2 Code";
                PostedCashDocumentLineCZP."Document Type" := PostedCashDocumentLine."Cash Document Type";
                PostedCashDocumentLineCZP."Currency Code" := PostedCashDocumentLine."Currency Code";
                PostedCashDocumentLineCZP."Cash Desk Event" := PostedCashDocumentLine."Cash Desk Event";
                PostedCashDocumentLineCZP."Salespers./Purch. Code" := PostedCashDocumentLine."Salespers./Purch. Code";
                PostedCashDocumentLineCZP."Reason Code" := PostedCashDocumentLine."Reason Code";
                PostedCashDocumentLineCZP."VAT Base Amount" := PostedCashDocumentLine."VAT Base Amount";
                PostedCashDocumentLineCZP."Amount Including VAT" := PostedCashDocumentLine."Amount Including VAT";
                PostedCashDocumentLineCZP."VAT Amount" := PostedCashDocumentLine."VAT Amount";
                PostedCashDocumentLineCZP."VAT Base Amount (LCY)" := PostedCashDocumentLine."VAT Base Amount (LCY)";
                PostedCashDocumentLineCZP."Amount Including VAT (LCY)" := PostedCashDocumentLine."Amount Including VAT (LCY)";
                PostedCashDocumentLineCZP."VAT Amount (LCY)" := PostedCashDocumentLine."VAT Amount (LCY)";
                PostedCashDocumentLineCZP."VAT Difference" := PostedCashDocumentLine."VAT Difference";
                PostedCashDocumentLineCZP."VAT %" := PostedCashDocumentLine."VAT %";
                PostedCashDocumentLineCZP."VAT Identifier" := PostedCashDocumentLine."VAT Identifier";
                PostedCashDocumentLineCZP."System-Created Entry" := PostedCashDocumentLine."System-Created Entry";
                PostedCashDocumentLineCZP."Gen. Posting Type" := PostedCashDocumentLine."Gen. Posting Type";
                PostedCashDocumentLineCZP."VAT Calculation Type" := PostedCashDocumentLine."VAT Calculation Type";
                PostedCashDocumentLineCZP."VAT Bus. Posting Group" := PostedCashDocumentLine."VAT Bus. Posting Group";
                PostedCashDocumentLineCZP."VAT Prod. Posting Group" := PostedCashDocumentLine."VAT Prod. Posting Group";
                PostedCashDocumentLineCZP."Use Tax" := PostedCashDocumentLine."Use Tax";
                PostedCashDocumentLineCZP."FA Posting Type" := PostedCashDocumentLine."FA Posting Type";
                PostedCashDocumentLineCZP."Depreciation Book Code" := PostedCashDocumentLine."Depreciation Book Code";
                PostedCashDocumentLineCZP."Maintenance Code" := PostedCashDocumentLine."Maintenance Code";
                PostedCashDocumentLineCZP."Duplicate in Depreciation Book" := PostedCashDocumentLine."Duplicate in Depreciation Book";
                PostedCashDocumentLineCZP."Use Duplication List" := PostedCashDocumentLine."Use Duplication List";
                PostedCashDocumentLineCZP."Responsibility Center" := PostedCashDocumentLine."Responsibility Center";
                PostedCashDocumentLineCZP."EET Transaction" := PostedCashDocumentLine."EET Transaction";
                PostedCashDocumentLineCZP."Dimension Set ID" := PostedCashDocumentLine."Dimension Set ID";
                PostedCashDocumentLineCZP.Modify(false);
            until PostedCashDocumentLine.Next() = 0;
    end;

    local procedure CopyPaymentMethod();
    var
        PaymentMethod: Record "Payment Method";
    begin
        PaymentMethod.SetLoadFields("Cash Desk Code", "Cash Document Status");
        if PaymentMethod.FindSet(true) then
            repeat
                PaymentMethod."Cash Desk Code CZP" := PaymentMethod."Cash Desk Code";
                PaymentMethod."Cash Document Action CZP" := PaymentMethod."Cash Document Status";
                PaymentMethod."Cash Desk Code" := '';
                PaymentMethod."Cash Document Status" := PaymentMethod."Cash Document Status"::" ";
                PaymentMethod.Modify(false);
            until PaymentMethod.Next() = 0;
    end;

    local procedure CopySalesHeader();
    var
        SalesHeader: Record "Sales Header";
        SalesHeaderDataTransfer: DataTransfer;
    begin
        SalesHeaderDataTransfer.SetTables(Database::"Sales Header", Database::"Sales Header");
        SalesHeaderDataTransfer.AddFieldValue(SalesHeader.FieldNo("Cash Desk Code"), SalesHeader.FieldNo("Cash Desk Code CZP"));
        SalesHeaderDataTransfer.AddFieldValue(SalesHeader.FieldNo("Cash Document Status"), SalesHeader.FieldNo("Cash Document Action CZP"));
        SalesHeaderDataTransfer.CopyFields();
    end;

    local procedure CopySalesInvoiceHeader();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceHeaderDataTransfer: DataTransfer;
    begin
        SalesInvoiceHeaderDataTransfer.SetTables(Database::"Sales Invoice Header", Database::"Sales Invoice Header");
        SalesInvoiceHeaderDataTransfer.AddFieldValue(SalesInvoiceHeader.FieldNo("Cash Desk Code"), SalesInvoiceHeader.FieldNo("Cash Desk Code CZP"));
        SalesInvoiceHeaderDataTransfer.AddFieldValue(SalesInvoiceHeader.FieldNo("Cash Document Status"), SalesInvoiceHeader.FieldNo("Cash Document Action CZP"));
        SalesInvoiceHeaderDataTransfer.CopyFields();
    end;

    local procedure CopySalesCrMemoHeader();
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoHeaderDataTransfer: DataTransfer;
    begin
        SalesCrMemoHeaderDataTransfer.SetTables(Database::"Sales Cr.Memo Header", Database::"Sales Cr.Memo Header");
        SalesCrMemoHeaderDataTransfer.AddFieldValue(SalesCrMemoHeader.FieldNo("Cash Desk Code"), SalesCrMemoHeader.FieldNo("Cash Desk Code CZP"));
        SalesCrMemoHeaderDataTransfer.AddFieldValue(SalesCrMemoHeader.FieldNo("Cash Document Status"), SalesCrMemoHeader.FieldNo("Cash Document Action CZP"));
        SalesCrMemoHeaderDataTransfer.CopyFields();
    end;

    local procedure CopyPurchaseHeader();
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseHeaderDataTransfer: DataTransfer;
    begin
        PurchaseHeaderDataTransfer.SetTables(Database::"Purchase Header", Database::"Purchase Header");
        PurchaseHeaderDataTransfer.AddFieldValue(PurchaseHeader.FieldNo("Cash Desk Code"), PurchaseHeader.FieldNo("Cash Desk Code CZP"));
        PurchaseHeaderDataTransfer.AddFieldValue(PurchaseHeader.FieldNo("Cash Document Status"), PurchaseHeader.FieldNo("Cash Document Action CZP"));
        PurchaseHeaderDataTransfer.CopyFields();
    end;

    local procedure CopyPurchaseInvoiceHeader();
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvHeaderDataTransfer: DataTransfer;
    begin
        PurchInvHeaderDataTransfer.SetTables(Database::"Purch. Inv. Header", Database::"Purch. Inv. Header");
        PurchInvHeaderDataTransfer.AddFieldValue(PurchInvHeader.FieldNo("Cash Desk Code"), PurchInvHeader.FieldNo("Cash Desk Code CZP"));
        PurchInvHeaderDataTransfer.AddFieldValue(PurchInvHeader.FieldNo("Cash Document Status"), PurchInvHeader.FieldNo("Cash Document Action CZP"));
        PurchInvHeaderDataTransfer.CopyFields();
    end;

    local procedure CopyPurchaseCrMemoHeader();
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoHdrDataTransfer: DataTransfer;
    begin
        PurchCrMemoHdrDataTransfer.SetTables(Database::"Purch. Cr. Memo Hdr.", Database::"Purch. Cr. Memo Hdr.");
        PurchCrMemoHdrDataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("Cash Desk Code"), PurchCrMemoHdr.FieldNo("Cash Desk Code CZP"));
        PurchCrMemoHdrDataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("Cash Document Status"), PurchCrMemoHdr.FieldNo("Cash Document Action CZP"));
        PurchCrMemoHdrDataTransfer.CopyFields();
    end;

    local procedure CopyServiceHeader();
    var
        ServiceHeader: Record "Service Header";
        ServiceHeaderDataTransfer: DataTransfer;
    begin
        ServiceHeaderDataTransfer.SetTables(Database::"Service Header", Database::"Service Header");
        ServiceHeaderDataTransfer.AddFieldValue(ServiceHeader.FieldNo("Cash Desk Code"), ServiceHeader.FieldNo("Cash Desk Code CZP"));
        ServiceHeaderDataTransfer.AddFieldValue(ServiceHeader.FieldNo("Cash Document Status"), ServiceHeader.FieldNo("Cash Document Action CZP"));
        ServiceHeaderDataTransfer.CopyFields();
    end;

    local procedure CopyServiceInvoiceHeader();
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceInvoiceHeaderDataTransfer: DataTransfer;
    begin
        ServiceInvoiceHeaderDataTransfer.SetTables(Database::"Service Invoice Header", Database::"Service Invoice Header");
        ServiceInvoiceHeaderDataTransfer.AddFieldValue(ServiceInvoiceHeader.FieldNo("Cash Desk Code"), ServiceInvoiceHeader.FieldNo("Cash Desk Code CZP"));
        ServiceInvoiceHeaderDataTransfer.AddFieldValue(ServiceInvoiceHeader.FieldNo("Cash Document Status"), ServiceInvoiceHeader.FieldNo("Cash Document Action CZP"));
        ServiceInvoiceHeaderDataTransfer.CopyFields();
    end;

    local procedure CopyServiceCrMemoHeader();
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        ServiceCrMemoHeaderDataTransfer: DataTransfer;
    begin
        ServiceCrMemoHeaderDataTransfer.SetTables(Database::"Service Cr.Memo Header", Database::"Service Cr.Memo Header");
        ServiceCrMemoHeaderDataTransfer.AddFieldValue(ServiceCrMemoHeader.FieldNo("Cash Desk Code"), ServiceCrMemoHeader.FieldNo("Cash Desk Code CZP"));
        ServiceCrMemoHeaderDataTransfer.AddFieldValue(ServiceCrMemoHeader.FieldNo("Cash Document Status"), ServiceCrMemoHeader.FieldNo("Cash Document Action CZP"));
        ServiceCrMemoHeaderDataTransfer.CopyFields();
    end;

    local procedure CopySourceCodeSetup();
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.SetLoadFields("Cash Desk");
        if SourceCodeSetup.Get() then begin
            SourceCodeSetup."Cash Desk CZP" := SourceCodeSetup."Cash Desk";
            SourceCodeSetup.Modify(false);
        end;
    end;

    local procedure CopyUserSetup();
    var
        UserSetup: Record "User Setup";
        UserSetupDataTransfer: DataTransfer;
    begin
        UserSetupDataTransfer.SetTables(Database::"User Setup", Database::"User Setup");
        UserSetupDataTransfer.AddFieldValue(UserSetup.FieldNo("Cash Resp. Ctr. Filter"), UserSetup.FieldNo("Cash Resp. Ctr. Filter CZP"));
        UserSetupDataTransfer.AddFieldValue(UserSetup.FieldNo("Cash Desk Amt. Approval Limit"), UserSetup.FieldNo("Cash Desk Amt. Appr. Limit CZP"));
        UserSetupDataTransfer.AddFieldValue(UserSetup.FieldNo("Unlimited Cash Desk Approval"), UserSetup.FieldNo("Unlimited Cash Desk Appr. CZP"));
        UserSetupDataTransfer.CopyFields();
    end;

    local procedure CopyGeneralLedgerSetup();
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.SetLoadFields("Cash Desk Nos.", "Cash Payment Limit (LCY)");
        if GeneralLedgerSetup.Get() then begin
            GeneralLedgerSetup."Cash Desk Nos. CZP" := GeneralLedgerSetup."Cash Desk Nos.";
            GeneralLedgerSetup."Cash Payment Limit (LCY) CZP" := GeneralLedgerSetup."Cash Payment Limit (LCY)";
            GeneralLedgerSetup.Modify(false);
        end;
    end;

    local procedure CopyCurrencyNominalValue();
    var
        CurrencyNominalValue: Record "Currency Nominal Value";
        CurrencyNominalValueCZP: Record "Currency Nominal Value CZP";
    begin
        if CurrencyNominalValue.FindSet() then
            repeat
                if not CurrencyNominalValueCZP.Get(CurrencyNominalValue."Currency Code", CurrencyNominalValue.Value) then begin
                    CurrencyNominalValueCZP.Init();
                    CurrencyNominalValueCZP."Currency Code" := CurrencyNominalValue."Currency Code";
                    CurrencyNominalValueCZP."Nominal Value" := CurrencyNominalValue.Value;
                    CurrencyNominalValueCZP.SystemId := CurrencyNominalValue.SystemId;
                    CurrencyNominalValueCZP.Insert(false, true);
                end;
            until CurrencyNominalValue.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    var
        DataClassEvalHandlerCZP: Codeunit "Data Class. Eval. Handler CZP";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        CreateCashDeskSetupSourceCode();
        InitCashDeskReportSelections();

        DataClassEvalHandlerCZP.ApplyEvaluationClassificationsForPrivacy();
        UpgradeTag.SetAllUpgradeTags();
    end;

    local procedure CreateCashDeskSetupSourceCode()
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        if not SourceCodeSetup.Get() then
            exit;
        if SourceCodeSetup."Cash Desk CZP" = '' then
            InitCashDeskSourceCode();
    end;

    local procedure InitCashDeskSourceCode()
    var
        CashDeskSourceCodeTxt: Label 'CASHDESK', MaxLength = 10;
        CashDeskSourceDescriptionTxt: Label 'Cash Desk Evidence', MaxLength = 100;
    begin
        InsertSourceCode(CashDeskSourceCodeTxt, CashDeskSourceDescriptionTxt);
        SetupSourceCode(CashDeskSourceCodeTxt);
    end;

    local procedure InsertSourceCode(SourceCodeCode: Code[10]; SourceCodeDescription: Text[100])
    var
        SourceCode: Record "Source Code";
    begin
        if SourceCode.Get(SourceCodeCode) then
            exit;
        SourceCode.Init();
        SourceCode.Code := SourceCodeCode;
        SourceCode.Description := SourceCodeDescription;
        SourceCode.Insert();
    end;

    local procedure SetupSourceCode(SourceCodeCode: Code[10])
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        if not SourceCodeSetup.Get() then
            exit;
        if SourceCodeSetup."Cash Desk CZP" = SourceCodeCode then
            exit;
        SourceCodeSetup."Cash Desk CZP" := SourceCodeCode;
        SourceCodeSetup.Modify();
    end;

    local procedure InitCashDeskReportSelections()
    var
        ReportUsage: Enum "Cash Desk Rep. Sel. Usage CZP";
    begin
        InsertCashDeskReportSelectionsCZP(ReportUsage::"Cash Receipt", '1', Report::"Receipt Cash Document CZP");
        InsertCashDeskReportSelectionsCZP(ReportUsage::"Cash Withdrawal", '1', Report::"Withdrawal Cash Document CZP");
        InsertCashDeskReportSelectionsCZP(ReportUsage::"Posted Cash Receipt", '1', Report::"Posted Rcpt. Cash Document CZP");
        InsertCashDeskReportSelectionsCZP(ReportUsage::"Posted Cash Withdrawal", '1', Report::"Posted Wdrl. Cash Document CZP");
    end;

    local procedure InsertCashDeskReportSelectionsCZP(ReportUsage: Enum "Cash Desk Rep. Sel. Usage CZP"; ReportSequence: Code[10]; ReportID: Integer)
    var
        CashDeskRepSelectionsCZP: Record "Cash Desk Rep. Selections CZP";
    begin
        if CashDeskRepSelectionsCZP.Get(ReportUsage, ReportSequence) then
            exit;

        CashDeskRepSelectionsCZP.Init();
        CashDeskRepSelectionsCZP.Validate(Usage, ReportUsage);
        CashDeskRepSelectionsCZP.Validate(Sequence, ReportSequence);
        CashDeskRepSelectionsCZP.Validate("Report ID", ReportID);
        CashDeskRepSelectionsCZP.Insert();
    end;
}
