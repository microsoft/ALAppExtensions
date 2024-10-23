namespace Microsoft.PowerBIReports;

using Microsoft.Foundation.Period;
using System.Threading;

codeunit 36951 Initialization
{
    Access = Internal;

    procedure InitialisePBISetup()
    var
        PBISetup: Record "PowerBI Reports Setup";
    begin
        if not PBISetup.Get() then begin
            PBISetup.Init();
            PBISetup.Insert();
        end;
    end;

    procedure InitialiseStartingEndingDates()
    var
        AccountingPeriod: Record "Accounting Period";
        PBISetup: Record "PowerBI Reports Setup";
    begin
        if PBISetup.Get() then begin
            if AccountingPeriod.FindFirst() then
                PBISetup."Date Table Starting Date" := AccountingPeriod."Starting Date";
            if AccountingPeriod.FindLast() then
                PBISetup."Date Table Ending Date" := AccountingPeriod."Starting Date";
            PBISetup.Modify();
        end;
    end;

    procedure InitialisePBIWorkingDays()
    var
        MondayLbl: Label 'Monday';
        TuesdayLbl: Label 'Tuesday';
        WednesdayLbl: Label 'Wednesday';
        ThursdayLbl: Label 'Thursday';
        FridayLbl: Label 'Friday';
        SaturdayLbl: Label 'Saturday';
        SundayLbl: Label 'Sunday';
    begin
        InsertWorkingDay(0, SundayLbl, false);
        InsertWorkingDay(1, MondayLbl, true);
        InsertWorkingDay(2, TuesdayLbl, true);
        InsertWorkingDay(3, WednesdayLbl, true);
        InsertWorkingDay(4, ThursdayLbl, true);
        InsertWorkingDay(5, FridayLbl, true);
        InsertWorkingDay(6, SaturdayLbl, false);
    end;

    local procedure InsertWorkingDay(DayNumber: Integer; DayName: Text[50]; Working: Boolean)
    var
        WorkingDay: Record "Working Day";
    begin
        if not WorkingDay.Get(DayNumber) then begin
            WorkingDay.Init();
            WorkingDay."Day Number" := DayNumber;
            WorkingDay."Day Name" := DayName;
            WorkingDay.Working := Working;
            WorkingDay.Insert();
        end;
    end;

    procedure InitialiseJobQueue(ObjectIDToRun: Integer; JobQueueEntryDescription: Text[250])
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueCategory: Record "Job Queue Category";
        JobQueueCategoryCodeLbl: Label 'PBI', Locked = true;
        JobQueueCategoryDescLbl: Label 'Power BI', MaxLength = 30;
    begin
        if not JobQueueCategory.Get(JobQueueCategoryCodeLbl) then begin
            JobQueueCategory.Init();
            JobQueueCategory.Code := JobQueueCategoryCodeLbl;
            JobQueueCategory.Description := JobQueueCategoryDescLbl;
            JobQueueCategory.Insert(true);
        end;

        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", ObjectIDToRun);
        if not JobQueueEntry.FindFirst() then begin
            JobQueueEntry.Init();
            JobQueueEntry.Insert(true);
        end;
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := ObjectIDToRun;
        JobQueueEntry."Earliest Start Date/Time" := CurrentDateTime();
        JobQueueEntry."Recurring Job" := true;
        JobQueueEntry."Run on Mondays" := true;
        JobQueueEntry."Run on Tuesdays" := true;
        JobQueueEntry."Run on Wednesdays" := true;
        JobQueueEntry."Run on Thursdays" := true;
        JobQueueEntry."Run on Fridays" := true;
        JobQueueEntry."Run on Saturdays" := true;
        JobQueueEntry."Run on Sundays" := true;
        JobQueueEntry."No. of Minutes between Runs" := 60;  // Runs every 1 hour
        JobQueueEntry.Description := JobQueueEntryDescription;
        JobQueueEntry."Job Queue Category Code" := JobQueueCategoryCodeLbl;
        JobQueueEntry."Rerun Delay (sec.)" := 60;
        JobQueueEntry."Maximum No. of Attempts to Run" := 5;
        JobQueueEntry.Modify(true);
        JobQueueEntry.SetStatus(JobQueueEntry.Status::Ready);
    end;

    procedure InitDimSetEntryLastUpdated()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PBIDimSetEntry: Record "Dimension Set Entry";
    begin
        if PBIDimSetEntry.IsEmpty() then
            exit;

        if PBISetup.Get() then
            if PBISetup."Last Dim. Set Entry Date-Time" = 0DT then begin
                PBIDimSetEntry.SetCurrentKey(SystemModifiedAt);
                if PBIDimSetEntry.FindLast() then begin
                    PBISetup."Last Dim. Set Entry Date-Time" := PBIDimSetEntry.SystemModifiedAt;
                    PBISetup.Modify();
                end;
            end;
    end;
}

