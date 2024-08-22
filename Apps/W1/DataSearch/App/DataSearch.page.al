namespace Microsoft.Foundation.DataSearch;

using System.Telemetry;

#pragma warning disable AS0040 // SourceTable has been removed
page 2680 "Data Search"
#pragma warning restore AS0040
{
    PageType = ListPlus;
    Caption = 'Search in company data';
    ApplicationArea = All;
    AboutTitle = 'About Search in company data';
    AboutText = 'Enter one or more search words in the search field. To see what data is being searched, select Set up where to search.';
    InherentEntitlements = X;

    layout
    {
        area(Content)
        {
            group(SearchStringgrp)
            {
                ShowCaption = false;
                field(SearchString; DisplaySearchString)
                {
                    Caption = 'Search for (min. 3 characters)';
#pragma warning disable AA0219
                    ToolTip = 'Specify at least three characters to search for. You can enter multiple search words, and we will only find data that contains all words.';
#pragma warning restore AA0219
                    ApplicationArea = All;
                    Style = Subordinate;
                    StyleExpr = SearchInProgress;

                    trigger OnValidate()
                    var
                        DataSearchInTable: Codeunit "Data Search in Table";
                        SearchStrings: List of [Text];
                        FirstString: Text;
                    begin
                        SearchString := DelChr(DisplaySearchString, '<>', ' ');
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
            part(LinesPart; "Data Search lines")
            {
                ApplicationArea = All;
                UpdatePropagation = Both;
            }
            group(lines)
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'Unnecessary';
                ObsoleteTag = '23.0';
                Visible = false;
                ShowCaption = false;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Search)
            {
                ApplicationArea = All;
                Caption = 'Start search';
                ToolTip = 'Starts the search.';
                Image = Find;
                Enabled = SearchString <> '';

                trigger OnAction()
                begin
                    LaunchDeltaSearch();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Search', Comment = 'Generated from the PromotedActionCategories property index 1.';

                actionref(Contact_Promoted; Search)
                {
                }
            }
        }
    }

    var
        SearchString: Text;
        DisplaySearchString: Text;
        SearchInProgress: Boolean;
        ActiveSearches: Dictionary of [Integer, Integer];
        QueuedSearches: List of [Integer];
        NoOfParallelTasks: Integer;
        NoTablesDefinedErr: Label 'No tables defined for search.';
        StatusSearchLbl: Label 'Searching for "%1"...', Comment = '%1 can be any text';
        DataSearchStartedTelemetryLbl: Label 'Data Search started', Locked = true;
        TelemetryCategoryLbl: Label 'Data Search', Locked = true;

    trigger OnInit()
    begin
        NoOfParallelTasks := 6;
        SearchString := '';
    end;

    trigger OnOpenPage()
    begin
        if SearchString <> '' then
            LaunchSearch();
    end;

    trigger OnClosePage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        FeatureUptakeStatus: Enum "Feature Uptake Status";
    begin
        FeatureTelemetry.LogUptake('0000IOJ', TelemetryCategoryLbl, FeatureUptakeStatus::Discovered);
    end;

    internal procedure LaunchSearch()
    var
        DataSearchSetupTable: Record "Data Search Setup (Table)";
        DataSearchDefaults: Codeunit "Data Search Defaults";
        DataSearchInTable: Codeunit "Data Search in Table";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        SearchStrings: List of [Text];
        Dimensions: Dictionary of [Text, Text];
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

        SearchInProgress := true;
        DisplaySearchString := StrSubstNo(StatusSearchLbl, SearchString);
        repeat
            QueueSearchInBackground(DataSearchSetupTable."Table/Type ID");
            NoOfTablesToSearch += 1;
        until DataSearchSetupTable.Next() = 0;

        DataSearchInTable.SplitSearchString(SearchString, SearchStrings);

        Dimensions.Add('NumberOfSearchWords', Format(SearchStrings.Count()));
        Dimensions.Add('NumberOfTablesToSearch', Format(NoOfTablesToSearch));
        FeatureTelemetry.LogUsage('0000I9B', TelemetryCategoryLbl, DataSearchStartedTelemetryLbl, Dimensions);
    end;

    local procedure LaunchDeltaSearch()
    var
        ModifiedTablesSetup: List of [Integer];
        TableTypeID: Integer;
    begin
        if SearchString = '' then
            exit;
        if CurrPage.LinesPart.Page.HasChangedSetupNotification() then begin
            ModifiedTablesSetup := CurrPage.LinesPart.Page.GetModifiedSetup();
            CurrPage.LinesPart.Page.RemoveResultsForModifiedSetup();
            CurrPage.LinesPart.Page.RecallLastNotification();
            if ModifiedTablesSetup.Count() > 0 then begin
                CancelRunningTasks();
                SearchInProgress := true;
                DisplaySearchString := StrSubstNo(StatusSearchLbl, SearchString);
                foreach TableTypeID in ModifiedTablesSetup do
                    QueueSearchInBackground(TableTypeID);
            end;
        end else
            LaunchSearch();
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
            DisplaySearchString := SearchString
        else
            DeQueueSearchInBackground();

        AddResults(TableTypeID, Results);
        if (ActiveSearches.Count() = 0) and (QueuedSearches.Count() = 0) then begin
            SearchInProgress := false;
            CurrPage.Update(false);
        end;
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
        SearchString := DelChr(NewSearchString, '<>', ' ');
    end;
}