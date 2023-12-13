// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Utilities;

report 11792 "Create VAT Period CZL"
{
    Caption = 'Create VAT Period';
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
                    field(VATPeriodStartDateCZL; VATPeriodStartDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Starting Date';
                        ToolTip = 'Specifies the first date of the VAT year.';
                    }
                    field(NoOfPeriodsCZL; NoOfPeriods)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'No. of Periods';
                        ToolTip = 'Specifies the number of VAT periods.';
                    }
                    field(PeriodLengthCZL; PeriodLength)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Period Length';
                        ToolTip = 'Specifies the length of the VAT period.';
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
            if VATPeriodCZL.FindLast() then
                VATPeriodStartDate := VATPeriodCZL."Starting Date";
        end;
    }
    trigger OnPreReport()
    begin
        VATPeriodCZL."Starting Date" := VATPeriodStartDate;
        VATPeriodCZL.TestField("Starting Date");

        if VATPeriodCZL.FindFirst() then begin
            FirstPeriodStartDate := VATPeriodCZL."Starting Date";
            if VATPeriodCZL.FindLast() then
                LastPeriodStartDate := VATPeriodCZL."Starting Date";
        end else
            if not ConfirmManagement.GetResponse(CreateVatYearQst, false) then
                exit;

        for i := 1 to NoOfPeriods + 1 do begin
            if (VATPeriodStartDate <= FirstPeriodStartDate) and (i = NoOfPeriods + 1) then
                exit;

            if FirstPeriodStartDate <> 0D then
                if (VATPeriodStartDate >= FirstPeriodStartDate) and (VATPeriodStartDate < LastPeriodStartDate) then
                    Error(OnlyOnePeriodErr);
            VATPeriodCZL.Init();
            VATPeriodCZL."Starting Date" := VATPeriodStartDate;
            VATPeriodCZL.Validate("Starting Date");
            if (i = 1) or (i = NoOfPeriods + 1) then
                VATPeriodCZL."New VAT Year" := true;
            if not VATPeriodCZL.Find('=') then
                VATPeriodCZL.Insert();
            VATPeriodStartDate := CalcDate(PeriodLength, VATPeriodStartDate);
        end;
    end;

    var
        VATPeriodCZL: Record "VAT Period CZL";
        ConfirmManagement: Codeunit "Confirm Management";
        PeriodLength: DateFormula;
        NoOfPeriods: Integer;
        VATPeriodStartDate: Date;
        FirstPeriodStartDate: Date;
        LastPeriodStartDate: Date;
        i: Integer;
        CreateVatYearQst: Label 'Once you create the new VAT year you cannot change its starting date.\\Do you want to create the VAT year?';
        OnlyOnePeriodErr: Label 'It is only possible to create new VAT years before or after the existing ones.';
}
