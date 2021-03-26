codeunit 20161 "Condition Mgmt."
{
    procedure OpenConditionsDialog(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        Condition: Record "Tax Test Condition";
        ConditionsDialog: Page "Conditions Dialog";
    begin
        Condition.GET(CaseID, ScriptID, ID);
        ConditionsDialog.SetCurrentRecord(Condition);
        ConditionsDialog.RunModal();
    end;

    procedure CheckCondition(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        ActionID: Guid): Boolean;
    var
        Condition: Record "Tax Test Condition";
        ConditionItem: Record "Tax Test Condition Item";
        ConditionOK: Boolean;
        LHSValue: Variant;
        RHSValue: Variant;
        LHSDatatype: Enum "Symbol Data Type";
        OptionString: Text;
        ConditionItemResult: Boolean;
        ConditionResult: Boolean;
    begin
        Condition.GET(CaseID, ScriptID, ActionID);
        ConditionOK := true;

        ConditionItem.SetRange("Case ID", CaseID);
        ConditionItem.SetRange("Script ID", ScriptID);
        ConditionItem.SetRange("Condition ID", ActionID);
        if not ConditionItem.FindSet() then
            exit(true);

        ConditionResult := true;

        repeat
            Clear(LHSValue);
            Clear(RHSValue);
            Clear(OptionString);

            SymbolStore.GetLookupValue(
                SourceRecRef,
                ConditionItem."Case ID",
                ConditionItem."Script ID",
                ConditionItem."LHS Lookup ID",
                LHSValue);

            LHSDatatype := LookupMgmt.GetLookupDatatype(
                ConditionItem."Case ID",
                ConditionItem."Script ID",
                ConditionItem."LHS Lookup ID");

            if LHSDatatype = "Symbol Data Type"::OPTION then
                OptionString := ScriptDataTypeMgmt.GetLookupOptionString(
                    ConditionItem."Case ID",
                    ConditionItem."Script ID",
                    ConditionItem."LHS Lookup ID");

            SymbolStore.GetConstantOrLookupValueOfType(
                SourceRecRef,
                ConditionItem."Case ID",
                ConditionItem."Script ID",
                ConditionItem."RHS Type",
                ConditionItem."RHS Value",
                ConditionItem."RHS Lookup ID",
                LHSDatatype,
                OptionString,
                RHSValue);

            ConditionItemResult := CompareVariants(LHSValue, RHSValue, ConditionItem."Conditional Operator");
            case ConditionItem."Logical Operator" of
                ConditionItem."Logical Operator"::" ":
                    ConditionResult := ConditionResult and ConditionItemResult;
                ConditionItem."Logical Operator"::"and":
                    ConditionResult := ConditionResult and ConditionItemResult;
                ConditionItem."Logical Operator"::"or":
                    ConditionResult := ConditionResult or ConditionItemResult;
            end;
        until ConditionItem.Next() = 0;

        exit(ConditionResult);
    end;

    procedure CalculateVariants(
            LHS: Variant;
            RHS: Variant;
            Operator: Enum "Arithmetic Operator";
            var OutputValue: Variant);
    var
        InvalidCalculationDatatypeErr: Label 'Invalid datatype for calculation.';
    begin
        if LHS.IsDecimal() then
            CalcDecimal(LHS, RHS, Operator, false, OutputValue)
        else
            if RHS.IsDecimal() then
                CalcDecimal(RHS, LHS, Operator, true, OutputValue)
            else
                if LHS.IsInteger() then
                    CalcInteger(LHS, RHS, Operator, OutputValue)
                else
                    Error(InvalidCalculationDatatypeErr);
    end;

    local procedure CompareVariants(
        LHS: Variant;
        RHS: Variant;
        Operator: Enum "Conditional Operator"): Boolean;
    begin
        if LHS.IsDecimal() or RHS.IsDecimal() then
            exit(CompareDecimals(LHS, RHS, Operator));
        if LHS.IsInteger() or RHS.IsInteger() then
            exit(CompareIntegers(LHS, RHS, Operator));

        if (LHS.IsOption() and (RHS.IsOption() or RHS.IsInteger())) or
          (RHS.IsOption() and (LHS.IsOption() or LHS.IsInteger()))
        then
            exit(CompareOptions(LHS, RHS, Operator));

        if LHS.IsDateTime() and RHS.IsDateTime() then
            exit(CompareDateTimes(LHS, RHS, Operator));
        if LHS.IsDate() and RHS.IsDate() then
            exit(CompareDates(LHS, RHS, Operator));
        if LHS.IsTime() and RHS.IsTime() then
            exit(CompareTimes(LHS, RHS, Operator));
        if LHS.IsBoolean() or RHS.IsBoolean() then
            exit(CompareBooleans(LHS, RHS, Operator));

        exit(CompareTexts(LHS, RHS, Operator));
    end;

    local procedure CompareDecimals(
        LHS: Decimal;
        RHS: Decimal;
        Operator: Enum "Conditional Operator"): Boolean;
    begin
        case Operator of
            Operator::equals:
                exit(LHS = RHS);
            Operator::"not equals":
                exit(LHS <> RHS);
            Operator::"is empty":
                exit(LHS = 0);
            Operator::"is not empty":
                exit(LHS <> 0);
            Operator::"begins with",
          Operator::"does not begin with",
          Operator::"ends with",
          Operator::"does not end with",
          Operator::contains,
          Operator::"does not contain",
          Operator::"equals ignore case",
          Operator::"contains ignore case":
                exit(false);
            Operator::"is greater than":
                exit(LHS > RHS);
            Operator::"is greater than or equals to":
                exit(LHS >= RHS);
            Operator::"is less than":
                exit(LHS < RHS);
            Operator::"is less than or equals to":
                exit(LHS <= RHS);
        end;
    end;

    local procedure CompareIntegers(
        LHS: Integer;
        RHS: Integer;
        Operator: Enum "Conditional Operator"): Boolean;
    begin
        case Operator of
            Operator::equals:
                exit(LHS = RHS);
            Operator::"not equals":
                exit(LHS <> RHS);
            Operator::"is empty":
                exit(LHS = 0);
            Operator::"is not empty":
                exit(LHS <> 0);
            Operator::"begins with",
          Operator::"does not begin with",
          Operator::"ends with",
          Operator::"does not end with",
          Operator::contains,
          Operator::"does not contain",
          Operator::"equals ignore case",
          Operator::"contains ignore case":
                exit(false);
            Operator::"is greater than":
                exit(LHS > RHS);
            Operator::"is greater than or equals to":
                exit(LHS >= RHS);
            Operator::"is less than":
                exit(LHS < RHS);
            Operator::"is less than or equals to":
                exit(LHS <= RHS);
        end;
    end;

    local procedure CompareBooleans(
        LHS: Boolean;
        RHS: Boolean;
        Operator: Enum "Conditional Operator"): Boolean;
    begin
        case Operator of
            Operator::equals:
                exit(LHS = RHS);
            Operator::"not equals":
                exit(LHS <> RHS);
            Operator::"begins with",
          Operator::"does not begin with",
          Operator::"ends with",
          Operator::"does not end with",
          Operator::contains,
          Operator::"does not contain",
          Operator::"equals ignore case",
          Operator::"contains ignore case",
          Operator::"is empty",
          Operator::"is not empty",
          Operator::"is greater than",
          Operator::"is greater than or equals to",
          Operator::"is less than",
          Operator::"is less than or equals to":
                exit(false);
        end;
    end;

    local procedure CompareOptions(
        LHS: Option;
        RHS: Option;
        Operator: Enum "Conditional Operator"): Boolean;
    begin
        case Operator of
            Operator::equals:
                exit(LHS = RHS);
            Operator::"not equals":
                exit(LHS <> RHS);
            Operator::"is empty":
                exit(LHS = 0);
            Operator::"is not empty":
                exit(LHS <> 0);
            Operator::"begins with",
          Operator::"does not begin with",
          Operator::"ends with",
          Operator::"does not end with",
          Operator::contains,
          Operator::"does not contain",
          Operator::"equals ignore case",
          Operator::"contains ignore case":
                exit(false);
            Operator::"is greater than":
                exit(LHS > RHS);
            Operator::"is greater than or equals to":
                exit(LHS >= RHS);
            Operator::"is less than":
                exit(LHS < RHS);
            Operator::"is less than or equals to":
                exit(LHS <= RHS);
        end;
    end;

    local procedure CompareDateTimes(
        LHS: DateTime;
        RHS: DateTime;
        Operator: Enum "Conditional Operator"): Boolean;
    begin
        case Operator of
            Operator::equals:
                exit(LHS = RHS);
            Operator::"not equals":
                exit(LHS <> RHS);
            Operator::"is empty":
                exit(LHS = 0DT);
            Operator::"is not empty":
                exit(LHS <> 0DT);
            Operator::"begins with",
          Operator::"does not begin with",
          Operator::"ends with",
          Operator::"does not end with",
          Operator::contains,
          Operator::"does not contain",
          Operator::"equals ignore case",
          Operator::"contains ignore case":
                exit(false);
            Operator::"is greater than":
                exit(LHS > RHS);
            Operator::"is greater than or equals to":
                exit(LHS >= RHS);
            Operator::"is less than":
                exit(LHS < RHS);
            Operator::"is less than or equals to":
                exit(LHS <= RHS);
        end;
    end;

    local procedure CompareDates(LHS: Date; RHS: Date; Operator: Enum "Conditional Operator"): Boolean;
    begin
        case Operator of
            Operator::equals:
                exit(LHS = RHS);
            Operator::"not equals":
                exit(LHS <> RHS);
            Operator::"is empty":
                exit(LHS = 0D);
            Operator::"is not empty":
                exit(LHS <> 0D);
            Operator::"begins with",
          Operator::"does not begin with",
          Operator::"ends with",
          Operator::"does not end with",
          Operator::contains,
          Operator::"does not contain",
          Operator::"equals ignore case",
          Operator::"contains ignore case":
                exit(false);
            Operator::"is greater than":
                exit(LHS > RHS);
            Operator::"is greater than or equals to":
                exit(LHS >= RHS);
            Operator::"is less than":
                exit(LHS < RHS);
            Operator::"is less than or equals to":
                exit(LHS <= RHS);
        end;
    end;

    local procedure CompareTimes(LHS: Time; RHS: Time; Operator: Enum "Conditional Operator"): Boolean;
    begin
        case Operator of
            Operator::equals:
                exit(LHS = RHS);
            Operator::"not equals":
                exit(LHS <> RHS);
            Operator::"is empty":
                exit(LHS = 0T);
            Operator::"is not empty":
                exit(LHS <> 0T);
            Operator::"begins with",
          Operator::"does not begin with",
          Operator::"ends with",
          Operator::"does not end with",
          Operator::contains,
          Operator::"does not contain",
          Operator::"equals ignore case",
          Operator::"contains ignore case":
                exit(false);
            Operator::"is greater than":
                exit(LHS > RHS);
            Operator::"is greater than or equals to":
                exit(LHS >= RHS);
            Operator::"is less than":
                exit(LHS < RHS);
            Operator::"is less than or equals to":
                exit(LHS <= RHS);
        end;
    end;

    local procedure CompareTexts(LHS: Text; RHS: Text; Operator: Enum "Conditional Operator"): Boolean;
    var
        Position: Integer;
    begin
        case Operator of
            Operator::equals:
                exit(LHS = RHS);
            Operator::"not equals":
                exit(LHS <> RHS);
            Operator::"is empty":
                exit(StrLen(LHS) = 0);
            Operator::"is not empty":
                exit(StrLen(LHS) <> 0);
            Operator::"begins with":
                exit(StrPos(LHS, RHS) = 1);
            Operator::"does not begin with":
                exit(StrPos(LHS, RHS) <> 1);
            Operator::"ends with":
                begin
                    Position := StrLen(LHS) - StrLen(RHS) + 1;
                    if Position < 1 then
                        exit(false);

                    exit(CopyStr(LHS, Position) = RHS)
                end;
            Operator::"does not end with":
                begin
                    Position := StrLen(LHS) - StrLen(RHS) + 1;
                    if Position < 1 then
                        exit(true);

                    exit(CopyStr(LHS, Position) <> RHS)
                end;
            Operator::contains:
                exit(StrPos(LHS, RHS) > 0);
            Operator::"does not contain":
                exit(StrPos(LHS, RHS) = 0);
            Operator::"equals ignore case":
                exit(UpperCase(LHS) = UpperCase(RHS));
            Operator::"contains ignore case":
                exit(StrPos(UpperCase(LHS), UpperCase(RHS)) > 0);
            Operator::"is greater than":
                exit(LHS > RHS);
            Operator::"is greater than or equals to":
                exit(LHS >= RHS);
            Operator::"is less than":
                exit(LHS < RHS);
            Operator::"is less than or equals to":
                exit(LHS <= RHS);
        end;
    end;

    local procedure CalcDecimal(
        Value1: Decimal;
        Value2: Variant;
        Operator: Enum "Arithmetic Operator";
        Swap: Boolean;
        var OutputValue: Variant);
    var
        Value2BigInteger: BigInteger;
        Value2Decimal: Decimal;
        Value2Integer: Integer;
    begin
        if Value2.IsBigInteger() then begin
            Value2BigInteger := Value2;

            case Operator of
                Operator::"divided by":
                    if Swap then
                        OutputValue := Value2BigInteger / Value1
                    else
                        OutputValue := Value1 / Value2BigInteger;
                Operator::minus:
                    if Swap then
                        OutputValue := Value2BigInteger - Value1
                    else
                        OutputValue := Value1 - Value2BigInteger;
                Operator::"mod":
                    if Swap then
                        OutputValue := Value2BigInteger MOD Value1
                    else
                        OutputValue := Value1 MOD Value2BigInteger;
                Operator::"multiply by":
                    OutputValue := Value1 * Value2BigInteger;
                Operator::plus:
                    OutputValue := Value1 + Value2BigInteger;
            end;
        end else
            if Value2.IsDecimal() then begin
                Value2Decimal := Value2;

                case Operator of
                    Operator::"divided by":
                        if Swap then
                            OutputValue := Value2Decimal / Value1
                        else
                            OutputValue := Value1 / Value2Decimal;
                    Operator::minus:
                        if Swap then
                            OutputValue := Value2Decimal - Value1
                        else
                            OutputValue := Value1 - Value2Decimal;
                    Operator::"mod":
                        if Swap then
                            OutputValue := Value2Decimal MOD Value1
                        else
                            OutputValue := Value1 MOD Value2Decimal;
                    Operator::"multiply by":
                        OutputValue := Value1 * Value2Decimal;
                    Operator::plus:
                        OutputValue := Value1 + Value2Decimal;
                end;
            end else
                if Value2.IsInteger() then begin
                    Value2Integer := Value2;

                    case Operator of
                        Operator::"divided by":
                            if Swap then
                                OutputValue := Value2Integer / Value1
                            else
                                OutputValue := Value1 / Value2Integer;
                        Operator::minus:
                            if Swap then
                                OutputValue := Value2Integer - Value1
                            else
                                OutputValue := Value1 - Value2Integer;
                        Operator::"mod":
                            if Swap then
                                OutputValue := Value2Integer MOD Value1
                            else
                                OutputValue := Value1 MOD Value2Integer;
                        Operator::"multiply by":
                            OutputValue := Value1 * Value2Integer;
                        Operator::plus:
                            OutputValue := Value1 + Value2Integer;
                    end;
                end;
    end;

    local procedure CalcInteger(
        Value1: Integer;
        Value2: Integer;
        Operator: Enum "Arithmetic Operator";
        var OutputValue: Variant): BigInteger;
    begin
        case Operator of
            Operator::"divided by":
                OutputValue := Value1 / Value2;
            Operator::minus:
                OutputValue := Value1 - Value2;
            Operator::"mod":
                OutputValue := Value1 MOD Value2;
            Operator::"multiply by":
                OutputValue := Value1 * Value2;
            Operator::plus:
                OutputValue := Value1 + Value2;
        end;
    end;

    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        LookupMgmt: Codeunit "Lookup Mgmt.";
}