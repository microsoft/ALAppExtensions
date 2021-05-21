codeunit 20131 "RecRef Handler"
{
    procedure SetFieldFilter(
        var RecRef: RecordRef;
        FieldID: Integer;
        FilterType: Enum "Conditional Operator";
        Value: Variant);
    var
        FldRef: FieldRef;
        NewValue: Variant;
        IsRange: Boolean;
    begin
        FldRef := RecRef.Field(FieldID);
        GetConstantFilter(RecRef, FldRef, Value, IsRange, NewValue);
        if IsRange then begin
            FldRef.SetFilter(Value);
            exit;
        end;

        case FilterType of
            FilterType::"CAL Filter":
                FldRef.SetFilter(Value);
            FilterType::Equals:
                FldRef.SetRange(NewValue);
            FilterType::"Not Equals":
                FldRef.SetFilter('<>%1', NewValue);
            FilterType::"Is Less Than":
                FldRef.SetFilter('<%1', NewValue);
            FilterType::"Is Less Than Or Equals To":
                FldRef.SetFilter('<=%1', NewValue);
            FilterType::"Is Greater Than":
                FldRef.SetFilter('>%1', NewValue);
            FilterType::"Is Greater Than Or Equals To":
                FldRef.SetFilter('>=%1', NewValue);
            FilterType::"Begins With":
                FldRef.SetFilter('%1*', NewValue);
            FilterType::"Ends With":
                FldRef.SetFilter('*%1', NewValue);
            FilterType::Contains:
                FldRef.SetFilter('*%1*', NewValue);
            FilterType::"Does Not Contain":
                FldRef.SetFilter('<>*%1*', NewValue);
            FilterType::"Does Not End With":
                FldRef.SetFilter('<>*%1', NewValue);
            FilterType::"Contains Ignore Case":
                FldRef.SetFilter('@*%1', NewValue);
            FilterType::"Equals Ignore Case":
                FldRef.SetFilter('@%1', NewValue);
        end;
    end;

    procedure SetFieldLinkFilter(var RecRef: RecordRef; FieldID: Integer; FilterType: Option "CONST","FILTER"; Value: Variant);
    var
        FldRef: FieldRef;
        NewValue: Variant;
        IsRange: Boolean;
    begin
        FldRef := RecRef.Field(FieldID);
        case FilterType of
            FilterType::CONST:
                begin
                    GetConstantFilter(RecRef, FldRef, Value, IsRange, NewValue);
                    if IsRange then
                        FldRef.SetFilter(Value)
                    else
                        FldRef.SetRange(NewValue);
                end;
            FilterType::FILTER:
                FldRef.SetFilter(Value);
        end;
    end;

    procedure GetFieldValue(var RecRef: RecordRef; FieldID: Integer; var Value: Variant);
    var
        FldRef: FieldRef;
        InvalidFieldClassErr: Label 'Invalid Field Class: %1', Comment = '%1 = Field Class';
    begin
        FldRef := RecRef.Field(FieldID);
        case Format(FldRef.Class()) of
            'FlowField':
                FldRef.CalcField();
            'FlowFilter', 'Normal':
                ;
            else
                Error(InvalidFieldClassErr, Format(FldRef.Class()));
        end;

        case Format(FldRef.Type()) of
            'BLOB':
                Value := FldRef;
            else
                Value := FldRef.Value();
        end;
    end;

    procedure SetFieldValue(var RecRef: RecordRef; FieldID: Integer; Value: Variant);
    var
        FldRef: FieldRef;
        TempValue: Variant;
        TypeNotSupportedLbl: Label '%1 not supported.', Comment = '%1 =Field Data type';
    begin
        FldRef := RecRef.Field(FieldID);
        case Format(FldRef.Type()) of
            'Integer',
            'Decimal',
            'BigInteger':
                FldRef.VALUE := DataTypeMgmt.Variant2Number(Value);
            'Option':
                begin
                    TempValue := FldRef.Value();
                    DataTypeMgmt.Variant2Option(Value, FldRef.OptionMembers(), TempValue);
                    FldRef.VALUE := TempValue;
                end;
            'Boolean':
                FldRef.VALUE := DataTypeMgmt.Variant2Boolean(Value);
            'Date':
                FldRef.VALUE := DataTypeMgmt.Variant2Date(Value);
            'Time':
                FldRef.VALUE := DataTypeMgmt.Variant2Time(Value);
            'DateFormula':
                begin
                    TempValue := FldRef.Value();
                    Variant2DateFormula(Value, TempValue);
                    FldRef.VALUE := TempValue;
                end;
            'GUID':
                FldRef.VALUE := DataTypeMgmt.Variant2GUID(Value);
            'RecordID':
                begin
                    TempValue := FldRef.Value();
                    DataTypeMgmt.Variant2RecordID(Value, TempValue);
                    FldRef.VALUE := TempValue;
                end;
            'DateTime':
                FldRef.VALUE := DataTypeMgmt.Variant2DateTime(Value);
            'Text',
            'Code':
                FldRef.VALUE := DataTypeMgmt.Variant2Text(Value, '');
            else
                Error(TypeNotSupportedLbl, Format(FldRef.Type()));
        end;
    end;

    procedure VariantToRecRef(var SourceRecord: Variant; var SourceRecordRef: RecordRef);
    var
        RecordID: RecordID;
    begin
        case true of
            SourceRecord.IsRecord():
                SourceRecordRef.GETTABLE(SourceRecord);
            SourceRecord.IsRecordRef():
                SourceRecordRef := SourceRecord;
            SourceRecord.IsRecordId():
                begin
                    RecordID := SourceRecord;
                    if RecordID.TableNo() = 0 then
                        Error(InvalidParameterErr);
                    if not SourceRecordRef.GET(RecordID) then
                        SourceRecordRef.OPEN(RecordID.TableNo());
                end;
            else
                Error(InvalidParameterErr);
        end;
    end;

    local procedure GetConstantFilter(var RecRef: RecordRef; var FldRef: FieldRef; ConstantValue: Variant; var IsRange: Boolean; var FromValue: Variant);
    var
        FieldDataType: Enum "Symbol Data Type";
        Filters: Text;
    begin
        FieldDataType := DataTypeMgmt.GetFieldDatatype(RecRef.Number(), FldRef.Number());
        if (ConstantValue.IsText() or ConstantValue.IsCode()) and
          (FieldDataType <> "Symbol Data Type"::String)
        then begin
            RecRef.FilterGroup := 4;
            FldRef.SetFilter(ConstantValue);
            Filters := FldRef.GetFilter();
            if StrPos(Filters, '..') <> 0 then
                IsRange := true
            else
                FromValue := FldRef.GetRangeMax();
            FldRef.SetRange();
            RecRef.FilterGroup := 0;
        end else
            FromValue := ConstantValue;
    end;

    local procedure Variant2DateFormula(Value: Variant; var DateFormula: DateFormula);
    var
        TmpDateFormula: DateFormula;
        InvalidDateValueErr: Label '%1 cannot be converted to DateFormula.', Comment = '%1 = DateValue';
    begin
        if Value.IsDateFormula() then
            DateFormula := Value
        else
            if Value.IsText() or Value.IsCode() then begin
                Evaluate(TmpDateFormula, Value);
                DateFormula := TmpDateFormula;
            end else
                Error(InvalidDateValueErr, Value);
    end;

    var
        DataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        InvalidParameterErr: Label 'Invalid Parameter';
}