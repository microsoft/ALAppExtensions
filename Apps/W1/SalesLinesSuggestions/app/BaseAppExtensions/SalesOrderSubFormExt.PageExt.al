// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.Sales.Document.Attachment;

pageextension 7278 "Sales Order Sub Form Ext" extends "Sales Order Subform"
{
    actions
    {
        addfirst(Prompting)
        {
            action("Suggest Sales Lines Prompting")
            {
                ApplicationArea = All;
                Caption = 'Suggest sales lines';
                Image = SparkleFilled;
                ToolTip = 'Get sales lines suggestions from Copilot';

                trigger OnAction()
                begin
                    SalesLineAISuggestionImp.GetLinesSuggestions(Rec);
                end;
            }
            action("Attach Prompting")
            {
                ApplicationArea = All;
                Caption = 'Suggest sales lines from file';
                Ellipsis = true;
                Image = SparkleFilled;
                ToolTip = 'Get sales lines from file with Copilot';

                trigger OnAction()
                begin
                    SalesLineFromAttachment.AttachAndSuggest(Rec);
                end;
            }
        }
        addlast(processing)
        {
            group("Copilot")
            {
                Image = SparkleFilled;
                ShowAs = SplitButton;

                action("Suggest Sales Lines")
                {
                    ApplicationArea = All;
                    Caption = 'Suggest sales lines';
                    Image = SparkleFilled;
                    ToolTip = 'Get sales lines suggestions from Copilot';

                    trigger OnAction()
                    begin
                        SalesLineAISuggestionImp.GetLinesSuggestions(Rec);
                    end;
                }
                action(Attach)
                {
                    ApplicationArea = All;
                    Caption = 'Suggest sales lines from file';
                    Ellipsis = true;
                    Image = SparkleFilled;
                    ToolTip = 'Get sales lines from file with Copilot';

                    trigger OnAction()
                    begin
                        SalesLineFromAttachment.AttachAndSuggest(Rec);
                    end;
                }
            }
        }
    }

    var
        SalesLineAISuggestionImp: Codeunit "Sales Lines Suggestions Impl.";
        SalesLineFromAttachment: Codeunit "Sales Line From Attachment";
}