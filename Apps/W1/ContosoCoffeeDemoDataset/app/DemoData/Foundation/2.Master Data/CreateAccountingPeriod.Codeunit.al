// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.DemoTool.Helpers;
using Microsoft.Foundation.Period;

codeunit 5225 "Create Accounting Period"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoUtilities: Codeunit "Contoso Utilities";
        ContosoAccountingPeriod: Codeunit "Contoso Accounting Period";
        StartDate, EndDate, date : Date;
    begin
        StartDate := ContosoUtilities.AdjustDate(19020101D);
        EndDate := ContosoUtilities.AdjustDate(19041201D);
        date := StartDate;

        while date <= EndDate do begin
            if IsStartOfTheYear(date) then
                ContosoAccountingPeriod.InsertAccountingPeriod(date, true)
            else
                ContosoAccountingPeriod.InsertAccountingPeriod(date, false);

            date := CalcDate('<1M>', date);
        end;

        CloseFiscalYear(StartDate, CalcDate('<-2Y>', EndDate));
    end;

    local procedure IsStartOfTheYear(date: Date): Boolean
    begin
        if (Date2DMY(date, 1) = 1) and (Date2DMY(date, 2) = 1) then
            exit(true)
        else
            exit(false);
    end;

    local procedure CloseFiscalYear(FiscalYearStartDate: Date; FiscalYearEndDate: Date)
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        AccountingPeriod.SetRange("Starting Date", FiscalYearStartDate, FiscalYearEndDate);
        AccountingPeriod.ModifyAll(Closed, true);

        AccountingPeriod.SetRange("Starting Date", FiscalYearStartDate, CalcDate('<1M>', FiscalYearEndDate));
        AccountingPeriod.ModifyAll("Date Locked", true);
    end;
}
