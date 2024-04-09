// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation;

using Microsoft.Bank;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Enums;
using Microsoft.Foundation.Period;
using System.Globalization;

codeunit 31041 "Company Info Handler CZL"
{
    var
        BankOperationsFunctionsCZL: Codeunit "Bank Operations Functions CZL";

    [EventSubscriber(ObjectType::Table, Database::"Company Information", 'OnBeforeValidateEvent', 'Bank Account No.', false, false)]
    local procedure CheckCzBankAccountNoOnBeforeBankAccountNoValidate(var Rec: Record "Company Information")
    begin
        BankOperationsFunctionsCZL.CheckCzBankAccountNo(Rec."Bank Account No.", Rec."Country/Region Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company Information", 'OnBeforeValidateEvent', 'Country/Region Code', false, false)]
    local procedure CheckCzBankAccountNoOnBeforeCountryRegionCodeValidate(var Rec: Record "Company Information")
    begin
        BankOperationsFunctionsCZL.CheckCzBankAccountNo(Rec."Bank Account No.", Rec."Country/Region Code");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::PeriodPageManagement, 'OnAfterCreatePeriodFormat', '', false, false)]
    local procedure ChangeMonthPeriodOnAfterCreatePeriodFormat(PeriodType: Enum "Analysis Period Type"; Date: Date; var PeriodFormat: Text[10])
    var
        Language: Codeunit Language;
        CSYTok: Label 'CSY', Locked = true;
        JuneFormatStringTok: Label 'čvn <Year4>', Locked = true;
        JulyFormatStringTok: Label 'čvc <Year4>', Locked = true;
    begin
        if PeriodType <> PeriodType::Month then
            exit;

        if Language.GetLanguageCode(GlobalLanguage) = CSYTok then
            case Date2DMY(Date, 2) of
                6:
                    PeriodFormat := Format(Date, 0, JuneFormatStringTok);
                7:
                    PeriodFormat := Format(Date, 0, JulyFormatStringTok);
            end;
    end;
}
