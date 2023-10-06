// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.DateTime;

using System.Utilities;

/// <summary>
/// Allows users to view and edit existing recurrence schedules.
/// </summary>
page 4690 "Recurrence Schedule Card"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Extensible = false;
    DataCaptionExpression = FORMAT(Rec.Pattern);
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Card;
    ShowFilter = false;
    SourceTable = "Recurrence Schedule";
    Permissions = tabledata "Recurrence Schedule" = rmd;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(ID; Rec.ID)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the ID of the recurrence schedule.';
                }
                field(RecurrenceStartTime; Rec."Start Time")
                {
                    ApplicationArea = All;
                    Caption = 'Recurrence Start Time';
                    Importance = Promoted;
                    ToolTip = 'Specifies the time of day when the recurrence takes effect. This is also the time of day for each occurrence.';
                }
                field(RecurrencePattern; Rec.Pattern)
                {
                    ApplicationArea = All;
                    Caption = 'Recurrence Pattern';
                    Importance = Promoted;
                    Visible = false;
                    ToolTip = 'Specifies the frequency of the recurrence. For example, a recurrence pattern might be set up for a day in the first week of every month.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when the recurrence takes effect.';
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the recurrence will stop.';
                }
            }
            group(Daily)
            {
                Caption = 'Daily';
                Visible = Rec."Pattern" = RecurrencePatterns::Daily;
                field(DailyFrequency; Rec."Recurs Every")
                {
                    ApplicationArea = All;
                    Caption = 'Days Between';
                    Importance = Promoted;
                    ToolTip = 'Specifies the interval between occurrences.';
                }
            }
            group(Weekly)
            {
                Caption = 'Weekly';
                Visible = Rec."Pattern" = Rec."Pattern"::Weekly;
                field(WeeklyFrequency; Rec."Recurs Every")
                {
                    ApplicationArea = All;
                    Caption = 'Weeks Between';
                    Importance = Promoted;
                    ToolTip = 'Specifies the interval between occurrences.';
                }
                field(RecurOnMonday; Rec."Recurs on Monday")
                {
                    ApplicationArea = All;
                    Caption = 'Recur on Monday';
                    ToolTip = 'Specifies that Monday is the day of the week for the recurrence.';
                }
                field(RecurOnTuesday; Rec."Recurs on Tuesday")
                {
                    ApplicationArea = All;
                    Caption = 'Recur on Tuesday';
                    ToolTip = 'Specifies that Tuesday is the day of the week for the recurrence.';
                }
                field(RecurOnWednesday; Rec."Recurs on Wednesday")
                {
                    ApplicationArea = All;
                    Caption = 'Recur on Wednesday';
                    ToolTip = 'Specifies that Wednesday is the day of the week for the recurrence.';
                }
                field(RecurOnThursday; Rec."Recurs on Thursday")
                {
                    ApplicationArea = All;
                    Caption = 'Recur on Thursday';
                    ToolTip = 'Specifies that Thursday is the day of the week for the recurrence.';
                }
                field(RecurOnFriday; Rec."Recurs on Friday")
                {
                    ApplicationArea = All;
                    Caption = 'Recur on Friday';
                    ToolTip = 'Specifies that Friday is the day of the week for the recurrence.';
                }
                field(RecurOnSaturday; Rec."Recurs on Saturday")
                {
                    ApplicationArea = All;
                    Caption = 'Recur on Saturday';
                    ToolTip = 'Specifies that Saturday is the day of the week for the recurrence.';
                }
                field(RecurOnSunday; Rec."Recurs on Sunday")
                {
                    ApplicationArea = All;
                    Caption = 'Recur on Sunday';
                    ToolTip = 'Specifies that Sunday is the day of the week for the recurrence.';
                }
            }
            group(Monthly)
            {
                Caption = 'Monthly';
                Visible = Rec."Pattern" = RecurrencePatterns::Monthly;
                field(MonthlyFrequency; Rec."Recurs Every")
                {
                    ApplicationArea = All;
                    Caption = 'Months Between';
                    Importance = Promoted;
                    ToolTip = 'Specifies the interval between occurrences.';
                }
                field("MonthlyRecurrencePattern>"; Rec."Monthly Pattern")
                {
                    ApplicationArea = All;
                    Caption = 'Recurrence Pattern';
                    Importance = Promoted;
                    ToolTip = 'Specifies the frequency of the recurrence. For example, a recurrence pattern might be set up for a day in the first week of every month.';
                }
                group(MonthlySpecificDay)
                {
                    Visible = Rec."Monthly Pattern" = RecurrenceMonthlyPattern::"Specific Day";
                    field(MRecurOnDay; Rec."Recurs on Day")
                    {
                        ApplicationArea = All;
                        Caption = 'Recur on Day';
                        Enabled = Rec."Monthly Pattern" = RecurrenceMonthlyPattern::"Specific Day";
                        ToolTip = 'Specifies the day of the month for the recurrence.';
                    }
                }
                group(MonthlyByWeekday)
                {
                    Visible = Rec."Monthly Pattern" = RecurrenceMonthlyPattern::"By Weekday";
                    field(MRecurInWeek; Rec."Ordinal Recurrence No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Recur in Week in Month';
                        Enabled = Rec."Monthly Pattern" = RecurrenceMonthlyPattern::"By Weekday";
                        ToolTip = 'Specifies the week of the month for the recurrence.';
                    }
                    field(MWeekday; Rec.Weekday)
                    {
                        ApplicationArea = All;
                        Caption = 'Weekday';
                        Enabled = Rec."Monthly Pattern" = RecurrenceMonthlyPattern::"By Weekday";
                        ToolTip = 'Specifies the day of the week for the recurrence.';
                    }
                }
            }
            group(Yearly)
            {
                Caption = 'Yearly';
                Visible = Rec."Pattern" = RecurrencePatterns::Yearly;
                field(YearlyFrequency; Rec."Recurs Every")
                {
                    ApplicationArea = All;
                    Caption = 'Years Between';
                    Importance = Promoted;
                    ToolTip = 'Specifies the interval between occurrences.';
                }
                field(YearlyRecurrencePattern; Rec."Monthly Pattern")
                {
                    ApplicationArea = All;
                    Caption = 'Recurrence Pattern';
                    Importance = Promoted;
                    ToolTip = 'Specifies the frequency of the recurrence. For example, a recurrence pattern might be set up for a day in the first week of every month.';
                }
                field(Month; Rec.Month)
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the month for the recurrence.';
                }
                group(YearlySpecificDay)
                {
                    Visible = Rec."Monthly Pattern" = RecurrenceMonthlyPattern::"Specific Day";
                    field(YRecurOnDay; Rec."Recurs on Day")
                    {
                        ApplicationArea = All;
                        Caption = 'Recur on Day';
                        Editable = Rec."Monthly Pattern" = RecurrenceMonthlyPattern::"Specific Day";
                        ToolTip = 'Specifies the day of the month for the recurrence.';
                    }
                }
                group(YearlyByWeekday)
                {
                    Visible = Rec."Monthly Pattern" = RecurrenceMonthlyPattern::"By Weekday";
                    field(YRecurInWeek; Rec."Ordinal Recurrence No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Recur in Week in Month';
                        Enabled = Rec."Monthly Pattern" = RecurrenceMonthlyPattern::"By Weekday";
                        ToolTip = 'Specifies the week of the month for the recurrence.';
                    }
                    field(YWeekday; Rec.Weekday)
                    {
                        ApplicationArea = All;
                        Caption = 'Weekday';
                        Enabled = Rec."Monthly Pattern" = RecurrenceMonthlyPattern::"By Weekday";
                        ToolTip = 'Specifies the day of the week for the recurrence.';
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Daily Recurrence")
            {
                ApplicationArea = All;
                Caption = 'Daily';
                Enabled = Rec."Pattern" <> RecurrencePatterns::Daily;
                Image = DueDate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Create a daily recurrence.';

                trigger OnAction()
                begin
                    Rec.Validate(Pattern, RecurrencePatterns::Daily);
                end;
            }
            action("Weekly Recurrence")
            {
                ApplicationArea = All;
                Caption = 'Weekly';
                Enabled = Rec."Pattern" <> RecurrencePatterns::Weekly;
                Image = Workdays;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Create a weekly recurrence.';

                trigger OnAction()
                begin
                    Rec.Validate(Pattern, RecurrencePatterns::Weekly);
                end;
            }
            action("Monthly Recurrence")
            {
                ApplicationArea = All;
                Caption = 'Monthly';
                Enabled = Rec."Pattern" <> RecurrencePatterns::Monthly;
                Image = Workdays;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Create a monthly recurrence.';

                trigger OnAction()
                begin
                    Rec.Validate(Pattern, RecurrencePatterns::Monthly);
                end;
            }
            action("Yearly Recurrence")
            {
                ApplicationArea = All;
                Caption = 'Yearly';
                Enabled = Rec."Pattern" <> RecurrencePatterns::Yearly;
                Image = Period;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Create a yearly recurrence.';

                trigger OnAction()
                begin
                    Rec.Validate(Pattern, RecurrencePatterns::Yearly);
                end;
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if CloseAction = Action::LookupOK then
            if Rec.Pattern in [RecurrencePatterns::Monthly, RecurrencePatterns::Yearly] then
                if Rec."Monthly Pattern" = RecurrenceMonthlyPattern::"Specific Day" then
                    if Rec."Recurs on Day" >= 29 then
                        exit(ConfirmManagement.GetResponseOrDefault(StrSubstNo(ConfirmLbl, Rec."Recurs on Day"), true));
        exit(true);
    end;

    var
        RecurrenceMonthlyPattern: Enum "Recurrence - Monthly Pattern";
        RecurrencePatterns: Enum "Recurrence - Pattern";
        ConfirmLbl: Label 'Some months have fewer than %1 days. These months will not be included in the recurrence.\\Do you want to continue?', Comment = '%1 - Number of days in month';
}


