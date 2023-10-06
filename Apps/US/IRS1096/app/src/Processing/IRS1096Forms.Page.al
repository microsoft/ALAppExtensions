// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 10019 "IRS 1096 Forms"
{
    Caption = '1096 Forms';
    PageType = List;
    SourceTable = "IRS 1096 Form Header";
    CardPageId = "IRS 1096 Form";
    Editable = false;
    RefreshOnActivate = true;
    ApplicationArea = BasicUS;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = BasicUS;
                    ToolTip = 'Specifies the unique number of the form.';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = BasicUS;
                    ToolTip = 'Specifies the starting date of the form.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = BasicUS;
                    ToolTip = 'Specifies the ending date of the form.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = BasicUS;
                    ToolTip = 'Specifies the status of the form. Only released forms can be printed. Only opened forms can be changed.';
                }
                field("IRS Code"; Rec."IRS Code")
                {
                    ApplicationArea = BasicUS;
                    ToolTip = 'Specifies the IRS code of the form.';
                }
            }
        }
        area(factboxes)
        {
            systempart(LinksFactBox; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(NotesFactBox; Notes)
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
            action(CreateForms)
            {
                ApplicationArea = BasicUS;
                Caption = 'Create Forms';
                Ellipsis = true;
                Image = Create;
                ToolTip = 'Create new 1096 forms for a certain period per each IRS code.';
                RunObject = report "IRS 1096 Create Forms";
            }
            action(PrintSingle)
            {
                ApplicationArea = BasicUS;
                Caption = 'Print-Single';
                Ellipsis = true;
                Image = PrintAcknowledgement;
                ToolTip = 'Prints a single form.';

                trigger OnAction()
                var
                    IRS1096FormMgt: Codeunit "IRS 1096 Form Mgt.";
                begin
                    IRS1096FormMgt.PrintSingleForm(Rec);
                end;
            }
            action(PrintPerPeriod)
            {
                ApplicationArea = BasicUS;
                Caption = 'Print-Per Period';
                Ellipsis = true;
                Image = PrintCover;
                ToolTip = 'Prints all forms within period.';

                trigger OnAction()
                var
                    IRS1096FormMgt: Codeunit "IRS 1096 Form Mgt.";
                begin
                    IRS1096FormMgt.PrintFormByPeriod(Rec);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                actionref(Create_Forms; CreateForms)
                {
                }
            }
            group(Category_Category11)
            {
                Caption = 'Print';
                group(Category_PrintOptions)
                {
                    Caption = 'Print';

                    actionref(Print_Single; PrintSingle)
                    {
                    }
                    actionref(Print_PerPeriod; PrintPerPeriod)
                    {
                    }
                }
            }
        }
    }
}
