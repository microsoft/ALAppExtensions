// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1282 "Password Handler Impl."
{
    Access = Internal;

    var
        InsufficientPassLengthErr: Label 'The password must contain at least %1 characters.', Comment = '%1 = the number of characters';


    procedure GeneratePassword(): Text;
    begin
        exit(GeneratePassword(GetPasswordMinLength()));
    end;

    procedure GeneratePassword(Length: Integer): Text;
    var
        SecurityMembership: DotNet "Security.Membership";
        Password: Text;
        MinNumOfNonAlphanumericChars: Integer;
    begin
        if Length < GetPasswordMinLength() then
            Error(InsufficientPassLengthErr, GetPasswordMinLength());

        MinNumOfNonAlphanumericChars := 1;
        repeat
            Password := SecurityMembership.GeneratePassword(Length, MinNumOfNonAlphanumericChars);
        until IsPasswordStrong(Password);
        exit(Password);
    end;

    procedure IsPasswordStrong(Password: Text): Boolean;
    var
        CharacterSets: List of [Text];
        CharacterSet: Text;
        Counter: Integer;
        SequenceLength: Integer;
    begin
        if StrLen(Password) < GetPasswordMinLength() then
            exit(false);

        AddRequiredCharacterSets(CharacterSets);

        // Check all character sets are present
        for Counter := 1 to CharacterSets.Count() do begin
            CharacterSets.Get(Counter, CharacterSet);
            if not ContainsAny(Password, CharacterSet) then
                exit(false);
        end;

        // Check no sequences
        SequenceLength := 3;
        AddReversedCharacterSets(CharacterSets);
        for Counter := 1 to StrLen(Password) - SequenceLength + 1 do
            if AreCharacterValuesEqualOrSequential(CharacterSets, CopyStr(Password, Counter, SequenceLength)) then
                exit(false);

        exit(true);
    end;

    procedure GetPasswordMinLength(): Integer
    var
        PasswordDialogManagement: Codeunit "Password Dialog Management";
        MinPasswordLength: Integer;
    begin
        PasswordDialogManagement.OnSetMinPasswordLength(MinPasswordLength);
        if MinPasswordLength < 8 then
            MinPasswordLength := 8; // the default

        exit(MinPasswordLength);
    end;

    local procedure ContainsAny(String: Text; Characters: Text): Boolean;
    var
        ReplacedText: Text;
    begin
        ReplacedText := DelChr(String, '=', Characters);
        if StrLen(ReplacedText) < StrLen(String) then
            exit(true);
        exit(false);
    end;

    local procedure AreCharacterValuesEqualOrSequential(CharacterSets: List of [Text]; SeqLetters: Text): Boolean;
    var
        CharacterSet: Text;
        ReplacedText: Text;
        Counter: Integer;
    begin
        // Check if all the characters are the same
        ReplacedText := DelChr(SeqLetters, '=', SeqLetters[1]);
        if StrLen(ReplacedText) = 0 then
            exit(true);

        // Check if characters form a sequence
        for Counter := 1 to CharacterSets.Count() do begin
            CharacterSets.Get(Counter, CharacterSet);
            if (StrPos(CharacterSet, SeqLetters) > 0) then
                exit(true);
        end;

        exit(false);
    end;

    local procedure AddRequiredCharacterSets(var CharacterSets: List of [Text])
    var
        UppercaseCharacters: Text;
        Digits: Text;
        SpecialCharacters: Text;
    begin
        UppercaseCharacters := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        Digits := '0123456789';
        SpecialCharacters := '!@#$%^&*()_-+=[{]};:<>|./?';

        CharacterSets.Add(UppercaseCharacters);
        CharacterSets.Add(LowerCase(UppercaseCharacters));
        CharacterSets.Add(Digits);
        CharacterSets.Add(SpecialCharacters);
    end;

    local procedure AddReversedCharacterSets(var CharacterSets: List of [Text])
    var
        ReverseUppercaseCharacters: Text;
        ReverseDigits: Text;
    begin
        ReverseUppercaseCharacters := 'ZYXWVUTSRQPONMLKJIHGFEDCBA';
        ReverseDigits := '9876543210';

        CharacterSets.Add(ReverseUppercaseCharacters);
        CharacterSets.Add(LowerCase(ReverseUppercaseCharacters));
        CharacterSets.Add(ReverseDigits);
    end;
}

