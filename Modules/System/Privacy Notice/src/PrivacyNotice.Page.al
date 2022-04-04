// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 1563 "Privacy Notice"
{
    Caption = 'Please review terms and conditions';
    PageType = NavigatePage;
    Editable = false;
    SourceTable = "Privacy Notice";
    SourceTableTemporary = true;
    Extensible = false;
    
    layout
    {
        area(Content)
        {
            label(PrivacyNoticeLabel)
            {
                ApplicationArea = All;
                CaptionClass = PrivacyText;
            }
            field(LearnMore; LearnMoreTxt)
            {
                ApplicationArea = All;
                Editable = false;
                ShowCaption = false;
                Caption = ' ';
                ToolTip = 'View information about the privacy.';

                trigger OnDrillDown()
                begin
                    Hyperlink(Rec.Link);
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
                Visible = ShowAgreeDisagreeButtons;

                trigger OnAction()
                begin
                    IsDisagreed := true;
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
                Visible = ShowAgreeDisagreeButtons;

                trigger OnAction()
                var
                    PrivacyNotice: Codeunit "Privacy Notice";
                begin
                    IsAgreed := true;
                    if ID <> '' then
                        PrivacyNotice.SetApprovalState(Rec.ID, "Privacy Notice Approval State"::Agreed);
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnInit()
    begin
        ShowAgreeDisagreeButtons := true;
    end;

    trigger OnOpenPage()
    var
        PrivacyNotice: Codeunit "Privacy Notice";
    begin
        PrivacyText := StrSubstNo(PrivacyAgreementTxt, Rec."Integration Service Name", ProductName.Marketing());
        UserCanApproveForOrganization := PrivacyNotice.CanCurrentUserApproveForOrganization();
    end;

    procedure GetUserApprovalState(): Enum "Privacy Notice Approval State"
    begin
        if IsAgreed then
            exit("Privacy Notice Approval State"::Agreed);
        if IsDisagreed then
            exit("Privacy Notice Approval State"::Disagreed);
        exit("Privacy Notice Approval State"::"Not set");
    end;

    procedure HideAgreeDisagreeActions()
    begin
        ShowAgreeDisagreeButtons := false;
    end;

    var
        LearnMoreTxt: Label 'Privacy and Cookies';
        PrivacyAgreementTxt: Label 'By enabling %1, you consent to your data being shared with Microsoft services that might be outside of your organization''s selected geographic boundaries and might have different compliance and security standards than %2. Your privacy is important to us, and you can choose whether to share data with the service. To learn more, follow the link below.', Comment = '%1 = the integration service name, ex. Microsoft Sharepoint, %2 = the full marketing name, such as Microsoft Dynamics 365 Business Central.';
        PrivacyText: Text;
        UserCanApproveForOrganization: Boolean;
        IsAgreed: Boolean;
        IsDisagreed: Boolean;
        ShowAgreeDisagreeButtons: Boolean;
}
