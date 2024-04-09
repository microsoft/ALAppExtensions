// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.IO;

page 11729 "Excel Templates CZL"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Excel Templates';
    PageType = List;
    SourceTable = "Excel Template CZL";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of Excel template.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the Excel template.';
                }
                field(HasValue; Rec.Template.HasValue())
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Template';
                    Editable = false;
                    ToolTip = 'Specifies if Excel template is imported.';
                }
                field(Sheet; Rec.Sheet)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies sheet of Excel template';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies Excel template is blocked.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(Import)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Import Template';
                Image = Import;
                ToolTip = 'Allows to import of Excel template into system.';
                Ellipsis = true;

                trigger OnAction()
                begin
                    Rec.ImportFromClientFile();
                end;
            }
            action(Export)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Export Template';
                Image = Export;
                ToolTip = 'Allows the Excel template export.';

                trigger OnAction()
                var
                    FileName: Text;
                begin
                    Rec.ExportToClientFile(FileName);
                end;
            }
            action(Delete)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Delete Template';
                Image = Delete;
                ToolTip = 'Enables to delete the Excel template.';
                Ellipsis = true;

                trigger OnAction()
                begin
                    Rec.RemoveTemplate(true);
                end;
            }
        }
    }
}
