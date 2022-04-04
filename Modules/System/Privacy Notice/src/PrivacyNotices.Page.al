// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 1565 "Privacy Notices"
{
    Caption = 'Privacy Notices Status';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Privacy Notice";
    SourceTableView = Sorting("Integration Service Name")
                      Where("User SID Filter" = filter('00000000-0000-0000-0000-000000000000'));
    Extensible = true;
    AccessByPermission = tabledata "Privacy Notice" = IM; // Only admin can see this page
    RefreshOnActivate = true;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(IntegrationServiceName; Rec."Integration Service Name")
                {
                    Caption = 'Integration Name';
                    ToolTip = 'Specifies the integration name.';
                    ApplicationArea = All;
                    Editable = false;

                    trigger OnDrillDown()
                    var
                        PrivacyNotice: Page "Privacy Notice";
                    begin
                        PrivacyNotice.HideAgreeDisagreeActions();
                        PrivacyNotice.SetRecord(Rec);
                        PrivacyNotice.Run();
                    end;
                }
                field(Accepted; Accepted)
                {
                    Caption = 'Agree for All';
                    ToolTip = 'Specifies whether an administrator has accepted the integration''s privacy notice on behalf of all users.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if Accepted then begin
                            Rejected := false;
                            UserDecides := false;
                        end else
                            UserDecides := true;

                        SetRecordApprovalState();
                    end;
                }
                field(Rejected; Rejected)
                {
                    Caption = 'Disagree for All';
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether an administrator has disagreed to the integration''s privacy notice on behalf of all users.';

                    trigger OnValidate()
                    begin
                        if Rejected then begin
                            Accepted := false;
                            UserDecides := false;
                        end else
                            UserDecides := true;

                        SetRecordApprovalState();
                    end;
                }
                field(LetUserDecide; UserDecides)
                {
                    Caption = 'Let User Decide';
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether users can choose to agree or disagree to the integration''s privacy notice for themselves.';

                    trigger OnValidate()
                    begin
                        if not UserDecides then
                            UserDecides := true; // This field can only be unset by selecting agree or disagree
                        Rejected := false;
                        Accepted := false;

                        SetRecordApprovalState();
                    end;
                }
#pragma warning disable AA0218                
                field(Accepted2; Rec.Enabled)
                {
                    ApplicationArea = All;
                    Visible = false; // This field ensures Enabled field is auto-calculated
                }
                field(Rejected2; Rec.Disabled)
                {
                    ApplicationArea = All;
                    Visible = false; // This field ensures Disabled field is auto-calculated
                }
#pragma warning restore AA0218                
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ApproveAll)
            {
                Caption = 'Approve All';
                ApplicationArea = All;
                ToolTip = 'Agrees to all privacy notices in the list for all users.';
                Image = Approval;

                trigger OnAction()
                var
                    PrivacyNotice: Codeunit "Privacy Notice";
                begin
                    if Rec.FindSet() then
                        repeat
                            PrivacyNotice.SetApprovalState(Rec.ID, "Privacy Notice Approval State"::Agreed);
                        until Rec.Next() = 0;
                    CurrPage.Update(false);
                end;
            }
            action(ShowIndividualUserApprovals)
            {
                Caption = 'Show individual approvals';
                ApplicationArea = All;
                ToolTip = 'Shows a list of individual approvals.';
                Image = Users;

                trigger OnAction()
                begin
                    Page.Run(Page::"Privacy Notice Approvals");
                end;
            }
        }
    }

    var
        Accepted: Boolean;
        Rejected: Boolean;
        UserDecides: Boolean;

    trigger OnInit()
    var
        PrivacyNotice: Codeunit "Privacy Notice";
    begin
        PrivacyNotice.CreateDefaultPrivacyNotices();
    end;

    trigger OnAfterGetRecord()
    begin
        Accepted := Rec.Enabled;
        Rejected := Rec.Disabled;
        UserDecides := not (Accepted or Rejected);
    end;

    local procedure SetRecordApprovalState()
    var
        PrivacyNotice: Codeunit "Privacy Notice";
    begin
        case true of
            Accepted:
                PrivacyNotice.SetApprovalState(Rec.ID, "Privacy Notice Approval State"::Agreed);
            Rejected:
                PrivacyNotice.SetApprovalState(Rec.ID, "Privacy Notice Approval State"::Disagreed);
            else
                PrivacyNotice.SetApprovalState(Rec.ID, "Privacy Notice Approval State"::"Not set");
        end;
    end;

}
