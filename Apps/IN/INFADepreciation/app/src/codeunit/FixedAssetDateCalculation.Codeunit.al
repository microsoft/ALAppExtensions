// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.FADepreciation;

using Microsoft.Foundation.Period;

codeunit 18634 "Fixed Asset Date Calculation"
{
    procedure GetFiscalYearStartDate(EndingDate: Date): Date
    var
        AccountingPeriod: Record "Accounting Period";
        DateErr: Label 'It was not possible to find a %1 in %2.', Comment = '%1 = Field Caption , %2 Table Caption';
    begin
        AccountingPeriod.SetRange("New Fiscal Year", true);
        AccountingPeriod.SetRange("Starting Date", 0D, EndingDate);
        if AccountingPeriod.FindLast() then
            exit(AccountingPeriod."Starting Date");

        Error(DateErr, AccountingPeriod.FieldCaption(AccountingPeriod."Starting Date"), AccountingPeriod.TableCaption);
    end;

    procedure GetFiscalYearEndDate(EndingDate: Date): Date
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        AccountingPeriod.SetRange("New Fiscal Year", true);
        AccountingPeriod.SetRange("Starting Date", 0D, EndingDate);
        if AccountingPeriod.FindLast() then begin
            AccountingPeriod.SetRange("Starting Date");
            if AccountingPeriod.Find('>') then
                exit(AccountingPeriod."Starting Date" - 1);
        end;
    end;

    procedure GetDaysInFiscalYear(EndDate: Date): Integer
    begin
        exit(1 + (GetFiscalYearEndDate(EndDate) - GetFiscalYearStartDate(EndDate)));
    end;

    procedure GetFiscalYearStartDateInc(EndingDate: Date): Date
    var
        AccountingPeriod: Record "Accounting Period";
        DateErr: Label 'It was not possible to find a %1 in %2.', Comment = '%1 = Field Caption , %2 Table Caption';
    begin
        AccountingPeriod.SetRange("New Fiscal Year", true);
        AccountingPeriod.SetRange("Starting Date", 0D, EndingDate);
        if AccountingPeriod.FindLast() then
            exit(AccountingPeriod."Starting Date");

        Error(DateErr, AccountingPeriod.FieldCaption("Starting Date"), AccountingPeriod.TableCaption);
    end;

    procedure GetFiscalYearEndDateInc(EndingDate: Date): Date
    var
        AccountingPeriod: Record "Accounting Period";
        DateErr: Label 'It was not possible to find a %1 in %2.', Comment = '%1 = Field Caption , %2 Table Caption';
    begin
        AccountingPeriod.SetRange("New Fiscal Year", true);
        AccountingPeriod.SetRange("Starting Date", 0D, EndingDate);
        if AccountingPeriod.FindLast() then begin
            AccountingPeriod.SetRange("Starting Date");
            if AccountingPeriod.Find('>') then
                exit(AccountingPeriod."Starting Date" - 1);
        end;
        Error(DateErr, AccountingPeriod.FieldCaption("Starting Date"), AccountingPeriod.TableCaption);
    end;

    procedure GetDaysInFiscalYearInc(EndDate: Date): Integer
    begin
        exit(1 + (GetFiscalYearEndDateInc(EndDate) - GetFiscalYearStartDateInc(EndDate)));
    end;
}
