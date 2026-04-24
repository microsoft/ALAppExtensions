// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Agent.PayablesAgent;

using System.Environment;

page 3318 "PA Trial Guide"
{
    PageType = NavigatePage;
    ApplicationArea = All;
    InherentEntitlements = X;
    InherentPermissions = X;
    Extensible = false;

    layout
    {
        area(Content)
        {
            group(StandardBanner)
            {
                ShowCaption = false;
                Editable = false;
                Visible = BannerVisible;

                field(MediaResourcesStd; MediaResourcesStandard."Media Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            field(TitleMsg; TitleMsg)
            {
                ApplicationArea = All;
                Style = Strong;
                ShowCaption = false;
            }
            field(ParagraphMsg; ParagraphMsg)
            {
                ApplicationArea = All;
                ShowCaption = false;
                MultiLine = true;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionFinish)
            {
                ApplicationArea = All;
                Caption = 'OK';
                ToolTip = 'OK';
                Image = Approve;
                InFooterBar = true;

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        MediaResourcesStandard: Record "Media Resources";
        BannerVisible: Boolean;
        TitleMsg: Label 'Thank you for trying the Payables Agent!';
        ParagraphMsg: Label 'The Payables Agent is now running in trial mode — there is no charge for agent usage during the trial. The invoice will show in the agent task pane on the right-hand side, where you can track its progress.';


    trigger OnInit()
    begin
        if MediaResourcesStandard.Get('COPILOTNOTAVAILABLE.PNG') then
            BannerVisible := MediaResourcesStandard."Media Reference".HasValue();
    end;

}
