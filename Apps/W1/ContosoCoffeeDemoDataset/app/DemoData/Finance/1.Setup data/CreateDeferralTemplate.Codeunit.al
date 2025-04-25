// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DemoData.Finance;

using Microsoft.Finance.Deferral;
using Microsoft.DemoTool.Helpers;

codeunit 5389 "Create Deferral Template"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoDeferralTemplate: Codeunit "Contoso Deferral Template";
        CreateGLAccount: Codeunit "Create G/L Account";
        DeferralAccountNo: Code[20];
    begin
        DeferralAccountNo := CreateGLAccount.OtherAccruedExpensesandDeferredIncome();
        ContosoDeferralTemplate.InsertDeferralTemplate(DeferralCode3M(), Description3M(), DeferralAccountNo, 100, Enum::"Deferral Calculation Method"::"Equal per Period", Enum::"Deferral Calculation Start Date"::"Beginning of Next Period", 3, '%4, %6');
        ContosoDeferralTemplate.InsertDeferralTemplate(DeferralCode1Y(), Description1Y(), DeferralAccountNo, 100, Enum::"Deferral Calculation Method"::"Equal per Period", Enum::"Deferral Calculation Start Date"::"Beginning of Next Period", 3, '%4, %6');
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
}
