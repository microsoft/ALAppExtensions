#if not CLEAN28
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Telemetry;

report 10063 "Upgrade IRS 1099 Data"
{
    Caption = 'Upgrade IRS 1099 Data';
    UsageCategory = Administration;
    ApplicationArea = BasicUS;
    ProcessingOnly = true;
    ObsoleteState = Pending;
    ObsoleteReason = 'This report will be removed in a future release as the IRS 1099 data upgrade is no longer needed.';
    ObsoleteTag = '28.0';

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
                    field(IRSReportingPeriodCodeField; IRSReportingPeriodCode)
                    {
                        ApplicationArea = BasicUS;
                        Caption = 'Reporting Period Code';
                        ToolTip = 'Specifies the code of the tax reporting period to upgrade the data from the old IRS 1099 feature to the new one.';
                        TableRelation = "IRS Reporting Period";
                        ShowMandatory = true;
                    }
                }
            }

        }
    }

    var
        IRSReportingPeriodCode: Code[20];

    trigger OnPostReport()
    var
        IRSReportingPeriod: Record "IRS Reporting Period";
        IRS1099FormBox: Record "IRS 1099 Form Box";
        IRS1099TransferFromBaseApp: Codeunit "IRS 1099 Transfer From BaseApp";
        Telemetry: Codeunit Telemetry;
        IRSReportingPeriodCodeNotSpecifiedErr: Label 'Reporting Period Code must be specified.';
        SetupTransferLbl: Label 'Setting up data transfer for IRS Reporting Period: %1. Starting Date = %2, Ending Date = %3', Comment = '%1 = code, %2 = starting date, %3 = ending date';
        TransferingDataLbl: Label 'Starting data transfer for IRS Reporting Period: %1. Starting Date = %2, Ending Date = %3', Comment = '%1 = code, %2 = starting date, %3 = ending date';
    begin
        if IRSReportingPeriodCode = '' then
            error(IRSReportingPeriodCodeNotSpecifiedErr);
        IRSReportingPeriod.Get(IRSReportingPeriodCode);
        if IRS1099FormBox.IsEmpty() then begin
            Telemetry.LogMessage('0000Q1X', StrSubstNo(SetupTransferLbl, IRSReportingPeriod."No.", IRSReportingPeriod."Starting Date", IRSReportingPeriod."Ending Date"), Verbosity::Normal, DataClassification::SystemMetadata);
            IRS1099TransferFromBaseApp.TransferIRS1099Setup(IRSReportingPeriod, Date2DMY(IRSReportingPeriod."Starting Date", 3));
        end;
        Telemetry.LogMessage('0000PZP', StrSubstNo(TransferingDataLbl, IRSReportingPeriod."No.", IRSReportingPeriod."Starting Date", IRSReportingPeriod."Ending Date"), Verbosity::Normal, DataClassification::SystemMetadata);
        IRS1099TransferFromBaseApp.TransferIRS1099Data(IRSReportingPeriod);
    end;
}
#endif