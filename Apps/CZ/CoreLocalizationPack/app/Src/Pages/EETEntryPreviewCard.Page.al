// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

using System.Security.User;
using System.Utilities;

page 31147 "EET Entry Preview Card CZL"
{
    Caption = 'EET Entry Preview Card';
    Editable = false;
    LinksAllowed = false;
    PageType = Card;
    SourceTable = "EET Entry CZL";
    SourceTableTemporary = true;

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
                    ToolTip = 'Specifies the number of the cash bank account for the entry.';
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
                field("Created At"; Rec."Created At")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date and time when the entry was created.';
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
                    ToolTip = 'Specifies the VAT base amount for base VAT rate.';
                }
                field("VAT Amount (Basic)"; Rec."VAT Amount (Basic)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT amount for base VAT rate.';
                }
                field("VAT Base (Reduced)"; Rec."VAT Base (Reduced)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT base amount for reduced VAT rate.';
                }
                field("VAT Amount (Reduced)"; Rec."VAT Amount (Reduced)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT amount for reduced VAT rate.';
                }
                field("VAT Base (Reduced 2)"; Rec."VAT Base (Reduced 2)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT base amount for reduced 2 VAT rate.';
                }
                field("VAT Amount (Reduced 2)"; Rec."VAT Amount (Reduced 2)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT amount for reduced 2 VAT rate.';
                }
                field("Amount - Art.89"; Rec."Amount - Art.89")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount under paragraph 89th.';
                }
                field("Amount (Basic) - Art.90"; Rec."Amount (Basic) - Art.90")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount under paragraph 90th for base rate.';
                }
                field("Amount (Reduced) - Art.90"; Rec."Amount (Reduced) - Art.90")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount under paragraph 90th for reduced rate.';
                }
                field("Amount (Reduced 2) - Art.90"; Rec."Amount (Reduced 2) - Art.90")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount under paragraph 90th for reduced 2 rate.';
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
                field("Status Last Changed At"; Rec."Status Last Changed At")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the date and time of the last status change for the EET entry.';

                    trigger OnDrillDown()
                    begin
                        ShowStatusLogPreview();
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
                    ShowStatusLogPreview();
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
        TempEETEntryStatusLogCZL: Record "EET Entry Status Log CZL" temporary;
        TempErrorMessage: Record "Error Message" temporary;
        SignatureCode: Text;
        StatusStyleExpr: Text;

    procedure Set(var NewTempEETEntryCZL: Record "EET Entry CZL" temporary; var NewTempEETEntryStatusLogCZL: Record "EET Entry Status Log CZL" temporary; var NewTempErrorMessage: Record "Error Message" temporary)
    begin
        Rec.Copy(NewTempEETEntryCZL, true);
        TempEETEntryStatusLogCZL.Copy(NewTempEETEntryStatusLogCZL, true);
        TempErrorMessage.Copy(NewTempErrorMessage, true);
    end;

    local procedure SetStatusStyle()
    begin
        StatusStyleExpr := Rec.GetStatusStyleExpr();
    end;

    local procedure ShowStatusLogPreview()
    var
        EETEntryStatusLogPrevCZL: Page "EET Entry Status Log Prev. CZL";
    begin
        EETEntryStatusLogPrevCZL.Set(TempEETEntryStatusLogCZL, TempErrorMessage);
        EETEntryStatusLogPrevCZL.RunModal();
    end;
}
