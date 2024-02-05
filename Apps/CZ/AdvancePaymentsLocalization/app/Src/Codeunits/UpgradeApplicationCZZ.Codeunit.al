// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft;
using Microsoft.Foundation.Reporting;
using System.Environment.Configuration;
using System.Upgrade;

codeunit 31088 "Upgrade Application CZZ"
{
    Subtype = Upgrade;

    var
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitionsCZZ: Codeunit "Upgrade Tag Definitions CZZ";
        InstallApplicationsMgtCZL: Codeunit "Install Applications Mgt. CZL";
        InstallApplicationCZZ: Codeunit "Install Application CZZ";

    trigger OnUpgradePerDatabase()
    begin
        DataUpgradeMgt.SetUpgradeInProgress();
        SetDatabaseUpgradeTags();
    end;

    trigger OnUpgradePerCompany()
    begin
        DataUpgradeMgt.SetUpgradeInProgress();
        BindSubscription(InstallApplicationsMgtCZL);
        UpgradeData();
        UnbindSubscription(InstallApplicationsMgtCZL);
        SetCompanyUpgradeTags();
    end;

    local procedure UpgradeData()
    var
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
    begin
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZZ.GetDataVersion200PerCompanyUpgradeTag()) then
            UpgradeAdvancePaymentsReportReportSelections();
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZZ.GetDataVersion210PerCompanyUpgradeTag()) then
            if AdvanceLetterTemplateCZZ.IsEmpty() then // feature AdvancePaymentsLocalizationForCzech was disabled
                InstallApplicationCZZ.CopyData();
        UpgradeCustomerNoInSalesAdvLetterEntries();
        UpgradeAdvanceLetterApplicationAmountLCY();
        UpgradePostVATDocForReverseCharge();
    end;

    local procedure UpgradeAdvancePaymentsReportReportSelections();
    var
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        ReportSelectionHandlerCZZ: Codeunit "Report Selection Handler CZZ";
    begin
        AdvanceLetterTemplateCZZ.SetRange("Sales/Purchase", AdvanceLetterTemplateCZZ."Sales/Purchase"::Purchase);
        AdvanceLetterTemplateCZZ.SetFilter("Document Report ID", '<>0');
        if AdvanceLetterTemplateCZZ.FindFirst() then
            ReportSelectionHandlerCZZ.InsertRepSelection(Enum::"Report Selection Usage"::"Purchase Advance Letter CZZ", '1', AdvanceLetterTemplateCZZ."Document Report ID")
        else
            ReportSelectionHandlerCZZ.InsertRepSelection(Enum::"Report Selection Usage"::"Purchase Advance Letter CZZ", '1', Report::"Purchase - Advance Letter CZZ");
        AdvanceLetterTemplateCZZ.SetRange("Document Report ID");
        AdvanceLetterTemplateCZZ.SetFilter("Invoice/Cr. Memo Report ID", '<>0');
        if AdvanceLetterTemplateCZZ.FindFirst() then
            ReportSelectionHandlerCZZ.InsertRepSelection(Enum::"Report Selection Usage"::"Purchase Advance VAT Document CZZ", '1', AdvanceLetterTemplateCZZ."Invoice/Cr. Memo Report ID")
        else
            ReportSelectionHandlerCZZ.InsertRepSelection(Enum::"Report Selection Usage"::"Purchase Advance VAT Document CZZ", '1', Report::"Purchase - Advance VAT Doc.CZZ");

        AdvanceLetterTemplateCZZ.Reset();
        AdvanceLetterTemplateCZZ.SetRange("Sales/Purchase", AdvanceLetterTemplateCZZ."Sales/Purchase"::Sales);
        AdvanceLetterTemplateCZZ.SetFilter("Document Report ID", '<>0');
        if AdvanceLetterTemplateCZZ.FindFirst() then
            ReportSelectionHandlerCZZ.InsertRepSelection(Enum::"Report Selection Usage"::"Sales Advance Letter CZZ", '1', AdvanceLetterTemplateCZZ."Document Report ID")
        else
            ReportSelectionHandlerCZZ.InsertRepSelection(Enum::"Report Selection Usage"::"Sales Advance Letter CZZ", '1', Report::"Sales - Advance Letter CZZ");
        AdvanceLetterTemplateCZZ.SetRange("Document Report ID");
        AdvanceLetterTemplateCZZ.SetFilter("Invoice/Cr. Memo Report ID", '<>0');
        if AdvanceLetterTemplateCZZ.FindFirst() then
            ReportSelectionHandlerCZZ.InsertRepSelection(Enum::"Report Selection Usage"::"Sales Advance VAT Document CZZ", '1', AdvanceLetterTemplateCZZ."Invoice/Cr. Memo Report ID")
        else
            ReportSelectionHandlerCZZ.InsertRepSelection(Enum::"Report Selection Usage"::"Sales Advance VAT Document CZZ", '1', Report::"Sales - Advance VAT Doc. CZZ");
    end;

    local procedure UpgradeCustomerNoInSalesAdvLetterEntries()
    var
        SalesAdvLetterEntry: Record "Sales Adv. Letter Entry CZZ";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZZ.GetSalesAdvLetterEntryCustomerNoUpgradeTag()) then
            exit;

        SalesAdvLetterEntry.SetLoadFields("Sales Adv. Letter No.");
        SalesAdvLetterEntry.SetRange("Customer No.", '');
        if SalesAdvLetterEntry.FindSet() then
            repeat
                SalesAdvLetterEntry."Customer No." := SalesAdvLetterEntry.GetCustomerNo();
                SalesAdvLetterEntry.Modify();
            until SalesAdvLetterEntry.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZZ.GetSalesAdvLetterEntryCustomerNoUpgradeTag());
    end;

    local procedure UpgradeAdvanceLetterApplicationAmountLCY()
    var
        AdvanceLetterApplication: Record "Advance Letter Application CZZ";
        CurrencyFactor: Decimal;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZZ.GetAdvanceLetterApplicationAmountLCYUpgradeTag()) then
            exit;

        AdvanceLetterApplication.SetLoadFields(Amount);
        AdvanceLetterApplication.SetRange("Amount (LCY)", 0);
        if AdvanceLetterApplication.FindSet() then
            repeat
                CurrencyFactor := GetCurrencyFactor(AdvanceLetterApplication."Advance Letter Type", AdvanceLetterApplication."Advance Letter No.");
                if CurrencyFactor <> 0 then begin
                    AdvanceLetterApplication."Amount (LCY)" := AdvanceLetterApplication.Amount / CurrencyFactor;
                    AdvanceLetterApplication.Modify();
                end;
            until AdvanceLetterApplication.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZZ.GetAdvanceLetterApplicationAmountLCYUpgradeTag());
    end;

    local procedure UpgradePostVATDocForReverseCharge()
    var
        AdvanceLetterTemplate: Record "Advance Letter Template CZZ";
        AdvLetterTemplateDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZZ.GetPostVATDocForReverseChargeUpgradeTag()) then
            exit;

        AdvLetterTemplateDataTransfer.SetTables(Database::"Advance Letter Template CZZ", Database::"Advance Letter Template CZZ");
        AdvLetterTemplateDataTransfer.AddConstantValue(true, AdvanceLetterTemplate.FieldNo("Post VAT Doc. for Rev. Charge"));
        AdvLetterTemplateDataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZZ.GetPostVATDocForReverseChargeUpgradeTag());
    end;

    local procedure GetCurrencyFactor(AdvanceLetterType: Enum "Advance Letter Type CZZ"; AdvanceLetterNo: Code[20]): Decimal
    var
        PurchAdvLetterHeader: Record "Purch. Adv. Letter Header CZZ";
        SalesAdvLetterHeader: Record "Sales Adv. Letter Header CZZ";
    begin
        case AdvanceLetterType of
            AdvanceLetterType::Purchase:
                if PurchAdvLetterHeader.Get(AdvanceLetterNo) then
                    exit(PurchAdvLetterHeader."Currency Factor");
            AdvanceLetterType::Sales:
                if SalesAdvLetterHeader.Get(AdvanceLetterNo) then
                    exit(SalesAdvLetterHeader."Currency Factor");
        end;
        exit(0);
    end;

    local procedure SetDatabaseUpgradeTags();
    begin
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZZ.GetDataVersion190PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZZ.GetDataVersion190PerDatabaseUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZZ.GetDataVersion200PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZZ.GetDataVersion200PerDatabaseUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZZ.GetDataVersion210PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZZ.GetDataVersion210PerDatabaseUpgradeTag());
    end;

    local procedure SetCompanyUpgradeTags();
    begin
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZZ.GetDataVersion190PerCompanyUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZZ.GetDataVersion190PerCompanyUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZZ.GetDataVersion200PerCompanyUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZZ.GetDataVersion200PerCompanyUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZZ.GetDataVersion210PerCompanyUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZZ.GetDataVersion210PerCompanyUpgradeTag());
    end;
}
