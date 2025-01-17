// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.Sales.Document.Attachment;
using System.AI;

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
                Enabled = IsCapabilityRegistered;
                Visible = IsCapabilityRegistered;

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
                Enabled = IsCapabilityRegistered;
                Visible = IsCapabilityRegistered;

                trigger OnAction()
                begin
                    SalesLineFromAttachment.AttachAndSuggest(Rec);
                end;
            }
        }
#if not CLEAN25
        addlast(processing)
        {
            group("Copilot")
            {
                Image = SparkleFilled;
                ShowAs = SplitButton;
                Visible = false;
                ObsoleteReason = 'Replaced by Suggest Sales Line Prompting';
                ObsoleteState = Pending;
                ObsoleteTag = '25.0';

                action("Suggest Sales Lines")
                {
                    ApplicationArea = All;
                    Caption = 'Suggest sales lines';
                    Image = SparkleFilled;
                    ToolTip = 'Get sales lines suggestions from Copilot';
                    Visible = false;
                    ObsoleteReason = 'Replaced by Suggest Sales Line Prompting';
                    ObsoleteState = Pending;
                    ObsoleteTag = '25.0';

                    trigger OnAction()
                    begin
                        SalesLineAISuggestionImp.GetLinesSuggestions(Rec);
                    end;
                }
            }
        }
#endif
    }

    var
        SalesLineAISuggestionImp: Codeunit "Sales Lines Suggestions Impl.";
        SalesLineFromAttachment: Codeunit "Sales Line From Attachment";
        IsCapabilityRegistered: Boolean;

    trigger OnOpenPage()
    var
        CopilotCapability: Codeunit "Copilot Capability";
    begin
        IsCapabilityRegistered := CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Sales Lines Suggestions");
    end;

}