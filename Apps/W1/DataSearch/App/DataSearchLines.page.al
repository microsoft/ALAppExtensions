page 2681 "Data Search lines"
{
    PageType = ListPart;
    Caption = 'Results';
    SourceTable = "Data Search Result";
    SourceTableTemporary = true;
    InsertAllowed = false;
    DeleteAllowed = false;

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
                Caption = 'Show tables to search';
                ToolTip = 'Opens a page that lists which tables are searched for your role center. If you have permissions, you can change which tables and fields are searched.';
                Image = AddWatch;

                trigger OnAction()
                begin
                    Page.RunModal(Page::"Data Search Setup (Table) List");
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
        [InDataSet]
        GetStyleExprTxt: Text;
        MoreRecLbl: Label '%1: Show all results', Comment = '%1 is a table name, e.g. Customer';
        SearchString: Text;
        UnsortableDescription: Text;
        RoleCenterID: Integer;

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
                Rec."No. of Hits" := 2000000000 - DataSearchSetupTable."No. of Hits";
                Rec."Parent ID" := RecID;
                Rec.Description := '  ' + CopyStr(NewResults.Values.Get(i), 1, MaxStrLen(Rec.Description) - 2);
                if i < 4 then
                    Rec."Line Type" := Rec."Line Type"::Data
                else
                    Rec."Line Type" := Rec."Line Type"::MoreData;
                Rec.Insert();
            end;
        SetDefaultView();
    end;

    internal procedure ClearResults();
    begin
        Rec.Reset();
        Rec.DeleteAll();
        SetDefaultView();
        CurrPage.Update(false);
    end;
}