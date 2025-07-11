namespace Microsoft.Foundation.DataSearch;

page 2681 "Data Search lines"
{
    PageType = ListPart;
    Caption = 'Results';
    SourceTable = "Data Search Result";
    SourceTableTemporary = true;
    ShowFilter = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(Content)
        {
            repeater(SearchTables)
            {
                field(Description; UnsortableDescription)
                {
                    Caption = 'Description';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the found entry.';
                    StyleExpr = GetStyleExprTxt;

                    trigger OnDrillDown()
                    begin
                        if ErrorMessages.ContainsKey(Rec."Table/Type ID") then
                            Message(ErrorMessages.Get(Rec."Table/Type ID"))
                        else
                            Rec.ShowRecord(RoleCenterID, SearchString);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Setup)
            {
                ApplicationArea = All;
                Caption = 'Set up which tables to search';
                ToolTip = 'Opens a page that lists which tables are enabled for search for your role center. If you have permissions, you can change which tables and fields are searched.';
                Image = SetupColumns;
                Visible = false;

                trigger OnAction()
                begin
                    RunSetupPage(Page::"Data Search Setup (Table) List");
                end;
            }
            action(SetupLists)
            {
                ApplicationArea = All;
                Caption = 'Set up where to search';
                ToolTip = 'Opens a page that shows which lists are enabled for search for your role center. If you have permissions, you can change which lists, tables and fields are searched.';
                Image = ShowList;

                trigger OnAction()
                begin
                    RunSetupPage(Page::"Data Search Setup (Lists)");
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        SetDefaultView();
    end;

    trigger OnAfterGetRecord()
    begin
        GetStyleExprTxt := Rec.GetStyleExpr();
        UnsortableDescription := Rec.Description;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        GetStyleExprTxt := Rec.GetStyleExpr();
    end;

    var
        ModifiedTablesSetup: List of [Integer];
        RemovedTablesSetup: List of [Integer];
        ErrorMessages: Dictionary of [Integer, Text];
        GetStyleExprTxt: Text;
        MoreRecLbl: Label '%1: Show all results', Comment = '%1 is a table name, e.g. Customer';
        SearchString: Text;
        UnsortableDescription: Text;
        RoleCenterID: Integer;
        LastChangedSetupNotification: Guid;

    internal procedure SetSearchParams(NewSearchString: Text; NewRoleCenterID: Integer)
    begin
        SearchString := NewSearchString;
        RoleCenterID := NewRoleCenterID;
    end;

    local procedure SetDefaultView()
    begin
        Rec.Reset();
        Rec.SetCurrentKey("No. of Hits", "Table No.", "Table Subtype", "Entry No.");  // note that "No. of Hits" is 'inverted' so it becomes descending
        Rec.SetFilter("Line Type", '%1|%2|%3', Rec."Line Type"::Header, Rec."Line Type"::Data, Rec."Line Type"::MoreHeader);
    end;

    internal procedure AddResults(TableTypeID: Integer; var NewResults: Dictionary of [Text, Text])
    var
        DataSearchSetupTable: Record "Data Search Setup (Table)";
        TableNo: Integer;
        TableSubtype: Integer;
        i: Integer;
        RecID: Guid;
        SearchErr: Label 'NB! Search failed. Drill down to see the error.';
    begin
        if NewResults.Count() = 0 then
            exit;

        DataSearchSetupTable.SetRange("Table/Type ID", TableTypeID);
        if not DataSearchSetupTable.FindFirst() then
            exit;
        TableNo := DataSearchSetupTable."Table No.";
        TableSubtype := DataSearchSetupTable."Table Subtype";

        if not Rec.Get(TableNo, TableSubtype, 0) then begin
            Rec.Init();
            Rec."Table No." := TableNo;
            Rec."Table Subtype" := TableSubtype;
            Rec."Table/Type ID" := TableTypeID;
            Rec."Entry No." := 0;
            Rec."No. of Hits" := 2000000000 - DataSearchSetupTable."No. of Hits";
            Rec."Line Type" := Rec."Line Type"::Header;
            Rec.Description := copystr(Rec.GetTableCaption(), 1, MaxStrLen(Rec.Description));
            Rec.Insert();
        end;
        Rec.Reset();
        if Rec.FindLast() then;
        for i := 1 to NewResults.Count() do
            if evaluate(RecID, NewResults.Keys.Get(i)) then begin
                if i >= 4 then begin
                    Rec."Entry No." += 1;
                    Rec."Table No." := TableNo;
                    Rec."Table Subtype" := TableSubtype;
                    Rec."Table/Type ID" := TableTypeID;
                    Rec."No. of Hits" := 2000000000 - DataSearchSetupTable."No. of Hits";
                    Clear(Rec."Parent ID");
                    Rec."Line Type" := Rec."Line Type"::MoreHeader;
                    Rec.CalcFields("Table Caption");
                    Rec.Description := '  ' + CopyStr(StrSubstNo(MoreRecLbl, Rec.GetTableCaption()), 1, MaxStrLen(Rec.Description) - 2);
                    Rec.Insert();
                end;
                Rec."Entry No." += 1;
                Rec."Table No." := TableNo;
                Rec."Table Subtype" := TableSubtype;
                Rec."Table/Type ID" := TableTypeID;
                Rec."No. of Hits" := 2000000000 - DataSearchSetupTable."No. of Hits";
                Rec."Parent ID" := RecID;
                Rec.Description := '  ' + CopyStr(NewResults.Values.Get(i), 1, MaxStrLen(Rec.Description) - 2);
                if i < 4 then
                    Rec."Line Type" := Rec."Line Type"::Data
                else
                    Rec."Line Type" := Rec."Line Type"::MoreData;
                Rec.Insert();
            end else
                if NewResults.Keys.Get(i) = '*ERROR*' then begin
                    Rec."Entry No." += 1;
                    Rec."Table No." := TableNo;
                    Rec."Table Subtype" := TableSubtype;
                    Rec."Table/Type ID" := TableTypeID;
                    Rec."No. of Hits" := 2000000000 - DataSearchSetupTable."No. of Hits";
                    Clear(Rec."Parent ID");
                    Rec.Description := '  ' + CopyStr(SearchErr, 1, MaxStrLen(Rec.Description) - 2);
                    Rec."Line Type" := Rec."Line Type"::Data;
                    Rec.Insert();
                    ErrorMessages.Add(Rec."Table/Type ID", NewResults.Values.Get(i));
                end;
        SetDefaultView();
    end;

    internal procedure ClearResults();
    begin
        Rec.Reset();
        Rec.DeleteAll();
        SetDefaultView();
        RecallLastNotification();
        Clear(ErrorMessages);
        CurrPage.Update(false);
    end;

    local procedure RunSetupPage(PageNo: Integer)
    var
        DataSearchSetupChanges: Codeunit "Data Search Setup Changes";
        ChangedSetupNotification: Notification;
        TrackChanges: Boolean;
        SetupChangedMsg: Label 'You have made changes to the setup. Please select the Start search action for the new settings to take effect.';
    begin
        TrackChanges := SearchString <> '';
        if TrackChanges then
            RecallLastNotification();
        BindSubscription(DataSearchSetupChanges);
        Page.RunModal(PageNo);
        if TrackChanges then
            UnbindSubscription(DataSearchSetupChanges)
        else
            exit;
        ModifiedTablesSetup := DataSearchSetupChanges.GetModifiedSetup();
        RemovedTablesSetup := DataSearchSetupChanges.GetRemovedSetup();
        if (ModifiedTablesSetup.Count() = 0) and (RemovedTablesSetup.Count() = 0) then
            exit;
        ChangedSetupNotification.Scope := ChangedSetupNotification.Scope::LocalScope;
        ChangedSetupNotification.Message(SetupChangedMsg);
        ChangedSetupNotification.Send();
        LastChangedSetupNotification := ChangedSetupNotification.Id;
    end;

    internal procedure GetModifiedSetup(): List of [Integer];
    begin
        exit(ModifiedTablesSetup);
    end;

    internal procedure RemoveResultsForModifiedSetup();
    begin
        if (ModifiedTablesSetup.Count() = 0) and (RemovedTablesSetup.Count() = 0) then
            exit;
        Rec.Reset();
        RemoveResultsForTableTypeIDList(ModifiedTablesSetup);
        RemoveResultsForTableTypeIDList(RemovedTablesSetup);
        SetDefaultView();
        CurrPage.Update();
        clear(ModifiedTablesSetup);
        clear(RemovedTablesSetup);
    end;

    local procedure RemoveResultsForTableTypeIDList(var TablesSetup: List of [Integer])
    var
        TableTypeID: Integer;
    begin
        if TablesSetup.Count() = 0 then
            exit;
        foreach TableTypeID in TablesSetup do begin
            Rec.SetRange("Table/Type ID", TableTypeID);
            Rec.DeleteAll();
        end;
        Rec.SetRange("Table/Type ID");
    end;

    internal procedure HasChangedSetupNotification(): Boolean
    var
        NullGuid: Guid;
    begin
        exit(LastChangedSetupNotification <> NullGuid);
    end;

    internal procedure RecallLastNotification()
    var
        ChangedSetupNotification: Notification;
    begin
        if not HasChangedSetupNotification() then
            exit;
        ChangedSetupNotification.Id := LastChangedSetupNotification;
        if ChangedSetupNotification.Recall() then;
        Clear(LastChangedSetupNotification);
    end;
}