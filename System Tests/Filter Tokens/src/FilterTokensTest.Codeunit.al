// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135034 "Filter Tokens Test"
{
    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
    end;

    var
        FilterTokens: Codeunit "Filter Tokens";
        Assert: Codeunit "Library Assert";
        FilterTokensTest: Codeunit "Filter Tokens Test";

    [Test]
    [Scope('OnPrem')]
    procedure MakeDateTimeFilter()
    begin
        // [SCENARIO] Different formats of date and time can be handled in filter expressions.

        // [GIVEN] A text which contains date and time in different formats.
        // [WHEN] MakeDateTimeFilter is called.
        // [THEN] Verify that the date and time in a valid format is extracted in the variable passed as VAR.
        BINDSUBSCRIPTION(FilterTokensTest);

        VerifyDateTimeFilter(' CHRISTMAS 11:11:11 ', FORMAT(CREATEDATETIME(DMY2DATE(25, 12, 2019), 111111T)));
        VerifyDateTimeFilter(' 01-01-2012 11:11:11 ', FORMAT(CREATEDATETIME(DMY2DATE(1, 1, 2012), 111111T)));
        VerifyDateTimeFilter(' 01-01-2012 LUNCH ', FORMAT(CREATEDATETIME(DMY2DATE(1, 1, 2012), 120000T)));
        VerifyDateTimeFilter('01-01-2012 11:11:11..NOW', FORMAT(CREATEDATETIME(DMY2DATE(1, 1, 2012), 111111T)) + '..%1');
        VerifyDateTimeFilter(' NOW ', '%1');
        VerifyDateTimeFilter(' NOW.. 01-01-2012 11:11:11', '%1..' + FORMAT(CREATEDATETIME(DMY2DATE(1, 1, 2012), 111111T)));
        VerifyDateTimeFilter(' ..NOW ', '..%1');
        VerifyDateTimeFilter('''''', '''''');

        UNBINDSUBSCRIPTION(FilterTokensTest);
    end;

    local procedure VerifyDateTimeFilter(FilterText: Text; ExpectedText: Text[250])
    var
        OrgFilterText: Text[250];
        ExpectedFilterText: Text;
        NoOfAttempts: Integer;
    begin
        OrgFilterText := CopyStr(FilterText, 1, MaxStrLen(OrgFilterText));

        // [WHEN] MakeDateTimeFilter is called.
        FilterTokens.MakeDateTimeFilter(FilterText);

        ExpectedFilterText := STRSUBSTNO(ExpectedText, CURRENTDATETIME());

        WHILE (NoOfAttempts < 10) AND (FilterText <> ExpectedFilterText) DO BEGIN // retry because time (seconds) may have shifted between the two calls to CURRENTDATETIME

            NoOfAttempts += 1;
            FilterText := OrgFilterText;
            FilterTokens.MakeDateTimeFilter(FilterText);
            ExpectedFilterText := STRSUBSTNO(ExpectedText, CURRENTDATETIME());
        END;

        // [THEN] A date and time in a valid format is extracted in the variable passed as VAR.
        Assert.AreEqual(ExpectedFilterText, FilterText, STRSUBSTNO('"%1" was not evaluated correctly.', OrgFilterText));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure MakeTimeFilter()
    begin
        // [SCENARIO] Different formats of time can be handled in filter expressions.

        // [GIVEN] A text which contains a time in different formats.
        // [WHEN] MakeTimeFilter is called.
        // [THEN] Verify that time in a valid format is extracted in the variable passed as VAR.
        BINDSUBSCRIPTION(FilterTokensTest);

        VerifyTimeFilter('  11:11:11 ', FORMAT(111111T));
        VerifyTimeFilter('LUNCH', FORMAT(120000T));
        VerifyTimeFilter(' NOW ', '%1');
        VerifyTimeFilter('''''', '''''');

        UNBINDSUBSCRIPTION(FilterTokensTest);
    end;

    local procedure VerifyTimeFilter(FilterText: Text; ExpectedText: Text)
    var
        OrgFilterText: Text[250];
        ExpectedFilterText: Text;
        NoOfAttempts: Integer;
    begin
        OrgFilterText := CopyStr(FilterText, 1, MaxStrLen(OrgFilterText));

        // [WHEN] MakeTimeFilter is called.
        FilterTokens.MakeTimeFilter(FilterText);

        ExpectedFilterText := STRSUBSTNO(ExpectedText, TIME());

        WHILE (NoOfAttempts < 10) AND (FilterText <> ExpectedFilterText) DO BEGIN // retry because time may have shifted between the two calls to TIME
            NoOfAttempts += 1;
            FilterText := OrgFilterText;
            FilterTokens.MakeTimeFilter(FilterText);
            ExpectedFilterText := STRSUBSTNO(ExpectedText, TIME());
        END;

        // [THEN] The time in a valid format is extracted in the variable passed as VAR.
        Assert.AreEqual(ExpectedFilterText, FilterText, STRSUBSTNO('"%1" was not evaluated correctly.', OrgFilterText));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure MakeDateFilter()
    begin
        // [SCENARIO] Different formats of date can be handled in filter expressions.

        BINDSUBSCRIPTION(FilterTokensTest);

        // [GIVEN] A text which contains a date in different formats.
        // [WHEN] MakeDateFilter is called.
        // [THEN] Verify that date in a valid format is extracted in the variable passed as VAR.
        VerifyDateFilter('SUMMER', STRSUBSTNO('%1..%2', FORMAT(DMY2DATE(21, 6, 2012)), FORMAT(DMY2DATE(23, 9, 2012))));
        VerifyDateFilter(' 01-01-2012 ', FORMAT(DMY2DATE(1, 1, 2012)));
        VerifyDateFilter(' 01-01-2012 .. 11-11-12', STRSUBSTNO('%1..%2', FORMAT(DMY2DATE(1, 1, 2012)), FORMAT(DMY2DATE(11, 11, 2012))));
        VerifyDateFilter('TODAY', FORMAT(TODAY()));
        VerifyDateFilter('YESTERDAY', FORMAT(TODAY() - 1));
        VerifyDateFilter('WORKDATE', FORMAT(WORKDATE()));
        VerifyDateFilter('TOMORROW', FORMAT(TODAY() + 1));
        VerifyDateFilter('WEEK', FORMAT(CALCDATE('<CW-6D>', TODAY())) + '..' + FORMAT(CALCDATE('<CW>', TODAY())));
        VerifyDateFilter('QUARTER', STRSUBSTNO('%1..%2', FORMAT(CALCDATE('<-CQ>')), FORMAT(CALCDATE('<CQ>'))));
        VerifyDateFilter('WEEK - 7D', FORMAT(CALCDATE('<CW-13D>', TODAY())) + '..' + FORMAT(CALCDATE('<CW-7D>', TODAY())));
        VerifyDateFilter('+15D', FORMAT(CALCDATE('<+15D>', TODAY())));
        VerifyDateFilter('15D', FORMAT(CALCDATE('<+15D>', TODAY())));
        VerifyDateFilter('WORKDATE+15D', FORMAT(CALCDATE('<+15D>', WORKDATE())));
        VerifyDateFilter('TODAY - 15D', FORMAT(CALCDATE('<-15D>', TODAY())));
        VerifyDateFilter('+15D+CM', FORMAT(CALCDATE('<+15D+CM>', TODAY())));
        VerifyDateFilter('CM', FORMAT(CALCDATE('<CM>', TODAY())));
        VerifyDateFilter('CQ', FORMAT(CALCDATE('<CQ>', TODAY())));
        VerifyDateFilter('CQ - 34D', FORMAT(CALCDATE('<CQ-34D>', TODAY())));
        VerifyDateFilter('WORKDATE + CQ - 34D', FORMAT(CALCDATE('<CQ-34D>', WORKDATE())));
        VerifyDateFilter('WORKDATE + CQ - 34D..TODAY+3D', FORMAT(CALCDATE('<CQ-34D>', WORKDATE())) + '..' + FORMAT(CALCDATE('<+3D>', TODAY())));
        VerifyDateFilter('''''', '''''');

        UNBINDSUBSCRIPTION(FilterTokensTest);
    end;

    local procedure VerifyDateFilter(FilterText: Text; ExpectedText: Text)
    var
        OrgFilterText: Text;
    begin
        OrgFilterText := FilterText;

        // [WHEN] MakeTimeFilter is called.
        FilterTokens.MakeDateFilter(FilterText);
        IF FilterText <> ExpectedText THEN BEGIN // retry because time may have shifted between the two calls to CURRENTDATETIME
            FilterText := OrgFilterText;
            FilterTokens.MakeDateFilter(FilterText);
        END;

        // [THEN] Verify that date in a valid format is extracted in the variable passed as VAR.
        Assert.AreEqual(ExpectedText, FilterText, STRSUBSTNO('"%1" was not evaluated correctly.', OrgFilterText));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure MakeTextFilter()
    begin
        // [SCENARIO] Different formats of text can be handled in filter expressions.

        // [GIVEN] A text which contains a filter.
        // [WHEN] MakeTextFilter is called.
        // [THEN] Verify that text filter in a valid format is extracted in the variable passed as VAR.
        BINDSUBSCRIPTION(FilterTokensTest);

        VerifyTextFilter('ME', USERID());
        VerifyTextFilter('COMPANY', COMPANYNAME());
        VerifyTextFilter('MyFilter', 'MyFilter');

        UNBINDSUBSCRIPTION(FilterTokensTest);
    end;

    local procedure VerifyTextFilter(FilterText: Text; ExpectedText: Text)
    var
        OrgFilterText: Text;
    begin
        OrgFilterText := FilterText;

        // [WHEN] MakeTextFilter is called.
        FilterTokens.MakeTextFilter(FilterText);

        // [THEN] Verify that text filter in a valid format is extracted in the variable passed as VAR.
        Assert.AreEqual(ExpectedText, FilterText, STRSUBSTNO('"%1" was not evaluated correctly.', OrgFilterText));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure MakeDateFilterWithOrCondition()
    begin
        // [SCENARIO] The <OR> condition can be handled in filter expression.

        // [GIVEN] A text which contains a date in different formats with <OR> condition.
        // [WHEN] MakeDateFilter is called.
        // [THEN] Verify that date in a valid format is extracted in the variable passed as VAR.

        BINDSUBSCRIPTION(FilterTokensTest);

        VerifyDateFilter('SUMMER|' + FORMAT(DMY2DATE(2, 12, 2019)), GetExpectedDateFilterExpression(STRSUBSTNO('%1..%2', FORMAT(DMY2DATE(21, 6, 2012)), FORMAT(DMY2DATE(23, 9, 2012))), FORMAT(DMY2DATE(2, 12, 2019))));
        VerifyDateFilter('CQ - 34D|WORKDATE + CQ - 34D', GetExpectedDateFilterExpression(FORMAT(CALCDATE('<CQ-34D>', TODAY())), FORMAT(CALCDATE('<CQ-34D>', WORKDATE()))));

        UNBINDSUBSCRIPTION(FilterTokensTest);
    end;

    local procedure GetExpectedDateFilterExpression(Date1: Text; Date2: Text): Text
    begin
        EXIT(STRSUBSTNO('%1|%2', Date1, Date2));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Filter Tokens", 'OnResolveDateTokenFromDateTimeFilter', '', false, false)]
    local procedure OnResolveDateTokenFromDateTimeFilter(DateToken: Text; var DateFilter: Date; var Handled: Boolean)
    var
        ChristmasTxt: Label 'CHRISTMAS';
    begin
        IF NOT Handled THEN
            CASE DateToken OF
                COPYSTR(ChristmasTxt, 1, STRLEN(ChristmasTxt)):
                    BEGIN
                        DateFilter := DMY2DATE(25, 12, 2019);
                        Handled := TRUE;
                    END;
            END;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Filter Tokens", 'OnResolveTimeTokenFromDateTimeFilter', '', false, false)]
    local procedure OnResolveTimeTokenFromDateTimeFilter(TimeToken: Text; var TimeFilter: Time; var Handled: Boolean)
    var
        LunchTxt: Label 'LUNCH';
    begin
        IF NOT Handled THEN
            CASE TimeToken OF
                COPYSTR(LunchTxt, 1, STRLEN(LunchTxt)):
                    BEGIN
                        TimeFilter := 120000T;
                        Handled := TRUE;
                    END;
            END;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Filter Tokens", 'OnResolveDateFilterToken', '', false, false)]
    local procedure OnResolveDateFilterToken(DateToken: Text; var FromDate: Date; var ToDate: Date; var Handled: Boolean)
    var
        SummerTxt: Label 'SUMMER';
    begin
        IF NOT Handled THEN
            CASE DateToken OF
                COPYSTR(SummerTxt, 1, STRLEN(SummerTxt)):
                    BEGIN
                        EVALUATE(FromDate, FORMAT(DMY2DATE(21, 06, 2012)));
                        EVALUATE(ToDate, FORMAT(DMY2DATE(23, 09, 2012)));
                        Handled := TRUE;
                    END;
            END;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Filter Tokens", 'OnResolveTimeFilterToken', '', false, false)]
    local procedure OnResolveTimeFilterToken(TimeToken: Text; var TimeFilter: Time; var Handled: Boolean)
    var
        LunchTxt: Label 'LUNCH';
    begin
        IF NOT Handled THEN
            CASE TimeToken OF
                COPYSTR(LunchTxt, 1, STRLEN(LunchTxt)):
                    BEGIN
                        TimeFilter := 120000T;
                        Handled := TRUE;
                    END;
            END;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Filter Tokens", 'OnResolveTextFilterToken', '', false, false)]
    local procedure OnResolveTextFilterToken(TextToken: Text; var TextFilter: Text; var Handled: Boolean)
    var
        MyFilterTxt: Label 'MyFilter';
    begin
        IF NOT Handled THEN
            CASE TextToken OF
                COPYSTR(MyFilterTxt, 1, STRLEN(MyFilterTxt)):
                    BEGIN
                        TextFilter := 'Custom Filter';
                        Handled := TRUE;
                    END;
            END;
    end;
}

