// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft;
using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Setup;
using System.Environment.Configuration;
using System.Upgrade;

#pragma warning disable AL0432
codeunit 31107 "Upgrade Application CZP"
{
    Subtype = Upgrade;
    Permissions = tabledata "Cash Desk User CZP" = m,
                  tabledata "Cash Desk Event CZP" = m,
                  tabledata "Cash Document Line CZP" = m,
                  tabledata "Posted Cash Document Hdr. CZP" = m,
                  tabledata "Posted Cash Document Line CZP" = m;

    var
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitionsCZP: Codeunit "Upgrade Tag Definitions CZP";
        InstallApplicationsMgtCZL: Codeunit "Install Applications Mgt. CZL";
        AppInfo: ModuleInfo;

    trigger OnUpgradePerDatabase()
    begin
        DataUpgradeMgt.SetUpgradeInProgress();
        UpgradePermission();
        SetDatabaseUpgradeTags();
    end;

    trigger OnUpgradePerCompany()
    begin
        DataUpgradeMgt.SetUpgradeInProgress();
        BindSubscription(InstallApplicationsMgtCZL);
        UpgradeUsage();
        UpgradeData();
        UnbindSubscription(InstallApplicationsMgtCZL);
        SetCompanyUpgradeTags();
    end;

    local procedure UpgradePermission()
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion174PerDatabaseUpgradeTag()) then
            exit;

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

    local procedure UpgradeUsage()
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion174PerDatabaseUpgradeTag()) then
            exit;

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

    local procedure UpgradeData()
    begin
        UpgradeCashDeskEvent();
        UpgradeCashDeskUser();
        UpgradeCashDocumentLine();
        UpgradePostedCashDocumentHeader();
        UpgradePostedCashDocumentLine();
    end;

    local procedure UpgradeCashDeskUser();
    var
        CashDeskUser: Record "Cash Desk User";
        CashDeskUserCZP: Record "Cash Desk User CZP";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion174PerCompanyUpgradeTag()) then
            exit;

        CashDeskUser.SetLoadFields("Cash Desk No.", "User ID", "Post EET Only");
        if CashDeskUser.FindSet() then
            repeat
                if CashDeskUserCZP.Get(CashDeskUser."Cash Desk No.", CashDeskUser."User ID") then begin
                    CashDeskUserCZP."Post EET Only" := CashDeskUser."Post EET Only";
                    CashDeskUserCZP.Modify(false);
                end;
            until CashDeskUser.Next() = 0;
    end;

    local procedure UpgradeCashDeskEvent();
    var
        CashDeskEvent: Record "Cash Desk Event";
        CashDeskEventCZP: Record "Cash Desk Event CZP";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion174PerCompanyUpgradeTag()) then
            exit;

        CashDeskEvent.SetLoadFields(Code, "EET Transaction");
        if CashDeskEvent.FindSet() then
            repeat
                if CashDeskEventCZP.Get(CashDeskEvent.Code) then begin
                    CashDeskEventCZP."EET Transaction" := CashDeskEvent."EET Transaction";
                    CashDeskEventCZP.Modify(false);
                end;
            until CashDeskEvent.Next() = 0;
    end;

    local procedure UpgradeCashDocumentLine();
    var
        CashDocumentLine: Record "Cash Document Line";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion173PerCompanyUpgradeTag()) and
           UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion174PerCompanyUpgradeTag())
        then
            exit;

        if not GeneralLedgerSetup.Get() then
            GeneralLedgerSetup.Init();
        CashDocumentLine.SetLoadFields("Cash Desk No.", "Cash Document No.", "Line No.", Prepayment, "Advance Letter Link Code", "EET Transaction");
        if CashDocumentLine.FindSet() then
            repeat
                if CashDocumentLineCZP.Get(CashDocumentLine."Cash Desk No.", CashDocumentLine."Cash Document No.", CashDocumentLine."Line No.") then begin
                    if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion173PerCompanyUpgradeTag()) then
                        if GeneralLedgerSetup."Prepayment Type" = GeneralLedgerSetup."Prepayment Type"::Advances then
                            if CashDocumentLine.Prepayment then
                                CashDocumentLineCZP."Advance Letter Link Code" := CashDocumentLine."Advance Letter Link Code";
                    if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion174PerCompanyUpgradeTag()) then
                        CashDocumentLineCZP."EET Transaction" := CashDocumentLine."EET Transaction";
                    CashDocumentLineCZP.Modify(false);
                end;
            until CashDocumentLine.Next() = 0;
    end;

    local procedure UpgradePostedCashDocumentHeader();
    var
        PostedCashDocumentHeader: Record "Posted Cash Document Header";
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion174PerCompanyUpgradeTag()) then
            exit;

        PostedCashDocumentHeader.SetLoadFields("Cash Desk No.", "No.", "EET Entry No.");
        if PostedCashDocumentHeader.FindSet() then
            repeat
                if PostedCashDocumentHdrCZP.Get(PostedCashDocumentHeader."Cash Desk No.", PostedCashDocumentHeader."No.") then begin
                    PostedCashDocumentHdrCZP."EET Entry No." := PostedCashDocumentHeader."EET Entry No.";
                    PostedCashDocumentHdrCZP.Modify(false);
                end;
            until PostedCashDocumentHeader.Next() = 0;
    end;

    local procedure UpgradePostedCashDocumentLine();
    var
        PostedCashDocumentLine: Record "Posted Cash Document Line";
        PostedCashDocumentLineCZP: Record "Posted Cash Document Line CZP";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion174PerCompanyUpgradeTag()) then
            exit;

        PostedCashDocumentLine.SetLoadFields("Cash Desk No.", "Cash Document No.", "Line No.", "EET Transaction");
        if PostedCashDocumentLine.FindSet() then
            repeat
                if PostedCashDocumentLineCZP.Get(PostedCashDocumentLine."Cash Desk No.", PostedCashDocumentLine."Cash Document No.", PostedCashDocumentLine."Line No.") then begin
                    PostedCashDocumentLineCZP."EET Transaction" := PostedCashDocumentLine."EET Transaction";
                    PostedCashDocumentLineCZP.Modify(false);
                end;
            until PostedCashDocumentLine.Next() = 0;
    end;

    local procedure SetDatabaseUpgradeTags();
    begin
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion173PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion173PerDatabaseUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion174PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion174PerDatabaseUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion180PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion180PerDatabaseUpgradeTag());
    end;

    local procedure SetCompanyUpgradeTags();
    begin
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion173PerCompanyUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion173PerCompanyUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion174PerCompanyUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion174PerCompanyUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion180PerCompanyUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion180PerCompanyUpgradeTag());
    end;
}
