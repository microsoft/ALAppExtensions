page 2683 "Data Search Setup (Table) List"
{
    Caption = 'Search Setup (Table) List';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = true;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = AllObjWithCaption;

    layout
    {
        area(content)
        {
            field(RoleName; AllProfile.Caption)
            {
                ApplicationArea = All;
                Caption = 'Role';
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
            repeater(Control1)
            {
                ShowCaption = false;
                field(ObjectID; Rec."Object ID")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Table No.';
                    Editable = false;
                    ToolTip = 'Specifies the ID of the table. ';
                }
                field(ObjectCaption; Rec."Object Caption")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Table Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of the table.';

                    trigger OnAssistEdit()
                    begin
                        AssistEdit();
                    end;
                }
                field(TableIsEnabledCtrl; TableIsEnabled)
                {
                    ApplicationArea = All;
                    Caption = 'Search Enabled';
                    ToolTip = 'Specifies whether this table is included in search.';

                    trigger OnValidate()
                    begin
                        UpdateRec();
                    end;
                }
            }
        }
        area(FactBoxes)
        {
            part(EnabledFields; "Data Search Setup (Field) Part")
            {
                ApplicationArea = All;
                SubPageLink = "Table No." = field("Object ID");
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
                Caption = 'Reset to default';
                ToolTip = 'Removes the current selection for this rolecenter and inserts the default table selection.';
                Image = Restore;

                trigger OnAction()
                begin
                    if not Confirm(ResetQst, false) then
                        exit;
                    RemoveSetup();
                    RefreshProfileSelection(RoleCenterID);
                end;
            }
            action(ShowAllTables)
            {
                ApplicationArea = All;
                Caption = 'Show all tables';
                ToolTip = 'Select this action if you want to see all tables and/or select more tables to be included in the search.';
                Image = ShowList;
                Enabled = TableFilterIsSet;

                trigger OnAction()
                begin
                    Rec.SetRange("Object ID");
                    TableFilterIsSet := false;
                end;
            }
            action(ShowFilteredTables)
            {
                ApplicationArea = All;
                Caption = 'Filter to selected tables';
                ToolTip = 'Compacts the view, so you only see the tables that have been selected for search.';
                Image = FilterLines;
                Enabled = not TableFilterIsSet;

                trigger OnAction()
                begin
                    SetEnabledTablesFilter(RoleCenterID);
                end;
            }
        }
    }

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
        Rec.SetRange("Object Type", Rec."Object Type"::Table);
        Rec.SetRange("Object ID", 1, 2000000000 - 1);
        Rec.SetRAnge("Object Subtype", 'Normal');
        Rec.FilterGroup(0);
    end;

    var
        DataSearchSetupTable: Record "Data Search Setup (Table)";
        TempDataSearchSetupTable: Record "Data Search Setup (Table)" temporary;
        AllProfile: Record "All Profile";
        [InDataSet]
        TableIsEnabled: Boolean;
        TableFilterIsSet: Boolean;
        ProfileID: Code[30];
        RoleCenterID: Integer;
        ResetQst: Label 'Do you want to remove the current setup and insert the default?';

    local procedure AssistEdit()
    var
        "Field": Record "Field";
        DataSearchSetupFieldList: Page "Data Search Setup (Field) List";
    begin
        Field.FilterGroup(2);
        Field.SetRange(TableNo, Rec."Object ID");
        Field.SetFilter(ObsoleteState, '<>%1', Field.ObsoleteState::Removed);
        Field.SetRange(Class, Field.Class::Normal);
        Field.SetFilter(Type, '%1|%2', Field.Type::Code, Field.Type::Text);
        Field.FilterGroup(0);
        DataSearchSetupFieldList.SetTableView(Field);
        DataSearchSetupFieldList.Run();
    end;

    local procedure RefreshProfileSelection(NewRoleCenterID: Integer)
    begin
        TempDataSearchSetupTable.DeleteAll();
        InitSetup(RoleCenterID);
        DataSearchSetupTable.SetRange("Role Center ID", NewRoleCenterID);
        DataSearchSetupTable.SetRange("Table Subtype", 0);
        if DataSearchSetupTable.FindSet() then
            repeat
                TempDataSearchSetupTable := DataSearchSetupTable;
                TempDataSearchSetupTable.Insert();
            until DataSearchSetupTable.Next() = 0;
        SetEnabledTablesFilter(NewRoleCenterID);
    end;

    local procedure UpdateRec()
    begin
        if not TableIsEnabled then begin
            if DataSearchSetupTable.Delete(true) then;  // deletes for all table subtypes
            if TempDataSearchSetupTable.Delete() then;
        end else begin
            if not DataSearchSetupTable.Insert(true) then; // inserts for all table subtypes
            if not TempDataSearchSetupTable.Insert() then;
        end;
    end;

    local procedure GetRec()
    begin
        if not TempDataSearchSetupTable.Get(RoleCenterID, Rec."Object ID", 0) then begin
            DataSearchSetupTable.Init();
            DataSearchSetupTable."Table No." := Rec."Object ID";
            DataSearchSetupTable."Table Subtype" := 0;
            DataSearchSetupTable."Role Center ID" := RoleCenterID;
            TempDataSearchSetupTable := DataSearchSetupTable;
            TableIsEnabled := false;
        end else begin
            DataSearchSetupTable := TempDataSearchSetupTable;
            TableIsEnabled := true;
        end;
    end;

    local procedure SetEnabledTablesFilter(NewRoleCenterID: Integer)
    var
        DataSearchSetupTable2: Record "Data Search Setup (Table)";
        EnabledTablesCount: Integer;
        FilterTxt: TextBuilder;
    begin
        DataSearchSetupTable2.SetRange("Role Center ID", NewRoleCenterID);
        DataSearchSetupTable2.SetRange("Table Subtype", 0);
        DataSearchSetupTable2.SetLoadFields("Table No.");
        if DataSearchSetupTable2.FindSet() then
            repeat
                EnabledTablesCount += 1;
                if EnabledTablesCount > 1000 then begin
                    Rec.SetRange("Object ID");
                    exit;
                end;
                if EnabledTablesCount > 1 then
                    FilterTxt.Append('|');
                FilterTxt.Append(Format(DataSearchSetupTable2."Table No."));
            until DataSearchSetupTable2.Next() = 0;
        Rec.SetFilter("Object ID", FilterTxt.ToText());
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