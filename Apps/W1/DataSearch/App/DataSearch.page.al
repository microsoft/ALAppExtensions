page 2680 "Data Search"
{
    PageType = ListPlus;
    Caption = 'Search in company data [Preview]';
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = "Data Search Source Temp";  // necessary in order to position cursor in search field
    SourceTableTemporary = true;
    DeleteAllowed = false;
    AboutTitle = 'About Search in company data';
    AboutText = 'Enter one or more search words in the search field. To see which tables are being searched, select Results | Show tables to search.';

    layout
    {
        area(Content)
        {
            group(SearchStringgrp)
            {
                Caption = 'Text to search for (enter at least 3 characters)';
                field(SearchString; SearchString)
                {
                    ShowCaption = false;
                    Caption = 'Text to search for';
                    ToolTip = 'Enter at least three characters to search for.';
                    ApplicationArea = All;
                    Width = 250;

                    trigger OnValidate()
                    var
                        DataSearchInTable: Codeunit "Data Search in Table";
                        SearchStrings: List of [Text];
                        FirstString: Text;
                    begin
                        SearchString := DelChr(SearchString, '<>', ' ');
                        if StrLen(DelChr(SearchString, '=', '*')) < 3 then
                            exit;
                        DataSearchInTable.SplitSearchString(SearchString, SearchStrings);
                        if not SearchStrings.Get(1, FirstString) then
                            exit;
                        if StrLen(FirstString) < 3 then
                            exit;
                        LaunchSearch();
                    end;
                }
            }
            group(lines)
            {
                Caption = 'Results';
                ShowCaption = false;
                part(LinesPart; "Data Search lines")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    var
        Notification: Notification;
        SearchString: Text;
        ActiveSearches: Dictionary of [Integer, Integer];
        QueuedSearches: List of [Integer];
        NoOfParallelTasks: Integer;
        NoTablesDefinedErr: Label 'No tables defined for search.';
        StatusLbl: Label 'Searching ...';
        TelemetryLbl: Label 'Data Search started. No. of search words: %1. No. of tables to search: %2.', Comment = '%1 and %2 are integer numbers equal to or greater than 1';
        TelemetryCategoryLbl: Label 'Data Search', Locked = true;

    trigger OnInit()
    begin
        NoOfParallelTasks := 5;
        SearchString := '';
    end;

    trigger OnClosePage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        FeatureUptakeStatus: Enum "Feature Uptake Status";
    begin
        FeatureTelemetry.LogUptake('0000IOJ', TelemetryCategoryLbl, FeatureUptakeStatus::Discovered);
    end;

    // necessary in order to position cursor in search field
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.Description := CopyStr(CurrPage.Caption, 1, MaxStrLen(Rec.Description));
    end;

    internal procedure LaunchSearch()
    var
        DataSearchSetupTable: Record "Data Search Setup (Table)";
        DataSearchDefaults: Codeunit "Data Search Defaults";
        DataSearchInTable: Codeunit "Data Search in Table";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        SearchStrings: List of [Text];
        RoleCenterID: Integer;
        NoOfTablesToSearch: Integer;
    begin
        CancelRunningTasks();
        RoleCenterID := DataSearchSetupTable.GetRoleCenterID();
        CurrPage.LinesPart.Page.SetSearchParams(SearchString, RoleCenterID);
        CurrPage.LinesPart.Page.ClearResults();
        DataSearchSetupTable.Setrange("Role Center ID", RoleCenterID);
        if DataSearchSetupTable.IsEmpty then begin
            DataSearchDefaults.InitSetupForProfile(RoleCenterID);
            if DataSearchSetupTable.IsEmpty then
                DataSearchSetupTable.Setrange("Role Center ID", 0);
        end;
        DataSearchSetupTable.SetCurrentKey("No. of Hits", "Table No.");
        DataSearchSetupTable.SetAscending("No. of Hits", false);
        if not DataSearchSetupTable.FindSet() then
            error(NoTablesDefinedErr);
        Notification.Message := StatusLbl;
        Notification.Send();
        repeat
            QueueSearchInBackground(DataSearchSetupTable."Table/Type ID");
            NoOfTablesToSearch += 1;
        until DataSearchSetupTable.Next() = 0;

        DataSearchInTable.SplitSearchString(SearchString, SearchStrings);
        FeatureTelemetry.LogUsage('0000I9B', TelemetryCategoryLbl, StrSubstNo(TelemetryLbl, SearchStrings.Count(), NoOfTablesToSearch));
    end;

    local procedure QueueSearchInBackground(TableTypeID: Integer)
    begin
        QueuedSearches.Add(TableTypeID);
        DeQueueSearchInBackground();
    end;

    local procedure DeQueueSearchInBackground()
    var
        TableTypeID: Integer;
    begin
        if NoOfParallelTasks = 0 then
            NoOfParallelTasks := 5;
        if QueuedSearches.Count() = 0 then
            exit;
        if ActiveSearches.Count() >= NoOfParallelTasks then
            exit;
        while (QueuedSearches.Count() > 0) and (ActiveSearches.Count() < NoOfParallelTasks) do begin
            QueuedSearches.Get(1, TableTypeID);
            if StartSearchInBackground(TableTypeID) then // will add to ActiveSearches.
                QueuedSearches.Remove(TableTypeID);
        end;
    end;

    local procedure StartSearchInBackground(TableTypeID: Integer): Boolean
    var
        Args: Dictionary of [Text, Text];
        NewTaskID: Integer;
    begin
        if TableTypeID = 0 then
            exit;
        Args.Add('TableTypeID', Format(TableTypeID));
        Args.Add('SearchString', SearchString);
        if not CurrPage.EnqueueBackgroundTask(NewTaskID, Codeunit::"Data Search in Table", Args) then
            exit(false);
        ActiveSearches.Add(NewTaskID, TableTypeID);
        exit(true);
    end;

    local procedure CancelRunningTasks()
    var
        TaskId: Integer;
    begin
        foreach TaskId in ActiveSearches.Keys do
            if CurrPage.CancelBackgroundTask(TaskId) then;
        Clear(ActiveSearches);
        Clear(QueuedSearches);
    end;

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    var
        TableTypeID: Integer;
    begin
        if not ActiveSearches.ContainsKey(TaskId) then
            exit;
        TableTypeID := ActiveSearches.Get(TaskId);
        ActiveSearches.Remove(TaskId);
        if (ActiveSearches.Count() = 0) and (QueuedSearches.Count() = 0) then
            Notification.Recall()
        else
            DeQueueSearchInBackground();

        AddResults(TableTypeID, Results);
        if (ActiveSearches.Count() = 0) and (QueuedSearches.Count() = 0) then
            CurrPage.Update(true);
    end;

    protected procedure AddResults(TableTypeId: Integer; var Results: Dictionary of [Text, Text])
    begin
        CurrPage.LinesPart.Page.AddResults(TableTypeID, Results);
    end;

    trigger OnPageBackgroundTaskError(TaskId: Integer; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text; var IsHandled: Boolean)
    begin
        IsHandled := true;
        if ActiveSearches.ContainsKey(TaskID) then
            ActiveSearches.Remove(TaskId);
        DeQueueSearchInBackground();
    end;

    procedure SetSearchString(NewSearchString: Text)
    begin
        SearchString := NewSearchString;
    end;
}