// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.AI;

using System.Environment;
using System.Privacy;
using System;

/// <summary>
/// This page is used to set the Copilot settings in the Environment.
/// </summary>
page 7775 "Copilot AI Capabilities"
{
    PageType = Document;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Copilot & AI capabilities';
    DataCaptionExpression = '';
    AboutTitle = 'About Copilot';
    AboutText = 'Copilot is the AI-powered assistant that helps people across your organization unlock their creativity and automate tedious tasks.';
    AdditionalSearchTerms = 'OpenAI,AI,Copilot,Co-pilot,Artificial Intelligence,GPT,GTP,Dynamics 365 Copilot,ChatGPT,Copilot settings,Copilot setup,enable Copilot,Copilot admin';
    InsertAllowed = false;
    DeleteAllowed = false;
    Extensible = false;
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(Content)
        {

            group(AlwaysConnected)
            {
                ShowCaption = false;
                InstructionalText = 'Copilot and other generative AI capabilities use Azure OpenAI Service. Your environment connects to Azure OpenAI Service in your region.';
                Visible = InGeo;

                field(GovernData; CopilotGovernDataLbl)
                {
                    ShowCaption = false;

                    trigger OnDrillDown()
                    begin
                        Hyperlink('https://go.microsoft.com/fwlink/?linkid=2249575');
                    end;
                }

            }

            group(NotAlwaysConnected)
            {
                ShowCaption = false;
                InstructionalText = 'Generative AI capabilities are deactivated because Azure OpenAI Service is not available in your region. By allowing data movement, you agree to data being stored and processed by the Azure OpenAI Service outside of your environment''s geographic region or compliance boundary.';
                Visible = not InGeo;

                field(DataMovement; AllowDataMovement)
                {
                    ApplicationArea = All;
                    Caption = 'Allow data movement';
                    ToolTip = 'Specifies whether data movement across regions is allowed. This is required to enable Copilot in your environment.';

                    trigger OnValidate()
                    var
                        PrivacyNotice: Codeunit "Privacy Notice";
                    begin
                        if AllowDataMovement then
                            PrivacyNotice.SetApprovalState(CopilotCapabilityImpl.GetAzureOpenAICategory(), Enum::"Privacy Notice Approval State"::Agreed)
                        else
                            PrivacyNotice.SetApprovalState(CopilotCapabilityImpl.GetAzureOpenAICategory(), Enum::"Privacy Notice Approval State"::Disagreed);

                        CurrPage.GenerallyAvailableCapabilities.Page.SetDataMovement(AllowDataMovement);
                        CurrPage.PreviewCapabilities.Page.SetDataMovement(AllowDataMovement);
                    end;
                }

                field(AOAIServiceLocated; AOAIServiceLocatedLbl)
                {
                    ShowCaption = false;

                    trigger OnDrillDown()
                    begin
                        Hyperlink('https://go.microsoft.com/fwlink/?linkid=2250267');
                    end;
                }
            }

            part(PreviewCapabilities; "Copilot Capabilities Preview")
            {
                Caption = 'Production ready previews';
                ApplicationArea = All;
                Editable = false;
            }
            part(GenerallyAvailableCapabilities; "Copilot Capabilities GA")
            {
                Caption = 'Generally available';
                ApplicationArea = All;
                Editable = false;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Check service health")
            {
                ApplicationArea = All;
                Image = ValidateEmailLoggingSetup;
                ToolTip = 'Check the health of the Azure OpenAI service for your region.';
                Visible = false;

                trigger OnAction()
                begin
                    Hyperlink('https://aka.ms/azurestatus');
                end;
            }
            action("Learn about Copilot")
            {
                ApplicationArea = All;
                Image = Info;
                ToolTip = 'Learn more about Copilot in Business Central.';

                trigger OnAction()
                begin
                    Hyperlink('https://aka.ms/bcai');
                end;
            }
        }

        area(Promoted)
        {
            actionref(PromotedServiceHealth; "Check service health")
            {
            }
            actionref(PromotedLearnAbout; "Learn about Copilot")
            {
            }
        }
    }

    trigger OnOpenPage()
    var
        EnvironmentInformation: Codeunit "Environment Information";
        ALCopilotFunctions: DotNet ALCopilotFunctions;
    begin
        InGeo := ALCopilotFunctions.IsWithinGeo();

        case PrivacyNotice.GetPrivacyNoticeApprovalState(CopilotCapabilityImpl.GetAzureOpenAICategory(), false) of
            Enum::"Privacy Notice Approval State"::Agreed:
                AllowDataMovement := true;
            Enum::"Privacy Notice Approval State"::Disagreed:
                AllowDataMovement := false;
            else
                AllowDataMovement := InGeo;
        end;

        CurrPage.GenerallyAvailableCapabilities.Page.SetDataMovement(AllowDataMovement);
        CurrPage.PreviewCapabilities.Page.SetDataMovement(AllowDataMovement);

        if not EnvironmentInformation.IsSaaSInfrastructure() then
            CopilotCapabilityImpl.ShowCapabilitiesNotAvailableOnPremNotification();

        if InGeo and (not AllowDataMovement) then
            CopilotCapabilityImpl.ShowPrivacyNoticeDisagreedNotification();
    end;

    var
        CopilotCapabilityImpl: Codeunit "Copilot Capability Impl";
        PrivacyNotice: Codeunit "Privacy Notice";
        InGeo: Boolean;
        AllowDataMovement: Boolean;
        CopilotGovernDataLbl: Label 'How do I govern my Copilot data?';
        AOAIServiceLocatedLbl: Label 'Where is Azure OpenAI Service Located?';
}