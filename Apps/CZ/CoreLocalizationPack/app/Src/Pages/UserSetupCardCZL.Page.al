// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
namespace System.Security.User;

page 31198 "User Setup Card CZL"
{
    Caption = 'User Setup Card';
    PageType = Card;
    SourceTable = "User Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ID of the user associated with the entry.';
                }
                field("User Name CZL"; Rec."User Name CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the User Name.';
                }
                field("Employee No. CZL"; Rec."Employee No. CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the connectivity between User ID and employee number.';
                }
                field("Check Doc. Date(work date) CZL"; Rec."Check Doc. Date(work date) CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies check document date (work date) allowed for posting (set in lines).';
                }
                field("Check Doc. Date(sys. date) CZL"; Rec."Check Doc. Date(sys. date) CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies check document date (system date) allowed for posting (set in lines).';
                }
                field("Check Post.Date(work date) CZL"; Rec."Check Post.Date(work date) CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies check posting date (work date) allowed for posting (set in lines).';
                }
                field("Check Post.Date(sys. date) CZL"; Rec."Check Post.Date(sys. date) CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies check posting date (system date) allowed for posting (set in lines).';
                }
                field("Allow Complete Job CZL"; Rec."Allow Complete Job CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether is allowed to close the Project.';
                }
                field("Allow VAT Date Changing CZL"; Rec."Allow VAT Date Changing CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether is allowed to change the VAT Date.';
                }
            }
            group(Posting)
            {
                Caption = 'Posting';
                field("Check Location Code CZL"; Rec."Check Location Code CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether is allowed to post only on Locations setted up in the Lines.';
                }
                field("Check Release LocationCode CZL"; Rec."Check Release LocationCode CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether is allowed to release document only with Locations setted up in the Lines.';
                }
                field("Check Bank Accounts CZL"; Rec."Check Bank Accounts CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether is allowed to post only on Bank accounts setted up in the Lines.';
                }
                field("Check Journal Templates CZL"; Rec."Check Journal Templates CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether is allowed to work only in journal templates setted up in the Lines.';
                }
                field("Check Dimension Values CZL"; Rec."Check Dimension Values CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether is allowed to post to Dimensions setted up in Dimensions.';
                }
                field("Allow Post.toClosed Period CZL"; Rec."Allow Post.toClosed Period CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the possibillity to allow or not allow posting to closed period.';
                }

                field("Check Invt. Movement Temp. CZL"; Rec."Check Invt. Movement Temp. CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether is allowed to post only with Invenotry Movement Templates setted up in the Lines.';
                }
                field("Allow Item Unapply CZL"; Rec."Allow Item Unapply CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether is allowed to cancel Item applying in Application Worksheet.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1220001; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1220000; Notes)
            {
                ApplicationArea = Notes;
                Visible = true;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("U&ser Check")
            {
                Caption = 'U&ser Check';
                action(Lines)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Lines';
                    Image = SocialSecurityLines;
                    RunObject = page "User Setup Lines CZL";
                    RunPageLink = "User ID" = field("User ID");
                    ToolTip = 'Specifies the lines for another user setup.';
                }
                action(Dimensions)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortcutKey = 'Shift+Ctrl+D';
                    ToolTip = 'Specifies the dimensions related to the user.';

                    trigger OnAction()
                    var
                        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
                    begin
                        UserSetupAdvManagementCZL.SelectDimensionsToCheck(Rec);
                    end;
                }
            }
        }
        area(reporting)
        {
            action("Print")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Print';
                Ellipsis = true;
                Image = Print;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Allows the user setup card printout.';

                trigger OnAction()
                var
                    UserSetup: Record "User Setup";
                begin
                    UserSetup.Copy(Rec);
                    UserSetup.SetRecFilter();
                    REPORT.RunModal(REPORT::"User Setup List CZL", true, false, UserSetup);
                end;
            }
        }
    }
}

