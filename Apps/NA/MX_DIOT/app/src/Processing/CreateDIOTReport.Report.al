// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Telemetry;
using System.Utilities;

report 27030 "Create DIOT Report"
{
    UsageCategory = Administration;
    Caption = 'Create DIOT Report';
    ApplicationArea = Basic, Suite;
    ProcessingOnly = true;

    dataset
    {
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group("Report Dates")
                {
                    field(StartingDate; StartingDateVariable)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Starting Date';
                        ToolTip = 'Starting Date for the report';
                    }
                    field(EndingDate; EndingDateVariable)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Ending Date';
                        ToolTip = 'Ending Date for the report';

                        trigger OnValidate()
                        begin
                            if EndingDateVariable < StartingDateVariable then
                                Error(EndingDateBeforeStartinDateErr);
                        end;
                    }
                }
            }
        }
    }

    var
        TempDIOTReportBuffer: Record "DIOT Report Buffer" temporary;
        TempDIOTReportVendorBuffer: Record "DIOT Report Vendor Buffer" temporary;
        TempErrorMessage: Record "Error Message" temporary;
        DIOTDataMgmt: Codeunit "DIOT Data Management";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        StartingDateVariable: Date;
        EndingDateVariable: Date;
        BlankStartingDateErr: Label 'Please provide a starting date.';
        BlankEndingDateErr: Label 'Please provide an ending date.';
        EndingDateBeforeStartinDateErr: Label 'Ending date cannot be before starting date.';
        MXDIOTTok: Label 'MX Setup and Generate DIOT Report', Locked = true;
        RunAssistedSetupMsg: Label 'You must complete Assisted Setup for DIOT before running this report. \\ Do you want to open assisted setup now?';

    trigger OnInitReport()
    var
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if not DIOTDataMgmt.GetAssistedSetupComplete() then begin
            if ConfirmManagement.GetResponseOrDefault(RunAssistedSetupMsg, true) then
                Page.Run(Page::"DIOT Setup Wizard");
            CurrReport.Quit();
        end;
    end;

    trigger OnPreReport()
    begin
        if StartingDateVariable = 0D then
            Error(BlankStartingDateErr);
        if EndingDateVariable = 0D then
            Error(BlankEndingDateErr);
    end;

    trigger OnPostReport()
    begin
        FeatureTelemetry.LogUptake('0000HQN', MXDIOTTok, Enum::"Feature Uptake Status"::"Used");
        DIOTDataMgmt.CollectDIOTDataSet(TempDIOTReportBuffer, TempDIOTReportVendorBuffer, TempErrorMessage, StartingDateVariable, EndingDateVariable);
        if TempErrorMessage.HasErrors(false) then
            TempErrorMessage.ShowErrors()
        else
            DIOTDataMgmt.WriteDIOTFile(TempDIOTReportBuffer, TempDIOTReportVendorBuffer);
        FeatureTelemetry.LogUsage('0000HQO', MXDIOTTok, 'MX DIOT Reports Generated');
    end;

}
