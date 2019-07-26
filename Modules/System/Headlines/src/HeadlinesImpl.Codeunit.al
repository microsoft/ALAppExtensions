// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1470 "Headlines Impl."
{
    Access = Internal;

    var
        MorningGreetingTxt: Label 'Good morning, %1!', Comment = 'Displayed between 00:00 and 10:59. %1 is the user name.';
        NoonGreetingTxt: Label 'Hi, %1!', Comment = 'Displayed between 11:00 and 13:59. %1 is the user name.';
        AfternoonGreetingTxt: Label 'Good afternoon, %1!', Comment = 'Displayed between 14:00 and 18:59. %1 is the user name.';
        EveningGreetingTxt: Label 'Good evening, %1!', Comment = 'Displayed between 19:00 and 23:59. %1 is the user name.';

    procedure Truncate(TextToTruncate: Text; MaxLength: Integer): Text;
    var
        Padding: Text;
    begin
        Padding := '...';

        if MaxLength <= 0 then
            exit('');

        if StrLen(TextToTruncate) <= MaxLength then
            exit(TextToTruncate);

        if MaxLength <= StrLen(Padding) then
            exit(CopyStr(TextToTruncate, 1, MaxLength));

        exit(CopyStr(TextToTruncate, 1, MaxLength - StrLen(Padding)) + Padding);
    end;

    procedure Emphasize(TextToEmphasize: Text): Text;
    begin
        if TextToEmphasize <> '' then
            exit(StrSubstNo('<emphasize>%1</emphasize>', TextToEmphasize));
    end;

    procedure GetHeadlineText(Qualifier: Text; Payload: Text; var ResultText: Text): Boolean;
    var
        DotNetRegex: DotNet Regex;
        PayloadWithoutEmphasize: Text[158];
    begin
        if Payload = '' then
            exit(false); // payload should not be empty

        if StrLen(Qualifier) > GetMaxQualifierLength() then
            exit(false); // qualifier is too long to be a qualifier

        PayloadWithoutEmphasize := DotNetRegex.Replace(Payload, '<emphasize>|</emphasize>', '');

        if StrLen(PayloadWithoutEmphasize) > GetMaxPayloadLength() then
            exit(false); // payload is too long for being a headline

        ResultText := GetQualifierText(Qualifier) + GetPayloadText(Payload);
        exit(true);
    end;

    local procedure GetPayloadText(PayloadText: Text): Text;
    begin
        if PayloadText <> '' then
            exit(StrSubstNo('<payload>%1</payload>', PayloadText));
    end;

    local procedure GetQualifierText(QualifierText: Text): Text;
    begin
        if QualifierText <> '' then
            exit(StrSubstNo('<qualifier>%1</qualifier>', QualifierText));
    end;

    procedure GetUserGreetingText(): Text
    var
        User: Record User;
    begin
        if User.GET(UserSecurityId()) then;
        exit(GetUserGreetingTextInternal(User."Full Name", Time()));
    end;

    procedure GetUserGreetingTextInternal(UserName: Text[80]; CurrentTimeOfDay: Time): Text;
    var
        GreetingText: Text;
    begin
        case CurrentTimeOfDay of
            000000T .. 105959T:
                GreetingText := MorningGreetingTxt;
            110000T .. 135959T:
                GreetingText := NoonGreetingTxt;
            140000T .. 185959T:
                GreetingText := AfternoonGreetingTxt;
            190000T .. 235959T:
                GreetingText := EveningGreetingTxt;
        end;

        // check if the UserName is empty or contains only spaces
        if (UserName = '') OR (DelChr(UserName, '=') = '') then
            // remove UserName from the greeting
            GreetingText := DelStr(GreetingText, StrPos(GreetingText, ','), StrLen(', %1'))
        else
            GreetingText := StrSubstNo(GreetingText, UserName);

        exit(GreetingText);
    end;

    procedure ShouldUserGreetingBeVisible(): Boolean;
    var
        LogInManagement: Codeunit "User Login Time Tracker";
        LimitDateTime: DateTime;
    begin
        LimitDateTime := CreateDateTime(Today(), Time() - (10 * 60 * 1000)); // greet if login is in the last 10 minutes, then stop greeting
        exit(LogInManagement.UserLoggedInSinceDateTime(LimitDateTime));
    end;

    procedure GetMaxQualifierLength(): Integer;
    begin
        exit(50);
    end;

    procedure GetMaxPayloadLength(): Integer;
    begin
        exit(75);
    end;
}

