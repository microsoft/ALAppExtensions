// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 58 "Filter Tokens Impl."
{
    Access = Internal;
    SingleInstance = true;

    var
        FilterTokens: Codeunit "Filter Tokens";
        FilterType: Option DateTime,Date,Time;
        TodayTxt: Label 'TODAY', Comment = 'Must be uppercase';
        WorkdateTxt: Label 'WORKDATE', Comment = 'Must be uppercase';
        AlphabetTxt: Label 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', Comment = 'Uppercase - translate into entire alphabet.';
        NowTxt: Label 'NOW', Comment = 'Must be uppercase.';
        YesterdayTxt: Label 'YESTERDAY', Comment = 'Must be uppercase';
        TomorrowTxt: Label 'TOMORROW', Comment = 'Must be uppercase';
        WeekTxt: Label 'WEEK', Comment = 'Must be uppercase';
        MonthTxt: Label 'MONTH', Comment = 'Must be uppercase';
        QuarterTxt: Label 'QUARTER', Comment = 'Must be uppercase';
        UserTxt: Label 'USER', Comment = 'Must be uppercase';
        MeTxt: Label 'ME', Comment = 'Must be uppercase';
        CompanyTxt: Label 'COMPANY', Comment = 'Must be uppercase';

    procedure MakeDateFilter(var DateFilter: Text)
    begin
        if not (DateFilter = '''''') then
            MakeFilterExpression(FilterType::Date, DateFilter);
    end;

    procedure MakeTimeFilter(var TimeFilter: Text)
    begin
        MakeFilterExpression(FilterType::Time, TimeFilter);
    end;

    procedure MakeDateTimeFilter(var DateTimeFilterText: Text)
    var
        FilterText: Text;
    begin
        FilterText := DateTimeFilterText;
        MakeFilterExpression(FilterType::DateTime, FilterText);
        DateTimeFilterText := CopyStr(FilterText, 1, MaxStrLen(DateTimeFilterText));
    end;

    procedure MakeTextFilter(var TextFilter: Text)
    var
        Position: Integer;
        TextToken: Text;
        Handled: Boolean;
    begin
        Position := 1;
        GetPositionDifferentCharacter(' ', TextFilter, Position);
        if FindText(TextToken, TextFilter, Position) then
            case TextToken of
                CopyStr('ME', 1, StrLen(TextToken)), CopyStr(MeTxt, 1, StrLen(TextToken)):
                    TextFilter := UserId();
                CopyStr('USER', 1, StrLen(TextToken)), CopyStr(UserTxt, 1, StrLen(TextToken)):
                    TextFilter := UserId();
                CopyStr('COMPANY', 1, StrLen(TextToken)), CopyStr(CompanyTxt, 1, StrLen(TextToken)):
                    TextFilter := CompanyName();
                else
                    FilterTokens.OnResolveTextFilterToken(TextToken, TextFilter, Handled);
            end;
    end;

    local procedure MakeFilterExpression(TypeOfFilter: Option; var FilterText: Text)
    var
        Head: Text;
        Tail: Text;
        Position: Integer;
        Length: Integer;
    begin
        FilterText := DelChr(FilterText, '<>'); // Removes all trailing and leading spaces
        Position := 1;
        Length := StrLen(FilterText);
        while Length <> 0 do begin
            GetPositionDifferentCharacter(' |()', FilterText, Position);
            if Position > 1 then begin
                Head := Head + CopyStr(FilterText, 1, Position - 1);
                FilterText := CopyStr(FilterText, Position);
                Position := 1;
                Length := StrLen(FilterText);
            end;
            if Length <> 0 then begin
                ReadUntilCharacter('|()', FilterText, Position);
                if Position > 1 then begin
                    Tail := CopyStr(FilterText, Position);
                    FilterText := CopyStr(FilterText, 1, Position - 1);
                    ResolveFilter(TypeOfFilter, FilterText);
                    Evaluate(Head, Head + FilterText);
                    FilterText := Tail;
                    Position := 1;
                    Length := StrLen(FilterText);
                end;
            end;
        end;
        FilterText := Head;
    end;

    local procedure ResolveFilter(TypeOfFilter: Option; var "Filter": Text)
    begin
        case TypeOfFilter of
            FilterType::DateTime:
                ResolveDateTimeFilter(Filter);
            FilterType::Date:
                ResolveDateFilter(Filter);
            FilterType::Time:
                ResolveTimeFilter(Filter);
        end;
    end;

    local procedure ResolveDateTimeFilter(var DateTimeFilter: Text)
    var
        DateTimeFilter1: DateTime;
        DateTimeFilter2: DateTime;
        DateFilter1: Date;
        DateFilter2: Date;
        TimeFilter1: Time;
        TimeFilter2: Time;
        RangeStartPosition: Integer;
    begin
        RangeStartPosition := StrPos(DateTimeFilter, '..');

        if RangeStartPosition = 0 then begin
            // If DateTimeFilter is not a range
            if not ExtractDateAndTimeFilter(DateTimeFilter, DateFilter1, TimeFilter1) or (DateFilter1 = 0D) then
                exit;
            if TimeFilter1 = 0T then begin
                DateTimeFilter := Format(CreateDateTime(DateFilter1, 000000T)) + '..' + Format(CreateDateTime(DateFilter1, 235959.995T));
                exit;
            end;
            DateTimeFilter := Format(CreateDateTime(DateFilter1, TimeFilter1));
            exit;
        end;

        if not ExtractDateAndTimeFilter(CopyStr(DateTimeFilter, 1, RangeStartPosition - 1), DateFilter1, TimeFilter1) then
            exit;
        if not ExtractDateAndTimeFilter(CopyStr(DateTimeFilter, RangeStartPosition + 2), DateFilter2, TimeFilter2) then
            exit;

        if (DateFilter1 = 0D) and (DateFilter2 = 0D) then
            exit;
        if DateFilter1 <> 0D then begin
            if TimeFilter1 = 0T then
                TimeFilter1 := 000000T;
            DateTimeFilter1 := CreateDateTime(DateFilter1, TimeFilter1);
        end;
        if DateFilter2 <> 0D then begin
            if TimeFilter2 = 0T then
                TimeFilter2 := 235959T;
            DateTimeFilter2 := CreateDateTime(DateFilter2, TimeFilter2);
        end;

        DateTimeFilter := Format(DateTimeFilter1) + '..' + Format(DateTimeFilter2);
    end;

    local procedure ExtractDateAndTimeFilter(DateTimeText: Text; var DateFilter: Date; var TimeFilter: Time): Boolean
    var
        DateText: Text;
        TimeText: Text;
        Position: Integer;
    begin
        if DateTimeText in [NowTxt, 'NOW'] then begin
            DateFilter := Today();
            TimeFilter := Time();
            exit(true);
        end;

        DateFilter := 0D;
        TimeFilter := 0T;
        Position := 1;

        GetPositionDifferentCharacter(' ', DateTimeText, Position);
        ReadUntilCharacter(' ', DateTimeText, Position);
        DateText := DelChr(CopyStr(DateTimeText, 1, Position - 1), '<>');
        TimeText := DelChr(CopyStr(DateTimeText, Position), '<>');

        if DateText = '' then
            exit(true);

        if not ResolveDateText(DateText, DateFilter) then
            exit(false);

        if (TimeText = '') or ResolveTimeText(TimeText, TimeFilter) then
            exit(true);

        exit(false);
    end;

    local procedure ResolveDateText(DateText: Text; var DateFilter: Date) Handled: Boolean
    var
        DateToken: Text;
        Position: Integer;
    begin
        Position := 1;
        GetPositionDifferentCharacter(' ', DateText, Position);
        if not FindText(DateToken, DateText, Position) then begin
            Handled := Evaluate(DateFilter, DateText);
            exit(Handled);
        end;
        case DateToken of
            CopyStr('TODAY', 1, StrLen(DateToken)), CopyStr(TodayTxt, 1, StrLen(DateToken)):
                begin
                    DateFilter := Today();
                    exit(true);
                end;
            CopyStr('WORKDATE', 1, StrLen(DateToken)), CopyStr(WorkdateTxt, 1, StrLen(DateToken)):
                begin
                    DateFilter := WorkDate();
                    exit(true);
                end;
            else begin
                    FilterTokens.OnResolveDateTokenFromDateTimeFilter(DateText, DateFilter, Handled);
                    exit(Handled);
                end;
        end;
    end;

    local procedure ResolveTimeText(TimeText: Text; var TimeFilter: Time) Handled: Boolean
    var
        TimeToken: Text;
        Position: Integer;
        Length: Integer;
    begin
        Position := 1;
        Length := StrLen(TimeText);
        GetPositionDifferentCharacter(' ', TimeText, Position);
        if not FindText(TimeToken, TimeText, Position) then begin
            Handled := Evaluate(TimeFilter, TimeText);
            exit(Handled);
        end;
        FilterTokens.OnResolveTimeTokenFromDateTimeFilter(TimeText, TimeFilter, Handled);
        if not Handled then begin
            Position := Position + StrLen(TimeToken);
            GetPositionDifferentCharacter(' ', TimeText, Position);
            if Position > Length then begin
                TimeFilter := 000000T + Round(Time() - 000000T, 1000);
                exit(true);
            end;
        end;
        exit(Handled);
    end;

    local procedure ResolveDateFilter(var DateFilter: Text)
    var
        Date1: Date;
        Date2: Date;
        Text1: Text;
        Text2: Text;
        RangeStartPosition: Integer;
        DateFilterRangeLbl: Label '%1..%2', Comment = '%1 - From date, %2 - Till date', Locked = true;
    begin
        DateFilter := DelChr(DateFilter, '<>');
        if DateFilter = '' then
            exit;
        RangeStartPosition := StrPos(DateFilter, '..');

        if RangeStartPosition = 0 then begin
            // If DateFilter is not a range
            if not ResolveDateFilterToken(Date1, Date2, DateFilter) then
                exit;
            if Date1 = Date2 then
                DateFilter := Format(Date1)
            else
                DateFilter := StrSubstNo(DateFilterRangeLbl, Date1, Date2);
            exit;
        end;

        Text1 := CopyStr(DateFilter, 1, RangeStartPosition - 1);
        if not ResolveDateFilterToken(Date1, Date2, Text1) then
            exit;
        Text1 := Format(Date1);
        GetPositionDifferentCharacter('.', DateFilter, RangeStartPosition);
        Text2 := CopyStr(DateFilter, RangeStartPosition);
        if not ResolveDateFilterToken(Date1, Date2, Text2) then
            exit;
        Text2 := Format(Date2);
        DateFilter := Text1 + '..' + Text2;
    end;

    local procedure ResolveDateFilterToken(var Date1: Date; var Date2: Date; DateFilter: Text) Handled: Boolean
    var
        DateFormula: DateFormula;
        DateToken: Text;
        RemainderOfText: Text;
        Position: Integer;
    begin
        if Evaluate(DateFormula, DateFilter) then begin
            // If DateFilter can be evaluated to a DateFormula
            RemainderOfText := DateFilter;
            DateFilter := '';
        end else begin
            ClearLastError(); // When Evaluate fails, the error shows up in 'View the last known error'
            Position := StrPos(DateFilter, '+');
            if Position = 0 then
                Position := StrPos(DateFilter, '-');
            if Position > 0 then begin
                RemainderOfText := DelChr(CopyStr(DateFilter, Position));
                if Evaluate(DateFormula, RemainderOfText) then
                    DateFilter := DelChr(CopyStr(DateFilter, 1, Position - 1))
                else
                    RemainderOfText := '';
            end;
        end;

        Position := 1;
        FindText(DateToken, DateFilter, Position);

        if DateToken <> '' then begin
            FilterTokens.OnResolveDateFilterToken(DateFilter, Date1, Date2, Handled);
            DateToken := UpperCase(DateFilter);

            if not Handled then
                case DateToken of
                    CopyStr('TODAY', 1, StrLen(DateToken)), CopyStr(TodayTxt, 1, StrLen(DateToken)):
                        Handled := FindDate(Today(), Date1, Date2);
                    CopyStr('WORKDATE', 1, StrLen(DateToken)), CopyStr(WorkdateTxt, 1, StrLen(DateToken)):
                        Handled := FindDate(WorkDate(), Date1, Date2);
                    CopyStr('NOW', 1, StrLen(DateToken)), CopyStr(NowTxt, 1, StrLen(DateToken)):
                        Handled := FindDate(DT2Date(CurrentDateTime()), Date1, Date2);
                    CopyStr('YESTERDAY', 1, StrLen(DateToken)), CopyStr(YesterdayTxt, 1, StrLen(DateToken)):
                        Handled := FindDate(CalcDate('<-1D>'), Date1, Date2);
                    CopyStr('TOMORROW', 1, StrLen(DateToken)), CopyStr(TomorrowTxt, 1, StrLen(DateToken)):
                        Handled := FindDate(CalcDate('<1D>'), Date1, Date2);
                    CopyStr('WEEK', 1, StrLen(DateToken)), CopyStr(WeekTxt, 1, StrLen(DateToken)):
                        Handled := FindDates('<-CW>', '<CW>', Date1, Date2);
                    CopyStr('MONTH', 1, StrLen(DateToken)), CopyStr(MonthTxt, 1, StrLen(DateToken)):
                        Handled := FindDates('<-CM>', '<CM>', Date1, Date2);
                    CopyStr('QUARTER', 1, StrLen(DateToken)), CopyStr(QuarterTxt, 1, StrLen(DateToken)):
                        Handled := FindDates('<-CQ>', '<CQ>', Date1, Date2);
                end
        end else
            if (DateFilter <> '') and Evaluate(Date1, DateFilter) then begin
                Date2 := Date1;
                Handled := true;
            end else
                if RemainderOfText <> '' then begin
                    Date1 := Today();
                    Date2 := Date1;
                    Handled := true;
                end else
                    Handled := false;

        if Handled and (RemainderOfText <> '') then begin
            Date1 := CalcDate(DateFormula, Date1);
            Date2 := CalcDate(DateFormula, Date2);
        end;
        exit(Handled);
    end;

    local procedure ResolveTimeFilter(var TimeFilter: Text)
    var
        Time1: Time;
        Time2: Time;
        RangeStartPosition: Integer;
    begin
        RangeStartPosition := StrPos(TimeFilter, '..');
        if RangeStartPosition = 0 then begin
            // If TimeFilter is not a range
            if not ResolveTimeToken(Time1, TimeFilter) then
                exit;
            if Time1 = 0T then
                TimeFilter := Format(000000T) + '..' + Format(235959.995T);
            TimeFilter := Format(Time1);
        end else begin
            // If TimeFilter is a range
            if not ResolveTimeToken(Time1, CopyStr(TimeFilter, 1, RangeStartPosition - 1)) then
                exit;
            if not ResolveTimeToken(Time2, CopyStr(TimeFilter, RangeStartPosition + 2)) then
                exit;

            if Time1 = 0T then
                Time1 := 000000T;
            if Time2 = 0T then
                Time2 := 235959T;

            TimeFilter := Format(Time1) + '..' + Format(Time2);
        end;
    end;

    local procedure ResolveTimeToken(var TimeFilter: Time; TimeToken: Text) Handled: Boolean
    begin
        TimeToken := DelChr(TimeToken); // Deletes all spaces in TimeToke
        case TimeToken of
            NowTxt, 'NOW':
                begin
                    TimeFilter := Time();
                    Handled := true;
                end;
            else
                FilterTokens.OnResolveTimeFilterToken(TimeToken, TimeFilter, Handled);
        end;
        if not Handled then
            Handled := Evaluate(TimeFilter, TimeToken);
    end;

    local procedure FindDate(Date1Input: Date; var Date1: Date; var Date2: Date): Boolean
    begin
        Date1 := Date1Input;
        Date2 := Date1;
        exit(true);
    end;

    local procedure FindDates(DateFormulaText1: Text; DateFormulaText2: Text; var Date1: Date; var Date2: Date): Boolean
    var
        DateFormula1: DateFormula;
        DateFormula2: DateFormula;
    begin
        Evaluate(DateFormula1, DateFormulaText1);
        Evaluate(DateFormula2, DateFormulaText2);
        Date1 := CalcDate(DateFormula1);
        Date2 := CalcDate(DateFormula2);
        exit(true);
    end;

    procedure FindText(var PartOfText: Text; Text: Text; Position: Integer): Boolean
    var
        Position2: Integer;
    begin
        Position2 := Position;
        GetPositionDifferentCharacter(AlphabetTxt, Text, Position);
        if Position = Position2 then
            exit(false);
        PartOfText := UpperCase(CopyStr(Text, Position2, Position - Position2));
        exit(true);
    end;

    procedure GetPositionDifferentCharacter(Character: Text[50]; Text: Text; var Position: Integer)
    var
        Length: Integer;
    begin
        Length := StrLen(Text);
        while (Position <= Length) and (StrPos(Character, UpperCase(CopyStr(Text, Position, 1))) <> 0) do
            Position := Position + 1;
    end;

    local procedure ReadUntilCharacter(Character: Text[50]; Text: Text; var Position: Integer)
    var
        Length: Integer;
    begin
        Length := StrLen(Text);
        while (Position <= Length) and (StrPos(Character, UpperCase(CopyStr(Text, Position, 1))) = 0) do
            Position := Position + 1;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Filter Helper Triggers", 'MakeDateTimeFilter', '', false, false)]
    local procedure DoMakeDateTimeFilter(var DateTimeFilterText: Text)
    begin
        MakeDateTimeFilter(DateTimeFilterText);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Filter Helper Triggers", 'MakeDateFilter', '', false, false)]
    local procedure DoMakeDateFilter(var DateFilterText: Text)
    begin
        MakeDateFilter(DateFilterText);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Filter Helper Triggers", 'MakeTextFilter', '', false, false)]
    local procedure DoMakeTextFilter(var TextFilterText: Text)
    begin
        MakeTextFilter(TextFilterText);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Filter Helper Triggers", 'MakeCodeFilter', '', false, false)]
    local procedure DoMakeCodeFilter(var TextFilterText: Text)
    begin
        MakeTextFilter(TextFilterText);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Filter Helper Triggers", 'MakeTimeFilter', '', false, false)]
    local procedure DoMakeTimeFilter(var TimeFilterText: Text)
    begin
        MakeTimeFilter(TimeFilterText);
    end;
}

