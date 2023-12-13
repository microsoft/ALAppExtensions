// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

using System.Security.User;

#pragma implicitwith disable
page 31146 "EET Entry Card CZL"
{
    Caption = 'EET Entry Card';
    Editable = false;
    PageType = Card;
    SourceTable = "EET Entry CZL";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
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
                    ToolTip = 'Specifies the source number of the entry.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the EET entry.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry''s document number.';
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
                field("Receipt Serial No."; Rec."Receipt Serial No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the serial no. of the EET receipt.';
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
            }
            group(Sale)
            {
                Caption = 'Sale';
                field("Total Sales Amount"; Rec."Total Sales Amount")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the total amount of cash document.';
                }
                field("Amount Exempted From VAT"; Rec."Amount Exempted From VAT")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount of cash document VAT-exempt.';
                }
                field("VAT Base (Basic)"; Rec."VAT Base (Basic)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT base amount.';
                }
                field("VAT Amount (Basic)"; Rec."VAT Amount (Basic)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the base VAT amount.';
                }
                field("VAT Base (Reduced)"; Rec."VAT Base (Reduced)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the reduced VAT base amount.';
                }
                field("VAT Amount (Reduced)"; Rec."VAT Amount (Reduced)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the reduced VAT amount.';
                }
                field("VAT Base (Reduced 2)"; Rec."VAT Base (Reduced 2)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the reduced VAT base amount.';
                }
                field("VAT Amount (Reduced 2)"; Rec."VAT Amount (Reduced 2)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the reduced VAT amount 2.';
                }
                field("Amount - Art.89"; Rec."Amount - Art.89")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount under paragraph 89th.';
                }
                field("Amount (Basic) - Art.90"; Rec."Amount (Basic) - Art.90")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the base amount under paragraph 90th.';
                }
                field("Amount (Reduced) - Art.90"; Rec."Amount (Reduced) - Art.90")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the reduced amount under paragraph 90th.';
                }
                field("Amount (Reduced 2) - Art.90"; Rec."Amount (Reduced 2) - Art.90")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the reduced amount 2 under paragraph 90th.';
                }
                field("Amt. For Subseq. Draw/Settle"; Rec."Amt. For Subseq. Draw/Settle")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount of the payments for subsequent drawdown or settlement.';
                }
                field("Amt. Subseq. Drawn/Settled"; Rec."Amt. Subseq. Drawn/Settled")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount of the subsequent drawing or settlement.';
                }
            }
            group(Communication)
            {
                Caption = 'Communication';
                field("Status"; Rec."Status")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    StyleExpr = StatusStyleExpr;
                    ToolTip = 'Specifies the current state of the EET entries.';
                }
                field(StatusLastChangedAt; Rec.GetFormattedStatusLastChangedAt())
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Status Last Changed At';
                    Importance = Promoted;
                    ToolTip = 'Specifies the date and time of the last status change for the EET entry.';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowStatusLog();
                    end;
                }
                field("Message UUID"; Rec."Message UUID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the UUID of the data message.';
                }
                field(SignatureCode; SignatureCode)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Taxpayer''s Signature Code';
                    ToolTip = 'Specifies the content of the field for the Signing code of the taxpayer.';
                }
                field("Taxpayer's Security Code"; Rec."Taxpayer's Security Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the content of the field for the Security code of the taxpayer.';
                }
                field("Fiscal Identification Code"; Rec."Fiscal Identification Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the content of the field for the Fiscal identification code of the receipt.';
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
        SignatureCode := Rec.GetSignatureCode();
        SetStatusStyle();
    end;

    var
        SignatureCode: Text;
        StatusStyleExpr: Text;

    local procedure SetStatusStyle()
    begin
        StatusStyleExpr := Rec.GetStatusStyleExpr();
    end;
}
