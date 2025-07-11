// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

report 10037 "IRS 1099 Copy Setup From"
{
    ProcessingOnly = true;
    ApplicationArea = BasicUS;

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(FromPeriod; FromPeriodNo)
                    {
                        ApplicationArea = BasicUS;
                        Caption = 'From Period';
                        ToolTip = 'Specifies the period to copy from';
                        TableRelation = "IRS Reporting Period";

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            IRSReportingPeriod: Record "IRS Reporting Period";
                            IRSReportingPeriods: Page "IRS Reporting Periods";
                        begin
                            IRSReportingPeriod.SetFilter("No.", '<>%1', ToPeriodNo);
                            IRSReportingPeriods.SetTableView(IRSReportingPeriod);
                            IRSReportingPeriods.LookupMode := true;
                            if IRSReportingPeriods.RunModal() = Action::LookupOK then begin
                                IRSReportingPeriods.GetRecord(IRSReportingPeriod);
                                FromPeriodNo := IRSReportingPeriod."No.";
                            end;
                        end;
                    }
                }
            }
        }
    }

    protected var
        ToPeriodNo: Code[20];
        FromPeriodNo: Code[20];


    trigger OnPostReport()
    var
        IRSReportingPeriod: Codeunit "IRS Reporting Period";
    begin
        IRSReportingPeriod.CopyReportingPeriodSetup(FromPeriodNo, ToPeriodNo);
    end;

    procedure InitializeRequest(NewToPeriodNo: Code[20]);
    begin
        ToPeriodNo := NewToPeriodNo;
    end;
}
