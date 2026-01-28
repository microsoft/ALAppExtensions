// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Ledger;

codeunit 31140 "VAT Statement Handler CZL"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    var
        GlobalGLAccount: Record "G/L Account";
        GlobalVATStmtCalcParametersCZL: Record "VAT Stmt. Calc. Parameters CZL";
        VATStatementCalculationCZL: Codeunit "VAT Statement Calculation CZL";

    procedure Activate()
    begin
        if IsActivated() then
            exit;
        ClearAll();
        BindSubscription(this);
    end;

    procedure IsActivated() IsActive: Boolean
    begin
        OnIsActivated(IsActive);
    end;

    procedure SetParameters(VATStmtCalcParameters: Record "VAT Stmt. Calc. Parameters CZL")
    begin
        OnSetParameters(VATStmtCalcParameters);
    end;

    local procedure ConditionalAdd(Amount: Decimal; AmountToAdd: Decimal; AddCurrAmountToAdd: Decimal; UseAmtsInAddCurr: Boolean): Decimal
    begin
        if UseAmtsInAddCurr then
            exit(Amount + AddCurrAmountToAdd);
        exit(Amount + AmountToAdd);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsActivated(var IsActive: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetParameters(VATStmtCalcParameters: Record "VAT Stmt. Calc. Parameters CZL")
    begin
    end;

    [EventSubscriber(ObjectType::Report, Report::"VAT Statement", 'OnAfterGetAmtRoundingDirection', '', false, false)]
    local procedure GetRoundingDirectionOnAfterGetAmtRoundingDirection(Direction: Text[1])
    begin
        Direction := GlobalVATStmtCalcParametersCZL.GetRoundingDirection();
    end;

    [EventSubscriber(ObjectType::Report, Report::"VAT Statement", 'OnBeforeCalcLineTotalWithBase', '', false, false)]
    local procedure CalcOnBeforeCalcLineTotalWithBase(VATStmtLine2: Record "VAT Statement Line"; var TotalAmount: Decimal; var TotalBase: Decimal; var IsHandled: Boolean)
    begin
        if (VATStmtLine2.Type <> VATStmtLine2.Type::"VAT Entry Totaling") or (GlobalVATStmtCalcParametersCZL."VAT Report No. Filter" = '') then
            exit;
        VATStatementCalculationCZL.CalcVATEntryTotalForVATReport(VATStmtLine2, GlobalVATStmtCalcParametersCZL, TotalAmount, TotalBase);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Report, Report::"VAT Statement", 'OnCalcLineTotalWithBaseOnCaseElse', '', false, false)]
    local procedure CalcFormulaOnCalcLineTotalWithBaseOnCaseElse(var VATStmtLine2: Record "VAT Statement Line"; var Amount: Decimal; var TotalAmount: Decimal; var TotalBase: Decimal; PrintInIntegers: Boolean)
    var
        Base: Decimal;
    begin
        if VATStmtLine2.Type <> VATStmtLine2.Type::"Formula CZL" then
            exit;
        VATStatementCalculationCZL.CalcFormulaLineTotal(VATStmtLine2, GlobalVATStmtCalcParametersCZL, Amount, Base);
        TotalAmount := TotalAmount + Amount;
        TotalBase := TotalBase + Base;
    end;

    [EventSubscriber(ObjectType::Report, Report::"VAT Statement", 'OnCalcLineTotalOnBeforeCalcTotalAmountAccountTotaling', '', false, false)]
    local procedure CalcLineTotalOnCalcLineTotalOnBeforeCalcTotalAmountAccountTotaling(VATStmtLine: Record "VAT Statement Line"; var Amount: Decimal; UseAmtsInAddCurr: Boolean)
    begin
        if VATStmtLine."G/L Amount Type CZL" = VATStmtLine."G/L Amount Type CZL"::"Net Change" then
            exit;

        Amount := 0;
        if GlobalGLAccount.FindSet() and (VATStmtLine."Account Totaling" <> '') then
            repeat
                case VATStmtLine."G/L Amount Type CZL" of
                    VATStmtLine."G/L Amount Type CZL"::Debit:
                        begin
                            GlobalGLAccount.CalcFields("Debit Amount", "Add.-Currency Debit Amount");
                            Amount := ConditionalAdd(Amount, GlobalGLAccount."Debit Amount", GlobalGLAccount."Add.-Currency Debit Amount", UseAmtsInAddCurr);
                        end;
                    VATStmtLine."G/L Amount Type CZL"::Credit:
                        begin
                            GlobalGLAccount.CalcFields("Credit Amount", "Add.-Currency Credit Amount");
                            Amount := ConditionalAdd(Amount, GlobalGLAccount."Credit Amount", GlobalGLAccount."Add.-Currency Credit Amount", UseAmtsInAddCurr);
                        end;
                end;
            until GlobalGLAccount.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Report, Report::"VAT Statement", 'OnCalcLineTotalWithBaseOnAfterGLAccSetFilters', '', false, false)]
    local procedure SetDateFilterOnCalcLineTotalWithBaseOnAfterGLAccSetFilters(var GLAccount: Record "G/L Account"; VATStatementLine2: Record "VAT Statement Line")
    begin
        GlobalGLAccount.Reset();
        GlobalGLAccount.CopyFilters(GLAccount);
    end;

    [EventSubscriber(ObjectType::Report, Report::"VAT Statement", 'OnCalcLineTotalOnVATEntryTotalingOnAfterVATEntrySetFilters', '', false, false)]
    local procedure OnCalcLineTotalOnVATEntryTotalingOnAfterVATEntrySetFilters(VATStmtLine: Record "VAT Statement Line"; var VATEntry: Record "VAT Entry"; Selection: Enum "VAT Statement Report Selection")
    var
        VATReportingDateMgt: Codeunit "VAT Reporting Date Mgt";
    begin
        VATEntry.SetVATStatementLineFiltersCZL(VATStmtLine);
        VATEntry.SetPeriodFilterCZL(
            GlobalVATStmtCalcParametersCZL."Period Selection", GlobalVATStmtCalcParametersCZL."Start Date", GlobalVATStmtCalcParametersCZL."End Date", VATReportingDateMgt.IsVATDateEnabled());
        VATEntry.SetClosedFilterCZL(Selection);
        if GlobalVATStmtCalcParametersCZL."VAT Settlement No. Filter" <> '' then
            VATEntry.SetFilter("VAT Settlement No. CZL", GlobalVATStmtCalcParametersCZL."VAT Settlement No. Filter");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VAT Statement Handler CZL", 'OnIsActivated', '', false, false)]
    local procedure HandleOnIsActivated(var IsActive: Boolean)
    begin
        IsActive := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VAT Statement Handler CZL", 'OnSetParameters', '', false, false)]
    local procedure HandleOnSetParameters(VATStmtCalcParameters: Record "VAT Stmt. Calc. Parameters CZL")
    begin
        GlobalVATStmtCalcParametersCZL := VATStmtCalcParameters;
    end;
}