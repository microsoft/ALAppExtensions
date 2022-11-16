// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 1563 "Privacy Notice"
{
    Caption = 'Please review terms and conditions';
    PageType = NavigatePage;
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
                    if PrivacyNoticeRecord.ID <> '' then
                        PrivacyNotice.SetApprovalState(PrivacyNoticeRecord.ID, "Privacy Notice Approval State"::Agreed);
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
        PrivacyText := StrSubstNo(PrivacyNotice.GetDefaultPrivacyAgreementTxt(), Rec."Integration Service Name", ProductName.Marketing());
        UserCanApproveForOrganization := PrivacyNotice.CanCurrentUserApproveForOrganization();
        PrivacyNoticeRecord := Rec;
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
        PrivacyNoticeRecord: Record "Privacy Notice";
        LearnMoreTxt: Label 'Privacy and Cookies';
        PrivacyText: Text;
        UserCanApproveForOrganization: Boolean;
        IsAgreed: Boolean;
        IsDisagreed: Boolean;
        ShowAgreeDisagreeButtons: Boolean;
}
