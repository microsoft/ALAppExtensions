// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.AI;

using System.Environment;

/// <summary>
/// Page for when copilot is unavailable due to various reasons. Fx capability disabled, cross region data movement is disabled.
/// </summary>
page 7771 "Copilot Not Available"
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
            group(Control96)
            {
                Editable = false;
                ShowCaption = false;
                Visible = BannerVisible;

                field(Banner; MediaResources."Media Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            field(CopilotNotAvailable; MakeCopilotTitle())
            {
                ApplicationArea = All;
                Style = Strong;
                ShowCaption = false;
            }
            field(CopilotNotAvailableErr; CopilotNotAvailableLbl)
            {
                ApplicationArea = All;
                ShowCaption = false;
                MultiLine = true;
            }
            field(OpenCopilotCapabilities; OpenCopilotLbl)
            {
                ApplicationArea = All;
                ShowCaption = false;

                trigger OnDrillDown()
                begin
                    Page.Run(Page::"Copilot AI Capabilities");
                end;
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

    trigger OnOpenPage()
    begin
        CurrPage.Caption(Format(CopilotCapability));
        LoadBanner();
    end;

    var
        MediaResources: Record "Media Resources";
        CopilotCapability: Enum "Copilot Capability";
        BannerVisible: Boolean;
        OpenCopilotLbl: Label 'Overview Copilot & AI Capabilities';
        CopilotNotAvailableTitleLbl: Label 'Sorry, your Copilot isn''t activated for %1', Comment = '%1 = Copilot Capability name';
        CopilotNotAvailableLbl: Label 'Don''t want to miss out? Contact the system administrator to make this capability available in Business Central.';

    internal procedure SetCopilotCapability(Capability: Enum "Copilot Capability")
    begin
        CopilotCapability := Capability;
    end;

    local procedure MakeCopilotTitle(): Text
    begin
        exit(StrSubstNo(CopilotNotAvailableTitleLbl, Format(CopilotCapability)));
    end;

    local procedure LoadBanner()
    begin
        if MediaResources.Get('COPILOTNOTAVAILABLE.PNG') then
            BannerVisible := MediaResources."Media Reference".HasValue;
    end;
}