// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// A list part factbox to view related entities for Word templates.
/// </summary>
page 9986 "Word Templates Related Card"
{
    PageType = Card;
    ApplicationArea = All;
    Caption = 'Related Entity';
    UsageCategory = Administration;
    SourceTable = "Word Templates Related Table";
    SourceTableTemporary = true;
    Extensible = false;

    layout
    {
        area(Content)
        {
            group(Group)
            {
                Caption = 'Related Entity';

                field("Table ID"; Rec."Related Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the id of the related entity.';
                    Visible = false;
                }
                field("Table Caption"; Rec."Related Table Caption")
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    ToolTip = 'Specifies the related entity.';
                    Editable = false;

                    trigger OnAssistEdit()
                    var
                        AllObjWithCaption: Record AllObjWithCaption;
                        WordTemplateImpl: Codeunit "Word Template Impl.";
                    begin
                        WordTemplateImpl.GetTable(SelectRelatedTableCaptionLbl, AllObjWithCaption, FilterExpression);
                        Rec."Related Table ID" := AllObjWithCaption."Object ID";

                        if Rec."Related Table ID" <> 0 then begin
                            Rec."Related Table Code" := WordTemplateImpl.GenerateCode(AllObjWithCaption."Object Caption");
                            Rec."Field No." := WordTemplateImpl.GetFieldNo(FieldFilterExpression, Rec."Table ID", Rec."Related Table ID");
                            Rec.CalcFields("Related Table Caption");
                            Rec.CalcFields("Field Caption");
                        end;

                        UpdateFieldSelectionVisibility();
                        CurrPage.Update();
                    end;
                }
                group(FieldSelection)
                {
                    ShowCaption = false;
                    Caption = ' ';
                    Visible = ShowFieldSelection;

                    field("Field No."; Rec."Field No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the field no. from the source entity that creates the relationship to the related entity.';
                        Editable = false;
                        Visible = false;
                    }
                    field("Field Caption"; Rec."Field Caption")
                    {
                        ApplicationArea = All;
                        Caption = 'Source Entity Relation';
                        ToolTip = 'Specifies the field from the source entity that creates the relationship to the related entity. If there are more than one related entities, specify the one to use for your template.​';
                        Editable = false;

                        trigger OnAssistEdit()
                        var
                            WordTemplateImpl: Codeunit "Word Template Impl.";
                        begin
                            if TableId <> 0 then begin
                                Rec."Field No." := WordTemplateImpl.GetField(SelectTableFieldLbl, TableId, FieldFilterExpression);
                                Rec.CalcFields("Field Caption");
                                CurrPage.Update();
                            end;
                        end;
                    }
                }
                field("Related Table Code"; Rec."Related Table Code")
                {
                    ApplicationArea = All;
                    Caption = 'Field Prefix';
                    ToolTip = 'Specifies a prefix that will indicate that the field is from the related entity when you are setting up the template. For example, if you enter Sales, the field names are prefixed with Sales_. The prefix must be unique.';
                }
            }
        }
    }

    var
        [InDataSet]
        ShowFieldSelection: Boolean;
        TableId: Integer;
        FilterExpression: Text;
        FieldFilterExpression: Text;
        SelectRelatedTableCaptionLbl: Label 'Select related entity for the Word template.';
        SelectTableFieldLbl: Label 'Select the source entity relation.';
        EmptyParentFieldErr: Label 'No source entity relation was specified.';

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Table ID" := TableId;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction <> Action::LookupOK then
            exit(true);

        if Rec."Field No." = 0 then
            Error(EmptyParentFieldErr);

        exit(true);
    end;

    internal procedure SetFilterExpression(Expression: Text)
    begin
        FilterExpression := Expression;
        UpdateFieldSelectionVisibility();
    end;

    internal procedure SetTableNo(TableNo: Integer)
    begin
        TableId := TableNo;
    end;

    internal procedure SetRelatedTable(var WordTemplatesRelatedTable: Record "Word Templates Related Table" temporary)
    begin
        if WordTemplatesRelatedTable.IsTemporary then
            Rec.Copy(WordTemplatesRelatedTable, true)
        else
            if WordTemplatesRelatedTable."Table ID" <> 0 then begin
                Rec.Copy(WordTemplatesRelatedTable);
                Rec.Insert();
            end;
    end;

    internal procedure GetRelatedTable(var WordTemplatesRelatedTable: Record "Word Templates Related Table" temporary)
    begin
        WordTemplatesRelatedTable.TransferFields(Rec);
    end;

    local procedure UpdateFieldSelectionVisibility()
    begin
        ShowFieldSelection := (FilterExpression = '') or (FieldFilterExpression <> '');
    end;
}