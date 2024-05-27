namespace Microsoft.Finance.ExcelReports;
using Microsoft.Finance.GeneralLedger.Account;

codeunit 4410 "Trial Balance"
{
    internal procedure InsertBreakdownForGLAccount(var GLAccount: Record "G/L Account"; Dimension1Values: List of [Code[20]]; Dimension2Values: List of [Code[20]]; var EXRTrialBalanceBuffer: Record "EXR Trial Balance Buffer")
    var
        i, j : Integer;
    begin
        Clear(EXRTrialBalanceBuffer);
        EXRTrialBalanceBuffer.DeleteAll();
        for i := 1 to Dimension1Values.Count do
            for j := 1 to Dimension2Values.Count do
                InsertGLAccountTotalsForFilters(Dimension1Values.Get(i), Dimension2Values.Get(j), GLAccount, EXRTrialBalanceBuffer);
    end;

    internal procedure InsertBreakdownForGLAccount(var GLAccount: Record "G/L Account"; Dimension1Values: List of [Code[20]]; Dimension2Values: List of [Code[20]]; BusinessUnitCodes: List of [Code[20]]; var EXRTrialBalanceBuffer: Record "EXR Trial Balance Buffer")
    var
        i, j, k : Integer;
    begin
        Clear(EXRTrialBalanceBuffer);
        EXRTrialBalanceBuffer.DeleteAll();
        for i := 1 to Dimension1Values.Count do
            for j := 1 to Dimension2Values.Count do
                for k := 1 to BusinessUnitCodes.Count do
                    InsertGLAccountTotalsForFilters(Dimension1Values.Get(i), Dimension2Values.Get(j), BusinessUnitCodes.Get(k), GLAccount, EXRTrialBalanceBuffer);
    end;

    local procedure InsertGLAccountTotalsForFilters(Dimension1ValueCode: Code[20]; Dimension2ValueCode: Code[20]; var GLAccount: Record "G/L Account"; var EXRTrialBalanceBuffer: Record "EXR Trial Balance Buffer")
    var
        LocalGlAccount: Record "G/L Account";
    begin
        LocalGlAccount.Copy(GLAccount);
        SetGLAccountFilters(LocalGlAccount, Dimension1ValueCode, Dimension2ValueCode);
        InsertTrialBalanceDataForGLAccountWithFilters(LocalGlAccount, EXRTrialBalanceBuffer);
    end;

    local procedure InsertGLAccountTotalsForFilters(Dimension1ValueCode: Code[20]; Dimension2ValueCode: Code[20]; BusinessUnitCode: Code[20]; var GLAccount: Record "G/L Account"; var EXRTrialBalanceBuffer: Record "EXR Trial Balance Buffer")
    var
        LocalGlAccount: Record "G/L Account";
    begin
        LocalGlAccount.Copy(GLAccount);
        SetGLAccountFilters(LocalGLAccount, Dimension1ValueCode, Dimension2ValueCode, BusinessUnitCode);
        InsertTrialBalanceDataForGLAccountWithFilters(LocalGlAccount, EXRTrialBalanceBuffer);
    end;

    local procedure SetGLAccountFilters(var GLAccount: Record "G/L Account"; Dimension1ValueCode: Code[20]; Dimension2ValueCode: Code[20])
    begin
        GLAccount.SetFilter("Global Dimension 1 Filter", Dimension1ValueCode);
        GLAccount.SetFilter("Global Dimension 2 Filter", Dimension2ValueCode);
    end;

    local procedure SetGLAccountFilters(var GLAccount: Record "G/L Account"; Dimension1ValueCode: Code[20]; Dimension2ValueCode: Code[20]; BusinessUnitCode: Code[20])
    begin
        SetGLAccountFilters(GLAccount, Dimension1ValueCode, Dimension2ValueCode);
        GLAccount.SetFilter("Business Unit Filter", BusinessUnitCode);
    end;

    local procedure InsertTrialBalanceDataForGLAccountWithFilters(var GLAccount: Record "G/L Account"; var EXRTrialBalanceBuffer: Record "EXR Trial Balance Buffer")
    begin
        GlAccount.CalcFields("Net Change", "Balance at Date", "Additional-Currency Net Change", "Add.-Currency Balance at Date", "Budgeted Amount", "Budget at Date");
        EXRTrialBalanceBuffer."G/L Account No." := GlAccount."No.";
        EXRTrialBalanceBuffer."Dimension 1 Code" := CopyStr(GLAccount.GetFilter("Global Dimension 1 Filter"), 1, MaxStrLen(EXRTrialBalanceBuffer."Dimension 1 Code"));
        EXRTrialBalanceBuffer."Dimension 2 Code" := CopyStr(GLAccount.GetFilter("Global Dimension 2 Filter"), 1, MaxStrLen(EXRTrialBalanceBuffer."Dimension 2 Code"));
        EXRTrialBalanceBuffer."Business Unit Code" := CopyStr(GLAccount.GetFilter("Business Unit Filter"), 1, MaxStrLen(EXRTrialBalanceBuffer."Business Unit Code"));
        EXRTrialBalanceBuffer.Validate("Net Change", GLAccount."Net Change");
        EXRTrialBalanceBuffer.Validate(Balance, GLAccount."Balance at Date");
        EXRTrialBalanceBuffer.Validate("Net Change (ACY)", GLAccount."Additional-Currency Net Change");
        EXRTrialBalanceBuffer.Validate("Balance (ACY)", GLAccount."Add.-Currency Balance at Date");
        EXRTrialBalanceBuffer.Validate("Budget (Net)", GLAccount."Budgeted Amount");
        EXRTrialBalanceBuffer.Validate("Budget (Bal. at Date)", GLAccount."Budget at Date");
        EXRTrialBalanceBuffer.CalculateBudgetComparisons();
        EXRTrialBalanceBuffer.Insert(true);
    end;
}