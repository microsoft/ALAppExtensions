// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

report 31009 "Create VAT Return Period CZL"
{
    Caption = 'Create VAT Return Period';
    ProcessingOnly = true;

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
                    field(StartDateField; StartDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Start Date';
                        ToolTip = 'Specifies the start date of the VAT Return Period.';
                    }
                    field(NoOfPeriodsField; NoOfPeriods)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'No. of Periods';
                        ToolTip = 'Specifies the number of newly generated periods.';
                    }
                    field(PeriodLengthField; PeriodLength)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Period Length';
                        ToolTip = 'Specifies the length of one period. Enter formula 1M or 1Q.';
                    }
                    field(CalculateDueDateField; CalculateDueDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Calculate Due Date';
                        ToolTip = 'Specifies formula for calculate maturity of VAT Return Period, for example 25D.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            NoOfPeriods := 12;
            Evaluate(PeriodLength, '<1M>');
            Evaluate(CalculateDueDate, '<+25D>');
            StartDate := FindLastPeriodStartDate();
        end;
    }

    trigger OnPreReport()
    var
        VATReturnPeriod: Record "VAT Return Period";
    begin
        if StartDate = 0D then
            Error(StartDateErr);

        FirstPeriodStartDate := FindFirstPeriodStartDate();
        LastPeriodStartDate := FindLastPeriodStartDate();

        for i := 1 to NoOfPeriods do begin
            if StartDate <= FirstPeriodStartDate then
                exit;

            if FirstPeriodStartDate <> 0D then
                if (StartDate >= FirstPeriodStartDate) and (StartDate < LastPeriodStartDate) then
                    Error(OnlyOnePeriodErr);

            Clear(VATReturnPeriod);
            VATReturnPeriod."Start Date" := StartDate;
            VATReturnPeriod."End Date" := CalcDate(PeriodLength, StartDate) - 1;
            VATReturnPeriod."Due Date" := CalcDate(CalculateDueDate, VATReturnPeriod."End Date");
            if not VATReturnPeriod.IsDuplicatePeriod() then
                VATReturnPeriod.Insert(true);
            StartDate := CalcDate(PeriodLength, StartDate);
        end;
    end;

    var
        PeriodLength: DateFormula;
        CalculateDueDate: DateFormula;
        NoOfPeriods: Integer;
        StartDate: Date;
        FirstPeriodStartDate: Date;
        LastPeriodStartDate: Date;
        i: Integer;
        StartDateErr: Label 'Start Date must be specified.';
        OnlyOnePeriodErr: Label 'It is only possible to create new VAT years before or after the existing ones.';

    local procedure FindFirstPeriodStartDate(): Date
    var
        VATReturnPeriod: Record "VAT Return Period";
    begin
        VATReturnPeriod.SetCurrentKey("Start Date");
        if VATReturnPeriod.FindFirst() then
            exit(VATReturnPeriod."Start Date");
        exit(0D);
    end;

    local procedure FindLastPeriodStartDate(): Date
    var
        VATReturnPeriod: Record "VAT Return Period";
    begin
        VATReturnPeriod.SetCurrentKey("Start Date");
        if VATReturnPeriod.FindLast() then
            exit(VATReturnPeriod."Start Date");
        exit(0D);
    end;
}