// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Utilities;

report 10034 "Create Transmission IRIS"
{
    ApplicationArea = BasicUS;
    ProcessingOnly = true;

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(PeriodGroup)
                {
                    ShowCaption = false;
                    field(PeriodNoField; PeriodNo)
                    {
                        ApplicationArea = BasicUS;
                        Caption = 'Reporting Period';
                        ToolTip = 'Specifies the period for which the 1099 forms will be submitted.';
                        TableRelation = "IRS Reporting Period"."No.";

                        trigger OnValidate()
                        begin
                            ValidatePeriod(PeriodNo);
                        end;
                    }
                }
            }
        }
    }

    var
        PeriodNo: Text[4];
        FormBoxesNotReportedMsg: Text;
        FormBoxNotReported: Text;
        FormBoxNotReportedList: List of [Text];
        FormBoxesNotReportedTxt: Label 'The form box(es) below will not be reported to IRS. Do you want to continue?\';
        TransmissionExistsQst: Label 'A transmission for the period %1 already exists. Do you want to replace it?', Comment = '%1 - period year, e.g. 2024';
        PeriodNoErr: Label 'The period %1 was not found. Make sure it exists on the IRS Reporting Periods page.', Comment = '%1 - period year, e.g. 2024';

    trigger OnPostReport()
    var
        Transmission: Record "Transmission IRIS";
        DataCheckIRIS: Codeunit "Data Check IRIS";
        IRSFormsFacade: Codeunit "IRS Forms Facade";
        ConfirmMgt: Codeunit "Confirm Management";
    begin
        Transmission.SetRange("Period No.", PeriodNo);
        if Transmission.FindFirst() then
            if not ConfirmMgt.GetResponseOrDefault(StrSubstNo(TransmissionExistsQst, PeriodNo), false) then
                Error('');

        FormBoxNotReportedList := DataCheckIRIS.GetFormBoxListWithEmptyAmtXmlElemName(PeriodNo);
        if FormBoxNotReportedList.Count > 0 then begin
            FormBoxesNotReportedMsg := FormBoxesNotReportedTxt;
            foreach FormBoxNotReported in FormBoxNotReportedList do
                FormBoxesNotReportedMsg += '\' + FormBoxNotReported;
            if not ConfirmMgt.GetResponseOrDefault(FormBoxesNotReportedMsg, false) then
                Error('');
        end;

        Transmission.DeleteAll(true);
        IRSFormsFacade.CreateTransmission(Transmission, PeriodNo);
    end;

    internal procedure SetPeriod(NewPeriodNo: Text[4])
    begin
        ValidatePeriod(NewPeriodNo);
        PeriodNo := NewPeriodNo;
    end;

    local procedure ValidatePeriod(NewPeriodNo: Text[4])
    var
        IRSReportingPeriod: Record "IRS Reporting Period";
    begin
        if not IRSReportingPeriod.Get(NewPeriodNo) then
            Error(PeriodNoErr, NewPeriodNo);
    end;
}
