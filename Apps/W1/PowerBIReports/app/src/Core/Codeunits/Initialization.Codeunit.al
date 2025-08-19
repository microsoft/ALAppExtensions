namespace Microsoft.PowerBIReports;

using Microsoft.Foundation.Period;
using System.Diagnostics;
using System.Threading;
using Microsoft.Foundation.AuditCodes;
using System.Environment.Configuration;
using System.Media;
using Microsoft.Finance.PowerBIReports;
using System.Telemetry;

/// <summary>
/// Creates the setup required to have the basic scenarios of the Power BI Reports working.
/// The only public procedure is the one calling all the setup actions. Internal procedures are the ones called by other "fix" actions in the setup page. The rest are local procedures.
/// Every "initialization" procedure should be safe to call multiple times and not override any user-defined setup. In contrast to the "restore" procedures.
/// </summary>
codeunit 36951 Initialization
{
    var
        JobQueueCategoryCodeLbl: Label 'PBI', Locked = true;
        DimensionSetEntriesJobQueueDescriptionLbl: Label 'Update Power BI Dimension Set Entries';

    procedure SetupDefaultsForPowerBIReportsIfNotInitialized()
    begin
        InsertGuidedExperience();
        InitializePBISetup();
        InitializePBIWorkingDays();
        InitializeStartingEndingDates();
        InitializeDimensionSetEntryCollectionJobQueueEntry();
        InitializeDimSetEntryLastUpdated();
        InitializeSetupFinancePowerBIReports();
        InitializeCloseIncomeSourceCodes();
    end;

    internal procedure RestoreDimensionSetEntryCollectionJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if InitializeDimensionSetEntryCollectionJobQueueEntry(JobQueueEntry) then
            exit;
        RestoreDefaultJobQueueEntrySetup(JobQueueEntry, Codeunit::"Update Dim. Set Entries", DimensionSetEntriesJobQueueDescriptionLbl, JobQueueCategoryCodeLbl);
    end;

    internal procedure RestorePowerBIAccountCategories()
    var
        FinanceInstallationHandler: Codeunit "Finance Installation Handler";
    begin
        FinanceInstallationHandler.RestorePowerBIAccountCategories();
    end;

    local procedure InitializeSetupFinancePowerBIReports()
    var
        FinanceInstallationHandler: Codeunit "Finance Installation Handler";
    begin
        FinanceInstallationHandler.SetupDefaultsForPowerBIReportsIfNotInitialized();
    end;

    local procedure InitializePBISetup()
    var
        PBISetup: Record "PowerBI Reports Setup";
    begin
        if not PBISetup.Get() then begin
            PBISetup.Init();
            PBISetup.Insert();
        end;
    end;

    local procedure InitializeStartingEndingDates()
    var
        AccountingPeriod: Record "Accounting Period";
        PBISetup: Record "PowerBI Reports Setup";
    begin
        if PBISetup.Get() then begin
            if PBISetup."Date Table Starting Date" = 0D then
                if AccountingPeriod.FindFirst() then
                    PBISetup."Date Table Starting Date" := AccountingPeriod."Starting Date";

            if PBISetup."Date Table Ending Date" = 0D then
                if AccountingPeriod.FindLast() then
                    PBISetup."Date Table Ending Date" := AccountingPeriod."Starting Date";
            PBISetup.Modify();
        end;
    end;

    local procedure InitializePBIWorkingDays()
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

    local procedure InitializeDimensionSetEntryCollectionJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        InitializeDimensionSetEntryCollectionJobQueueEntry(JobQueueEntry);
    end;

    local procedure InitializeDimensionSetEntryCollectionJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry"): Boolean
    begin
        exit(InitializeJobQueueEntry(Codeunit::"Update Dim. Set Entries", DimensionSetEntriesJobQueueDescriptionLbl, JobQueueEntry));
    end;

    local procedure InitializeJobQueueEntry(ObjectIDToRun: Integer; JobQueueEntryDescription: Text[250]; var JobQueueEntry: Record "Job Queue Entry"): Boolean
    var
        JobQueueCategory: Record "Job Queue Category";
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
            RestoreDefaultJobQueueEntrySetup(JobQueueEntry, ObjectIDToRun, JobQueueEntryDescription, JobQueueCategoryCodeLbl);
            exit(true);
        end;
        exit(false);
    end;

    local procedure RestoreDefaultJobQueueEntrySetup(var JobQueueEntry: Record "Job Queue Entry"; ObjectIDToRun: Integer; JobQueueEntryDescription: Text[250]; JobQueueCategoryCode: Code[10])
    begin
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
        JobQueueEntry."Job Queue Category Code" := JobQueueCategoryCode;
        JobQueueEntry."Rerun Delay (sec.)" := 60;
        JobQueueEntry."Maximum No. of Attempts to Run" := 5;
        JobQueueEntry.Modify(true);
        JobQueueEntry.SetStatus(JobQueueEntry.Status::Ready);
    end;

    local procedure InitializeDimSetEntryLastUpdated()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PBIDimSetEntry: Record "PowerBI Flat Dim. Set Entry";
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

    local procedure InsertGuidedExperience()
    var
        GuidedExperience: Codeunit "Guided Experience";
        AssistedSetupLbl: Label 'Connect to Power BI', MaxLength = 50;
        AssistedSetupDescriptionTxt: Label 'Connect to your data to Power BI for better insights into your business. Here you connect and configure how your data will be displayed in Power BI.', MaxLength = 1024;
        AppHelpUrlTxt: Label 'https://learn.microsoft.com/dynamics365/business-central/', Locked = true;
    begin
        if GuidedExperience.Exists("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"Assisted Setup") then
            exit;
        GuidedExperience.InsertAssistedSetup(
            AssistedSetupLbl,
            AssistedSetupLbl,
            AssistedSetupDescriptionTxt,
            5,
            ObjectType::Page,
            Page::"PowerBI Assisted Setup",
            Enum::"Assisted Setup Group"::Connect,
            '',
            Enum::"Video Category"::Connect,
            AppHelpUrlTxt
        );
    end;

    internal procedure InitializeCloseIncomeSourceCodes()
    var
        SourceCodeSetup: Record "Source Code Setup";
        CloseIncomeStmtSourceCode: Record "PBI C. Income St. Source Code";
    begin
        if SourceCodeSetup.Get() then
            if SourceCodeSetup."Close Income Statement" <> '' then
                if not CloseIncomeStmtSourceCode.Get(SourceCodeSetup."Close Income Statement") then begin
                    CloseIncomeStmtSourceCode.Init();
                    CloseIncomeStmtSourceCode."Source Code" := SourceCodeSetup."Close Income Statement";
                    CloseIncomeStmtSourceCode.Insert(true);
                end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Change Log Management", 'OnAfterIsAlwaysLoggedTable', '', false, false)]
    local procedure OnAfterIsAlwaysLoggedTable(TableID: Integer; var AlwaysLogTable: Boolean)
    begin
        if TableID = Database::"PowerBI Reports Setup" then
            AlwaysLogTable := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Change Log Management", 'OnInsertLogEntryOnBeforeChangeLogEntryValidateChangedRecordSystemId', '', false, false)]
    local procedure OnInsertLogEntryOnBeforeChangeLogEntryValidateChangedRecordSystemId(var ChangeLogEntry: Record "Change Log Entry"; RecRef: RecordRef; FldRef: FieldRef)
    var
        PowerBIReportsSetup: Record "PowerBI Reports Setup";
        AuditLog: Codeunit "Audit Log";
        PowerBIReportConfiguredLbl: Label 'Power BI report configured by UserSecurityId %1.', Locked = true;
    begin
        if RecRef.Number() <> Database::"PowerBI Reports Setup" then
            exit;
        if not (FldRef.Number in [
                PowerBIReportsSetup.FieldNo("Finance Report Id"),
                PowerBIReportsSetup.FieldNo("Sales Report Id"),
                PowerBIReportsSetup.FieldNo("Projects Report Id"),
                PowerBIReportsSetup.FieldNo("Inventory Report Id"),
                PowerBIReportsSetup.FieldNo("Purchases Report Id"),
                PowerBIReportsSetup.FieldNo("Manufacturing Report Id"),
                PowerBIReportsSetup.FieldNo("Inventory Val. Report Id"),
                PowerBIReportsSetup.FieldNo("Sustainability Report Id")
        ]) then
            exit;
        ChangeLogEntry."Field Log Entry Feature" := "Field Log Entry Feature"::"Monitor Sensitive Fields";
        AuditLog.LogAuditMessage(StrSubstNo(PowerBIReportConfiguredLbl, UserSecurityId()), SecurityOperationResult::Success, AuditCategory::ApplicationManagement, 1, 0);
    end;

}

