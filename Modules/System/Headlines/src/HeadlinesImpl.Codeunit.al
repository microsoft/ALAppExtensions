// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1470 "Headlines Impl."
{
    Access = Internal;
    Permissions = tabledata User = r;

    var
        MorningGreetingWithUsernameTxt: Label 'Good morning, %1!', Comment = 'Displayed between 00:00 and 10:59. %1 is the user name.';
        NoonGreetingWithUsernameTxt: Label 'Hi, %1!', Comment = 'Displayed between 11:00 and 13:59. %1 is the user name.';
        AfternoonGreetingWithUsernameTxt: Label 'Good afternoon, %1!', Comment = 'Displayed between 14:00 and 18:59. %1 is the user name.';
        EveningGreetingWithUsernameTxt: Label 'Good evening, %1!', Comment = 'Displayed between 19:00 and 23:59. %1 is the user name.';

        MorningGreetingWithoutUsernameTxt: Label 'Good morning!', Comment = 'Displayed between 00:00 and 10:59.';
        NoonGreetingWithoutUsernameTxt: Label 'Hi!', Comment = 'Displayed between 11:00 and 13:59.';
        AfternoonGreetingWithoutUsernameTxt: Label 'Good afternoon!', Comment = 'Displayed between 14:00 and 18:59.';
        EveningGreetingWithoutUsernameTxt: Label 'Good evening!', Comment = 'Displayed between 19:00 and 23:59.';

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
    var
        EmphasizeLbl: Label '<emphasize>%1</emphasize>', Comment = '%1 - Text to be emphasized', Locked = true;
    begin
        if TextToEmphasize <> '' then
            exit(StrSubstNo(EmphasizeLbl, TextToEmphasize));
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
    var
        PayloadLbl: Label '<payload>%1</payload>', Comment = '%1 - The payload', Locked = true;
    begin
        if PayloadText <> '' then
            exit(StrSubstNo(PayloadLbl, PayloadText));
    end;

    local procedure GetQualifierText(QualifierText: Text): Text;
    var
        QualifierLbl: Label '<qualifier>%1</qualifier>', Comment = '%1 - The qualifier', Locked = true;
    begin
        if QualifierText <> '' then
            exit(StrSubstNo(QualifierLbl, QualifierText));
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
        GreetingTextWithUsername: Text;
        GreetingTextWithoutUsername: Text;
    begin
        case CurrentTimeOfDay of
            000000T .. 105959T:
                begin
                    GreetingTextWithUsername := MorningGreetingWithUsernameTxt;
                    GreetingTextWithoutUsername := MorningGreetingWithoutUsernameTxt;
                end;
            110000T .. 135959T:
                begin
                    GreetingTextWithUsername := NoonGreetingWithUsernameTxt;
                    GreetingTextWithoutUsername := NoonGreetingWithoutUsernameTxt;
                end;
            140000T .. 185959T:
                begin
                    GreetingTextWithUsername := AfternoonGreetingWithUsernameTxt;
                    GreetingTextWithoutUsername := AfternoonGreetingWithoutUsernameTxt;
                end;
            190000T .. 235959T:
                begin
                    GreetingTextWithUsername := EveningGreetingWithUsernameTxt;
                    GreetingTextWithoutUsername := EveningGreetingWithoutUsernameTxt;
                end;
        end;

        // check if the UserName is empty or contains only spaces
        if (UserName = '') OR (DelChr(UserName, '=') = '') then
            exit(GreetingTextWithoutUsername);

        GreetingTextWithUsername := StrSubstNo(GreetingTextWithUsername, UserName);
        exit(GreetingTextWithUsername);
    end;

    procedure ShouldUserGreetingBeVisible(): Boolean;
    var
        LogInManagement: Codeunit "User Login Time Tracker";
        LimitDateTime: DateTime;
        TenMinutesInMilliseconds: Integer;
    begin
        TenMinutesInMilliseconds := 10 * 60 * 1000;
        LimitDateTime := CurrentDateTime() - TenMinutesInMilliseconds; // greet if login is in the last 10 minutes, then stop greeting
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

