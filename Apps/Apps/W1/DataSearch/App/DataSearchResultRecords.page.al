namespace Microsoft.Foundation.DataSearch;

using System.Utilities;

page 2682 "Data Search Result Records"
{
    Caption = 'Search Result Records';
    DataCaptionExpression = TableCaptionTxt;
    LinksAllowed = false;
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Column,Record';
    ShowFilter = false;
    SourceTable = Integer;
    SourceTableView = where(Number = filter('>0'));
    InherentEntitlements = X;
    InherentPermissions = X;
    AnalysisModeEnabled = false;
    
    layout
    {
        area(content)
        {
            repeater(Control48)
            {
                Editable = false;

                field(ColumnValues1; ColumnValues[1])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + ColumnCaptions[1];
                    ToolTip = 'Specifies a field in the table.';

                    trigger OnDrillDown()
                    begin
                        DrillDown();
                    end;
                }
                field(ColumnValues2; ColumnValues[2])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + ColumnCaptions[2];
                    ToolTip = 'Specifies a field in the table.';
                    Visible = NoOfColumns >= 2;

                    trigger OnDrillDown()
                    begin
                        DrillDown();
                    end;
                }
                field(ColumnValues3; ColumnValues[3])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + ColumnCaptions[3];
                    ToolTip = 'Specifies a field in the table.';
                    Visible = NoOfColumns >= 3;

                    trigger OnDrillDown()
                    begin
                        DrillDown();
                    end;
                }
                field(ColumnValues4; ColumnValues[4])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + ColumnCaptions[4];
                    ToolTip = 'Specifies a field in the table.';
                    Visible = NoOfColumns >= 4;

                    trigger OnDrillDown()
                    begin
                        DrillDown();
                    end;
                }
                field(ColumnValues5; ColumnValues[5])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + ColumnCaptions[5];
                    ToolTip = 'Specifies a field in the table.';
                    Visible = NoOfColumns >= 5;

                    trigger OnDrillDown()
                    begin
                        DrillDown();
                    end;
                }
                field(ColumnValues6; ColumnValues[6])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + ColumnCaptions[6];
                    ToolTip = 'Specifies a field in the table.';
                    Visible = NoOfColumns >= 6;

                    trigger OnDrillDown()
                    begin
                        DrillDown();
                    end;
                }
                field(ColumnValues7; ColumnValues[7])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + ColumnCaptions[7];
                    ToolTip = 'Specifies a field in the table.';
                    Visible = NoOfColumns >= 7;

                    trigger OnDrillDown()
                    begin
                        DrillDown();
                    end;
                }
                field(ColumnValues8; ColumnValues[8])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + ColumnCaptions[8];
                    ToolTip = 'Specifies a field in the table.';
                    Visible = NoOfColumns >= 8;

                    trigger OnDrillDown()
                    begin
                        DrillDown();
                    end;
                }
                field(ColumnValues9; ColumnValues[9])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + ColumnCaptions[9];
                    ToolTip = 'Specifies a field in the table.';
                    Visible = NoOfColumns >= 9;

                    trigger OnDrillDown()
                    begin
                        DrillDown();
                    end;
                }
                field(ColumnValues10; ColumnValues[10])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + ColumnCaptions[10];
                    ToolTip = 'Specifies a field in the table.';
                    Visible = NoOfColumns >= 10;

                    trigger OnDrillDown()
                    begin
                        DrillDown();
                    end;
                }
                field(ColumnValues11; ColumnValues[11])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + ColumnCaptions[11];
                    ToolTip = 'Specifies a field in the table.';
                    Visible = NoOfColumns >= 11;

                    trigger OnDrillDown()
                    begin
                        DrillDown();
                    end;
                }
                field(ColumnValues12; ColumnValues[12])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + ColumnCaptions[12];
                    ToolTip = 'Specifies a field in the table.';
                    Visible = NoOfColumns >= 12;

                    trigger OnDrillDown()
                    begin
                        DrillDown();
                    end;
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            group(Columns)
            {
                Caption = 'Columns';
                Visible = NoOfColumns > 12;
                Image = NextRecord;
                action(PreviousColumn)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Previous Column';
                    Enabled = ColumnOffset > 0;
                    Image = PreviousRecord;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    ToolTip = 'Go to the previous column.';

                    trigger OnAction()
                    begin
                        AdjustColumnOffset(-1);
                    end;
                }
                action(NextColumn)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Next Column';
                    Enabled = ColumnOffset < NoOfColumnsMinus12;
                    Image = NextRecord;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    ToolTip = 'Go to the next column.';

                    trigger OnAction()
                    begin
                        AdjustColumnOffset(1);
                    end;
                }
            }
            group(Record)
            {
                Caption = 'Record';
                Image = Card;
                action(ShowRecord)
                {
                    Caption = 'Show Record';
                    Image = Card;
                    ApplicationArea = Basic, Suite;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    ToolTip = 'Open the record in its list or card page.';

                    trigger OnAction()
                    begin
                        DrillDown();
                    end;

                }
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    var
        FldRef: FieldRef;
        Found: Boolean;
        RecID: Guid;
    begin
        Clear(ColumnValues);
        if SourceRecRef.Number = 0 then
            exit(false);

        if ResultRecSet.Get(Rec.Number, RecID) then
            if SourceRecRef.GetBySystemId(RecID) then;
        Found := FindRecRef(SourceRecRef, Which);
        if Found then begin
            FldRef := SourceRecRef.Field(SourceRecRef.SystemIdNo);
            if not ResultRecSet.ContainsKey(Rec.Number) then
                ResultRecSet.Add(Rec.Number, FldRef.Value);
        end;
        exit(Found);
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    var
        FldRef: FieldRef;
        RecID: Guid;
        ResultSteps: Integer;
    begin
        Clear(ColumnValues);
        if SourceRecRef.Number = 0 then
            exit(0);

        if ResultRecSet.Get(Rec.Number, RecID) then
            if SourceRecRef.GetBySystemId(RecID) then;

        ResultSteps := NextRecRef(SourceRecRef, Steps);
        if ResultSteps <> 0 then begin
            ResultSteps := Rec.Next(ResultSteps);
            FldRef := SourceRecRef.Field(SourceRecRef.SystemIdNo);
            if not ResultRecSet.ContainsKey(Rec.Number) then
                ResultRecSet.Add(Rec.Number, FldRef.Value);
        end;
        exit(ResultSteps);
    end;

    local procedure FindRecRef(var RecRef: RecordRef; Which: Text): Boolean
    var
        DataSearchInTable: Codeunit "Data Search in Table";
        Found: Boolean;
        i: Integer;
    begin
        if RecRef.Number = 0 then
            exit(false);
        for i := 1 to StrLen(Which) do begin
            Found := RecRef.Find(Which[i]);
            if Found then
                while Found and not DataSearchInTable.IsFullMatch(SourceRecRef, SearchStrings, FieldList) do
                    case Which[i] of
                        '=':
                            Found := false;
                        '<', '>':
                            Found := RecRef.Find(Which[i]);
                        '-':
                            Found := RecRef.Next() <> 0;
                        '+':
                            Found := RecRef.Next(-1) <> 0;
                    end;
            if Found then
                exit(true);
        end;
        exit(false);
    end;

    local procedure NextRecRef(var RecRef: RecordRef; Steps: Integer) ResultSteps: Integer
    var
        DataSearchInTable: Codeunit "Data Search in Table";
        Step: Integer;
    begin
        if RecRef.Number = 0 then
            exit(0);
        if Steps > 0 then
            Step := 1
        else
            Step := -1;
        ResultSteps := RecRef.Next(Step);
        if ResultSteps = 0 then
            exit(0);
        while (ResultSteps <> 0) and not DataSearchInTable.IsFullMatch(SourceRecRef, SearchStrings, FieldList) do
            ResultSteps := RecRef.Next(Step);
        exit(ResultSteps);
    end;

    trigger OnAfterGetRecord()
    var
        FldRef: FieldRef;
        ColumnNo: Integer;
    begin
        Clear(ColumnValues);
        Clear(ColumnCaptions);
        for ColumnNo := 1 to SourceRecRef.FieldCount() do
            if (ColumnNo > ColumnOffset) and (ColumnNo - ColumnOffset <= ArrayLen(ColumnValues)) then begin
                FldRef := SourceRecRef.FieldIndex(ColumnNo);
                ColumnValues[ColumnNo - ColumnOffset] := copystr(Format(FldRef.Value), 1, 80);
                ColumnCaptions[ColumnNo - ColumnOffset] := copystr(Format(FldRef.Caption), 1, 80);
            end;
    end;

    trigger OnAfterGetCurrRecord()
    var
        RecID: Guid;
    begin
        if ResultRecSet.Get(Rec.Number, RecID) then
            if SourceRecRef.GetBySystemId(RecID) then;
    end;

    trigger OnOpenPage()
    begin
        NoOfColumns := SourceRecRef.FieldCount();
        NoOfColumnsMinus12 := NoOfColumns - 12;
        if SourceRecRef.FindFirst() then
            Rec.Get(1);
        if TableCaptionTxt = '' then
            TableCaptionTxt := SourceRecRef.Caption;
    end;

    var
        SourceRecRef: RecordRef;
        ResultRecSet: Dictionary of [Integer, Guid];
        TableCaptionTxt: Text;
        NoOfColumns: Integer;
        NoOfColumnsMinus12: Integer;
        ColumnOffset: Integer;
        ColumnValues: array[15] of Text;
        ColumnCaptions: array[15] of Text[80];
        SearchStrings: List of [Text];
        FieldList: List of [Integer];
        SetViewLbl: Label 'SORTING(%1) ORDER(Descending)', Comment = 'Do not translate! It will break the feature. %1 is a field name.', Locked = true;

    internal procedure SetSourceRecRef(var RecRef: RecordRef; TableSubtype: Integer; SearchString: Text; NewPageCaption: Text)
    var
        DataSearchInTable: Codeunit "Data Search in Table";
        FldRef: FieldRef;
    begin
        if RecRef.Number = 0 then
            exit;
        DataSearchInTable.SplitSearchString(SearchString, SearchStrings);
        SearchStrings.Get(1, SearchString);
        DataSearchInTable.GetFieldList(RecRef, FieldList);
        SourceRecRef.Open(RecRef.Number);
        FldRef := SourceRecRef.Field(SourceRecRef.SystemModifiedAtNo);
        SourceRecRef.SetView(StrSubstNo(SetViewLbl, FldRef.Name));
        DataSearchInTable.SetFiltersOnRecRef(SourceRecRef, TableSubtype, SearchString);
        TableCaptionTxt := NewPageCaption;
    end;

    local procedure DrillDown()
    var
        DataSearchResult: Record "Data Search Result";
    begin
        DataSearchResult.ShowPage(SourceRecRef);
    end;

    local procedure AdjustColumnOffset(Delta: Integer)
    var
        OldColumnOffset: Integer;
    begin
        OldColumnOffset := ColumnOffset;
        ColumnOffset := ColumnOffset + Delta;
        if ColumnOffset + 12 > SourceRecRef.FieldCount then
            ColumnOffset := SourceRecRef.FieldCount - 12;
        if ColumnOffset < 0 then
            ColumnOffset := 0;
        if ColumnOffset <> OldColumnOffset then
            CurrPage.Update(false);
    end;
}

