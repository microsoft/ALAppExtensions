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
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Iss. Payment Order Line CZB", Database::"Iss. Payment Order Line CZB");
    end;

    local procedure CopyUsage();
    begin
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Iss. Payment Order Line CZB", Database::"Iss. Payment Order Line CZB");
    end;

    local procedure CopyData()
    begin
        CopyBankAccount();
        InitExpLauncherSEPA();
    end;

    local procedure CopyBankAccount();
    var
        BankAccount: Record "Bank Account";
    begin
        if BankAccount.FindSet() then
            repeat
                BankAccount."Domestic Payment Order ID CZB" := Report::"Iss. Payment Order CZB";
                BankAccount."Foreign Payment Order ID CZB" := Report::"Iss. Payment Order CZB";
                BankAccount.Modify(false);
            until BankAccount.Next() = 0;
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
