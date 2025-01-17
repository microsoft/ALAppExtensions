namespace Microsoft.Foundation.DataSearch;

using System.Environment.Configuration;
using System.Reflection;

page 2686 "Data Search Setup (Lists)"
{
    Caption = 'Enable lists for searching';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = true;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "Page Metadata";
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(content)
        {
            field(RoleName; AllProfile.Caption)
            {
                ApplicationArea = All;
                Caption = 'Choose among lists for role';
                Editable = false;
                ToolTip = 'Specifies which role the search setup is valid for.';

                trigger OnAssistEdit()
                var
                    TempAllProfile: Record "All Profile" temporary;
                    DataSearchDefaults: Codeunit "Data Search Defaults";
                    NewProfileID: Code[30];
                begin
                    DataSearchDefaults.PopulateProfiles(TempAllProfile);
                    TempAllProfile := AllProfile;
                    if Page.RunModal(Page::Roles, TempAllProfile) = Action::LookupOK then begin
                        AllProfile := TempAllProfile;
                        NewProfileID := AllProfile."Profile ID";
                        RoleCenterID := AllProfile."Role Center ID";
                        if NewProfileID <> ProfileID then begin
                            ProfileID := NewProfileID;
                            RefreshProfileSelection(RoleCenterID);
                            CurrPage.Update(false);
                        end;
                    end;
                end;
            }
            field(ShowAll; TableFilterIsSet)
            {
                ApplicationArea = All;
                Caption = 'Show only search enabled lists';
                ToolTip = 'Specifies whether only the enabled lists are shown or all lists are shown.';
                trigger OnValidate()
                begin
                    if TableFilterIsSet then
                        SetEnabledTablesFilter(RoleCenterID)
                    else begin
                        Rec.SetRange(ID);
                        TableFilterIsSet := false;
                    end;
                    CurrPage.Update(false);
                end;
            }
            repeater(Control1)
            {
                ShowCaption = false;
                field(ObjectID; Rec.ID)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'List No.';
                    Editable = false;
                    ToolTip = 'Specifies the ID of the page. ';
                }
                field(ObjectCaption; Rec.Caption)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'List Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of the list.';

                    trigger OnAssistEdit()
                    begin
                        AssistEdit();
                    end;
                }
                field(ListIsEnabledCtrl; ListIsEnabled)
                {
                    ApplicationArea = All;
                    Caption = 'Enable Search';
                    ToolTip = 'Specifies whether this list is included in search.';

                    trigger OnValidate()
                    begin
                        UpdateRec();
                    end;
                }
                field(TableCaption; TableMetadata.Caption)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Main Source Table';
                    Enabled = false;
                    Style = Subordinate;
                    ToolTip = 'Specifies the base table name of the list.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ResetSetup)
            {
                ApplicationArea = All;
                AccessByPermission = TableData "Data Search Setup (Table)" = IMD;
                Caption = 'Reset to default';
                ToolTip = 'Removes the current selection for this rolecenter and inserts the default list selection.';
                Image = Restore;

                trigger OnAction()
                begin
                    if not Confirm(ResetQst, false) then
                        exit;
                    RemoveSetup();
                    RefreshProfileSelection(RoleCenterID);
                end;
            }
            action(ShowAllLists)
            {
                ApplicationArea = All;
                AccessByPermission = TableData "Data Search Setup (Table)" = IMD;
                Caption = 'All lists';
                ToolTip = 'Select this action if you want to see all lists and/or select more lists to be included in the search.';
                Image = ShowList;
                Enabled = TableFilterIsSet;
                Visible = false;

                trigger OnAction()
                begin
                    Rec.SetRange(ID);
                    TableFilterIsSet := false;
                end;
            }
            action(ShowEnabledLists)
            {
                ApplicationArea = All;
                Caption = 'Only enabled lists';
                ToolTip = 'Compacts the view, so you only see the lists that have been enabled for search.';
                Image = FilterLines;
                Enabled = not TableFilterIsSet;
                Visible = false;

                trigger OnAction()
                begin
                    SetEnabledTablesFilter(RoleCenterID);
                end;
            }
        }
        area(Promoted)
        {
            actionref(ShowAllTables_Promoted; ShowAllLists)
            {
            }
            actionref(ShowFilteredTables_Promoted; ShowEnabledLists)
            {
            }
            actionref(ResetSetup_Promoted; ResetSetup)
            {
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        exit(FindRec(Rec, Which));
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin
        exit(NextRec(Rec, Steps));
    end;

    trigger OnAfterGetRecord()
    begin
        GetRec();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        GetRec();
    end;

    trigger OnOpenPage()
    begin
        ProfileID := DataSearchSetupTable.GetProfileID();
        AllProfile.SetRange("Profile ID", ProfileID);
        if AllProfile.FindFirst() then;
        RoleCenterID := AllProfile."Role Center ID";
        AllProfile.SetRange("Profile ID");
        RefreshProfileSelection(RoleCenterID);
        Rec.FilterGroup(2);
        Rec.SetRange(ID, 1, 2000000000 - 1);
        Rec.SetFilter(SourceTable, '>0');
        Rec.SetRange(SourceTableTemporary, false);
        Rec.SetFilter(PageType, '%1|%2|%3', Rec.PageType::List, Rec.PageType::ListPlus, Rec.PageType::Worksheet);
        Rec.FilterGroup(0);
    end;

    var
        DataSearchSetupTable: Record "Data Search Setup (Table)";
        TempDataSearchSetupTable: Record "Data Search Setup (Table)" temporary;
        AllProfile: Record "All Profile";
        TableMetadata: Record "Table Metadata";
        ListIsEnabled: Boolean;
        TableFilterIsSet: Boolean;
        ProfileID: Code[30];
        RoleCenterID: Integer;
        ResetQst: Label 'Do you want to remove the current setup and insert the default?';


    internal procedure FindRec(var PageMetadata: Record "Page Metadata"; Which: Text): Boolean
    var
        Found: Boolean;
        i: Integer;
    begin
        for i := 1 to StrLen(Which) do begin
            Found := PageMetadata.Find(Which[i]);
            if Found then
                while Found and not ValidateAgainstFilteredRecord(PageMetadata) do
                    case Which[i] of
                        '=':
                            Found := false;
                        '<', '>':
                            Found := PageMetadata.Find(Which[i]);
                        '-':
                            Found := PageMetadata.Next() <> 0;
                        '+':
                            Found := PageMetadata.Next(-1) <> 0;
                    end;
            if Found then
                exit(true);
        end;
        exit(false);
    end;

    internal procedure NextRec(var PageMetadata: Record "Page Metadata"; Steps: Integer) ResultSteps: Integer
    var
        Step: Integer;
    begin
        if Steps > 0 then
            Step := 1
        else
            Step := -1;
        ResultSteps := PageMetadata.Next(Step);
        if ResultSteps = 0 then
            exit(0);
        while (ResultSteps <> 0) and not ValidateAgainstFilteredRecord(PageMetadata) do
            ResultSteps := PageMetadata.Next(Step);
        exit(ResultSteps);
    end;

    local procedure ValidateAgainstFilteredRecord(var PageMetadata: Record "Page Metadata"): Boolean
    var
        DataSearchObjectMapping: Codeunit "Data Search Object Mapping";
    begin
        if PageMetadata.SourceTable = 0 then
            exit(false);
        if not TableMetadata.Get(PageMetadata.SourceTable) then
            exit(false);
        exit(PageMetadata.ID = DataSearchObjectMapping.GetListPageNo(PageMetadata.SourceTable, DataSearchObjectMapping.GetTableSubTypeFromPage(Rec.ID)));
    end;

    local procedure AssistEdit()
    var
        Field: Record Field;
        DataSearchObjectMapping: Codeunit "Data Search Object Mapping";
        DataSearchSetupFieldList: Page "Data Search Setup (Field) List";
        TableNos: List of [Integer];
        TableNo: Integer;
        TableFilter: TextBuilder;
    begin
        TableNos := DataSearchObjectMapping.GetSubTableNos(Rec.SourceTable);
        TableNos.Add(Rec.SourceTable);
        foreach TableNo in TableNos do begin
            if TableFilter.Length > 0 then
                TableFilter.Append('|');
            TableFilter.Append(Format(TableNo));
        end;
        Field.FilterGroup(2);
        Field.SetFilter(TableNo, TableFilter.ToText());
        Field.SetFilter(ObsoleteState, '<>%1', Field.ObsoleteState::Removed);
        Field.SetRange(Class, Field.Class::Normal);
        Field.SetFilter(Type, '%1|%2', Field.Type::Code, Field.Type::Text);
        Field.FilterGroup(0);
        DataSearchSetupFieldList.SetTableView(Field);
        DataSearchSetupFieldList.SetPageCaption(Rec.Caption);
        DataSearchSetupFieldList.RunModal();
    end;

    local procedure RefreshProfileSelection(NewRoleCenterID: Integer)
    begin
        TempDataSearchSetupTable.Reset();
        TempDataSearchSetupTable.DeleteAll();
        InitSetup(RoleCenterID);
        DataSearchSetupTable.SetRange("Role Center ID", NewRoleCenterID);
        if DataSearchSetupTable.FindSet() then
            repeat
                TempDataSearchSetupTable := DataSearchSetupTable;
                TempDataSearchSetupTable.Insert();
            until DataSearchSetupTable.Next() = 0;
        SetEnabledTablesFilter(NewRoleCenterID);
    end;

    local procedure UpdateRec()
    begin
        if not ListIsEnabled then begin
            DataSearchSetupTable.DeleteRec(false);  // deletes for sub tables, e.g. sales line
            TempDataSearchSetupTable.DeleteRec(false);
        end else begin
            DataSearchSetupTable.InsertRec(false); // inserts for sub tables, e.g. sales line
            TempDataSearchSetupTable.InsertRec(false);
        end;
    end;

    local procedure GetRec()
    var
        DataSearchObjectMapping: Codeunit "Data Search Object Mapping";
    begin
        if not TempDataSearchSetupTable.Get(RoleCenterID, Rec.SourceTable, DataSearchObjectMapping.GetTableSubTypeFromPage(Rec.ID)) then begin
            DataSearchSetupTable.Init();
            DataSearchSetupTable."Table No." := Rec.SourceTable;
            DataSearchSetupTable."Table Subtype" := DataSearchObjectMapping.GetTableSubTypeFromPage(Rec.ID);
            DataSearchSetupTable."Role Center ID" := RoleCenterID;
            TempDataSearchSetupTable := DataSearchSetupTable;
            ListIsEnabled := false;
        end else begin
            DataSearchSetupTable := TempDataSearchSetupTable;
            ListIsEnabled := true;
        end;
        if not TableMetadata.Get(Rec.SourceTable) then
            Clear(TableMetadata);
    end;

    local procedure SetEnabledTablesFilter(NewRoleCenterID: Integer)
    var
        DataSearchObjectMapping: Codeunit "Data Search Object Mapping";
        EnabledTablesCount: Integer;
        FilterTxt: TextBuilder;
    begin
        TempDataSearchSetupTable.SetRange("Role Center ID", NewRoleCenterID);
        if TempDataSearchSetupTable.FindSet() then
            repeat
                EnabledTablesCount += 1;
                if EnabledTablesCount > 1000 then begin
                    Rec.SetRange(ID);
                    exit;
                end;
                if EnabledTablesCount > 1 then
                    FilterTxt.Append('|');
                FilterTxt.Append(Format(DataSearchObjectMapping.GetListPageNo(TempDataSearchSetupTable."Table No.", TempDataSearchSetupTable."Table Subtype")));
            until TempDataSearchSetupTable.Next() = 0;
        TempDataSearchSetupTable.SetRange("Table Subtype");
        Rec.SetFilter(ID, FilterTxt.ToText());
        TableFilterIsSet := true;
    end;

    internal procedure InitSetup(NewRoleCenterID: Integer)
    var
        DataSearchDefaults: Codeunit "Data Search Defaults";
    begin
        DataSearchSetupTable.SetRange("Role Center ID", NewRoleCenterID);
        if not DataSearchSetupTable.IsEmpty then
            exit;
        DataSearchDefaults.InitSetupForProfile(NewRoleCenterID);
    end;

    local procedure RemoveSetup()
    var
        DataSearchSetupTable2: Record "Data Search Setup (Table)";
        DataSearchSetupField: Record "Data Search Setup (Field)";
    begin
        DataSearchSetupTable2.SetRange("Role Center ID", RoleCenterID);
        DataSearchSetupTable2.DeleteAll();
        DataSearchSetupTable2.SetRange("Role Center ID");
        if DataSearchSetupTable2.IsEmpty() then
            DataSearchSetupField.DeleteAll();
    end;
}