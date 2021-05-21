codeunit 20132 "Script Data Type Mgmt."
{
    procedure GetFieldDatatype(TableID: Integer; FieldID: Integer): Enum "Symbol Data Type";
    var
        Field: Record Field;
    begin
        Field.GET(TableID, FieldID);
        exit(GetFieldDatatypeInternal(Field.Type, true));
    end;

    procedure GetLookupOptionString(CaseID: Guid; ScriptID: Guid; ID: Guid): Text;
    var
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        IsTableField: Boolean;
    begin
        ScriptSymbolLookup.GET(CaseID, ScriptID, ID);
        case ScriptSymbolLookup."Source Type" of
            ScriptSymbolLookup."Source Type"::"Current Record":
                IsTableField := true;
            ScriptSymbolLookup."Source Type"::Table:
                case ScriptSymbolLookup."Table Method" of
                    ScriptSymbolLookup."Table Method"::First,
                  ScriptSymbolLookup."Table Method"::Last:
                        IsTableField := true;
                end;
        end;

        if (not IsTableField) or (ScriptSymbolLookup."Source Field ID" = 0) then
            exit('');

        if GetFieldDatatype(ScriptSymbolLookup."Source ID", ScriptSymbolLookup."Source Field ID") = "Symbol Data Type"::Option then
            exit(GetFieldOptionString(ScriptSymbolLookup."Source ID", ScriptSymbolLookup."Source Field ID"));
    end;

    procedure EvaluateDate(var Date: Date; DateText: Text; DateFormat: Text): Boolean;
    var
        Variant: Variant;
    begin
        Variant := 0D;
        if TypeHelper.Evaluate(Variant, DateText, DateFormat, '') then begin
            Date := Variant;
            exit(true);
        end;
    end;

    procedure EvaluateDateTime(var DateTime: DateTime; DateText: Text; DateFormat: Text): Boolean;
    var
        Variant: Variant;
    begin
        Variant := 0DT;
        if TypeHelper.Evaluate(Variant, DateText, DateFormat, '') then begin
            DateTime := Variant;
            exit(true);
        end;
    end;

    procedure IsNumber(Text: Text): Boolean;
    begin
        exit(TypeHelper.IsNumeric(Text));
    end;

    procedure IsBoolean(Text: Text): Boolean;
    var
        BoolValue: Boolean;
    begin
        if Evaluate(BoolValue, Text) then
            exit(true);
        if UPPERCASE(Text) in ['YES', 'TRUE', 'NO', 'FALSE', '0', '1'] then
            exit(true);
    end;

    procedure IsRecID(Text: Text): Boolean;
    var
        RecID: RecordId;
    begin
        if Evaluate(RecID, Text) then
            exit(true);
    end;

    procedure IsDate(Text: Text): Boolean;
    var
        DateValue: Date;
    begin
        if Evaluate(DateValue, Text) then
            exit(true);
    end;

    procedure IsTime(Text: Text): Boolean;
    var
        TimeValue: Time;
    begin
        if Evaluate(TimeValue, Text) then
            exit(true);
    end;

    procedure IsDateTime(Text: Text): Boolean;
    var
        DateTimeValue: DateTime;
    begin
        if EvaluateDateTime(DateTimeValue, Text, '') then
            exit(true);
    end;

    procedure IsGUID(Text: Text): Boolean;
    var
        GUIDValue: Guid;
    begin
        if Evaluate(GUIDValue, Text) then
            exit(true);
    end;

    procedure IsOption(Text: Text; OptionString: Text): Boolean;
    var
        TmpOptionIndex: Integer;
    begin
        if TypeHelper.IsNumeric(Text) then begin
            Evaluate(TmpOptionIndex, Text);
            if GetOptionText(OptionString, TmpOptionIndex) = '' then
                Exit;
        end else
            if TypeHelper.GetOptionNo(Text, OptionString) = -1 then
                exit;
        exit(true);
    end;

    procedure IsBlob(var Value: Variant): Boolean;
    var
        FldRef: FieldRef;
        Type: Text;
    begin
        if not Value.IsFieldRef then
            exit(false);

        FldRef := Value;
        Type := Format(FldRef.Type());

        if Type = 'BLOB' then
            exit(true);
    end;

    /// Type Convertion

    procedure ConvertText2Type(
        Text: Text;
        ToDatatype: Enum "Symbol Data Type";
        OptionString: Text;
        var ConvertedValue: Variant);
    begin
        case ToDatatype of
            "Symbol Data Type"::Number:
                ConvertedValue := Text2Number(Text);
            "Symbol Data Type"::Option:
                ConvertedValue := TypeHelper.GetOptionNo(Text, OptionString);
            "Symbol Data Type"::Boolean:
                ConvertedValue := Text2Boolean(Text);
            "Symbol Data Type"::Date:
                ConvertedValue := Text2Date(Text);
            "Symbol Data Type"::String:
                ConvertedValue := Text;
            else
                Error(InvalidConvertedTextErr, Text, ToDatatype);
        end;
    end;

    procedure Text2Number(Text: Text): Decimal;
    var
        Variant: Variant;
        NumberValue: Decimal;
    begin
        NumberValue := 0;
        Variant := NumberValue;
        TypeHelper.Evaluate(Variant, Text, '', '');
        exit(Variant);
    end;

    procedure Text2Boolean(Text: Text): Boolean;
    begin
        if UPPERCASE(Text) in ['YES', 'TRUE', '1'] then
            exit(true);
        if UPPERCASE(Text) in ['NO', 'FALSE', '0'] then
            exit(false);
    end;

    procedure Text2Date(Text: Text): Date;
    var
        DateValue: Date;
    begin
        if (Text = '') or (Text = '0D') then
            exit(0D);

        if EvaluateDate(DateValue, Text, '') then
            exit(DateValue);
    end;

    procedure Text2Time(Text: Text): Time;
    var
        TimeValue: Time;
    begin
        Evaluate(TimeValue, Text);
        exit(TimeValue);
    end;

    procedure Text2DateTime(Text: Text): DateTime;
    var
        DateTimeValue: DateTime;
    begin
        if EvaluateDateTime(DateTimeValue, Text, '') then
            exit(DateTimeValue);
    end;

    procedure Text2GUID(Text: Text): Guid;
    var
        GUIDValue: Guid;
    begin
        Evaluate(GUIDValue, Text);
        exit(GUIDValue);
    end;

    procedure Text2RecordID(Text: Text; var RecordID: RecordID);
    var
        RecordIDValue: RecordID;
    begin
        Evaluate(RecordIDValue, Text);
        RecordID := RecordIDValue;
    end;

    procedure Text2BLOB(Text: Text; var FieldRef: FieldRef);
    var
        TempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
        OStream: OutStream;
    begin
        RecRef := FieldRef.Record();
        TempBlob.CREATEOUTSTREAM(OStream, TEXTENCODING::UTF8);
        OStream.WRITETEXT(Text);
        TempBlob.ToRecordRef(RecRef, FieldRef.Number());
        FieldRef.VALUE := RecRef.Field(FieldRef.Number()).Value();
    end;

    /// Variant
    procedure Variant2Text(Value: Variant; FormatExpr: Text): Text;
    var
        TempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        IStream: InStream;
        TextBuffer: Text;
        Content: Text[250];
    begin
        if Value.IsText() or Value.IsCode() then
            exit(Value);

        if Value.IsFieldRef() then begin
            FieldRef := Value;
            RecRef := FieldRef.Record();
            if Format(FieldRef.Type()) = 'BLOB' then begin
                TempBlob.FromRecordRef(RecRef, FieldRef.Number());
                if not TempBlob.HasValue() then begin
                    FieldRef.CalcField();
                    TempBlob.FromRecordRef(RecRef, FieldRef.Number());
                end;
                TempBlob.CreateInStream(IStream, TEXTENCODING::UTF8);
                while IStream.READTEXT(TextBuffer) <> 0 do
                    Content += TextBuffer;
                exit(Content);
            end else
                exit(Format(FieldRef.Value()));
        end;

        if FormatExpr <> '' then
            exit(Format(Value, 0, FormatExpr))
        else
            exit(Format(Value));
    end;

    procedure Variant2Option(Value: Variant; OptionString: Text; var OptionValue: Option);
    var
        InvalidOptionValueErr: Label '%1 cannot be converted to option.', Comment = '%1 option value';
    begin
        if Value.IsOption() or Value.IsInteger() or Value.IsBigInteger() or Value.IsDecimal() then
            OptionValue := Value
        else
            if Value.IsText() or Value.IsCode() then
                OptionValue := TypeHelper.GetOptionNo(Value, OptionString)
            else
                Error(InvalidOptionValueErr, Value);
    end;

    procedure Variant2Number(Value: Variant): Decimal;
    var
        InvalidDecimalValueErr: Label '%1 cannot be converted to decimal.', Comment = '%1 decimal value';
    begin
        if Value.IsDecimal() or Value.IsInteger() or Value.IsBigInteger() or Value.IsOption() then
            exit(Value)
        else
            if Value.IsText() or Value.IsCode() then
                exit(Text2Number(Value))
            else
                Error(InvalidDecimalValueErr, Value);
    end;

    procedure Variant2Boolean(Value: Variant): Boolean;
    var
        InvalidBooleanValueErr: Label '%1 cannot be converted to boolean.', Comment = '%1 boolean value';
    begin
        if Value.IsBoolean() then
            exit(Value)
        else
            if Value.IsText() or Value.IsCode() then
                exit(Text2Boolean(Value))
            else
                Error(InvalidBooleanValueErr, Value);
    end;

    procedure Variant2Date(Value: Variant): Date;
    var
        InvalidDateValueErr: Label '%1 cannot be converted to date.', Comment = '%1 date value';
    begin
        if Value.IsDate() then
            exit(Value)
        else
            if Value.IsText() or Value.IsCode() then
                exit(Text2Date(Value))
            else
                Error(InvalidDateValueErr, Value);
    end;

    procedure Variant2Time(Value: Variant): Time;
    var
        InvalidTimeValueErr: Label '%1 cannot be converted to time.', Comment = '%1 time value';
    begin
        if Value.IsTime() then
            exit(Value)
        else
            if Value.IsText() or Value.IsCode() then
                exit(Text2Time(Value))
            else
                Error(InvalidTimeValueErr, Value);
    end;

    procedure Variant2DateTime(Value: Variant): DateTime;
    var
        InvalidDateTimeErr: Label '%1 cannot be converted to datetime.', Comment = '%1 = datetime value';
    begin
        if Value.IsDateTime() then
            exit(Value)
        else
            if Value.IsText() or Value.IsCode() then
                exit(Text2DateTime(Value))
            else
                Error(InvalidDateTimeErr, Value);
    end;

    procedure Variant2GUID(Value: Variant): Guid;
    var
        InvalidGuidErr: Label '%1 cannot be converted to Guid.', Comment = '%1 = Guid value';
    begin
        if Value.IsGuid() then
            exit(Value)
        else
            if Value.IsText() or Value.IsCode() then
                exit(Text2GUID(Value))
            else
                Error(InvalidGuidErr, Value);
    end;

    procedure Variant2RecordID(Value: Variant; var RecordID: RecordID);
    var
        InvalidRecIdErr: Label '%1 cannot be converted to RecordID.', Comment = '%1 = RecordID value';
    begin
        if Value.IsRecordId() then
            RecordID := Value
        else
            if Value.IsText() or Value.IsCode() then
                Text2RecordID(Value, RecordID)
            else
                Error(InvalidRecIdErr, Value);
    end;

    /// Expressions
    procedure EvaluateExpression(
        Expression: Text;
        Values: Dictionary of [Text, Decimal]): Decimal;
    var
        Operators: Text;
        Result: Decimal;
        Parantheses: Integer;
        IsExpression: Boolean;
        OperatorNo: Integer;
        i: Integer;
        RightResult: Decimal;
        LeftResult: Decimal;
        RightOperand: Text;
        LeftOperand: Text;
        Operator: Char;
        ExprLength: Integer;
    begin
        Expression := Trim(Expression);
        ExprLength := StrLen(Expression);

        if ExprLength = 0 then
            exit(0);

        Operators := '+-*/^';
        OperatorNo := 1;

        repeat
            i := ExprLength;
            repeat
                if Expression[i] = '(' then
                    Parantheses := Parantheses + 1
                else
                    if Expression[i] = ')' then
                        Parantheses := Parantheses - 1;

                if (Parantheses = 0) and (Expression[i] = Operators[OperatorNo]) then
                    IsExpression := true
                else
                    i := i - 1;
            until IsExpression or (i <= 0);
            if not IsExpression then
                OperatorNo := OperatorNo + 1;
        until (OperatorNo > StrLen(Operators)) or IsExpression;

        if IsExpression then begin
            if i > 1 then LeftOperand := COPYSTR(Expression, 1, i - 1);
            if i < ExprLength then RightOperand := COPYSTR(Expression, i + 1);

            Operator := Expression[i];
            LeftResult := EvaluateExpression(LeftOperand, Values);
            RightResult := EvaluateExpression(RightOperand, Values);

            case Operator of
                '^':
                    Result := POWER(LeftResult, RightResult);
                '*':
                    Result := LeftResult * RightResult;
                '/':
                    if RightResult = 0 then
                        Result := 0
                    else
                        Result := LeftResult / RightResult;
                '+':
                    Result := LeftResult + RightResult;
                '-':
                    Result := LeftResult - RightResult;
            end;
        end else
            if (Expression[1] = '(') and (Expression[ExprLength] = ')') then
                Result := EvaluateExpression(COPYSTR(Expression, 2, ExprLength - 2), Values)
            else
                if Values.ContainsKey(Expression) then
                    Result := Values.Get(Expression)
                else
                    Evaluate(Result, Expression);
        exit(Result);
    end;

    procedure EvaluateStringExpression(Expression: Text; var Values: Dictionary of [Text, Text]): Text;
    var
        Result: Text;
        Len: Integer;
        x: Integer;
        Chr: Char;
        OpenCurlyBraces: Integer;
        Token: Text;
        TokenIndex: Integer;
    begin
        Len := StrLen(Expression);
        for x := 1 to Len do begin
            Chr := Expression[x];
            if Chr in ['{', '}'] then begin
                if Chr = '{' then OpenCurlyBraces += 1;
                if Chr = '}' then OpenCurlyBraces -= 1;
                if (Chr = '}') and (OpenCurlyBraces = 0) then
                    Result += Values.Get(Token);

                Token := '';
                TokenIndex := 0;
            end else
                if OpenCurlyBraces = 0 then
                    Result += Format(Chr, 0, 2)
                else begin
                    TokenIndex += 1;
                    Token[TokenIndex] := Chr;
                end;
        end;

        exit(Result);
    end;

    procedure GetTokensFromStringExpression(Expression: Text; var TextTokens: List of [Text]);
    var
        x: Integer;
        Len: Integer;
        Chr: Char;
        Token: Text;
        TokenIndex: Integer;
        OpenCurlyBraces: Integer;
    begin
        Len := StrLen(Expression);
        for x := 1 to Len do begin
            Chr := Expression[x];
            if Chr in ['{', '}'] then begin
                if Chr = '{' then OpenCurlyBraces += 1;
                if Chr = '}' then OpenCurlyBraces -= 1;
                if (Chr = '}') and (OpenCurlyBraces = 0) then
                    if not TextTokens.Contains(Token) then
                        TextTokens.Add(Token);

                Token := '';
                TokenIndex := 0;
            end else begin
                TokenIndex += 1;
                Token[TokenIndex] := Chr;
            end;
        end;
    end;

    procedure GetTokensFromNumberExpression(Expression: Text; var TextTokens: List of [Text]);
    var
        x: Integer;
        Len: Integer;
        Chr: Char;
        Token: Text;
        TokenIndex: Integer;
    begin
        Len := StrLen(Expression);
        for x := 1 to Len do begin
            Chr := Expression[x];
            if Chr in ['(', ')', '+', '-', '/', '*', '^'] then begin
                Token := Trim(Token);
                if (not TypeHelper.IsNumeric(Token)) and (StrLen(Token) > 0) then
                    if not TextTokens.Contains(Token) then
                        TextTokens.Add(Token);

                Token := '';
                TokenIndex := 0;
            end else begin
                TokenIndex += 1;
                Token[TokenIndex] := Chr;
            end;
        end;

        Token := Trim(Token);
        if (not TypeHelper.IsNumeric(Token)) and (StrLen(Token) > 0) then
            if not TextTokens.Contains(Token) then
                TextTokens.Add(Token);
    end;

    procedure GetOptionText(OptionString: Text; Index: Integer): Text[30];
    var
        Length: Integer;
        i: Integer;
        OptionIndex: Integer;
        OptionText: Text[30];
    begin
        OptionIndex := 0;
        Length := StrLen(OptionString);

        for i := 1 to Length do
            if OptionString[i] = ',' then begin
                if Index = OptionIndex then
                    exit(OptionText);

                OptionIndex += 1;
                OptionText := '';
            end else
                OptionText += Format(OptionString[i], 0, 2);

        if Index = OptionIndex then
            exit(OptionText);

        exit(Format(Index, 0, 2));
    end;

    procedure GetOptionTextList(OptionString: Text; var OptionList: List of [Text])
    var
        Length: Integer;
        i: Integer;
        OptionText: Text[30];
    begin
        Length := StrLen(OptionString);
        for i := 1 to Length do
            if OptionString[i] = ',' then begin
                OptionList.Add(OptionText);
                OptionText := '';
            end else
                OptionText += Format(OptionString[i], 0, 2);

        OptionList.Add((OptionText));
    end;

    procedure GetFieldOptionString(TableNo: Integer; FieldNo: Integer): Text;
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        OptionString: Text;
    begin
        if (TableNo = 0) or (FieldNo = 0) then
            Exit;
        RecRef.OPEN(TableNo);
        if RecRef.FIELDEXIST(FieldNo) then begin
            FldRef := RecRef.Field(FieldNo);
            OptionString := FldRef.OptionMembers();
        end;
        RecRef.Close();
        exit(OptionString);
    end;

    procedure GetFieldOptionText(TableID: Integer; FieldID: Integer; Index: Integer): Text;
    begin
        exit(GetOptionText(GetFieldOptionString(TableID, FieldID), Index));
    end;

    procedure GetFieldOptionIndex(TableID: Integer; FieldID: Integer; OptionText: Text): Integer;
    begin
        exit(TypeHelper.GetOptionNo(OptionText, GetFieldOptionString(TableID, FieldID)));
    end;

    procedure SetConstantValue(
        Datatype: Enum "Symbol Data Type";
        TextValue: Text;
        OptionString: Text;
        var Value: Variant);
    var
        InvalidDatatypeErr: Label 'Convertion of Text to %1 not supported.', Comment = '%1 = Datatype';
    begin
        case Datatype of
            "Symbol Data Type"::Number:
                Value := Text2Number(TextValue);
            "Symbol Data Type"::Option:
                if TypeHelper.IsNumeric(TextValue) then
                    Value := Text2Number(TextValue)
                else
                    Value := TypeHelper.GetOptionNo(TextValue, OptionString);

            "Symbol Data Type"::Boolean:
                Value := Text2Boolean(TextValue);
            "Symbol Data Type"::Date:
                Value := Text2Date(TextValue);
            "Symbol Data Type"::String:
                Value := TextValue;
            else
                Error(InvalidDatatypeErr, Datatype);
        end;
    end;

    procedure CheckConstantDatatype(ConstantValue: Text; ExpectedType: Enum "Symbol Data Type"; OptionString: Text);
    var
        YouCanNotEnterValueErr: Label 'You cannot enter %1 in %2.', Comment = '%1 - Value, %2 - DataType';
        YouCanNotEnterValueOptionErr: Label 'You cannot enter %1 in %2. Possible values are %3.', Comment = '%1 - Value, %2 - DataType, %3 - Options';
        InvalidDatatypErr: Label 'Datatype %1 not supported.', Comment = '%1 = Expected Data type';
    begin
        case ExpectedType of
            "Symbol Data Type"::String:
                Exit;
            "Symbol Data Type"::Number:
                if TypeHelper.IsNumeric(ConstantValue) then
                    Exit;
            "Symbol Data Type"::Boolean:
                if IsBoolean(ConstantValue) then
                    Exit;
            "Symbol Data Type"::Date:
                if IsDate(ConstantValue) then
                    Exit;
            "Symbol Data Type"::Option:
                begin
                    if IsOption(ConstantValue, OptionString) then
                        Exit;
                    Error(YouCanNotEnterValueOptionErr, ConstantValue, ExpectedType, OptionString);
                end;
            else
                Error(InvalidDatatypErr, ExpectedType);
        end;

        Error(YouCanNotEnterValueErr, ConstantValue, ExpectedType);
    end;

    procedure IsPrimitiveDatatype(Datatype: Enum "Symbol Data Type"): Boolean;
    begin
        case Datatype of
            "Symbol Data Type"::Boolean,
          "Symbol Data Type"::Date,
          "Symbol Data Type"::Number,
          "Symbol Data Type"::Option,
          "Symbol Data Type"::String:
                exit(true);
        end;

        exit(false);
    end;

    procedure ConvertLocalToXmlFormat(var Value: Text; Datatype: Enum "Symbol Data Type"): Text
    var
        RecID: RecordId;
        GuidValue: Guid;
        DateValue: Date;
        DateTimeValue: DateTime;
        TimeValue: Time;
        NumberValue: Decimal;
        BooleanValue: Boolean;
        XmlValue: Text;
    begin
        SetInitialValue(Value, Datatype);
        if Value = '' then
            exit(Value);

        case Datatype of
            Datatype::Date:
                begin
                    Evaluate(DateValue, Value);
                    XmlValue := Format(DateValue, 0, 9);
                end;
            Datatype::Number:
                begin
                    Evaluate(NumberValue, Value);
                    XmlValue := Format(NumberValue, 0, 9);
                end;
            Datatype::Boolean:
                begin
                    Evaluate(BooleanValue, Value);
                    XmlValue := Format(BooleanValue, 0, 9);
                end;
            Datatype::Datetime:
                begin
                    Evaluate(DateTimeValue, Value);
                    XmlValue := Format(DateTimeValue, 0, 9);
                end;
            Datatype::Time:
                begin
                    Evaluate(TimeValue, Value);
                    XmlValue := Format(TimeValue, 0, 9);
                end;
            Datatype::Guid:
                begin
                    Evaluate(GuidValue, Value);
                    XmlValue := Format(GuidValue, 0, 9);
                end;
            Datatype::Recid:
                begin
                    Evaluate(RecID, Value);
                    XmlValue := Format(RecID, 0, 9);
                end;
            else
                XmlValue := Value;
        end;
        Value := ConvertXmlToLocalFormat(XmlValue, Datatype);
        exit(XmlValue);
    end;

    procedure ConvertXmlToLocalFormat(Value: Text; Datatype: Enum "Symbol Data Type"): Text
    var
        RecIdValue: RecordId;
        GuidValue: Guid;
        BooleanValue: Boolean;
        DateValue: Date;
        DateTimeValue: DateTime;
        TimeValue: Time;
        NumberValue: Decimal;
    begin
        SetInitialValue(Value, Datatype);
        case Datatype of
            Datatype::Number:
                begin
                    if Evaluate(NumberValue, Value, 9) then;
                    exit(Format(NumberValue, 0, '<Precision,2:3><Standard Format,0>'));
                end;
            Datatype::Boolean:
                begin
                    if uppercase(Value) in ['0', 'NO', 'FALSE'] then
                        Value := 'false';
                    if uppercase(Value) in ['1', 'YES', 'TRUE'] then
                        Value := 'true';
                    Evaluate(BooleanValue, Value, 9);
                    exit(Format(BooleanValue, 0, 0));
                end;
        end;

        if Value = '' then
            exit(Value);

        case Datatype of
            datatype::Date:
                begin
                    Evaluate(DateValue, Value, 9);
                    exit(Format(DateValue, 0, 0));
                end;
            datatype::Datetime:
                begin
                    Evaluate(DateTimeValue, Value, 9);
                    exit(Format(DateTimeValue, 0, 0));
                end;
            datatype::Time:
                begin
                    Evaluate(TimeValue, Value, 9);
                    exit(Format(TimeValue, 0, 0));
                end;
            datatype::Recid:
                begin
                    Evaluate(RecIdValue, Value, 9);
                    exit(Format(RecIdValue, 0, 0));
                end;
            datatype::Guid:
                begin
                    Evaluate(GuidValue, Value, 9);
                    exit(Format(GuidValue, 0, 0));
                end;
            else
                exit(Value);
        end;
    end;

    procedure FormatAttributeValue(DataType: Option Option,Text,Integer,Decimal,Boolean,Date; var Value: Text[250])
    var
        SymbolDataType: Enum "Symbol Data Type";
        DecimalValue: Decimal;
        ValueText: Text;
        IntegerValue: Integer;
        BooleanValue: Boolean;
        DateValue: Date;
    begin
        case DataType of
            DataType::Decimal:
                begin
                    ValueText := Value;
                    SetInitialValue(ValueText, SymbolDataType::Number);
                    Evaluate(DecimalValue, ValueText);
                    Value := Format(DecimalValue, 0, '<Precision,2:3><Standard Format,0>');
                end;
            DataType::Integer:
                begin
                    ValueText := Value;
                    SetInitialValue(ValueText, SymbolDataType::Number);
                    Evaluate(IntegerValue, ValueText);
                    Value := Format(IntegerValue);
                end;
            DataType::Boolean:
                begin
                    ValueText := Value;
                    SetInitialValue(ValueText, SymbolDataType::Boolean);
                    Evaluate(BooleanValue, ValueText);
                    Value := Format(BooleanValue);
                end;
            DataType::Date:
                begin
                    ValueText := Value;
                    SetInitialValue(ValueText, SymbolDataType::Date);
                    Evaluate(DateValue, ValueText);
                    Value := Format(DateValue);
                end;
        end;
    end;

    local procedure SetInitialValue(var Value: Text; Datatype: Enum "Symbol Data Type")
    begin
        if StrLen(Value) > 0 then
            exit;

        case Datatype of
            Datatype::Number:
                Value := Format(0);
            Datatype::Boolean:
                Value := Format(false);
            Datatype::Option:
                Value := Format(0);
        end;
    end;

    /// String Functions
    local procedure Trim(Text: Text): Text;
    var
        String: Codeunit DotNet_String;
    begin
        String.Set(Text);
        exit(String.Trim());
    end;

    local procedure GetFieldDatatypeInternal(FieldDataType: Option; ThrowError: Boolean): Enum "Symbol Data Type";
    var
        Field: Record Field;
        InvalidDatatypeErr: Label 'Unsupported datatype: %1', Comment = '%1 = Field datatype';
    begin
        case FieldDataType of
            Field.Type::Text,
            Field.Type::Code:
                exit("Symbol Data Type"::String);
            Field.Type::Boolean:
                exit("Symbol Data Type"::Boolean);
            Field.Type::Integer,
            Field.Type::Decimal:
                exit("Symbol Data Type"::Number);
            Field.Type::Date:
                exit("Symbol Data Type"::Date);
            Field.Type::Time:
                exit("Symbol Data Type"::Time);
            Field.Type::DateTime:
                exit("Symbol Data Type"::Datetime);
            Field.Type::Option:
                exit("Symbol Data Type"::Option);
            Field.Type::GUID:
                exit("Symbol Data Type"::Guid);
            Field.Type::RecordID:
                exit("Symbol Data Type"::Recid);
            else
                if ThrowError then
                    Error(InvalidDatatypeErr, Field.Type)
        end;
    end;

    var
        TypeHelper: Codeunit "Type Helper";
        InvalidConvertedTextErr: Label 'Convert text ''%1'' to ''%2'' not supported', Comment = '%1 = Text value, %2= Datatype';
}