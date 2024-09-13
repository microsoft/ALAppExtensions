// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.Sales.Document.Attachment;
using System.Environment;

pageextension 7279 "Sales Quote Sub Form Ext" extends "Sales Quote Subform"
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
                Visible = IsOnPrem;
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
        IsOnPrem: Boolean;

    trigger OnOpenPage()
    var
        EnvironmentT: Codeunit "Environment Information";
    begin
        IsOnPrem := EnvironmentT.IsOnPrem();
    end;

}