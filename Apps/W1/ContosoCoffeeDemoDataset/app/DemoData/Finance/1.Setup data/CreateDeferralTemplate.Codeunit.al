// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;
using Microsoft.Finance.Deferral;

codeunit 5389 "Create Deferral Template"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        FinanceModuleSetup: Record "Finance Module Setup";
        ContosoDeferralTemplate: Codeunit "Contoso Deferral Template";
        CreateGLAccount: Codeunit "Create G/L Account";
        DeferralAccountNo: Code[20];
    begin
#if not CLEAN28
        OnDefineDeferralAccountNo(DeferralAccountNo);
        if DeferralAccountNo = '' then
            if FinanceModuleSetup.Get() then
                DeferralAccountNo := FinanceModuleSetup."Deferral Account No.";

        if DeferralAccountNo = '' then
            DeferralAccountNo := CreateGLAccount.OtherAccruedExpensesandDeferredIncome();
#else
        if DeferralAccountNo = '' then
            if FinanceModuleSetup.Get() then
                DeferralAccountNo := FinanceModuleSetup."Deferral Account No.";

        if DeferralAccountNo = '' then
            DeferralAccountNo := CreateGLAccount.OtherAccruedExpensesandDeferredIncome();
#endif
        ContosoDeferralTemplate.InsertDeferralTemplate(DeferralCode3M(), Description3M(), DeferralAccountNo, 100, Enum::"Deferral Calculation Method"::"Equal per Period", Enum::"Deferral Calculation Start Date"::"Beginning of Next Period", 3, '%4, %6');
        ContosoDeferralTemplate.InsertDeferralTemplate(DeferralCode1Y(), Description1Y(), DeferralAccountNo, 100, Enum::"Deferral Calculation Method"::"Equal per Period", Enum::"Deferral Calculation Start Date"::"Beginning of Next Period", 12, '%4, %6');
    end;

    procedure Description3M(): Text[100]
    begin
        exit(Description3MTok);
    end;

    procedure Description1Y(): Text[100]
    begin
        exit(Description1YTok);
    end;

    procedure DeferralCode3M(): Code[10]
    begin
        exit(DeferralCode3MTok);
    end;

    procedure DeferralCode1Y(): Code[10]
    begin
        exit(DeferralCode1YTok);
    end;

    var
        DeferralCode3MTok: Label '3M', MaxLength = 10;
        DeferralCode1YTok: Label '1Y', MaxLength = 10;
        Description3MTok: Label '3 months, equal, begin next period', MaxLength = 100;
        Description1YTok: Label '1 year, equal, begin next period', MaxLength = 100;

#if not CLEAN28
#pragma warning disable AS0018
    [IntegrationEvent(false, false)]
    [Obsolete('This event will be removed in future releases.', '28.0')]
    local procedure OnDefineDeferralAccountNo(var DeferralAccountNo: Code[20])
    begin
    end;
#pragma warning restore AS0018
#endif
}
