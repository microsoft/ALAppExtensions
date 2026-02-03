// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Security.User;

using Microsoft.Finance.GeneralLedger.Setup;

pageextension 11721 "User Setup CZL" extends "User Setup"
{
    layout
    {
        addbefore(Email)
        {
            field("Employee No. CZL"; Rec."Employee No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the connectivity between User ID and employee number.';
            }
            field("User Name CZL"; Rec."User Name CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the short name for the user.';
            }
        }
        addlast(Control1)
        {
            field("Allow Item Unapply CZL"; Rec."Allow Item Unapply CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the possibillity to allow or not allow item apply.';
                Visible = IsUserChecksAllowed;
            }
            field("Check Doc. Date(work date) CZL"; Rec."Check Doc. Date(work date) CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies check document date (work date) allowed for posting (set in lines).';
                Visible = IsUserChecksAllowed;
            }
            field("Check Doc. Date(sys. date) CZL"; Rec."Check Doc. Date(sys. date) CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies check document date (system date) allowed for posting (set in lines).';
                Visible = IsUserChecksAllowed;
            }
            field("Check Post.Date(work date) CZL"; Rec."Check Post.Date(work date) CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies check posting date (work date) allowed for posting (set in lines).';
                Visible = IsUserChecksAllowed;
            }
            field("Check Post.Date(sys. date) CZL"; Rec."Check Post.Date(sys. date) CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies check posting date (system date) allowed for posting (set in lines).';
                Visible = IsUserChecksAllowed;
            }
            field("Check Bank Accounts CZL"; Rec."Check Bank Accounts CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies check Bank Accounts allowed for posting (set in lines) for selected user.';
                Visible = IsUserChecksAllowed;
            }
            field("Check Journal Templates CZL"; Rec."Check Journal Templates CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies check journal templates allowed for posting (set in lines) for selected user.';
                Visible = IsUserChecksAllowed;
            }
            field("Check Dimension Values CZL"; Rec."Check Dimension Values CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies check Dimension Values allowed for posting (set in lines).';
                Visible = IsUserChecksAllowed;
            }
            field("Allow Post.toClosed Period CZL"; Rec."Allow Post.toClosed Period CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the possibillity to allow or not allow posting to closed period.';
                Visible = IsUserChecksAllowed;
            }
            field("Allow Complete Job CZL"; Rec."Allow Complete Job CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the possibillity to allow or not allow complete job.';
                Visible = IsUserChecksAllowed;
            }
            field("Check Location Code CZL"; Rec."Check Location Code CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies check location code allowed for posting (set in lines) for selected user.';
                Visible = IsUserChecksAllowed;
            }
            field("Check Release LocationCode CZL"; Rec."Check Release LocationCode CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies check release location code allowed for posting (set in lines) for selected user.';
                Visible = IsUserChecksAllowed;
            }
            field("Check Invt. Movement Temp. CZL"; Rec."Check Invt. Movement Temp. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies check Invt. Movement Templates allowed for posting (set in lines) for selected user.';
                Visible = IsUserChecksAllowed;
            }
        }
    }
    actions
    {
        addlast(processing)
        {
            group("User Check CZL")
            {
                Caption = 'User Check';

                action("Card CZL")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Card';
                    Image = Card;
                    RunObject = page "User Setup Card CZL";
                    RunPageLink = "User ID" = field("User ID");
                    ShortcutKey = 'Shift+F7';
                    ToolTip = 'Specifies the user setup card.';
                    Visible = IsUserChecksAllowed;
                }
                action("Lines CZL")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Lines';
                    Image = SetupLines;
                    RunObject = page "User Setup Lines CZL";
                    RunPageLink = "User ID" = field("User ID");
                    ToolTip = 'Specifies the lines for another user setup.';
                    Visible = IsUserChecksAllowed;
                }
                action("Dimensions CZL")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortcutKey = 'Shift+Ctrl+D';
                    ToolTip = 'Specifies the dimensions related to the user.';
                    Visible = IsUserChecksAllowed;

                    trigger OnAction()
                    var
                        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
                    begin
                        UserSetupAdvManagementCZL.SelectDimensionsToCheck(Rec);
                    end;
                }
            }

            group("Functions CZL")
            {
                Caption = 'Functions';

                action("Copy User Setup CZL")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Copy User Setup';
                    Ellipsis = true;
                    Image = Copy;
                    ToolTip = 'Allows to copy user setup from user to another user.';
                    Visible = IsUserChecksAllowed;

                    trigger OnAction()
                    var
                        CopyUserSetupCZL: Report "Copy User Setup CZL";
                    begin
                        CopyUserSetupCZL.SetFromUserId(Rec."User ID");
                        CopyUserSetupCZL.RunModal();
                    end;
                }
            }

            group("Reporting CZL")
            {
                Caption = 'Reporting';

                action("Print CZL")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Print';
                    Ellipsis = true;
                    Image = Print;
                    ToolTip = 'Open the report for user setup.';
                    Visible = IsUserChecksAllowed;

                    trigger OnAction()
                    var
                        UserSetup: Record "User Setup";
                    begin
                        if UserSetup.Get(Rec."User ID") then begin
                            UserSetup.SetRecFilter();
                            Report.RunModal(Report::"User Setup List CZL", true, false, UserSetup);
                        end;
                    end;
                }
            }
        }
        addlast(Promoted)
        {
            group(UserCheckPromotedCZL)
            {
                Caption = 'User Check';

                actionref(CardCZL_Promoted; "Card CZL")
                {
                }
                actionref(LinesCZL_Promoted; "Lines CZL")
                {
                }
                actionref(DimensionsCZL_Promoted; "Dimensions CZL")
                {
                }
                actionref(CopyUserSetupCZL_Promoted; "Copy User Setup CZL")
                {
                }
                actionref("Print CZL_Promoted"; "Print CZL")
                {
                }
            }
        }
    }

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        IsUserChecksAllowed: Boolean;

    trigger OnOpenPage()
    begin
        GeneralLedgerSetup.Get();
        IsUserChecksAllowed := GeneralLedgerSetup."User Checks Allowed CZL";
    end;
}