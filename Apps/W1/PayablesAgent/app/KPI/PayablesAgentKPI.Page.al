// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.PayablesAgent;

using System.Agents;

page 3306 "Payables Agent KPI"
{
    PageType = CardPart;
    ApplicationArea = All;
    SourceTable = Agent;
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(Content)
        {
            cuegroup(Summary)
            {
                ShowCaption = false;
                field(AgentTasksReceived; CountKPI.Get("PA KPI Scenario"::"Agent Tasks Received"))
                {
                    ApplicationArea = All;
                    Caption = 'Emails received';
                    ToolTip = 'Specifies the number of emails received by the agent.';
                }
                field(AgentEDocsFinalizedByAgent; CountKPI.Get("PA KPI Scenario"::"Agent E-Docs Finalized by Agent") + CountKPI.Get("PA KPI Scenario"::"Agent E-Docs Finalized by User"))
                {
                    ApplicationArea = All;
                    Caption = 'Invoices created';
                    ToolTip = 'Specifies the number of tasks finalized by the agent.';
                }
                field(TimeSavedEmails; TimeSavedEmails)
                {
                    ApplicationArea = All;
                    Caption = 'Time saved on emails';
                    ToolTip = 'Specifies the time saved by the agent on emails.';
                    AutoFormatType = 11;
                    AutoFormatExpression = TimeSavedEmailsFormatExpression;
                }
                field(TimeSavedInvoices; TimeSavedInvoices)
                {
                    ApplicationArea = All;
                    Caption = 'Time saved on invoices';
                    ToolTip = 'Specifies the time saved by the agent on invoices.';
                    AutoFormatType = 11;
                    AutoFormatExpression = TimeSavedEmailsFormatExpression;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        i: Integer;
    begin
        foreach i in PAKPIScenario.Ordinals() do begin
            PAKPIScenario := "PA KPI Scenario".FromInteger(i);
            CountKPI.Set(PAKPIScenario, PayablesAgentKPI.GetAggregateKPI(PAKPIScenario).Count);
        end;
        TimeSavedEmails := ConvertDurationToText(CountKPI.Get("PA KPI Scenario"::"Agent Tasks Received") * 3, TimeSavedEmailsFormatExpression); // Estimated 3 minutes saved per email
        TimeSavedInvoices := ConvertDurationToText((CountKPI.Get("PA KPI Scenario"::"Agent E-Docs Finalized by Agent") + CountKPI.Get("PA KPI Scenario"::"Agent E-Docs Finalized by User")) * 5, TimeSavedInvoicesFormatExpression); // Estimated 5 minutes saved per invoice
    end;

    var
        PayablesAgentKPI: Codeunit "Payables Agent KPI";
        CountKPI: Dictionary of [Enum "PA KPI Scenario", Integer];
        PAKPIScenario: Enum "PA KPI Scenario";
        TimeSavedEmails, TimeSavedInvoices : Decimal;
        TimeSavedEmailsFormatExpression, TimeSavedInvoicesFormatExpression : Text;

    local procedure ConvertDurationToText(MinutesSaved: Integer; var ControlAutoFormatExpression: Text): Decimal // Workitem to unify approaches with how SOA implements this: 581118 
    var
        HoursSaved: Decimal;
        DaysSaved: Decimal;
        YearsSaved: Decimal;
        AutoFormatExpressionLbl: Label '<Precision,0:1><Standard Format,0> %1', Locked = true, Comment = '%1 - is the unit hr or min';
        HoursUnitLbl: Label 'h', Comment = 'h represents hours, it will be shown like 23.7 h', MaxLength = 3;
        DaysUnitLbl: Label 'd', Comment = 'd represents days, it will be shown like 23.6 d', MaxLength = 3;
        YearsUnitLbl: Label 'yr', Comment = 'yr represents years, it will be shown like 3.6 yr', MaxLength = 3;
        MinutesUnitLbl: Label 'min', Comment = 'min represents minutes, it will be shown like 23 min', MaxLength = 3;
    begin
        ControlAutoFormatExpression := StrSubstNo(AutoFormatExpressionLbl, MinutesUnitLbl);

        if MinutesSaved < 60 then
            exit(MinutesSaved);

        ControlAutoFormatExpression := StrSubstNo(AutoFormatExpressionLbl, HoursUnitLbl);

        // Under 100 hours we track with 0.1 increment, over 100 hours we track with 0.5 increment.
        // This is to show more progress in the beginning. With larger numbers it feels odd to track with small increments.
        if MinutesSaved < 6000 then
            HoursSaved := Round(MinutesSaved / 60, 0.1)
        else
            HoursSaved := Round(MinutesSaved / 60, 0.5);

        if HoursSaved < 1000 then
            exit(HoursSaved);

        // Under 100 days we track with 0.1 increment, over 100 days we report full days.
        DaysSaved := Round(HoursSaved / 24, 0.1);
        ControlAutoFormatExpression := StrSubstNo(AutoFormatExpressionLbl, DaysUnitLbl);
        if DaysSaved < 100 then
            exit(DaysSaved)
        else
            DaysSaved := Round(DaysSaved, 1);

        if DaysSaved < 1000 then
            exit(DaysSaved);

        // Years are always reported with 0.01 increment.
        YearsSaved := Round(DaysSaved / 365, 0.01);
        ControlAutoFormatExpression := StrSubstNo(AutoFormatExpressionLbl, YearsUnitLbl);
        exit(YearsSaved);
    end;

}