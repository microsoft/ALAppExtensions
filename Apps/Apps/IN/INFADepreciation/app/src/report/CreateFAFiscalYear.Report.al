// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.FADepreciation;

report 18632 "Create FA Fiscal Year"
{
    Caption = 'Create Fixed Asset Fiscal Year';
    ProcessingOnly = true;

    dataset
    {
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(StartingDate; FiscalYearStartDate)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Starting Date';
                        ToolTip = 'Specifies the date from which the report or batch job processes information.';
                    }
                    field(TotalPeriods; NoOfPeriods)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'No. of Periods';
                        ToolTip = 'Specifies how many accounting periods to include.';
                    }
                    field(PeriodInterval; PeriodLength)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Period Length';
                        ToolTip = 'Specifies the period for which data is shown in the report. For example, enter "1M" for one month, "30D" for thirty days, "3Q" for three quarters, or "5Y" for five years.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            if NoOfPeriods = 0 then begin
                NoOfPeriods := 12;
                Evaluate(PeriodLength, '<1M>');
            end;

            if FaAccountingPeriod.FindLast() then
                FiscalYearStartDate := FaAccountingPeriod."Starting Date";
        end;
    }

    trigger OnPreReport()
    begin
        FAAccountingPeriod."Starting Date" := FiscalYearStartDate;
        FAAccountingPeriod.TestField("Starting Date");

        if FAAccountingPeriod.Find('-') then begin
            FirstPeriodStartDate := FAAccountingPeriod."Starting Date";
            FirstPeriodLocked := FAAccountingPeriod."Date Locked";

            if (FiscalYearStartDate < FirstPeriodStartDate) and FirstPeriodLocked then
                if not Confirm(CreateAndCloseQst) then
                    exit;

            if FAAccountingPeriod.FindLast() then
                LastPeriodStartDate := FAAccountingPeriod."Starting Date";
        end else
            if not Confirm(NewPeriodCreationQst) then
                exit;

        for i := 1 to NoOfPeriods + 1 do begin
            if (FiscalYearStartDate <= FirstPeriodStartDate) and (i = NoOfPeriods + 1) then
                exit;

            if FirstPeriodStartDate <> 0D then
                if (FiscalYearStartDate >= FirstPeriodStartDate) and (FiscalYearStartDate < LastPeriodStartDate) then
                    Error(NewPeriofCreationErr);

            FAAccountingPeriod.Init();
            FAAccountingPeriod."Starting Date" := FiscalYearStartDate;
            FAAccountingPeriod.Validate("Starting Date");

            if (i = 1) or (i = NoOfPeriods + 1) then
                FAAccountingPeriod."New Fiscal Year" := true;

            if (FirstPeriodStartDate = 0D) and (i = 1) then
                FAAccountingPeriod."Date Locked" := true;

            if (FAAccountingPeriod."Starting Date" < FirstPeriodStartDate) and FirstPeriodLocked then begin
                FAAccountingPeriod.Closed := true;
                FAAccountingPeriod."Date Locked" := true;
            end;

            if not FAAccountingPeriod.Find('=') then
                FAAccountingPeriod.Insert();

            FiscalYearStartDate := CalcDate(PeriodLength, FiscalYearStartDate);
        end;
    end;

    var
        FAAccountingPeriod: Record "FA Accounting Period Inc. Tax";
        PeriodLength: DateFormula;
        LastPeriodStartDate: Date;
        NoOfPeriods: Integer;
        FiscalYearStartDate: Date;
        FirstPeriodStartDate: Date;
        FirstPeriodLocked: Boolean;
        i: Integer;
        CreateAndCloseQst: Label 'The new fiscal year begins before an existing fiscal year, so the new year will be closed automatically.\\Do you want to create and close the fiscal year?';
        NewPeriodCreationQst: Label 'Once you create the new fiscal year you cannot change its starting date.\\Do you want to create the fiscal year?';
        NewPeriofCreationErr: Label 'It is only possible to create new fiscal years before or after the existing ones.';
}
