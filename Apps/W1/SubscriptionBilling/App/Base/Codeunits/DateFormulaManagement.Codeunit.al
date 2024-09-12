namespace Microsoft.SubscriptionBilling;

codeunit 8057 "Date Formula Management"
{
    Access = Internal;

    var
        DateFormulaNegativeErr: Label 'The date formula cannot be negative.';
        DateFormulaEmptyErr: Label 'The %1 must be filled out. Please enter a date formula.';
        DateEmptyErr: Label 'The %1 must be filled out. Please enter a date.';
        CurrentPeriodErr: Label 'Current Period cannot be used for The Date Formula.';
        EmptyFormulaErr: Label 'The Date Formula cannot be empty.';
        ComplexFormulaErr: Label 'The Date Formula cannot be complex.';
        NaturalNumberRatioErr: Label 'The ratio of ''%1'' and ''%2'' or vice versa must give a natural number.';

    procedure ErrorIfDateFormulaEmpty(DateFormula: DateFormula; FieldCaption: Text)
    begin
        if Format(DateFormula) = '' then
            Error(DateFormulaEmptyErr, FieldCaption);
    end;

    procedure ErrorIfDateFormulaNegative(DateFormula: DateFormula)
    begin
        if StrPos(Format(DateFormula), '-') <> 0 then
            Error(DateFormulaNegativeErr);
    end;

    procedure ErrorIfDateEmpty(Date: Date; FieldCaption: Text)
    begin
        if Date = 0D then
            Error(DateEmptyErr, FieldCaption);
    end;

    procedure CheckIntegerRatioForDateFormulas(DateFormula1: DateFormula; DateFormula1Caption: Text; DateFormula2: DateFormula; DateFormula2Caption: Text)
    var
        DateFormulaType1: Enum "Date Formula Type";
        DateFormulaType2: Enum "Date Formula Type";
        PeriodCountForComparison1: Integer;
        PeriodCountForComparison2: Integer;
        Modulus: Decimal;
    begin
        if (Format(DateFormula1) = '') or (Format(DateFormula2) = '') then
            exit;

        DateFormulaType1 := FindDateFormulaTypeForComparison(DateFormula1, PeriodCountForComparison1);
        DateFormulaType2 := FindDateFormulaTypeForComparison(DateFormula2, PeriodCountForComparison2);

        if (DateFormulaType1 = DateFormulaType1::Empty) or
          (DateFormulaType2 = DateFormulaType2::Empty)
        then
            Error(EmptyFormulaErr);
        if (DateFormulaType1 = DateFormulaType1::ComplexFormula) or
          (DateFormulaType2 = DateFormulaType2::ComplexFormula)
        then
            Error(ComplexFormulaErr);
        if (DateFormulaType1 = DateFormulaType1::CurrentPeriod) or
            (DateFormulaType2 = DateFormulaType2::CurrentPeriod)
         then
            Error(CurrentPeriodErr);

        if (DateFormulaType1 in [DateFormulaType1::Day, DateFormulaType1::Week]) or
           (DateFormulaType2 in [DateFormulaType2::Day, DateFormulaType2::Week])
        then
            if DateFormulaType1 <> DateFormulaType2 then
                Error(NaturalNumberRatioErr, DateFormula1Caption, DateFormula2Caption);

        if PeriodCountForComparison1 > PeriodCountForComparison2 then
            Modulus := PeriodCountForComparison1 / PeriodCountForComparison2 mod 1
        else
            Modulus := PeriodCountForComparison2 / PeriodCountForComparison1 mod 1;

        if Modulus <> 0 then
            Error(NaturalNumberRatioErr, DateFormula1Caption, DateFormula2Caption);
    end;

    procedure FindDateFormulaType(InputDateFormula: DateFormula; var PeriodCount: Integer; var Letter: Char) DateFormulaType: Enum "Date Formula Type"
    var
        InputDateText: Text;
        LetterPosition: Integer;
    begin
        InputDateText := DelChr(Format(InputDateFormula, 0, 2), '=', '<>');
        if StrPos(InputDateText, 'C') <> 0 then
            exit(DateFormulaType::CurrentPeriod);
        InputDateText := ConvertStr(InputDateText, 'DWMQY', 'FFFFF'); // Convert all Letters used for Date Formula in order to check that only exactly Letter used for Date Formula exist
        if StrPos(InputDateText, 'F') = 0 then
            exit(DateFormulaType::Empty)
        else
            if StrPos(CopyStr(InputDateText, StrPos(InputDateText, 'F') + 1), 'F') <> 0 then
                exit(DateFormulaType::ComplexFormula);
        InputDateText := DelChr(Format(InputDateFormula, 0, 2), '=', '<>');

        case true of
            StrPos(InputDateText, 'D') <> 0:
                begin
                    DateFormulaType := DateFormulaType::Day;
                    LetterPosition := StrPos(InputDateText, 'D');
                end;
            StrPos(InputDateText, 'W') <> 0:
                begin
                    DateFormulaType := DateFormulaType::Week;
                    LetterPosition := StrPos(InputDateText, 'W');
                end;
            StrPos(InputDateText, 'M') <> 0:
                begin
                    DateFormulaType := DateFormulaType::Month;
                    LetterPosition := StrPos(InputDateText, 'M');
                end;
            StrPos(InputDateText, 'Q') <> 0:
                begin
                    DateFormulaType := DateFormulaType::Quarter;
                    LetterPosition := StrPos(InputDateText, 'Q');
                end;
            StrPos(InputDateText, 'Y') <> 0:
                begin
                    DateFormulaType := DateFormulaType::Year;
                    LetterPosition := StrPos(InputDateText, 'Y');
                end;
        end;
        Evaluate(PeriodCount, CopyStr(InputDateText, 1, LetterPosition - 1));
        Evaluate(Letter, CopyStr(InputDateText, LetterPosition, 1));
    end;

    procedure FindDateFormulaType(InputDateFormula: DateFormula; var PeriodCount: Integer) DateFormulaType: Enum "Date Formula Type"
    var
        Letter: Char;
    begin
        DateFormulaType := FindDateFormulaType(InputDateFormula, PeriodCount, Letter);
    end;

    procedure FindDateFormulaTypeForComparison(InputDateFormula: DateFormula; var PeriodCountForComparison: Integer) DateFormulaType: Enum "Date Formula Type"
    begin
        DateFormulaType := FindDateFormulaType(InputDateFormula, PeriodCountForComparison);
        // Months can be compared to a Quarter and to a Year, Weeks and Days cannot be compared to Months, Quartes and Years
        case DateFormulaType of
            DateFormulaType::Quarter:
                PeriodCountForComparison := PeriodCountForComparison * 3;
            DateFormulaType::Year:
                PeriodCountForComparison := PeriodCountForComparison * 12;
        end;
    end;

    internal procedure CalculateRenewalTermRatioByBillingRhythm(StartDate: Date; RenewalTermDateFormula: DateFormula; BillingRhythmFormula: DateFormula) RenewalRatio: Decimal
    var
        RenewalTermEndDate: Date;
        NextBillingDate: Date;
        PreviousBillingDate: Date;
        RemainingDaysToRenewalTermEndDate: Integer;
        RemainingDaysToNextBillingDate: Integer;
    begin
        RenewalTermEndDate := CalcDate(RenewalTermDateFormula, StartDate);
        NextBillingDate := CalcDate(BillingRhythmFormula, StartDate);
        PreviousBillingDate := StartDate;
        while NextBillingDate <= RenewalTermEndDate do begin
            RenewalRatio += 1;
            PreviousBillingDate := NextBillingDate;
            NextBillingDate := CalcDate(BillingRhythmFormula, NextBillingDate);
        end;
        if NextBillingDate > RenewalTermEndDate then begin
            RemainingDaysToRenewalTermEndDate := RenewalTermEndDate - PreviousBillingDate;
            RemainingDaysToNextBillingDate := NextBillingDate - PreviousBillingDate;
            RenewalRatio += RemainingDaysToRenewalTermEndDate / RemainingDaysToNextBillingDate;
        end;
    end;
}