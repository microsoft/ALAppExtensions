// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// A page to view and edit related entities for Word templates.
/// </summary>
page 9983 "Word Templates Related Edit"
{
    Caption = 'Entities';
    PageType = StandardDialog;
    SourceTable = "Word Template";
    InsertAllowed = false;
    ModifyAllowed = true;
    DeleteAllowed = true;
    Permissions = tabledata "Word Template" = r,
                  tabledata "Word Template Field" = rimd,
                  tabledata "Word Templates Related Table" = rimd;
    Extensible = false;

    layout
    {
        area(content)
        {
            label(SelectRelatedEntity)
            {
                ApplicationArea = All;
                Caption = 'You can also merge data from fields on entities that are related to the source entity. For example, if the source is the Customer entity, your template can include data from the Salesperson/Purchaser entity.​';
            }

#if not CLEAN22
            label(RelatedEntityOptions)
            {
                ApplicationArea = All;
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Moved to Word Templates Related Card.';
                Caption = 'Related entities share a field, typically an identifier such as its name, code, or ID, with the source entity. When adding a related entity the list is filtered to predefined relations that are available. To define a relation, if you know the shared field, you can remove the filtering and define the relation.​';
            }
#endif

            part(RelatedTables; "Word Templates Related Part")
            {
                ApplicationArea = All;
                UpdatePropagation = Both;
                Caption = 'Entities';
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction <> Action::OK then
            exit(true);

        CurrPage.RelatedTables.Page.VerifyNoSelectedFields();

        if not Confirm(ApplyChangesQst) then
            exit;

        UpdateRelatedTables();
        UpdateSelectedFields();

        exit(true);
    end;

    internal procedure SetWordTemplate(WordTemplate: Record "Word Template")
    begin
        Rec := WordTemplate;
        CurrPage.RelatedTables.Page.SetWordTemplate(Rec);
    end;

    local procedure UpdateSelectedFields()
    var
        WordTemplateField: Record "Word Template Field";
        TempWordTemplateField: Record "Word Template Field" temporary;
    begin
        CurrPage.RelatedTables.Page.GetWordTemplateFields(TempWordTemplateField);
        WordTemplateField.SetRange("Word Template Code", Rec.Code);
        WordTemplateField.DeleteAll();

        TempWordTemplateField.Reset();
        if TempWordTemplateField.FindSet() then
            repeat
                WordTemplateField := TempWordTemplateField;
                WordTemplateField."Word Template Code" := Rec.Code;
                WordTemplateField.Insert();
            until TempWordTemplateField.Next() = 0;
    end;

    local procedure UpdateRelatedTables()
    var
        WordTemplatesRelatedTable: Record "Word Templates Related Table";
        TempWordTemplatesRelatedTable: Record "Word Templates Related Table" temporary;
    begin
        WordTemplatesRelatedTable.SetRange(Code, Rec.Code);
        WordTemplatesRelatedTable.DeleteAll();

        CurrPage.RelatedTables.Page.GetRelatedTables(TempWordTemplatesRelatedTable);
        if TempWordTemplatesRelatedTable.FindSet() then
            repeat
                WordTemplatesRelatedTable.TransferFields(TempWordTemplatesRelatedTable);
                WordTemplatesRelatedTable.Code := Rec.Code;
                WordTemplatesRelatedTable.Insert();
            until TempWordTemplatesRelatedTable.Next() = 0;
    end;

    var
        ApplyChangesQst: Label 'Are you sure you want to apply these changes?';
}