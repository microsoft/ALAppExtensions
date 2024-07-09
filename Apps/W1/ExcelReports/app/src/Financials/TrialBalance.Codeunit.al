namespace Microsoft.Finance.ExcelReports;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.Consolidation;
using Microsoft.Finance.Dimension;

codeunit 4410 "Trial Balance"
{
    var
        GlobalBreakdownByDimension: Boolean;
        GlobalBreakdownByBusinessUnit: Boolean;
        BlankLbl: Label '(BLANK)';

    internal procedure ConfigureTrialBalance(BreakdownByDimension: Boolean; BreakdownByBusinessUnit: Boolean)
    begin
        GlobalBreakdownByDimension := BreakdownByDimension;
        GlobalBreakdownByBusinessUnit := BreakdownByBusinessUnit;
    end;

    internal procedure InsertTrialBalanceReportData(var GLAccount: Record "G/L Account"; var Dimension1Values: Record "Dimension Value" temporary; var Dimension2Values: Record "Dimension Value" temporary; var TrialBalanceData: Record "EXR Trial Balance Buffer")
    var
        DimensionValue: Record "Dimension Value";
        BusinessUnitFilters, Dimension1Filters, Dimension2Filters : List of [Code[20]];
    begin
        if not GLAccount.FindSet() then
            exit;

        if GlobalBreakdownByDimension then begin
            DimensionValue.SetRange("Global Dimension No.", 1);
            InsertDimensionFiltersFromDimensionValues(DimensionValue, Dimension1Filters);
            DimensionValue.SetRange("Global Dimension No.", 2);
            InsertDimensionFiltersFromDimensionValues(DimensionValue, Dimension2Filters);
        end;
        if GlobalBreakdownByBusinessUnit then
            InsertBusinessUnitFilters(BusinessUnitFilters);

        Clear(TrialBalanceData);
        TrialBalanceData.DeleteAll();
        repeat
            InsertBreakdownForGLAccount(GLAccount, Dimension1Filters, Dimension2Filters, BusinessUnitFilters, TrialBalanceData, Dimension1Values, Dimension2Values);
        until GLAccount.Next() = 0;
    end;

    local procedure InsertBusinessUnitFilters(var BusinessUnitFilters: List of [Code[20]])
    var
        BusinessUnit: Record "Business Unit";
    begin
        BusinessUnitFilters.Add('');
        if not BusinessUnit.FindSet() then
            exit;
        repeat
            BusinessUnitFilters.Add(BusinessUnit.Code);
        until BusinessUnit.Next() = 0;
    end;

    local procedure InsertDimensionFiltersFromDimensionValues(var DimensionValue: Record "Dimension Value"; var DimensionFilters: List of [Code[20]])
    begin
        DimensionFilters.Add('');
        if not DimensionValue.FindSet() then
            exit;
        repeat
            DimensionFilters.Add(DimensionValue.Code);
        until DimensionValue.Next() = 0;
    end;

    local procedure InsertBreakdownForGLAccount(var GLAccount: Record "G/L Account"; Dimension1Filters: List of [Code[20]]; Dimension2Filters: List of [Code[20]]; BusinessUnitCodeFilters: List of [Code[20]]; var TrialBalanceData: Record "EXR Trial Balance Buffer"; var Dimension1Values: Record "Dimension Value" temporary; var Dimension2Values: Record "Dimension Value" temporary)
    var
        i, j, k : Integer;
    begin
        if GlobalBreakdownByDimension then
            for i := 1 to Dimension1Filters.Count do
                for j := 1 to Dimension2Filters.Count do
                    if GlobalBreakdownByBusinessUnit then
                        for k := 1 to BusinessUnitCodeFilters.Count do
                            InsertGLAccountTotalsForFilters(Dimension1Filters.Get(i), Dimension2Filters.Get(j), BusinessUnitCodeFilters.Get(k), GLAccount, TrialBalanceData, Dimension1Values, Dimension2Values)
                    else
                        InsertGLAccountTotalsForFilters(Dimension1Filters.Get(i), Dimension2Filters.Get(j), GLAccount, TrialBalanceData, Dimension1Values, Dimension2Values)
        else
            if GlobalBreakdownByBusinessUnit then
                for i := 1 to BusinessUnitCodeFilters.Count do
                    InsertGLAccountTotalsForFilters(BusinessUnitCodeFilters.Get(i), GLAccount, TrialBalanceData)
            else
                InsertGLAccountTotalsForFilters(GLAccount, TrialBalanceData);
    end;

    local procedure InsertGLAccountTotalsForFilters(var GLAccount: Record "G/L Account"; var TrialBalanceData: Record "EXR Trial Balance Buffer")
    var
        TempDimension1Values: Record "Dimension Value" temporary;
        TempDimension2Values: Record "Dimension Value" temporary;
    begin
        InsertGLAccountTotalsForFilters('', '', '', GLAccount, TrialBalanceData, TempDimension1Values, TempDimension2Values);
    end;

    local procedure InsertGLAccountTotalsForFilters(BusinessUnitCode: Code[20]; var GLAccount: Record "G/L Account"; var TrialBalanceData: Record "EXR Trial Balance Buffer")
    var
        TempDimension1Values: Record "Dimension Value" temporary;
        TempDimension2Values: Record "Dimension Value" temporary;
    begin
        InsertGLAccountTotalsForFilters('', '', BusinessUnitCode, GLAccount, TrialBalanceData, TempDimension1Values, TempDimension2Values);
    end;

    local procedure InsertGLAccountTotalsForFilters(Dimension1ValueCode: Code[20]; Dimension2ValueCode: Code[20]; var GLAccount: Record "G/L Account"; var TrialBalanceData: Record "EXR Trial Balance Buffer"; var Dimension1Values: Record "Dimension Value" temporary; var Dimension2Values: Record "Dimension Value" temporary)
    begin
        InsertGLAccountTotalsForFilters(Dimension1ValueCode, Dimension2ValueCode, '', GLAccount, TrialBalanceData, Dimension1Values, Dimension2Values);
    end;

    local procedure InsertGLAccountTotalsForFilters(Dimension1ValueCode: Code[20]; Dimension2ValueCode: Code[20]; BusinessUnitCode: Code[20]; var GLAccount: Record "G/L Account"; var TrialBalanceData: Record "EXR Trial Balance Buffer"; var Dimension1Values: Record "Dimension Value" temporary; var Dimension2Values: Record "Dimension Value" temporary)
    var
        LocalGlAccount: Record "G/L Account";
    begin
        LocalGlAccount.Copy(GLAccount);
        if GlobalBreakdownByDimension then begin
            LocalGLAccount.SetFilter("Global Dimension 1 Filter", '= ''%1''', Dimension1ValueCode);
            LocalGLAccount.SetFilter("Global Dimension 2 Filter", '= ''%1''', Dimension2ValueCode);
        end;
        if GlobalBreakdownByBusinessUnit then
            LocalGLAccount.SetFilter("Business Unit Filter", '= %1', BusinessUnitCode);
        InsertTrialBalanceDataForGLAccountWithFilters(LocalGlAccount, Dimension1ValueCode, Dimension2ValueCode, BusinessUnitCode, TrialBalanceData, Dimension1Values, Dimension2Values);
    end;

    local procedure InsertTrialBalanceDataForGLAccountWithFilters(var GLAccount: Record "G/L Account"; Dimension1ValueCode: Code[20]; Dimension2ValueCode: Code[20]; BusinessUnitCode: Code[20]; var TrialBalanceData: Record "EXR Trial Balance Buffer"; var Dimension1Values: Record "Dimension Value" temporary; var Dimension2Values: Record "Dimension Value" temporary)
    begin
        GlAccount.CalcFields("Net Change", "Balance at Date", "Additional-Currency Net Change", "Add.-Currency Balance at Date", "Budgeted Amount", "Budget at Date");
        TrialBalanceData."G/L Account No." := GlAccount."No.";
        TrialBalanceData."Dimension 1 Code" := Dimension1ValueCode;
        TrialBalanceData."Dimension 2 Code" := Dimension2ValueCode;
        TrialBalanceData."Business Unit Code" := BusinessUnitCode;
        TrialBalanceData.Validate("Net Change", GLAccount."Net Change");
        TrialBalanceData.Validate(Balance, GLAccount."Balance at Date");
        TrialBalanceData.Validate("Net Change (ACY)", GLAccount."Additional-Currency Net Change");
        TrialBalanceData.Validate("Balance (ACY)", GLAccount."Add.-Currency Balance at Date");
        TrialBalanceData.Validate("Budget (Net)", GLAccount."Budgeted Amount");
        TrialBalanceData.Validate("Budget (Bal. at Date)", GLAccount."Budget at Date");
        TrialBalanceData.CalculateBudgetComparisons();
        TrialBalanceData.CheckAllZero();
        if not TrialBalanceData."All Zero" then begin
            TrialBalanceData.Insert(true);
            if GlobalBreakdownByDimension then begin
                InsertUsedDimensionValue(1, TrialBalanceData."Dimension 1 Code", Dimension1Values);
                InsertUsedDimensionValue(2, TrialBalanceData."Dimension 2 Code", Dimension2Values);
            end;
        end;
    end;

    local procedure InsertUsedDimensionValue(GlobalDimensionNo: Integer; DimensionCode: Code[20]; var InsertedDimensionValues: Record "Dimension Value" temporary)
    var
        DimensionValue: Record "Dimension Value";
    begin
        Clear(InsertedDimensionValues);
        if DimensionCode <> '' then
            InsertedDimensionValues.SetRange("Global Dimension No.", GlobalDimensionNo);
        InsertedDimensionValues.SetRange(Code, DimensionCode);
        if not InsertedDimensionValues.IsEmpty() then
            exit;
        if DimensionCode = '' then begin
            InsertedDimensionValues."Dimension Code" := DimensionCode;
            InsertedDimensionValues.Name := BlankLbl;
            InsertedDimensionValues.Insert();
            exit;
        end;
        DimensionValue.CopyFilters(InsertedDimensionValues);
        DimensionValue.FindFirst();
        InsertedDimensionValues.Copy(DimensionValue);
        InsertedDimensionValues.Insert();
    end;
}