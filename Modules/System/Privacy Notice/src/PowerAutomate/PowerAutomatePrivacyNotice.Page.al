
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Privacy;

using System.Environment;

page 1568 "Power Automate Privacy Notice"
{
    Caption = 'Set Up Power Automate';
    PageType = NavigatePage;
    SourceTable = "Privacy Notice";
    SourceTableTemporary = true;
    RefreshOnActivate = true;
    Extensible = false;

    layout
    {
        area(Content)
        {
            group(Step1)
            {
                Visible = Step = Step::Start;
                group(TopBanner)
                {
                    Editable = false;
                    ShowCaption = false;
                    Visible = true;

                    field("<MediaRepositoryStandard>"; MediaResourcesStandard."Media Reference")
                    {
                        ApplicationArea = All;
                        Caption = '';
                        Editable = false;
                        ToolTip = 'Specifies an image that will be shown at the top of each page in the assisted setup guide.';
                    }
                }

                group(WelcomeSection)
                {
                    Caption = 'Welcome to Power Automate Setup';

                    label(Description)
                    {
                        ApplicationArea = All;
                        Caption = 'Business Central offers even deeper integration with Power Automate now. With this new capability, users can create and start an instant Power Automate flow for a given record, such as a customer, item, or sales order.';
                    }

                    label(DescriptionSummary)
                    {
                        ApplicationArea = All;
                        Caption = 'When this feature is switched on, every page that contains data gets a new Automate group in the action bar. From that group, users can run any instant manual flows that the company has defined for Business Central in Power Automate in a seamless, no-code approach.';
                    }

                    field(LearnMore; LearnMoreTxt)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;
                        Caption = ' ';
                        ToolTip = 'Learn more about this capability.';

                        trigger OnDrillDown()
                        begin
                            Hyperlink(LearnMoreLinkTxt);
                        end;
                    }

                    label(EmptySpace)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        Caption = '';
                    }
                    group(FinalInfo)
                    {
                        Caption = 'Let''s go!';
                        InstructionalText = 'Choose Next to switch on the new Power Automate integration.';
                    }
                }
            }
            group(Step2)
            {
                Visible = Step = Step::Finish;
                group(PrivacyNotice)
                {
                    Caption = 'Privacy notice';
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
                        Caption = ' ';
                        ToolTip = 'View information about the privacy.';

                        trigger OnDrillDown()
                        begin
                            Hyperlink(PrivacyNoticeRecord.Link);
                        end;
                    }
                    label(ApproveForOrganization)
                    {
                        ApplicationArea = All;
                        Visible = UserCanApproveForOrganization;
                        Caption = 'You are consenting on behalf of your organization.';
                    }
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Reject)
            {
                ApplicationArea = All;
                Caption = 'Disagree';
                ToolTip = 'Disagree to the terms and conditions.';
                Image = PreviousRecord;
                InFooterBar = true;
                Visible = (Step = Step::Finish);

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
            action(Back)
            {
                ApplicationArea = All;
                Caption = 'Back';
                Enabled = BackActionEnabled;
                ToolTip = 'Go back to the previous page.';
                Image = PreviousRecord;
                InFooterBar = true;
                Visible = not (Step = Step::Finish);

                trigger OnAction()
                begin
                    NextStep(true);
                end;
            }
            action(Next)
            {
                ApplicationArea = All;
                Enabled = NextActionEnabled;
                Caption = 'Next';
                ToolTip = 'Go to the next page.';
                Image = NextRecord;
                InFooterBar = true;
                Visible = not (Step = Step::Finish);

                trigger OnAction()
                begin
                    NextStep(false);
                end;
            }
            action(Accept)
            {
                ApplicationArea = All;
                Caption = 'Agree';
                ToolTip = 'Agree to the terms and conditions.';
                Image = NextRecord;
                InFooterBar = true;
                Visible = (Step = Step::Finish);

                trigger OnAction()
                var
                    PrivacyNotice: Codeunit "Privacy Notice";
                begin
                    if PrivacyNoticeRecord.ID <> '' then
                        PrivacyNotice.SetApprovalState(PrivacyNoticeRecord.ID, "Privacy Notice Approval State"::Agreed);
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnInit()
    begin
        Step := Step::Start;
        NextActionEnabled := true;
    end;

    trigger OnOpenPage()
    var
        PrivacyNoticeCodeunit: Codeunit "Privacy Notice";
    begin
        PrivacyText := StrSubstNo(PrivacyNoticeCodeunit.GetDefaultPrivacyAgreementTxt(), Rec."Integration Service Name", ProductName.Marketing());
        UserCanApproveForOrganization := PrivacyNoticeCodeunit.CanCurrentUserApproveForOrganization();
        PrivacyNoticeRecord := Rec;
    end;

    local procedure NextStep(Backward: Boolean)
    begin
        if Backward then
            Step := Step - 1
        else
            Step := Step + 1;

        NextActionEnabled := Step <> Step::Finish;
        BackActionEnabled := Step <> Step::Start;
    end;

    var
        MediaResourcesStandard: Record "Media Resources";
        PrivacyNoticeRecord: Record "Privacy Notice";
        PrivacyAndCookiesTxt: Label 'Privacy and Cookies';
        LearnMoreTxt: Label 'Learn more';
        LearnMoreLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2202635', Locked = true;
        PrivacyText: Text;
        Step: Option Start,Finish;
        BackActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        UserCanApproveForOrganization: Boolean;
}
