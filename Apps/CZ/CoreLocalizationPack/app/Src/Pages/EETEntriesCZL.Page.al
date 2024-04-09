// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

using System.Security.User;

page 31145 "EET Entries CZL"
{
    ApplicationArea = Basic, Suite;
    Caption = 'EET Entries';
    CardPageId = "EET Entry Card CZL";
    Editable = false;
    PageType = List;
    SourceTable = "EET Entry CZL";
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Business Premises Code"; Rec."Business Premises Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the business premises.';
                }
                field("Cash Register Code"; Rec."Cash Register Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the EET cash register.';
                }
                field("Cash Register Type"; Rec."Cash Register Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the source type of the entry.';
                }
                field("Cash Register No."; Rec."Cash Register No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the cash bank account for the entry.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry''s document number.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the EET entry.';
                }
                field("Total Sales Amount"; Rec."Total Sales Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total amount of cash document.';
                }
                field("Amount Exempted From VAT"; Rec."Amount Exempted From VAT")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount of cash document VAT-exempt.';
                }
                field("Status"; Rec."Status")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StatusStyleExpr;
                    ToolTip = 'Specifies the current state of the EET entries.';
                }
                field(StatusLastChangedAt; Rec.GetFormattedStatusLastChangedAt())
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Status Last Changed At';
                    ToolTip = 'Specifies the date and time of the last status change for the EET entry.';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowStatusLog();
                    end;
                }
                field("Receipt Serial No."; Rec."Receipt Serial No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the serial no. of the EET receipt.';
                }
                field("Applied Document Type"; Rec."Applied Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of the applied document.';
                }
                field("Applied Document No."; Rec."Applied Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the applied document.';
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ID of the user who created the entry.';

                    trigger OnDrillDown()
                    var
                        UserMgt: Codeunit "User Management";
                    begin
                        UserMgt.DisplayUserInformation(Rec."Created By");
                    end;
                }
                field(CreatedAt; Rec.GetFormattedCreatedAt())
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Created At';
                    ToolTip = 'Specifies the date and time when the entry was created.';
                }
                field("Canceled By Entry No."; Rec."Canceled By Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of entry to be canceled.';
                }
                field("Simple Registration"; Rec."Simple Registration")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    ToolTip = 'Specifies whether it is a simplified registration entry.';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the EET entry number.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Entry Status Log")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Entry Status Log';
                Image = Status;
                ToolTip = 'Displays a log of the EET entry status changes.';

                trigger OnAction()
                begin
                    Rec.ShowStatusLog();
                end;
            }
            action("Show Document")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Show Document';
                Image = Document;
                ToolTip = 'Displays the document related to the entry.';

                trigger OnAction()
                begin
                    Rec.ShowDocument();
                end;
            }
        }
        area(processing)
        {
            action(Send)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Send';
                Image = SendElectronicDocument;
                ToolTip = 'Sends the selected entry to the EET service to register.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.Send(true);
                    CurrPage.Update(false);
                end;
            }
            action(Verify)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Verify';
                Image = SendApprovalRequest;
                ToolTip = 'Sends the selected entry to the EET service to verification.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.Verify();
                end;
            }
            action(Cancel)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Cancel';
                Image = Cancel;
                ToolTip = 'Sends the selected entry to the EET service to cancel.';

                trigger OnAction()
                begin
                    Rec.Cancel(true);
                end;
            }
            action(SimpleRegistration)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Simple EET Registration';
                Image = ReverseRegister;
                RunObject = page "EET Simple Registration CZL";
                ToolTip = 'Create simple EET entry.';
            }
        }
        area(Reporting)
        {
            action(Confirmation)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Confirmation';
                Image = PrintReport;
                ToolTip = 'Print Confirmation of EET Entry';

                trigger OnAction()
                var
                    EETEntryCZL: Record "EET Entry CZL";
                    EETConfirmationCZL: Report "EET Confirmation CZL";
                begin
                    EETEntryCZL := Rec;
                    EETEntryCZL.SetRecFilter();
                    EETConfirmationCZL.SetTableView(EETEntryCZL);
                    EETConfirmationCZL.RunModal();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetStatusStyle();
    end;

    var
        StatusStyleExpr: Text;

    local procedure SetStatusStyle()
    begin
        StatusStyleExpr := Rec.GetStatusStyleExpr();
    end;
}
