// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 1564 "Privacy Notice Approvals"
{
    PageType = List;
    SourceTable = "Privacy Notice Approval";
    InsertAllowed = false;
    ModifyAllowed = false;
    
    layout
    {
        area(Content)
        {
            repeater(PrivacyNoticeApprovals)
            {
                field(IntegrationServiceName; IntegrationServiceName)
                {
                    Caption = 'Integration Name';
                    ToolTip = 'Specifies the integration name.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(UserName; UserName)
                {
                    Caption = 'User Name';
                    ToolTip = 'Specifies the user who this approval belongs to. <Organization> means for everyone in the company.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Accepted; Rec.Approved)
                {
                    Caption = 'Agree';
                    ToolTip = 'Specifies that the privacy notice was agreed to. .';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Rejected; not Rec.Approved)
                {
                    Caption = 'Disagree';
                    ApplicationArea = All;
                    ToolTip = 'Specifies that the privacy notice was not agreed to. .';
                    Editable = false;
                }
                field(ApproverUserName; ApproverUserName)
                {
                    Caption = 'Approver User Name';
                    ToolTip = 'Specifies the user who agreed/disagreed to the privacy notice.';
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    var
        IntegrationServiceName: Text;
        UserName: Text;
        ApproverUserName: Text;
        OrganizationTxt: Label '<Organization>', Comment = 'This is an indication that the privacy notice was approved by the organization and must align with the tooltip for the UserName';

    trigger OnAfterGetRecord()
    var
        PrivacyNotice: Record "Privacy Notice";
        User: Record User;
    begin
        PrivacyNotice.Get(Rec.ID);
        IntegrationServiceName := PrivacyNotice."Integration Service Name";
        case true of
            IsNullGuid(Rec."User SID"):
                UserName := OrganizationTxt;
            User.Get(Rec."User SID"):
                UserName := User."User Name";
            else
                Clear(UserName);
        end;

        if User.Get(Rec."Approver User SID") then
            ApproverUserName := User."User Name"
        else
            Clear(ApproverUserName);
    end;
}