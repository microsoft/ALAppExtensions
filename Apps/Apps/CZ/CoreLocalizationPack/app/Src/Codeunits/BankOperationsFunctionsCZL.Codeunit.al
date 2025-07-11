// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank;

using Microsoft.Foundation.Company;
using System.Utilities;

codeunit 31037 "Bank Operations Functions CZL"
{
    var
        TempErrorMessage: Record "Error Message" temporary;
        InvalidCharactersErr: Label 'Bank account no. contains invalid characters "%1".', Comment = '%1 = invalid characters';
        BankAccountNoTooLongErr: Label 'Bank account no. is too long.';
        BankAccountNoTooShortErr: Label 'Bank account no. is too short.';
        BankCodeSlashMissingErr: Label 'Bank code must be separated by a slash.';
        BankCodeTooLongErr: Label 'Bank code is too long.';
        BankCodeTooShortErr: Label 'Bank code is too short.';
        PrefixTooLongErr: Label 'Bank account prefix is too long.';
        PrefixIncorrectChecksumErr: Label 'Bank account prefix has incorrect checksum.';
        IdentificationTooLongErr: Label 'Bank account identification is too long.';
        IdentificationTooShortErr: Label 'Bank account identification is too short.';
        IdentificationNonZeroDigitsErr: Label 'Bank account identification must contain at least two non-zero digits.';
        IdentificationIncorrectChecksumErr: Label 'Bank account identification has incorrect checksum.';
        FirstHyphenErr: Label 'Bank account no. must not start with character "-".';

    procedure CreateVariableSymbol(Input: Code[35]): Code[10]
    begin
        if Input = '' then
            exit('');
        exit(CopyStr(TrimLeft(NumbersOnly(Input), '0'), 1, 10));
    end;

    local procedure NumbersOnly(Input: Text): Text
    begin
        exit(DelChr(Input, '=', DelChr(Input, '=', '0123456789')));
    end;

    local procedure TrimLeft(Input: Text; DeletedChar: Text[1]): Text
    begin
        exit(DelChr(Input, '<', DeletedChar));
    end;

    procedure CheckCzBankAccountNo(BankAccountNo: Text[30]; CountryRegionCode: Code[10])
    var
        CompanyInformation: Record "Company Information";
    begin
        if not CompanyInformation.Get() then
            exit;
        if not CompanyInformation."Bank Account Format Check CZL" then begin
            CreateBankAccountFormatCheckNotification();
            exit;
        end;
        if (CountryRegionCode = '') or (CompanyInformation."Country/Region Code" = CountryRegionCode) then
            CheckBankAccountNo(BankAccountNo, true);
    end;

    procedure CreateBankAccountFormatCheckNotification()
    var
        BankAccountFormatCheckNotification: Notification;
        BankAccountFormatCheckDisabledLbl: Label 'Bank Account Format Check is disabled.';
        EnableLbl: Label 'Enable';
    begin
        BankAccountFormatCheckNotification.Message := BankAccountFormatCheckDisabledLbl;
        BankAccountFormatCheckNotification.Scope := NotificationScope::LocalScope;
        BankAccountFormatCheckNotification.AddAction(EnableLbl, Codeunit::"Bank Operations Functions CZL", 'EnableBankAccountFormatCheck');
        BankAccountFormatCheckNotification.Send();
    end;

    procedure EnableBankAccountFormatCheck(BankAccountFormatCheckNotification: Notification)
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation."Bank Account Format Check CZL" := true;
        CompanyInformation.Modify(true);
    end;

    procedure CheckBankAccountNo(BankAccountNo: Text[30]; ShowErrorMessages: Boolean): Boolean
    var
        HasErrors: Boolean;
    begin
        if BankAccountNo = '' then
            exit(true);
        ClearErrorMessageLog();

        if not HasBankAccountNoValidCharacters(BankAccountNo) then
            LogErrorMessage(StrSubstNo(InvalidCharactersErr, GetInvalidCharactersFromBankAccountNo(BankAccountNo)));
        if StrLen(BankAccountNo) > 22 then
            LogErrorMessage(BankAccountNoTooLongErr);
        if StrLen(BankAccountNo) < 7 then
            LogErrorMessage(BankAccountNoTooShortErr);

        CheckBankCode(BankAccountNo);
        CheckBankAccountIdentification(BankAccountNo);
        CheckBankAccountPrefix(BankAccountNo);

        HasErrors := TempErrorMessage.HasErrors(ShowErrorMessages);
        if ShowErrorMessages then
            TempErrorMessage.ShowErrorMessages(true);

        exit(not HasErrors);
    end;

    local procedure ClearErrorMessageLog()
    begin
        TempErrorMessage.ClearLog();
    end;

    local procedure LogErrorMessage(NewDescription: Text)
    begin
        TempErrorMessage.LogSimpleMessage(TempErrorMessage."Message Type"::Error, NewDescription);
    end;

    procedure HasBankAccountNoValidCharacters(BankAccountNo: Text[30]): Boolean
    begin
        exit(GetInvalidCharactersFromBankAccountNo(BankAccountNo) = '');
    end;

    procedure GetInvalidCharactersFromBankAccountNo(BankAccountNo: Text[30]): Text
    begin
        exit(DelChr(BankAccountNo, '=', GetValidCharactersForBankAccountNo()));
    end;

    procedure GetValidCharactersForBankAccountNo(): Text
    begin
        exit('0123456789-/');
    end;

    local procedure CheckBankCode(BankAccountNo: Text[30])
    var
        BankCode: Text;
        SlashPosition: Integer;
    begin
        SlashPosition := StrPos(BankAccountNo, '/');
        if SlashPosition = 0 then begin
            LogErrorMessage(BankCodeSlashMissingErr);
            exit;
        end;

        BankCode := CopyStr(BankAccountNo, SlashPosition + 1);

        if StrLen(BankCode) > 4 then
            LogErrorMessage(BankCodeTooLongErr);

        if StrLen(BankCode) < 4 then
            LogErrorMessage(BankCodeTooShortErr);
    end;

    local procedure CheckBankAccountIdentification(BankAccountNo: Text[30])
    var
        BankAccountIdentification: Text;
        SlashPosition: Integer;
        HyphenPosition: Integer;
    begin
        SlashPosition := StrPos(BankAccountNo, '/');
        HyphenPosition := StrPos(BankAccountNo, '-');

        if SlashPosition = 0 then
            SlashPosition := StrLen(BankAccountNo) + 1;

        BankAccountIdentification := CopyStr(BankAccountNo, 1, SlashPosition - 1);
        BankAccountIdentification := CopyStr(BankAccountIdentification, HyphenPosition + 1);

        if StrLen(BankAccountIdentification) > 10 then
            LogErrorMessage(IdentificationTooLongErr);

        if StrLen(BankAccountIdentification) < 2 then
            LogErrorMessage(IdentificationTooShortErr);

        if not CheckModulo(BankAccountIdentification) then
            LogErrorMessage(IdentificationIncorrectChecksumErr);

        if DelChr(BankAccountIdentification, '=', '0') = '' then
            LogErrorMessage(IdentificationNonZeroDigitsErr);
    end;

    local procedure CheckBankAccountPrefix(BankAccountNo: Text[30])
    var
        BankAccountPrefix: Text;
        HyphenPosition: Integer;
    begin
        HyphenPosition := StrPos(BankAccountNo, '-');
        if HyphenPosition = 0 then
            exit;

        BankAccountPrefix := CopyStr(BankAccountNo, 1, HyphenPosition - 1);

        if StrLen(BankAccountPrefix) = 0 then
            LogErrorMessage(FirstHyphenErr);

        if StrLen(BankAccountPrefix) > 6 then
            LogErrorMessage(PrefixTooLongErr);

        if not CheckModulo(BankAccountPrefix) then
            LogErrorMessage(PrefixIncorrectChecksumErr);
    end;

    local procedure CheckModulo(Input: Text): Boolean
    begin
        exit(Modulo(Input) = 0);
    end;

    local procedure Modulo(Input: Text): Integer
    var
        OutputSum: Integer;
    begin
        while StrLen(Input) < 10 do
            Input := '0' + Input;

        OutputSum :=
          (Input[1] - '0') * 6 +
          (Input[2] - '0') * 3 +
          (Input[3] - '0') * 7 +
          (Input[4] - '0') * 9 +
          (Input[5] - '0') * 10 +
          (Input[6] - '0') * 5 +
          (Input[7] - '0') * 8 +
          (Input[8] - '0') * 4 +
          (Input[9] - '0') * 2 +
          (Input[10] - '0') * 1;

        exit(OutputSum mod 11);
    end;
}
