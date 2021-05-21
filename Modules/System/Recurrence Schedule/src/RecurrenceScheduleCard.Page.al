// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Allows users to view and edit existing recurrence schedules.
/// </summary>
page 4690 "Recurrence Schedule Card"
{
    Extensible = false;
    DataCaptionExpression = FORMAT(Pattern);
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
                field(ID; ID)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the ID of the recurrence schedule.';
                }
                field(RecurrenceStartTime; "Start Time")
                {
                    ApplicationArea = All;
                    Caption = 'Recurrence Start Time';
                    Importance = Promoted;
                    ToolTip = 'Specifies the time of day when the recurrence takes effect. This is also the time of day for each occurrence.';
                }
                field(RecurrencePattern; Pattern)
                {
                    ApplicationArea = All;
                    Caption = 'Recurrence Pattern';
                    Importance = Promoted;
                    Visible = false;
                    ToolTip = 'Specifies the frequency of the recurrence. For example, a recurrence pattern might be set up for a day in the first week of every month.';

                    trigger OnValidate()
                    begin
                        CurrPage.UPDATE(TRUE);
                    end;
                }
                field("Start Date"; "Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when the recurrence takes effect.';
                }
                field("End Date"; "End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the recurrence will stop.';
                }
            }
            group(Daily)
            {
                Caption = 'Daily';
                Visible = "Pattern" = RecurrencePatterns::Daily;
                field(DailyFrequency; "Recurs Every")
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
                Visible = "Pattern" = "Pattern"::Weekly;
                field(WeeklyFrequency; "Recurs Every")
                {
                    ApplicationArea = All;
                    Caption = 'Weeks Between';
                    Importance = Promoted;
                    ToolTip = 'Specifies the interval between occurrences.';
                }
                field(RecurOnMonday; "Recurs on Monday")
                {
                    ApplicationArea = All;
                    Caption = 'Recur on Monday';
                    ToolTip = 'Specifies that Monday is the day of the week for the recurrence.';
                }
                field(RecurOnTuesday; "Recurs on Tuesday")
                {
                    ApplicationArea = All;
                    Caption = 'Recur on Tuesday';
                    ToolTip = 'Specifies that Tuesday is the day of the week for the recurrence.';
                }
                field(RecurOnWednesday; "Recurs on Wednesday")
                {
                    ApplicationArea = All;
                    Caption = 'Recur on Wednesday';
                    ToolTip = 'Specifies that Wednesday is the day of the week for the recurrence.';
                }
                field(RecurOnThursday; "Recurs on Thursday")
                {
                    ApplicationArea = All;
                    Caption = 'Recur on Thursday';
                    ToolTip = 'Specifies that Thursday is the day of the week for the recurrence.';
                }
                field(RecurOnFriday; "Recurs on Friday")
                {
                    ApplicationArea = All;
                    Caption = 'Recur on Friday';
                    ToolTip = 'Specifies that Friday is the day of the week for the recurrence.';
                }
                field(RecurOnSaturday; "Recurs on Saturday")
                {
                    ApplicationArea = All;
                    Caption = 'Recur on Saturday';
                    ToolTip = 'Specifies that Saturday is the day of the week for the recurrence.';
                }
                field(RecurOnSunday; "Recurs on Sunday")
                {
                    ApplicationArea = All;
                    Caption = 'Recur on Sunday';
                    ToolTip = 'Specifies that Sunday is the day of the week for the recurrence.';
                }
            }
            group(Monthly)
            {
                Caption = 'Monthly';
                Visible = "Pattern" = RecurrencePatterns::Monthly;
                field(MonthlyFrequency; "Recurs Every")
                {
                    ApplicationArea = All;
                    Caption = 'Months Between';
                    Importance = Promoted;
                    ToolTip = 'Specifies the interval between occurrences.';
                }
                field("MonthlyRecurrencePattern>"; "Monthly Pattern")
                {
                    ApplicationArea = All;
                    Caption = 'Recurrence Pattern';
                    Importance = Promoted;
                    ToolTip = 'Specifies the frequency of the recurrence. For example, a recurrence pattern might be set up for a day in the first week of every month.';
                }
                group(MonthlySpecificDay)
                {
                    Visible = "Monthly Pattern" = RecurrenceMonthlyPattern::"Specific Day";
                    field(MRecurOnDay; "Recurs on Day")
                    {
                        ApplicationArea = All;
                        Caption = 'Recur on Day';
                        Enabled = "Monthly Pattern" = RecurrenceMonthlyPattern::"Specific Day";
                        ToolTip = 'Specifies the day of the month for the recurrence.';
                    }
                }
                group(MonthlyByWeekday)
                {
                    Visible = "Monthly Pattern" = RecurrenceMonthlyPattern::"By Weekday";
                    field(MRecurInWeek; "Ordinal Recurrence No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Recur in Week in Month';
                        Enabled = "Monthly Pattern" = RecurrenceMonthlyPattern::"By Weekday";
                        ToolTip = 'Specifies the week of the month for the recurrence.';
                    }
                    field(MWeekday; Weekday)
                    {
                        ApplicationArea = All;
                        Caption = 'Weekday';
                        Enabled = "Monthly Pattern" = RecurrenceMonthlyPattern::"By Weekday";
                        ToolTip = 'Specifies the day of the week for the recurrence.';
                    }
                }
            }
            group(Yearly)
            {
                Caption = 'Yearly';
                Visible = "Pattern" = RecurrencePatterns::Yearly;
                field(YearlyFrequency; "Recurs Every")
                {
                    ApplicationArea = All;
                    Caption = 'Years Between';
                    Importance = Promoted;
                    ToolTip = 'Specifies the interval between occurrences.';
                }
                field(YearlyRecurrencePattern; "Monthly Pattern")
                {
                    ApplicationArea = All;
                    Caption = 'Recurrence Pattern';
                    Importance = Promoted;
                    ToolTip = 'Specifies the frequency of the recurrence. For example, a recurrence pattern might be set up for a day in the first week of every month.';
                }
                field(Month; Month)
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the month for the recurrence.';
                }
                group(YearlySpecificDay)
                {
                    Visible = "Monthly Pattern" = RecurrenceMonthlyPattern::"Specific Day";
                    field(YRecurOnDay; "Recurs on Day")
                    {
                        ApplicationArea = All;
                        Caption = 'Recur on Day';
                        Editable = "Monthly Pattern" = RecurrenceMonthlyPattern::"Specific Day";
                        ToolTip = 'Specifies the day of the month for the recurrence.';
                    }
                }
                group(YearlyByWeekday)
                {
                    Visible = "Monthly Pattern" = RecurrenceMonthlyPattern::"By Weekday";
                    field(YRecurInWeek; "Ordinal Recurrence No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Recur in Week in Month';
                        Enabled = "Monthly Pattern" = RecurrenceMonthlyPattern::"By Weekday";
                        ToolTip = 'Specifies the week of the month for the recurrence.';
                    }
                    field(YWeekday; Weekday)
                    {
                        ApplicationArea = All;
                        Caption = 'Weekday';
                        Enabled = "Monthly Pattern" = RecurrenceMonthlyPattern::"By Weekday";
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
                Enabled = "Pattern" <> RecurrencePatterns::Daily;
                Image = DueDate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Create a daily recurrence.';

                trigger OnAction()
                begin
                    VALIDATE(Pattern, RecurrencePatterns::Daily);
                end;
            }
            action("Weekly Recurrence")
            {
                ApplicationArea = All;
                Caption = 'Weekly';
                Enabled = "Pattern" <> RecurrencePatterns::Weekly;
                Image = Workdays;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Create a weekly recurrence.';

                trigger OnAction()
                begin
                    VALIDATE(Pattern, RecurrencePatterns::Weekly);
                end;
            }
            action("Monthly Recurrence")
            {
                ApplicationArea = All;
                Caption = 'Monthly';
                Enabled = "Pattern" <> RecurrencePatterns::Monthly;
                Image = Workdays;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Create a monthly recurrence.';

                trigger OnAction()
                begin
                    VALIDATE(Pattern, RecurrencePatterns::Monthly);
                end;
            }
            action("Yearly Recurrence")
            {
                ApplicationArea = All;
                Caption = 'Yearly';
                Enabled = "Pattern" <> RecurrencePatterns::Yearly;
                Image = Period;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Create a yearly recurrence.';

                trigger OnAction()
                begin
                    VALIDATE(Pattern, RecurrencePatterns::Yearly);
                end;
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if CloseAction = Action::LookupOK then
            if Pattern in [RecurrencePatterns::Monthly, RecurrencePatterns::Yearly] then
                if "Monthly Pattern" = RecurrenceMonthlyPattern::"Specific Day" then
                    if "Recurs on Day" >= 29 then
                        exit(ConfirmManagement.GetResponseOrDefault(StrSubstNo(ConfirmLbl, "Recurs on Day"), true));
        exit(true);
    end;

    var
        [InDataSet]
        RecurrenceMonthlyPattern: Enum "Recurrence - Monthly Pattern";
        [InDataSet]
        RecurrencePatterns: Enum "Recurrence - Pattern";
        ConfirmLbl: Label 'Some months have fewer than %1 days. These months will not be included in the recurrence.\\Do you want to continue?', Comment = '%1 - Number of days in month';


}

