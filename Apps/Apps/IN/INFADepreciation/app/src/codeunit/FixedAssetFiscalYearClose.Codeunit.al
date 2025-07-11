// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.FADepreciation;

codeunit 18635 "Fixed Asset Fiscal Year-Close"
{
    TableNo = "FA Accounting Period Inc. Tax";

    trigger OnRun()
    begin
        AccountingPeriod.Copy(Rec);
        Code();
        Rec := AccountingPeriod;
    end;

    var
        AccountingPeriod: Record "FA Accounting Period Inc. Tax";

    local procedure Code()
    var
        ClosedAccountingPeriod: Record "FA Accounting Period Inc. Tax";
        CopyClosedAccountingPeriod: Record "FA Accounting Period Inc. Tax";
        FiscalYearStartDate: Date;
        FiscalYearEndDate: Date;
        NewFiscalYrErr: Label 'You must create a new fiscal year before you can close the old year.';
        CloseFiscalYrErr: Label 'This function closes the fiscal year from %1 to %2. ', Comment = '%1 = Start Date, %2 End Date';
        ClosedFiscalYrErr: Label 'Once the fiscal year is closed it cannot be opened again, and the periods in the fiscal year cannot be changed.\\';
        ConfirmToCloseFiscalYrQst: Label 'Do you want to close the fiscal year?';
    begin
        ClosedAccountingPeriod.SetRange(Closed, false);
        ClosedAccountingPeriod.FindFirst();

        FiscalYearStartDate := ClosedAccountingPeriod."Starting Date";
        AccountingPeriod := ClosedAccountingPeriod;
        AccountingPeriod.TestField("New Fiscal Year", true);

        ClosedAccountingPeriod.SetRange("New Fiscal Year", true);
        if ClosedAccountingPeriod.Find('>') then begin
            FiscalYearEndDate := CalcDate('<-1D>', ClosedAccountingPeriod."Starting Date");

            CopyClosedAccountingPeriod := ClosedAccountingPeriod;
            ClosedAccountingPeriod.SetRange("New Fiscal Year");
            ClosedAccountingPeriod.Find('<');
        end else
            Error(NewFiscalYrErr);

        if not Confirm(CloseFiscalYrErr + ClosedFiscalYrErr + ConfirmToCloseFiscalYrQst, false, FiscalYearStartDate, FiscalYearEndDate) then
            exit;

        AccountingPeriod.Reset();
        AccountingPeriod.SetRange("Starting Date", FiscalYearStartDate, ClosedAccountingPeriod."Starting Date");
        AccountingPeriod.ModifyAll(Closed, true);

        AccountingPeriod.SetRange("Starting Date", FiscalYearStartDate, CopyClosedAccountingPeriod."Starting Date");
        AccountingPeriod.ModifyAll("Date Locked", true);
    end;
}
