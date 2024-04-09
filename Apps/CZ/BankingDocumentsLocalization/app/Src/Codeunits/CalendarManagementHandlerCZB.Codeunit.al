// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.BankAccount;
using Microsoft.Foundation.Calendar;

codeunit 31389 "CalendarManagement Handler CZB"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calendar Management", 'OnFillSourceRec', '', false, false)]
    local procedure BankAccountOnFillSourceRec(RecRef: RecordRef; var CustomCalendarChange: Record "Customized Calendar Change")
    begin
        if RecRef.RecordId.TableNo = Database::"Bank Account" then
            SetSourceBankAccount(RecRef, CustomCalendarChange);
    end;

    local procedure SetSourceBankAccount(RecordRef: RecordRef; var CustomizedCalendarChange: Record "Customized Calendar Change")
    var
        BankAccount: Record "Bank Account";
    begin
        RecordRef.SetTable(BankAccount);
        CustomizedCalendarChange.SetSource(CustomizedCalendarChange."Source Type"::"Bank Account CZB", '', '', BankAccount."Base Calendar Code CZB");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calendar Management", 'OnCreateWhereUsedEntries', '', false, false)]
    local procedure BankAccountOnCreateWhereUsedEntries(BaseCalendarCode: Code[10])
    begin
        AddWhereUsedBaseCalendarBankAccount(BaseCalendarCode);
    end;

    local procedure AddWhereUsedBaseCalendarBankAccount(BaseCalendarCode: Code[10])
    var
        BankAccount: Record "Bank Account";
        WhereUsedBaseCalendar: Record "Where Used Base Calendar";
        CalendarManagement: Codeunit "Calendar Management";
    begin
        BankAccount.Reset();
        BankAccount.SetRange("Base Calendar Code CZB", BaseCalendarCode);
        if BankAccount.FindSet() then
            repeat
                WhereUsedBaseCalendar.Init();
                WhereUsedBaseCalendar."Base Calendar Code" := BaseCalendarCode;
                WhereUsedBaseCalendar."Source Type" := WhereUsedBaseCalendar."Source Type"::"Bank Account CZB";
                WhereUsedBaseCalendar."Source Code" := BankAccount."No.";
                WhereUsedBaseCalendar."Source Name" := CopyStr(BankAccount.Name, 1, MaxStrLen(WhereUsedBaseCalendar."Source Name"));
                WhereUsedBaseCalendar."Customized Changes Exist" := CalendarManagement.CustomizedChangesExist(BankAccount);
                WhereUsedBaseCalendar.Insert();
            until BankAccount.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calendar Management", 'OnCalcDateBOCOnAfterGetCalendarCodes', '', false, false)]
    local procedure CalcCalendarCodeOnCalcDateBOCOnAfterGetCalendarCodes(var CustomCalendarChange: array[2] of Record "Customized Calendar Change")
    begin
        CalcCalendarCode(CustomCalendarChange[1]);
        CalcCalendarCode(CustomCalendarChange[2]);
    end;

    local procedure CalcCalendarCode(var CustomizedCalendarChange: Record "Customized Calendar Change")
    var
        BankAccount: Record "Bank Account";
    begin
        if CustomizedCalendarChange."Source Type" = CustomizedCalendarChange."Source Type"::"Bank Account CZB" then
            if BankAccount.Get(CustomizedCalendarChange."Source Code") then
                CustomizedCalendarChange."Base Calendar Code" := BankAccount."Base Calendar Code CZB";
    end;
}
