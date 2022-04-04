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
    SourceTable = "Word Templates Related Table";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = true;
    SourceTableTemporary = true;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Tables)
            {
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
                        WordTemplateRelatedCard: Page "Word Templates Related Card";
                    begin
                        WordTemplateRelatedCard.SetTableNo(Rec."Table ID");
                        WordTemplateRelatedCard.SetRelatedTable(Rec);
                        WordTemplateRelatedCard.LookupMode(true);
                        if WordTemplateRelatedCard.RunModal() = Action::LookupOK then
                            WordTemplateRelatedCard.GetRelatedTable(Rec);
                        CurrPage.Update();
                    end;
                }
                field("Related Table Code"; Rec."Related Table Code")
                {
                    ApplicationArea = All;
                    Caption = 'Field Prefix';
                    ToolTip = 'Specifies a prefix that will indicate that the field is from the related entity when you are setting up the template. For example, if you enter SALES, the field names are prefixed with SALES_. The prefix must be unique.';
                }
            }
        }
    }

    var
        TableId: Integer;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Table ID" := TableId;
    end;

    internal procedure AddRelatedTable(TableId: Integer; FilterRelatedTables: Boolean)
    var
        WordTemplateImpl: Codeunit "Word Template Impl.";
    begin
        WordTemplateImpl.AddRelatedTable(Rec, TableId, FilterRelatedTables);
    end;

    internal procedure SetTableNo(TableNo: Integer)
    begin
        if TableId <> TableNo then begin
            TableId := TableNo;
            Rec.DeleteAll();
        end;
    end;

    internal procedure SetRelatedTable(TableId: Integer; RelatedTableId: Integer; FieldNo: Integer; RelatedCode: Code[5])
    begin
        Rec.Init();
        Rec."Table ID" := TableId;
        Rec."Related Table ID" := RelatedTableId;
        Rec."Field No." := FieldNo;
        Rec."Related Table Code" := RelatedCode;
        Rec.Insert();
    end;

    internal procedure GetRelatedTables(var RelatedTableIds: List of [Integer]; var RelatedTableCodes: List of [Code[5]])
    begin
        if Rec.FindSet() then
            repeat
                RelatedTableIds.Add(Rec."Related Table ID");
                RelatedTableCodes.Add(Rec."Related Table Code");
            until Rec.Next() = 0;
    end;

    internal procedure GetRelatedTables(var WordTemplatesRelatedTable: Record "Word Templates Related Table" temporary)
    begin
        WordTemplatesRelatedTable.Copy(Rec, true);
    end;
}