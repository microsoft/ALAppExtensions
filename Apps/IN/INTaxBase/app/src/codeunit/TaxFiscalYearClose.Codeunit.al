// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

codeunit 18545 "Tax Fiscal Year Close"
{
    TableNo = "Tax Accounting Period";

    trigger OnRun()
    begin
        TaxAccountingPeriod.Copy(Rec);
        Code();
        Rec := TaxAccountingPeriod;
    end;

    var
        TaxAccountingPeriod: Record "Tax Accounting Period";

    local procedure Code()
    var
        ClosedTaxAccountingPeriod: Record "Tax Accounting Period";
        LockedTaxAccountingPeriod: Record "Tax Accounting Period";
        FiscalYearStartDate: Date;
        FiscalYearEndDate: Date;
        CloseTheOldYearErr: Label 'You must create a new fiscal year before you can close the old year.';
        ClosesTheFiscalYearLbl: Label 'This function closes the fiscal year from %1 to %2 for Tax Type Code %3.', Comment = '%1=Fiscal year from., %2=Fiscal year to., %3=Tax Type Code.';
        FiscalYearCannotBeChangedLbl: Label 'Once the fiscal year is closed it cannot be opened again, and the periods in the fiscal year cannot be changed.\\';
        CloseTheFiscalYearQst: Label 'Do you want to close the fiscal year for Tax Type Code %3?', Comment = '%3 Tax Type Code.';
    begin
        ClosedTaxAccountingPeriod.SetRange(Closed, false);
        ClosedTaxAccountingPeriod.SetRange("Tax Type Code", TaxAccountingPeriod."Tax Type Code");
        ClosedTaxAccountingPeriod.FindFirst();

        FiscalYearStartDate := ClosedTaxAccountingPeriod."Starting Date";
        TaxAccountingPeriod := ClosedTaxAccountingPeriod;
        TaxAccountingPeriod.TestField("New Fiscal Year", true);

        ClosedTaxAccountingPeriod.SetRange("New Fiscal Year", true);
        ClosedTaxAccountingPeriod.SetRange("Tax Type Code", TaxAccountingPeriod."Tax Type Code");
        if ClosedTaxAccountingPeriod.Find('>') then begin
            FiscalYearEndDate := CalcDate('<-1D>', ClosedTaxAccountingPeriod."Starting Date");
            LockedTaxAccountingPeriod := ClosedTaxAccountingPeriod;
            ClosedTaxAccountingPeriod.SetRange("New Fiscal Year");
            ClosedTaxAccountingPeriod.SetRange("Tax Type Code", TaxAccountingPeriod."Tax Type Code");
            ClosedTaxAccountingPeriod.Find('<')
        end else
            Error(CloseTheOldYearErr);

        if not
           Confirm(
             ClosesTheFiscalYearLbl +
             FiscalYearCannotBeChangedLbl +
             CloseTheFiscalYearQst, false,
             FiscalYearStartDate, FiscalYearEndDate, TaxAccountingPeriod."Tax Type Code")
        then
            exit;

        TaxAccountingPeriod.Reset();
        TaxAccountingPeriod.SetRange("Starting Date", FiscalYearStartDate, ClosedTaxAccountingPeriod."Starting Date");
        TaxAccountingPeriod.SetRange("Tax Type Code", ClosedTaxAccountingPeriod."Tax Type Code");
        TaxAccountingPeriod.ModifyAll(Closed, true);

        TaxAccountingPeriod.SetRange("Starting Date", FiscalYearStartDate, LockedTaxAccountingPeriod."Starting Date");
        TaxAccountingPeriod.SetRange("Tax Type Code", LockedTaxAccountingPeriod."Tax Type Code");
        TaxAccountingPeriod.ModifyAll("Date Locked", true);
    end;
}
