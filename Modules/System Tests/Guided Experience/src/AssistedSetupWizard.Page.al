// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 132610 "Assisted Setup Wizard"
{
    PageType = NavigatePage;

    layout
    {
    }

    actions
    {
        area(processing)
        {
            action(Finish)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Finish';
                ToolTip = 'Finish';

                trigger OnAction()
                var
                    GuidedExperience: Codeunit "Guided Experience";
                begin
                    GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"Assisted Setup Wizard");
                end;
            }
        }
    }
}