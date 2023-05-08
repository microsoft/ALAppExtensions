// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// A list part page to view and edit related entities for Word templates.
/// </summary>
page 9987 "Word Templates Related Part"
{
    Caption = 'Related Entities';
    PageType = ListPart;
    SourceTable = "Word Templates Related Buffer";
    InsertAllowed = false;
    ModifyAllowed = true;
    DeleteAllowed = true;
    SourceTableTemporary = true;
    Extensible = false;
    Permissions = tabledata "Word Template" = r,
                  tabledata "Word Template Field" = r,
                  tabledata "Word Templates Related Table" = r;

    layout
    {
        area(content)
        {
            repeater(Tables)
            {
                ShowAsTree = true;
                IndentationColumn = Rec.Depth;
                IndentationControls = "Table Caption";

                field("Table Caption"; Rec."Related Table Caption")
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    ToolTip = 'Specifies the related entity.';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = Rec."Related Table ID" = SourceTableId;
                }
                field("Related Table Code"; Rec."Related Table Code")
                {
                    ApplicationArea = All;
                    Caption = 'Prefix';
                    ToolTip = 'Specifies a prefix that will indicate that the field is from the related entity when you are setting up the template. For example, if you enter SALES, the field names are prefixed with SALES_. The prefix must be unique.';
                    Editable = Rec."Related Table ID" <> SourceTableId;

                    trigger OnValidate()
                    var
                        WordTemplateImpl: Codeunit "Word Template Impl.";
                    begin
                        WordTemplateImpl.VerifyRelatedTableCodeIsUnique(Rec.Code, Rec."Related Table Code", Rec."Related Table ID", Rec);
                    end;
                }
                field(SelectedFields; NumberOfSelectedFields)
                {
                    ApplicationArea = All;
                    Caption = 'Number of Selected Fields';
                    ToolTip = 'Specifies the number of fields for this record that has been selected.';
                    Editable = false;

                    trigger OnAssistEdit()
                    var
                        WordTemplateFieldSelection: Codeunit "Word Template Field Selection";
                    begin
                        WordTemplateFieldSelection.ShowFieldSelection(Rec."Related Table ID", TempWordTemplateField);
                        NumberOfSelectedFields := WordTemplateFieldSelection.CalculateNoSelectedFields(Rec."Related Table ID", TempWordTemplateField);
                        SelectedFieldsCount.Set(Rec."Related Table ID", NumberOfSelectedFields);
                    end;
                }
                field("Entity Relation"; RecordTypeTxt)
                {
                    ApplicationArea = All;
                    Style = Subordinate;
                    Enabled = false;
                    Editable = false;
                    Caption = 'Entity relation';
                    ToolTip = 'Specifies the relation to the source entity.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group("Add Entity")
            {
                Caption = 'Add';
                ShowAs = SplitButton;
                Image = NewRow;

                action("Add related table")
                {
                    ApplicationArea = All;
                    Caption = 'Add related entity';
                    ToolTip = 'Add a related entity to the template.';
                    Scope = Repeater;
                    Image = NewRow;

                    trigger OnAction()
                    begin
                        AddRelatedTable(Rec."Related Table ID")
                    end;
                }

                action("Add specific table")
                {
                    ApplicationArea = All;
                    Caption = 'Add unrelated entity';
                    ToolTip = 'Select and add an unrelated entity to the template.';
                    Scope = Repeater;
                    Image = New;

                    trigger OnAction()
                    begin
                        if WordTemplateImpl.AddSelectedTable(Rec, Rec.Code, TempWordTemplateField) then
                            RefreshTreeView();
                    end;
                }
            }
            action("Edit relation")
            {
                ApplicationArea = All;
                Caption = 'Edit';
                ToolTip = 'Change the field from the source entity that creates the relationship to the related entity.';
                Scope = Repeater;
                Image = EditLines;
                Enabled = EditEnabled;

                trigger OnAction()
                begin
                    WordTemplateImpl.EditRelatedTable(Rec, TempWordTemplateField);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        RefreshTreeView();
    end;

    trigger OnAfterGetRecord()
    var
        RecordSelection: Codeunit "Record Selection";
    begin
        if IsNullGuid(Rec."Source Record ID") then
            if Rec."Related Table ID" = SourceTableId then
                RecordTypeTxt := SourceRecordTypeLbl
            else begin
                Rec.CalcFields("Table Caption");
                RecordTypeTxt := StrSubstNo(RelatedRecordTypeLbl, Rec."Table Caption")
            end
        else
            RecordTypeTxt := StrSubstNo(SelectedRecordTypeLbl, RecordSelection.ToText(Rec."Related Table ID", Rec."Source Record ID"));

        CalculateSelectedFields();
    end;

    internal procedure VerifyNoSelectedFields()
    var
        FieldCount: Integer;
        TotalFieldCount: Integer;
    begin
        foreach FieldCount in SelectedFieldsCount.Values() do
            TotalFieldCount += FieldCount;
        if TotalFieldCount > 250 then
            Error(FieldCountErr);
    end;

    local procedure CalculateSelectedFields()
    var
        WordTemplateFieldSelection: Codeunit "Word Template Field Selection";
    begin
        if not SelectedFieldsCount.Get(Rec."Related Table ID", NumberOfSelectedFields) then begin // Cache custom fields since code may be executed on every call.
            NumberOfSelectedFields := WordTemplateFieldSelection.CalculateNoSelectedFields(Rec."Related Table ID", TempWordTemplateField);
            SelectedFieldsCount.Add(Rec."Related Table ID", NumberOfSelectedFields);
        end;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        EditEnabled := IsNullGuid(Rec."Source Record ID") and (Rec."Related Table ID" <> SourceTableId);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        if Rec."Related Table ID" = SourceTableId then
            Error(CannotDeleteSourceRecordErr);
        TempWordTemplateField.Reset();
        TempWordTemplateField.SetRange("Table ID", "Related Table ID");
        TempWordTemplateField.DeleteAll();
    end;

    internal procedure AddRelatedTable(TableId: Integer)
    begin
        if Rec."Table ID" = 0 then
            TableId := SourceTableId;

        if not IsNullGuid(Rec."Source Record ID") then
            TableId := Rec."Related Table ID";

        if WordTemplateImpl.AddRelatedTable(Rec, TableId, true, TempWordTemplateField) then
            RefreshTreeView();
    end;

    internal procedure RefreshTreeView()
    begin
        WordTemplateImpl.RefreshTreeView(SourceTableId, Rec);
        Rec.SetCurrentKey(Position);
        CurrPage.Update(false);
    end;

    internal procedure SetTableNo(TableId: Integer)
    var
        WordTemplateFieldSelection: Codeunit "Word Template Field Selection";
    begin
        if SourceTableId <> TableId then begin
            TempWordTemplateField.Reset();
            TempWordTemplateField.DeleteAll();
            WordTemplateFieldSelection.SelectDefaultFieldsForTable('', TableId, TempWordTemplateField);
            SourceTableId := TableId;
            Rec.Reset();
            Rec.DeleteAll();
            RefreshTreeView();
        end;
    end;

    internal procedure SetWordTemplate(WordTemplate: Record "Word Template")
    var
        WordTemplatesRelatedTable: Record "Word Templates Related Table";
        WordTemplateField: Record "Word Template Field";
    begin
        SourceTableId := WordTemplate."Table ID";
        WordTemplateImpl.RefreshTreeView(SourceTableId, Rec);

        WordTemplatesRelatedTable.SetRange(Code, WordTemplate.Code);
        if WordTemplatesRelatedTable.FindSet() then
            repeat
                Rec.TransferFields(WordTemplatesRelatedTable);
                Rec.Code := '';
                Rec.Insert();
            until WordTemplatesRelatedTable.Next() = 0;

        WordTemplateField.SetRange("Word Template Code", WordTemplate.Code);
        if WordTemplateField.FindSet() then
            repeat
                TempWordTemplateField := WordTemplateField;
                TempWordTemplateField."Word Template Code" := '';
                TempWordTemplateField.Insert();
            until WordTemplateField.Next() = 0;
    end;

    internal procedure SetRelatedTable(TableId: Integer; RelatedTableId: Integer; FieldNo: Integer; RelatedCode: Code[5])
    var
        WordTemplateFieldSelection: Codeunit "Word Template Field Selection";
    begin
        Rec.Init();
        Rec."Table ID" := TableId;
        Rec."Related Table ID" := RelatedTableId;
        Rec."Field No." := FieldNo;
        Rec."Related Table Code" := RelatedCode;
        Rec.Insert();
        WordTemplateFieldSelection.SelectDefaultFieldsForTable('', RelatedTableId, TempWordTemplateField);
    end;

    internal procedure SetUnrelatedTable(TableId: Integer; UnrelatedTableID: Integer; RecordSystemId: Guid; RelatedCode: Code[5])
    begin
        WordTemplateImpl.AddTable(Rec, Rec.Code, UnrelatedTableID, RecordSystemId, RelatedCode, TempWordTemplateField);
    end;

    internal procedure SetFieldsToBeIncluded(TableId: Integer; IncludeFields: List of [Text[30]])
    var
        WordTemplateFieldSelection: Codeunit "Word Template Field Selection";
    begin
        WordTemplateFieldSelection.SetIncludeFields('', TableId, IncludeFields, TempWordTemplateField);
    end;

    internal procedure GetRelatedTables(var RelatedTableIds: List of [Integer]; var RelatedTableCodes: List of [Code[5]])
    begin
        Rec.Reset();
        Rec.SetFilter("Related Table ID", '<>%1', SourceTableId); // Exclude source record 
        if Rec.FindSet() then
            repeat
                RelatedTableIds.Add(Rec."Related Table ID");
                RelatedTableCodes.Add(Rec."Related Table Code");
            until Rec.Next() = 0;
    end;

    internal procedure GetWordTemplateFields(var OutTempWordTemplateField: Record "Word Template Field" temporary)
    begin
        OutTempWordTemplateField.Copy(TempWordTemplateField, true);
    end;

    internal procedure GetRelatedTables(var WordTemplatesRelatedTable: Record "Word Templates Related Table" temporary)
    begin
        Rec.Reset();
        Rec.SetFilter("Related Table ID", '<>%1', SourceTableId); // Exclude source record 
        if Rec.FindSet() then
            repeat
                WordTemplatesRelatedTable.TransferFields(Rec);
                WordTemplatesRelatedTable.Insert();
            until Rec.Next() = 0;
    end;

    var
        TempWordTemplateField: Record "Word Template Field" temporary;
        WordTemplateImpl: Codeunit "Word Template Impl.";
        SelectedFieldsCount: Dictionary of [Integer, Integer];
        [InDataSet]
        RecordTypeTxt: Text;
        [InDataSet]
        NumberOfSelectedFields: Integer;
        EditEnabled: Boolean;
        SourceTableId: Integer;
        CannotDeleteSourceRecordErr: Label 'You cannot delete the source record.';
        SourceRecordTypeLbl: Label 'Source entity';
        RelatedRecordTypeLbl: Label 'Related to %1 entity', Comment = '%1 - Table caption of the entity that this entity is related to';
        SelectedRecordTypeLbl: Label 'Selected record: {%1}', Comment = '%1 - Text representation of a record';
        FieldCountErr: Label 'At most 250 fields can be selected.';
}