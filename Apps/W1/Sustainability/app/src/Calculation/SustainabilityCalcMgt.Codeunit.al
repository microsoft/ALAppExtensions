namespace Microsoft.Sustainability.Calculation;

using Microsoft.Sustainability.Journal;
using Microsoft.Sustainability.Account;
using Microsoft.Finance.GeneralLedger.Ledger;

codeunit 6218 "Sustainability Calc. Mgt."
{
    var
        FromToFilterLbl: Label '%1..%2', Locked = true;

    internal procedure CalculationEmissions(var SustainabilityJnlLine: Record "Sustainability Jnl. Line")
    var
        SustainAccountCategory: Record "Sustain. Account Category";
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
        IsHandled: Boolean;
    begin
        OnBeforeCalculationEmissions(IsHandled, SustainabilityJnlLine);

        if IsHandled then
            exit;

        SustainAccountCategory.Get(SustainabilityJnlLine."Account Category");
        SustainAccountSubcategory.Get(SustainabilityJnlLine."Account Category", SustainabilityJnlLine."Account Subcategory");

        CalculationEmissions(SustainabilityJnlLine, SustainAccountCategory, SustainAccountSubcategory);
    end;

    internal procedure CalculationEmissions(var SustainabilityJnlLine: Record "Sustainability Jnl. Line"; SustainAccountCategory: Record "Sustain. Account Category"; SustainAccountSubcategory: Record "Sustain. Account Subcategory")
    var
        SustainabilityCalculation: Codeunit "Sustainability Calculation";
    begin
        if SustainabilityJnlLine."Manual Input" then
            exit;

        SustainAccountCategory.TestField("Emission Scope");
        SustainAccountCategory.TestField("Calculation Foundation");

        case SustainAccountCategory."Emission Scope" of
            Enum::"Emission Scope"::"Scope 1":
                SustainabilityCalculation.CalculateScope1Emissions(SustainabilityJnlLine, SustainAccountCategory, SustainAccountSubcategory);

            Enum::"Emission Scope"::"Scope 2":
                SustainabilityCalculation.CalculateScope2Emissions(SustainabilityJnlLine, SustainAccountCategory, SustainAccountSubcategory);

            Enum::"Emission Scope"::"Scope 3":
                SustainabilityCalculation.CalculateScope3Emissions(SustainabilityJnlLine, SustainAccountCategory, SustainAccountSubcategory);

            Enum::"Emission Scope"::"Water/Waste":
                SustainabilityCalculation.CalculateWaterOrWaste(SustainabilityJnlLine, SustainAccountCategory, SustainAccountSubcategory);
        end;

        if not SustainAccountCategory.CO2 then
            SustainabilityJnlLine.Validate("Emission CO2", 0);

        if not SustainAccountCategory.CH4 then
            SustainabilityJnlLine.Validate("Emission CH4", 0);

        if not SustainAccountCategory.N2O then
            SustainabilityJnlLine.Validate("Emission N2O", 0);

        if not SustainAccountCategory."Water Intensity" then
            SustainabilityJnlLine.Validate("Water Intensity", 0);

        if not SustainAccountCategory."Waste Intensity" then
            SustainabilityJnlLine.Validate("Waste Intensity", 0);

        if not SustainAccountCategory."Discharged Into Water" then
            SustainabilityJnlLine.Validate("Discharged Into Water", 0);
    end;

    /// <summary>
    /// Filter general ledger entries by criteria defined in sustainability category and by date and calculate the total
    /// </summary>
    /// <param name="SustainAccountCategory">Specifies the sustainability category that contains default filters.</param>
    /// <param name="FromDate">Specifies the "from" part of a date filter .</param>
    /// <param name="ToDate">Specifies the "to" part of a date filter .</param>
    /// <returns>The sum of G/L Entry Amounts.</returns>
    procedure GetCollectableGLAmount(SustainAccountCategory: Record "Sustain. Account Category"; FromDate: Date; ToDate: Date): Decimal
    var
        GLEntry: Record "G/L Entry";
    begin
        FilterGLEntry(SustainAccountCategory, FromDate, ToDate, GLEntry);
        GLEntry.CalcSums(Amount);
        exit(Abs(GLEntry.Amount));
    end;

    internal procedure CollectGeneralLedgerAmount(var SustainabilityJnlLine: Record "Sustainability Jnl. Line")
    var
        SustainAccountCategory: Record "Sustain. Account Category";
        CollectAmountFromGLEntry: Page "Collect Amount from G/L Entry";
        FromDate, ToDate : Date;
    begin
        SustainabilityJnlLine.Validate("Custom Amount");

        SustainAccountCategory.Get(SustainabilityJnlLine."Account Category");
        SustainAccountCategory.SetRecFilter();

        CollectAmountFromGLEntry.SetTableView(SustainAccountCategory);
        CollectAmountFromGLEntry.LookupMode(true);
        if CollectAmountFromGLEntry.RunModal() = Action::LookupOK then begin
            CollectAmountFromGLEntry.GetDates(FromDate, ToDate);
            SustainabilityJnlLine.Validate("Custom Amount", GetCollectableGLAmount(SustainAccountCategory, FromDate, ToDate));
        end;
    end;

    internal procedure FilterGLEntry(SustainAccountCategory: Record "Sustain. Account Category"; FromDate: Date; ToDate: Date; var GLEntry: Record "G/L Entry");
    begin
        GLEntry.Reset();
        GLEntry.SetFilter("G/L Account No.", SustainAccountCategory."G/L Account Filter");
        GLEntry.SetFilter("Global Dimension 1 Code", SustainAccountCategory."Global Dimension 1 Filter");
        GLEntry.SetFilter("Global Dimension 2 Code", SustainAccountCategory."Global Dimension 2 Filter");
        if (FromDate <> 0D) or (ToDate <> 0D) then
            GLEntry.SetFilter("Posting Date", StrSubstNo(FromToFilterLbl, FromDate, ToDate));
        OnAfterFilterGLEntry(SustainAccountCategory, FromDate, ToDate, GLEntry);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFilterGLEntry(SustainAccountCategory: Record "Sustain. Account Category"; FromDate: Date; ToDate: Date; var GLEntry: Record "G/L Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalculationEmissions(var IsHandled: Boolean; var SustainabilityJnlLine: Record "Sustainability Jnl. Line")
    begin
    end;
}