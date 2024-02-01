namespace Microsoft.Sustainability.Posting;

using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Journal;
using Microsoft.Sustainability.Setup;
using Microsoft.Finance.Dimension;
using Microsoft.Sustainability.Calculation;

codeunit 6216 "Sustainability Jnl.-Check"
{
    Access = Internal;
    TableNo = "Sustainability Jnl. Line";
    Permissions =
        tabledata "Sustainability Jnl. Line" = r,
        tabledata "Sustainability Jnl. Batch" = r,
        tabledata "Sustainability Account" = r;

    trigger OnRun()
    begin
        Rec.ReadIsolation := IsolationLevel::ReadUncommitted;

        CheckCommonConditionsBeforePosting(Rec);

        if Rec.FindSet() then
            repeat
                CheckSustainabilityJournalLine(Rec);
            until Rec.Next() = 0;
    end;

    procedure CheckCommonConditionsBeforePosting(var SustainabilityJnlLine: Record "Sustainability Jnl. Line")
    begin
        if SustainabilityJnlLine."Line No." = 0 then
            Error(SustainabilityJnlLineEmptyErr);

        // This condition should be met by design, but checking in case of customization
        if not (SustainabilityJnlLine.GetRangeMax("Journal Template Name") = SustainabilityJnlLine.GetRangeMin("Journal Template Name")) then
            Error(SustainabilityJournalTemplateMismatchErr);

        if not (SustainabilityJnlLine.GetRangeMax("Journal Batch Name") = SustainabilityJnlLine.GetRangeMin("Journal Batch Name")) then
            Error(SustainabilityJournalBatchMismatchErr);
    end;

    procedure CheckSustainabilityJournalLine(SustainabilityJnlLine: Record "Sustainability Jnl. Line")
    var
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
    begin
        SustainabilityJnlLine.TestField("Posting Date", ErrorInfo.Create());
        SustainabilityJnlLine.TestField("Document No.", ErrorInfo.Create());
        SustainabilityJnlLine.TestField(Description, ErrorInfo.Create());
        SustainabilityJnlLine.TestField("Unit of Measure", ErrorInfo.Create());

        if SustainabilityAccount.Get(SustainabilityJnlLine."Account No.") then begin
            SustainabilityAccount.CheckAccountReadyForPosting();
            SustainabilityAccount.TestField("Direct Posting", ErrorInfo.Create());
            SustainabilityJournalMgt.CheckScopeMatchWithBatch(SustainabilityJnlLine);
        end else
            SustainabilityJnlLine.TestField("Account No.", ErrorInfo.Create());

        TestEmissionCalculationAndAmount(SustainabilityJnlLine);

        TestRequiredFieldsFromSetupForJnlLine(SustainabilityJnlLine);

        TestDimensionsForJnlLine(SustainabilityJnlLine);
    end;

    local procedure TestEmissionCalculationAndAmount(SustainabilityJnlLine: Record "Sustainability Jnl. Line")
    var
        SustainabilityCalcMgt: Codeunit "Sustainability Calc. Mgt.";
        EmissionCO2, EmissionCH4, EmissionN2O : Decimal;
    begin
        if (SustainabilityJnlLine."Emission CO2" = 0) and (SustainabilityJnlLine."Emission CH4" = 0) and (SustainabilityJnlLine."Emission N2O" = 0) then
            Error(ErrorInfo.Create(AllEmissionsZeroErr, true, SustainabilityJnlLine));

        EmissionCO2 := SustainabilityJnlLine."Emission CO2";
        EmissionCH4 := SustainabilityJnlLine."Emission CH4";
        EmissionN2O := SustainabilityJnlLine."Emission N2O";

        SustainabilityCalcMgt.CalculationEmissions(SustainabilityJnlLine);

        if (EmissionCO2 <> SustainabilityJnlLine."Emission CO2") or (EmissionCH4 <> SustainabilityJnlLine."Emission CH4") or (EmissionN2O <> SustainabilityJnlLine."Emission N2O") then
            Error(ErrorInfo.Create(EmissionCalculationErr, true, SustainabilityJnlLine));
    end;

    local procedure TestRequiredFieldsFromSetupForJnlLine(SustainabilityJnlLine: Record "Sustainability Jnl. Line")
    var
        SustainabilitySetup: Record "Sustainability Setup";
    begin
        SustainabilitySetup.Get();
        if SustainabilitySetup."Country/Region Mandatory" then
            SustainabilityJnlLine.TestField("Country/Region Code", ErrorInfo.Create());

        if SustainabilitySetup."Resp. Center Mandatory" then
            SustainabilityJnlLine.TestField("Responsibility Center", ErrorInfo.Create());
    end;

    local procedure TestDimensionsForJnlLine(SustainabilityJnlLine: Record "Sustainability Jnl. Line")
    var
        DimMgt: Codeunit DimensionManagement;
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        if not DimMgt.CheckDimIDComb(SustainabilityJnlLine."Dimension Set ID") then
            Error(ErrorInfo.Create(DimMgt.GetDimCombErr(), true, SustainabilityJnlLine));

        TableID[1] := Database::"Sustainability Account";
        No[1] := SustainabilityJnlLine."Account No.";

        if not DimMgt.CheckDimValuePosting(TableID, No, SustainabilityJnlLine."Dimension Set ID") then
            Error(ErrorInfo.Create(DimMgt.GetDimValuePostingErr(), true, SustainabilityJnlLine));
    end;

    var
        SustainabilityJnlLineEmptyErr: Label 'There is nothing to post.';
        SustainabilityJournalTemplateMismatchErr: Label 'The journal template name must be the same for all lines.';
        SustainabilityJournalBatchMismatchErr: Label 'The journal batch name must be the same for all lines.';
        AllEmissionsZeroErr: Label 'At least one emission must be specified.';
        EmissionCalculationErr: Label 'The emission calculation is not correct, use the `Recalculate` action on the Journal page to recalculate the emission before posting.';
}