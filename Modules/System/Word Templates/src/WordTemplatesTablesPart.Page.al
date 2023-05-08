// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// A list part page to view, add and remove tables for Word templates.
/// </summary>
page 9997 "Word Templates Tables Part"
{
    Caption = 'Word Template Tables';
    PageType = ListPart;
    SourceTable = "Word Templates Table";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = true;
    Extensible = false;
    Permissions = tabledata "Word Templates Table" = rmd;

    layout
    {
        area(content)
        {
            repeater(Tables)
            {
                Editable = false;
                field(Name; Rec."Table Caption")
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    ToolTip = 'Specifies the name of the data source from which the template will get data.';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {

            action("Add new entity")
            {
                ApplicationArea = All;
                Caption = 'Add new entity';
                ToolTip = 'Select and add a source table to the template.';
                Image = New;

                trigger OnAction()
                var
                    WordTemplateImpl: Codeunit "Word Template Impl.";
                    TableId: Integer;
                begin
                    TableId := WordTemplateImpl.AddTable();
                    if TableId <> 0 then begin
                        Rec.Get(TableId);
                        CurrPage.Update(false);
                    end;
                end;
            }
        }
    }
}