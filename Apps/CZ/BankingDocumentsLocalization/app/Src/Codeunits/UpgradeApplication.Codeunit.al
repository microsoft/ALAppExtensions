// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.BankAccount;
using System.Environment.Configuration;
using System.Upgrade;

codeunit 31332 "Upgrade Application CZB"
{
    Subtype = Upgrade;

    var
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitionsCZB: Codeunit "Upgrade Tag Definitions CZB";

    trigger OnUpgradePerDatabase()
    begin
        DataUpgradeMgt.SetUpgradeInProgress();
        SetDatabaseUpgradeTags();
    end;

    trigger OnUpgradePerCompany()
    begin
        DataUpgradeMgt.SetUpgradeInProgress();
        UpgradeData();
        SetCompanyUpgradeTags();
    end;

    local procedure UpgradeData()
    begin
        UpgradeBankAccount();
    end;

    local procedure UpgradeBankAccount();
    var
        BankAccount: Record "Bank Account";
        BankaccountDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZB.GetDataVersion221PerCompanyUpgradeTag()) then
            exit;

        BankaccountDataTransfer.SetTables(Database::"Bank Account", Database::"Bank Account");
        BankaccountDataTransfer.AddFieldValue(BankAccount.FieldNo("Payment Jnl. Template Name CZB"), BankAccount.FieldNo("Pmt.Jnl. Templ. Name Order CZB"));
        BankaccountDataTransfer.AddFieldValue(BankAccount.FieldNo("Payment Jnl. Batch Name CZB"), BankAccount.FieldNo("Pmt. Jnl. Batch Name Order CZB"));
        BankaccountDataTransfer.CopyFields();
    end;

    local procedure SetDatabaseUpgradeTags();
    begin
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZB.GetDataVersion190PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZB.GetDataVersion190PerDatabaseUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZB.GetDataVersion221PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZB.GetDataVersion221PerDatabaseUpgradeTag());
    end;

    local procedure SetCompanyUpgradeTags();
    begin
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZB.GetDataVersion190PerCompanyUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZB.GetDataVersion190PerCompanyUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZB.GetDataVersion221PerCompanyUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZB.GetDataVersion221PerCompanyUpgradeTag());
    end;
}
