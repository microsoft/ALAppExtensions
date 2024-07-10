// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

pageextension 7277 "Sales Invoice Sub Form Ext" extends "Sales Invoice Subform"
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
        }
        addlast(processing)
        {
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
        }
    }

    var
        SalesLineAISuggestionImp: Codeunit "Sales Lines Suggestions Impl.";
}