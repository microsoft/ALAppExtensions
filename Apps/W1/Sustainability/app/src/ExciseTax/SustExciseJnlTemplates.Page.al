// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ExciseTax;

page 6285 "Sust. Excise Jnl. Templates"
{
    Caption = 'Excise Journal Templates';
    PageType = List;
    SourceTable = "Sust. Excise Journal Template";
    ApplicationArea = Basic, Suite;
    AnalysisModeEnabled = false;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Name"; Rec.Name)
                {
                    ToolTip = 'Specifies the name of the Sustainability excise Journal Template.';
                }
                field("Description"; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the Sustainability excise Journal Template.';
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            group(Batch)
            {
                action(Batches)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Batches';
                    Image = Description;
                    RunObject = Page "Sust. Excise Jnl. Batches";
                    RunPageLink = "Journal Template Name" = field(Name);
                    ToolTip = 'View or edit multiple journals for a specific template. You can use batches when you need multiple journals of a certain type.';
                    Scope = Repeater;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(Batch_Promoted; Batches)
                {
                }
            }
        }
    }
}