#if not CLEAN24
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Text;

using System.Privacy;
using System.Environment;
using System.Environment.Configuration;

/// <summary>
/// Page for viewing information about Copilot.
/// </summary>
page 2014 "Copilot Information"
{

    ObsoleteState = Pending;
    ObsoleteReason = 'Information about Copilot capabilities has been moved to page 7775 "Copilot AI Capabilities"';
    ObsoleteTag = '24.0';
    Caption = 'Copilot';
    PageType = NavigatePage;
    SourceTable = "Privacy Notice";
    SourceTableTemporary = true;
    RefreshOnActivate = true;
    Extensible = false;

    layout
    {
        area(Content)
        {
            group(CopilotNotEnabledAdmin)
            {
                Visible = (Step = Step::NotEnabled) and UserCanApproveForOrganization;

                group(WelcomeSection)
                {
                    Caption = 'Enable AI capabilities';

                    label(PrivacyNoticeLabel)
                    {
                        ApplicationArea = All;
                        CaptionClass = '3,' + PrivacyText;
                    }

                    field(PrivacyAndCookies; PrivacyAndCookiesTxt)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;
                        ToolTip = 'View information about the privacy and cookies.';

                        trigger OnDrillDown()
                        begin
                            Hyperlink(PrivacyNoticeRec.Link);
                        end;
                    }

                    field(SupplementalTerms; SupplementalTermsTxt)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;
                        ToolTip = 'View supplemental information about Azure OpenAI.';

                        trigger OnDrillDown()
                        begin
                            Hyperlink(SupplementalTermsLinkTxt);
                        end;
                    }

                    label(HttpCallsLabel)
                    {
                        ApplicationArea = All;
                        Visible = ShowHttpCallsNotice;
                        CaptionClass = '3,' + HttpCallsNoticeText;
                    }

                    label(ApproveForOrganization)
                    {
                        ApplicationArea = All;
                        Visible = UserCanApproveForOrganization;
                        Caption = 'You are consenting on behalf of your organization.';
                    }
                }
            }

            group(CopilotNotEnabledUser)
            {
                Visible = (Step = Step::NotEnabled) and (not UserCanApproveForOrganization);

                group(AiNotEnabledGroup)
                {
                    Caption = 'AI capabilities are not enabled';
                    label(CopilotUserInfo)
                    {
                        ApplicationArea = All;
                        Caption = 'To enable intelligent features, an administrator must consent to terms and conditions.';
                    }

                    group(AskAdminGroup)
                    {
                        ShowCaption = false;

                        label(AskAdmin)
                        {
                            ApplicationArea = All;
                            Caption = 'When an administrator opens this page, more options are available below.';
                        }
                    }
                }
            }

            group(CopilotEnabled)
            {
                Visible = Step = Step::Enabled;
                group(CopilotInfo)
                {
                    Caption = 'AI capabilities are enabled';

                    label(CopilotInfoLabel)
                    {
                        ApplicationArea = All;
                        Caption = 'Your organization has enabled intelligent features that are governed by terms and conditions.';
                    }

                    field(PrivacyAndCookiesEnabled; PrivacyAndCookiesTxt)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;
                        ToolTip = 'View information about the privacy and cookies.';

                        trigger OnDrillDown()
                        begin
                            Hyperlink(PrivacyNoticeRec.Link);
                        end;
                    }

                    field(SupplementalTermsEnabled; SupplementalTermsTxt)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;
                        ToolTip = 'View supplemental information about Azure OpenAI.';

                        trigger OnDrillDown()
                        begin
                            Hyperlink(SupplementalTermsLinkTxt);
                        end;
                    }
                }

                group(ProductDescriptionInfo)
                {
                    Caption = 'AI-powered product descriptions (preview)';

                    label(ProductDescriptionInfoLabel)
                    {
                        ApplicationArea = All;
                        Caption = 'Copilot provides product description suggestions to accelerate your time to market.';
                    }

                    label(ProductDescription)
                    {
                        ApplicationArea = All;
                        Caption = 'Here''s what you need to know about the feature: (1) This feature is experimental, and your administrator must have enabled it, (2) suggestions are AI-generated and may be incorrect, (3) you must review suggestions to make sure they are accurate and appropriate, and (4) this feature runs on the Azure OpenAI service.';
                    }

                    field(LearnMoreProductDescriptions; LearnMoreTxt)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;
                        ToolTip = 'Learn more about the AI-powered produced descriptions.';

                        trigger OnDrillDown()
                        begin
                            Hyperlink(ProductDescriptionsLearnMoreLinkTxt);
                        end;
                    }
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Disagree)
            {
                ApplicationArea = All;
                Caption = 'Disagree';
                ToolTip = 'Disagree to the terms and conditions.';
                Image = PreviousRecord;
                InFooterBar = true;
                Visible = (Step = Step::NotEnabled) and UserCanApproveForOrganization;

                trigger OnAction()
                var
                    PrivacyNotice: Codeunit "Privacy Notice";
                begin
                    if PrivacyNoticeRec.ID <> '' then
                        PrivacyNotice.SetApprovalState(PrivacyNoticeRec.ID, "Privacy Notice Approval State"::Disagreed);

                    CurrPage.Close();
                end;
            }
            action(Close)
            {
                ApplicationArea = All;
                Caption = 'Close';
                ToolTip = 'Close the page.';
                Image = PreviousRecord;
                InFooterBar = true;
                Visible = (Step = Step::Enabled) or (not UserCanApproveForOrganization);

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
            action(Accept)
            {
                ApplicationArea = All;
                Caption = 'Agree';
                ToolTip = 'Agree to the terms and conditions.';
                Image = NextRecord;
                InFooterBar = true;
                Visible = (Step = Step::NotEnabled) and UserCanApproveForOrganization;

                trigger OnAction()
                var
                    PrivacyNotice: Codeunit "Privacy Notice";
                begin
                    if PrivacyNoticeRec.ID <> '' then
                        PrivacyNotice.SetApprovalState(PrivacyNoticeRec.ID, "Privacy Notice Approval State"::Agreed);

                    if ShowHttpCallsNotice then
                        AllowHttpCallsInModule();

                    Step := Step::Enabled;
                end;
            }
        }
    }

    trigger OnInit()
    begin
        Step := Step::NotEnabled;
    end;

    trigger OnOpenPage()
    var
        PrivacyNoticeCodeunit: Codeunit "Privacy Notice";
    begin
        CheckHttpNoticeVisibility();

        if Rec.ID = '' then begin
            if not PrivacyNoticeRec.Get(AzureOpenAiTxt) then begin
                PrivacyNoticeCodeunit.CreateDefaultPrivacyNotices();
                PrivacyNoticeRec.Get(AzureOpenAiTxt);
            end;

            Rec.TransferFields(PrivacyNoticeRec, true);
        end;

        if PrivacyNoticeCodeunit.GetPrivacyNoticeApprovalState(Rec.ID, false) = Enum::"Privacy Notice Approval State"::Agreed then
            Step := Step::Enabled;

        PrivacyText := StrSubstNo(PrivacyNoticeCodeunit.GetDefaultPrivacyAgreementTxt(), Rec."Integration Service Name", ProductName.Marketing());
        UserCanApproveForOrganization := PrivacyNoticeCodeunit.CanCurrentUserApproveForOrganization();

        PrivacyNoticeRec := Rec;
    end;

    var
        PrivacyNoticeRec: Record "Privacy Notice";
        PrivacyText: Text;
        HttpCallsNoticeText: Text;
        Step: Option NotEnabled,Enabled;
        UserCanApproveForOrganization: Boolean;
        ShowHttpCallsNotice: Boolean;
        PrivacyAndCookiesTxt: Label 'Privacy and Cookies';
        SupplementalTermsTxt: Label 'Supplemental preview terms';
        LearnMoreTxt: Label 'Learn more';
        AzureOpenAiTxt: Label 'Azure OpenAI', Locked = true;
        SupplementalTermsLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2227013', Locked = true;
        ProductDescriptionsLearnMoreLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2226375', Locked = true;
        EnableHttpCallsTxt: Label 'Communication with external services is turned off by default in Sandbox environments. By accepting these terms, you also allow %1 by %2 to communicate with external services. You can always change this from the Extension Management page.', Comment = '%1 = The name of the extension, for example System Application; %2 = the extension publisher, for example Microsoft.';

    local procedure CheckHttpNoticeVisibility()
    var
        NavAppSettings: Record "NAV App Setting";
        EnvironmentInformation: Codeunit "Environment Information";
        CurrentModuleInfo: ModuleInfo;
    begin
        ShowHttpCallsNotice := false;

        if EnvironmentInformation.IsSandbox() then
            if NavAppSettings.WritePermission() then
                if NavApp.GetCurrentModuleInfo(CurrentModuleInfo) then
                    if not NavAppSettings.Get(CurrentModuleInfo.Id()) then
                        ShowHttpCallsNotice := true;

        HttpCallsNoticeText := StrSubstNo(EnableHttpCallsTxt, CurrentModuleInfo.Name(), CurrentModuleInfo.Publisher());
    end;

    local procedure AllowHttpCallsInModule()
    var
        NavAppSettings: Record "NAV App Setting";
        CurrentModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);

        if not NavAppSettings.Get(CurrentModuleInfo.Id()) then begin
            NavAppSettings."App ID" := CurrentModuleInfo.Id();
            NavAppSettings."Allow HttpClient Requests" := true;
            if NavAppSettings.Insert() then;
        end;
    end;
}
#endif