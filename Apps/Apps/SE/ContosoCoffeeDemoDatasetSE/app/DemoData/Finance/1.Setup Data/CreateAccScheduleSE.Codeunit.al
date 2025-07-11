// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Finance.FinancialReports;

codeunit 11212 "Create Acc. Schedule SE"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertAccScheduleLine(var Rec: Record "Acc. Schedule Line")
    var
        CreateAccountScheduleName: Codeunit "Create Acc. Schedule Name";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        if Rec."Schedule Name" = CreateAccountScheduleName.AccountCategoriesOverview() then
            case Rec."Line No." of
                60000:
                    ValidateRecordFields(Rec, CreateGLAccount.NETINCOME(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.CapitalStructure() then
            case Rec."Line No." of
                40000:
                    ValidateRecordFields(Rec, CreateGLAccount.InventoryTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                50000:
                    ValidateRecordFields(Rec, CreateGLAccount.AccountsReceivableTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                60000:
                    ValidateRecordFields(Rec, CreateGLAccount.SecuritiesTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                70000:
                    ValidateRecordFields(Rec, CreateGLAccount.LiquidAssetsTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                110000:
                    ValidateRecordFields(Rec, CreateGLAccount.RevolvingCredit(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
                120000:
                    ValidateRecordFields(Rec, CreateGLAccount.AccountsPayableTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                130000:
                    ValidateRecordFields(Rec, CreateGLAccount.VATTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                140000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalPersonnelrelatedItems(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                150000:
                    ValidateRecordFields(Rec, CreateGLAccount.OtherLiabilitiesTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.CashCycle() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalRevenue(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                20000:
                    ValidateRecordFields(Rec, CreateGLAccount.AccountsReceivableTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                30000:
                    ValidateRecordFields(Rec, CreateGLAccount.AccountsPayableTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                40000:
                    ValidateRecordFields(Rec, CreateGLAccount.InventoryTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                50000:
                    ValidateRecordFields(Rec, '-360*''20''/''10''', Enum::"Acc. Schedule Line Totaling Type"::Formula, true);
                60000:
                    ValidateRecordFields(Rec, '360*''30''/''10''', Enum::"Acc. Schedule Line Totaling Type"::Formula, true);
                70000:
                    ValidateRecordFields(Rec, '-360*''40''/''10''', Enum::"Acc. Schedule Line Totaling Type"::Formula, true);
                80000:
                    ValidateRecordFields(Rec, '100+110-120', Enum::"Acc. Schedule Line Totaling Type"::Formula, true);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.CashFlow() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, CreateGLAccount.AccountsReceivableTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                20000:
                    ValidateRecordFields(Rec, CreateGLAccount.AccountsPayableTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                30000:
                    ValidateRecordFields(Rec, CreateGLAccount.LiquidAssetsTotal() + '|' + CreateGLAccount.RevolvingCredit(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                40000:
                    ValidateRecordFields(Rec, '10' + '..' + '30', Enum::"Acc. Schedule Line Totaling Type"::Formula, false);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.IncomeExpense() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalRevenue(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                30000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalCost(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                40000:
                    ValidateRecordFields(Rec, CreateGLAccount.BalanceSheet(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                50000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalPersonnelExpenses(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                60000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalFixedAssetDepreciation(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                70000:
                    ValidateRecordFields(Rec, CreateGLAccount.OtherCostsofOperations(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.ReducedTrialBalance() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalRevenue(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                20000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalCost(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                40000:
                    ValidateRecordFields(Rec, '-''30''/''10''*100', Enum::"Acc. Schedule Line Totaling Type"::Formula, true);
                50000:
                    ValidateRecordFields(Rec, CreateGLAccount.BalanceSheet() + '|' + CreateGLAccount.TotalPersonnelExpenses() + '|' + CreateGLAccount.TotalFixedAssetDepreciation(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                70000:
                    ValidateRecordFields(Rec, '-''60''/''10''*100', Enum::"Acc. Schedule Line Totaling Type"::Formula, true);
                80000:
                    ValidateRecordFields(Rec, CreateGLAccount.OtherCostsofOperations(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
                90000:
                    ValidateRecordFields(Rec, CreateGLAccount.NETINCOMEBEFORETAXES(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.Revenues() then
            case Rec."Line No." of
                40000:
                    ValidateRecordFields(Rec, CreateGLAccount.SalesRetailDom(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
                50000:
                    ValidateRecordFields(Rec, CreateGLAccount.SalesRetailEU(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
                60000:
                    ValidateRecordFields(Rec, CreateGLAccount.SalesRetailExport(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
                70000:
                    ValidateRecordFields(Rec, CreateGLAccount.JobSalesAppliedRetail(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
                80000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalSalesofRetail(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
            end;
    end;

    local procedure ValidateRecordFields(var AccScheduleLine: Record "Acc. Schedule Line"; Totaling: Text; TotalingType: Enum "Acc. Schedule Line Totaling Type"; HideCurrencySymbol: Boolean)
    begin
        AccScheduleLine.Validate(Totaling, Totaling);
        AccScheduleLine.Validate("Totaling Type", TotalingType);
        if HideCurrencySymbol then
            AccScheduleLine.Validate("Hide Currency Symbol", HideCurrencySymbol);
    end;
}
