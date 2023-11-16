// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank;

codeunit 31346 "Bank Operations Functions CZB"
{
    var
        BankOperationsFunctionsCZL: Codeunit "Bank Operations Functions CZL";

    procedure GetBankCode(BankAccountNo: Text[30]): Text[4]
    var
        SlashPosition: Integer;
    begin
        SlashPosition := StrPos(BankAccountNo, '/');
        if SlashPosition <> 0 then
            exit(CopyStr(BankAccountNo, SlashPosition + 1, 4));
    end;

    procedure IBANBankCode(IBAN: Code[50]): Code[10]
    begin
        case CopyStr(IBAN, 1, 2) of
            'CZ':
                begin
                    if CopyStr(IBAN, 5, 1) = '' then
                        exit(CopyStr(IBAN, 6, 4));
                    exit(CopyStr(IBAN, 5, 4));
                end;
        end;
        exit('');
    end;

    procedure CheckBankAccountNoCharacters(BankAccountNo: Text[30])
    var
        InvalidCharactersErr: Label 'Bank account no. contains invalid characters "%1".', Comment = '%1 = invalid characters';
    begin
        if not BankOperationsFunctionsCZL.HasBankAccountNoValidCharacters(BankAccountNo) then
            Error(InvalidCharactersErr, BankOperationsFunctionsCZL.GetInvalidCharactersFromBankAccountNo(BankAccountNo));
    end;

    procedure GetValidCharactersForVariableSymbol(): Text
    begin
        exit('0123456789');
    end;

    procedure GetValidCharactersForConstantSymbol(): Text
    begin
        exit('0123456789');
    end;

    procedure GetValidCharactersForSpecificSymbol(): Text
    begin
        exit('0123456789');
    end;
}
