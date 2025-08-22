// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

using System.Telemetry;

codeunit 6329 "Sustainability Formula"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        Telemetry: Codeunit Telemetry;
        PublicInformationLbl: Label 'Public information';
        InvalidFormulaFormatLbl: Label 'Invalid formula format', Locked = true;
        CannotCalculateFormulaForLineNoLbl: Label 'Cannot calculate formula for line %1', Comment = '%1 = line no.', Locked = true;
        EmissionFormulaJsonDoesNotContainValueLbl: Label 'Emission formula JSON for line %1 does not contain value', Comment = '%1 = line no.', Locked = true;
        NotAllExpressionsHandledLbl: Label 'Not all expressions returned from LLM have been considered for calculation for line %1.', Comment = '%1 = line no.', Locked = true;
        FirstExpressionShouldBeTotalEmissionLbl: Label 'First expression should be Total emission for line %1', Comment = '%1 = line no.', Locked = true;
        EmissionFactorTakenFromSourceLbl: Label 'Emission factor taken from source for line %1', Comment = '%1 = line no.', Locked = true;
        CannotRetrieveExpressionFromArrayLbl: Label 'Cannot retrieve expression %1 from the array for line %2', Comment = '%1 = expression name, %2 = line no.', Locked = true;
        ExpressionAlreadyHandledLbl: Label 'Expression %1 is already handled. It might mean a circular reference for line %2', Comment = '%1 = expression name, %2 = line no.', Locked = true;
        UndefinedOperandTypeLbl: Label 'Undefined operand type for line %1', Comment = '%1 = line no.', Locked = true;
        UndefinedOperatorLbl: Label 'Undefined operator for line %1', Comment = '%1 = line no.', Locked = true;
        NoExpressionsHaveBeenRetrievedLbl: Label 'No expressions have been retrieved for line %1', Comment = '%1 = line no.', Locked = true;
        NoOFSourcesCalculatedLbl: Label 'No of sources calculated for line %1 is %2', Comment = '%1 = line no., %2 = no. of sources', Locked = true;
        ConversionFactorIsAppliedLbl: Label 'Conversion factor is applied for line %1', Comment = '%1 = line no.', Locked = true;
        NoSourceEmissionFactorFoundLbl: Label 'No source emission factor found for line %1', Comment = '%1 = line no.', Locked = true;
        SingleSourceEmissionFactorLbl: Label 'Single source emission factor is used for line %1', Comment = '%1 = line no.', Locked = true;
        LessThanFiveEmissionSourcesLbl: Label 'Less than five emission sources are available for line %1', Comment = '%1 = line no.', Locked = true;
        MoreThanFiveEmissionSourcesLbl: Label 'More than five emission sources are available for line %1', Comment = '%1 = line no.', Locked = true;

    [TryFunction]
    procedure ApplyFormula(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion"; var SourceCO2EmissionBuffer: Record "Source CO2 Emission Buffer")
    var
        SustFormulaBuffer: Record "Sust. Formula Buffer";
        SustainabilityEmissionSource: Codeunit "Sustainability Emission Source";
        LinesToken, ExpressionsToken : JsonToken;
        FormulaInStream: InStream;
    begin
        SustainEmissionSuggestion.CalcFields("Emission Formula Json");
        if not SustainEmissionSuggestion."Emission Formula Json".HasValue() then begin
            Telemetry.LogMessage('0000PWM', StrSubstNo(EmissionFormulaJsonDoesNotContainValueLbl, SustainEmissionSuggestion."Line No."), Verbosity::Error, DataClassification::SystemMetadata);
            exit;
        end;
        SustainEmissionSuggestion."Emission Formula Json".CreateInStream(FormulaInStream);
        LinesToken.ReadFrom(FormulaInStream);
        if not LinesToken.IsObject() then begin
            Telemetry.LogMessage('0000PWN', InvalidFormulaFormatLbl, Verbosity::Error, DataClassification::SystemMetadata);
            error(InvalidFormulaFormatLbl);
        end;

        SustainabilityEmissionSource.KeepRelevantSourceCO2EmissionBuffer(SustainEmissionSuggestion, SourceCO2EmissionBuffer);
        LinesToken.AsObject().Get('expressions', ExpressionsToken);
        if not CalculateFormulaTextAndValue(SustFormulaBuffer, SustainEmissionSuggestion, SourceCO2EmissionBuffer, ExpressionsToken) then begin
            Telemetry.LogMessage('0000PWO', StrSubstNo(CannotCalculateFormulaForLineNoLbl, SustainEmissionSuggestion."Line No."), Verbosity::Error, DataClassification::SystemMetadata);
            exit;
        end;

        CopySustFormulaBufferToSustainEmissionSuggestion(SustainEmissionSuggestion, SustFormulaBuffer, SourceCO2EmissionBuffer);
    end;

    [TryFunction]
    local procedure CalculateFormulaTextAndValue(var SustFormulaBuffer: Record "Sust. Formula Buffer"; var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion"; var SourceCO2EmissionBuffer: Record "Source CO2 Emission Buffer"; ExpressionsToken: JsonToken)
    var
        ExpressionToken: JsonToken;
        ExpressionsArray: JsonArray;
        LLMExpressionsCount, HandledExpressionsCount, Depth : Integer;
        ErrorMessage: Text;
    begin
        if not ExpressionsToken.IsArray() then
            exit;
        ExpressionsArray := ExpressionsToken.AsArray();
        ExpressionsArray.Get(0, ExpressionToken);
        BreakdownExpression(SustFormulaBuffer, SustainEmissionSuggestion, SourceCO2EmissionBuffer, Depth, ExpressionToken, ExpressionsArray, 0);
        LLMExpressionsCount := ExpressionsArray.Count();
        HandledExpressionsCount := SustFormulaBuffer.Count();
        if HandledExpressionsCount <> LLMExpressionsCount then begin
            ErrorMessage := StrSubstNo(NotAllExpressionsHandledLbl, SustainEmissionSuggestion."Line No.");
            Telemetry.LogMessage('0000PWP', ErrorMessage, Verbosity::Error, DataClassification::SystemMetadata);
            Error(ErrorMessage);
        end;
    end;

    local procedure BreakdownExpression(var SustFormulaBuffer: Record "Sust. Formula Buffer"; var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion"; var SourceCO2EmissionBuffer: Record "Source CO2 Emission Buffer"; var Depth: Integer; ExpressionToken: JsonToken; ExpressionsArray: JsonArray; ExpressionOrder: Integer) ExpressionResult: Decimal
    var
        ValueToken: JsonToken;
        LeftOperandValue, RightOperandValue : Decimal;
        ExpressionName, Operator, ExpressionText, ExpressionValueText, ErrorMessage : Text;
    begin
        ExpressionToken.AsObject().Get('name', ValueToken);
        ExpressionName := ValueToken.AsValue().AsText();
        if (ExpressionOrder = 0) and (ExpressionName.ToUpper() <> GetTotalEmissionExpressionName()) then begin
            ErrorMessage := StrSubstNo(FirstExpressionShouldBeTotalEmissionLbl, SustainEmissionSuggestion."Line No.");
            Telemetry.LogMessage('0000PWQ', ErrorMessage, Verbosity::Error, DataClassification::SystemMetadata);
            error(ErrorMessage);
        end;
        ExpressionText := ValueToken.AsValue().AsText() + ' = ';
        BreakdownOperandValue(ExpressionText, ExpressionValueText, LeftOperandValue, SustFormulaBuffer, SustainEmissionSuggestion, SourceCO2EmissionBuffer, Depth, ExpressionsArray, ExpressionToken, 'left');
        ExpressionToken.AsObject().Get('operator', ValueToken);
        Operator := ValueToken.AsValue().AsText();
        ExpressionText += ' ' + Operator + ' ';
        ExpressionValueText += ' ' + Operator + ' ';
        BreakdownOperandValue(ExpressionText, ExpressionValueText, RightOperandValue, SustFormulaBuffer, SustainEmissionSuggestion, SourceCO2EmissionBuffer, Depth, ExpressionsArray, ExpressionToken, 'right');
        ExpressionText += ' = ';
        ExpressionValueText += ' = ';
        DoCalculation(ExpressionResult, LeftOperandValue, RightOperandValue, Operator, SustainEmissionSuggestion."Line No.");
        ExpressionValueText += Format(ExpressionResult);
        ExpressionText += ExpressionValueText;
        SustFormulaBuffer.InsertExpression(ExpressionName, ExpressionText, ExpressionResult, ExpressionOrder);
        exit(ExpressionResult);
    end;

    local procedure BreakdownOperandValue(var ExpressionText: Text; var ExpressionValueText: Text; var OperandValue: Decimal; var SustFormulaBuffer: Record "Sust. Formula Buffer"; var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion"; var SourceCO2EmissionBuffer: Record "Source CO2 Emission Buffer"; var Depth: Integer; ExpressionsArray: JsonArray; ExpressionToken: JsonToken; Side: Text)
    var
        ValueToken, NewExpressionToken, NewExpressionValueToken : JsonToken;
        ExpressionName, ExpressionErr, OperandValueText, ErrorMessage : Text;
        MaximumDepthExceededLbl: Label 'Maximum depth of %1 exceeded for line %2', Comment = '%1 = maximum depth, %2 = line no.', Locked = true;
        i: Integer;
    begin
        ExpressionToken.AsObject().Get(Side + '_operand_name', ValueToken);
        ExpressionName := ValueToken.AsValue().AsText();
        ExpressionToken.AsObject().Get(Side + '_operand_value', ValueToken);
        OperandValue := ValueToken.AsValue().AsDecimal();
        ExpressionToken.AsObject().Get(Side + '_operand_type', ValueToken);
        case ValueToken.AsValue().AsText() of
            'value':
                begin
                    ExpressionText += ExpressionName;
                    OperandValueText := Format(OperandValue);
                    if StrPos(ExpressionName, 'Emission Factor') > 0 then
                        if SustainEmissionSuggestion."Factor Taken From Source" then begin
                            OperandValue := SustainEmissionSuggestion."Emission Factor CO2";
                            Telemetry.LogMessage('0000PWR', StrSubstNo(EmissionFactorTakenFromSourceLbl, SustainEmissionSuggestion."Line No."), Verbosity::Normal, DataClassification::SystemMetadata);
                        end else
                            UseSourceCO2EmissionInFormula(SustainEmissionSuggestion, SourceCO2EmissionBuffer, OperandValue, ExpressionText, OperandValueText);
                    ExpressionValueText += OperandValueText;
                end;
            'expression':
                begin
                    for i := 1 to ExpressionsArray.Count() - 1 do begin
                        ExpressionsArray.Get(i, NewExpressionToken);
                        NewExpressionToken.AsObject().Get('name', NewExpressionValueToken);
                        if NewExpressionValueToken.AsValue().AsText() = ExpressionName then
                            break;
                    end;
                    if NewExpressionValueToken.AsValue().AsText() <> ExpressionName then begin
                        ExpressionErr := StrSubstNo(CannotRetrieveExpressionFromArrayLbl, ExpressionName, SustainEmissionSuggestion."Line No.");
                        error(ExpressionErr);
                    end;
                    if SustFormulaBuffer.Get(ExpressionName) then begin
                        ErrorMessage := StrSubstNo(ExpressionAlreadyHandledLbl, ExpressionName, SustainEmissionSuggestion."Line No.");
                        Telemetry.LogMessage('0000PWS', ErrorMessage, Verbosity::Error, DataClassification::SystemMetadata);
                        error(ExpressionAlreadyHandledLbl);
                    end;
                    OperandValue := BreakdownExpression(SustFormulaBuffer, SustainEmissionSuggestion, SourceCO2EmissionBuffer, Depth, NewExpressionToken, ExpressionsArray, i);
                    ExpressionText += ExpressionName;
                    ExpressionValueText += Format(OperandValue);
                end;
            else begin
                ErrorMessage := StrSubstNo(UndefinedOperandTypeLbl, SustainEmissionSuggestion."Line No.");
                Telemetry.LogMessage('0000PWT', ErrorMessage, Verbosity::Error, DataClassification::SystemMetadata);
                error(ErrorMessage);
            end;
        end;
        Depth += 1;
        if Depth > GetMaximumFormulaDepth() then begin
            ErrorMessage := StrSubstNo(MaximumDepthExceededLbl, Depth, SustainEmissionSuggestion."Line No.");
            Telemetry.LogMessage('0000PX2', ErrorMessage, Verbosity::Error, DataClassification::SystemMetadata);
            error(ErrorMessage);
        end;
    end;

    local procedure DoCalculation(var ExpressionResult: Decimal; LeftOperandValue: Decimal; RightOperandValue: Decimal; Operator: Text; JnlLineNo: Integer)
    var
        ErrorMessage: Text;
    begin
        case Operator of
            '+':
                ExpressionResult := LeftOperandValue + RightOperandValue;
            '-':
                ExpressionResult := LeftOperandValue - RightOperandValue;
            '*':
                ExpressionResult := LeftOperandValue * RightOperandValue;
            '/':
                ExpressionResult := LeftOperandValue / RightOperandValue;
            else begin
                ErrorMessage := StrSubstNo(UndefinedOperatorLbl, JnlLineNo);
                Telemetry.LogMessage('0000PWU', ErrorMessage, Verbosity::Error, DataClassification::SystemMetadata);
                error(ErrorMessage);
            end;
        end;
    end;

    local procedure GetTotalEmissionExpressionName(): Text;
    begin
        exit('TOTAL EMISSION');
    end;

    local procedure CopySustFormulaBufferToSustainEmissionSuggestion(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion"; var SustFormulaBuffer: Record "Sust. Formula Buffer"; var SourceCO2EmissionBuffer: Record "Source CO2 Emission Buffer")
    var
        CalculationDescription, ErrorMessage : Text;
        TotalEmission: Decimal;
        CalcTextBuilder: TextBuilder;
        CalcDescrOutStr: OutStream;
        NoOfSources: Integer;
    begin
        SustFormulaBuffer.SetCurrentKey(Order);
        SustFormulaBuffer.SetAscending(Order, false);
        if not SustFormulaBuffer.FindSet() then begin
            ErrorMessage := StrSubstNo(NoExpressionsHaveBeenRetrievedLbl, SustainEmissionSuggestion."Line No.");
            Telemetry.LogMessage('0000PWV', ErrorMessage, Verbosity::Error, DataClassification::SystemMetadata);
            error(ErrorMessage);
        end;
        repeat
            CalcTextBuilder.AppendLine(SustFormulaBuffer."Expression Formula");
        until SustFormulaBuffer.Next() = 0;
        CalculationDescription := CalcTextBuilder.ToText();
        TotalEmission := SustFormulaBuffer."Expression Value";

        SustainEmissionSuggestion."Calculated by Copilot" := true;
        NoOfSources := SourceCO2EmissionBuffer.Count();
        // NoOfSources = 0 - public information
        // NoOfSources = 1 - only one source
        // Factor Taken From Source - user choose one of the sources
        if (NoOfSources = 0) or (NoOfSources = 1) or SustainEmissionSuggestion."Factor Taken From Source" then begin
            SustainEmissionSuggestion."Emission CO2" := TotalEmission;
            if SustainEmissionSuggestion."Emission Factor Source" = '' then
                SustainEmissionSuggestion."Emission Factor Source" := PublicInformationLbl;
        end;
        Telemetry.LogMessage('0000PWW', StrSubstNo(NoOFSourcesCalculatedLbl, SustainEmissionSuggestion."Line No.", Format(NoOfSources)), Verbosity::Normal, DataClassification::SystemMetadata);
        SustainEmissionSuggestion."Emission Calc. Explanation".CreateOutStream(CalcDescrOutStr, TextEncoding::UTF8);
        CalcDescrOutStr.WriteText(CalculationDescription);
        SustainEmissionSuggestion.Modify();
    end;

    local procedure UseSourceCO2EmissionInFormula(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion"; var SourceCO2EmissionBuffer: Record "Source CO2 Emission Buffer"; var OperandValue: Decimal; var ExpressionText: Text; var OperandValueText: Text)
    var
        EmissionSourceSetup: Record "Emission Source Setup";
        ChooseOptionsSourceDescriptionLbl: Label 'Choose one of options!';
        TooManyOptionsWarningLbl: Label 'Too many options to offer. Please refine the description.';
        ChooseOptionsWarningLbl: Label 'There are more than one source, please choose one of the options. If you don''t choose any, the line won''t be kept and transferred to the journal.';
    begin
        SourceCO2EmissionBuffer.SetCurrentKey("Confidence Value");
        SourceCO2EmissionBuffer.SetAscending("Confidence Value", false);
        SourceCO2EmissionBuffer.SetRange("Line No.", SustainEmissionSuggestion."Line No.");
        if not SourceCO2EmissionBuffer.FindFirst() then begin
            Telemetry.LogMessage('0000PWX', StrSubstNo(NoSourceEmissionFactorFoundLbl, SustainEmissionSuggestion."Line No."), Verbosity::Error, DataClassification::SystemMetadata);
            SustainEmissionSuggestion."Emission Factor CO2" := OperandValue;
            exit;
        end;
        OperandValue := SourceCO2EmissionBuffer."Emission Factor CO2";
        OperandValueText := Format(OperandValue);
        EmissionSourceSetup.Get(SourceCO2EmissionBuffer."Emission Source ID");
        case SourceCO2EmissionBuffer.Count() of
            1:
                begin
                    if SourceCO2EmissionBuffer."Conversion Factor" <> 0 then begin
                        OperandValue *= SourceCO2EmissionBuffer."Conversion Factor";
                        ExpressionText += ' * Conversion Factor';
                        OperandValueText += ' * ' + Format(SourceCO2EmissionBuffer."Conversion Factor");
                        Telemetry.LogMessage('0000PWY', StrSubstNo(ConversionFactorIsAppliedLbl, SustainEmissionSuggestion."Line No."), Verbosity::Normal, DataClassification::SystemMetadata);
                    end;
                    SustainEmissionSuggestion."Emission Factor CO2" := OperandValue;
                    SustainEmissionSuggestion."Emission Factor Source" := EmissionSourceSetup.Description + ', ' + SourceCO2EmissionBuffer.Description;
                    Telemetry.LogMessage('0000PWZ', StrSubstNo(SingleSourceEmissionFactorLbl, SustainEmissionSuggestion."Line No."), Verbosity::Normal, DataClassification::SystemMetadata);
                end;
            2 .. 5:
                begin
                    SustainEmissionSuggestion."Emission Factor Source" := ChooseOptionsSourceDescriptionLbl;
                    SustainEmissionSuggestion."Emission Factor CO2" := 0;
                    SustainEmissionSuggestion.UpdateWarnings(ChooseOptionsWarningLbl);
                    Telemetry.LogMessage('0000PX0', StrSubstNo(LessThanFiveEmissionSourcesLbl, SustainEmissionSuggestion."Line No."), Verbosity::Normal, DataClassification::SystemMetadata);
                end;
            else
                if SourceCO2EmissionBuffer.Count() > 5 then begin
                    SustainEmissionSuggestion."Emission Factor Source" := '';
                    SustainEmissionSuggestion."Emission Factor CO2" := 0;
                    SustainEmissionSuggestion.UpdateWarnings(TooManyOptionsWarningLbl);
                    Telemetry.LogMessage('0000PX1', StrSubstNo(MoreThanFiveEmissionSourcesLbl, SustainEmissionSuggestion."Line No."), Verbosity::Normal, DataClassification::SystemMetadata);
                end;
        end;
    end;

    local procedure GetMaximumFormulaDepth(): Integer
    begin
        exit(10);
    end;
}