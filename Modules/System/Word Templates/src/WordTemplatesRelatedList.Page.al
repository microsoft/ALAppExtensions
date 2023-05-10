#if not CLEAN22
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// A list page to view and edit related entities for Word templates.
/// </summary>
page 9985 "Word Templates Related List"
{
    Caption = 'Related Entities';
    PageType = List;
    SourceTable = "Word Templates Related Table";
    InsertAllowed = false;
    Permissions = tabledata "Word Templates Related Table" = rimd;
    Extensible = false;
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
    ObsoleteReason = 'No longer used. Use page 9987 Word Templates Related Part instead.';

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
                        WordTemplateImpl: Codeunit "Word Template Impl.";
                    begin
                        WordTemplateImpl.UpdateRelatedEntity(Rec, TableId);
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

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Table ID" := TableId;
    end;

    internal procedure AddTable(WordTemplatesRelatedTable: Record "Word Templates Related Table"): Boolean
    var
        WordTemplateImpl: Codeunit "Word Template Impl.";
    begin
        exit(WordTemplateImpl.AddRelatedTable(Rec, WordTemplatesRelatedTable));
    end;

    internal procedure SetTableNo(TableNo: Integer)
    begin
        TableId := TableNo;
    end;

    var
        TableId: Integer;
}
#endif