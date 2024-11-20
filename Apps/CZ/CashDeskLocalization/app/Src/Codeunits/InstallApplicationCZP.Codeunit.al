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
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Bank Account", Database::"Cash Desk CZP");
    end;

    local procedure CopyUsage();
    begin
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Bank Account", Database::"Cash Desk CZP");
    end;

    local procedure CopyData()
    begin
        CopySourceCodeSetup();
        InitCashDeskSourceCode();
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
