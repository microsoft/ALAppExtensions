// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ReturnSettlement;

page 18319 "GST Liability Adj. Journal"
{
    Caption = 'GST Liability Adj. Journal';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    SourceTable = "GST Liability Adjustment";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Journal Doc. No."; Rec."Journal Doc. No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number for the Journal.';
                }
                field("GST Registration No."; Rec."GST Registration No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the companies GST registration number.';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Vendor number for which adjustment needs to be done.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of document that the entry belongs to.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number for the journal entry .';
                }
                field("Document Posting Date"; Rec."Document Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entries posting date.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a document number that refers to the Customers or Vendors numbering system.';
                }
                field("Location State Code"; Rec."Location State Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the sate code mentioned in location used in the transaction.';
                }
                field("GST Jurisdiction Type"; Rec."GST Jurisdiction Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type related to GST jurisdiction. For example, interstate/intrastate.';
                }
                field("Adjustment Posting Date"; Rec."Adjustment Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the adjustment entries posting date.';
                }
                field("Adjustment Amount"; Rec."Adjustment Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount to be adjusted.';
                }
                field("Total GST Amount"; Rec."Total GST Amount")
                {
                    Visible = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies different adjustment types. For example, Generate/Reverse etc.';
                }
                field("Total GST Credit Amount"; Rec."Total GST Credit Amount")
                {
                    Visible = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total GST Credit amount calculated for credit adjustment journal.';
                }
                field("Total GST Liability Amount"; Rec."Total GST Liability Amount")
                {
                    Visible = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total GST Liability amount calculated for Liability adjustment journal.';
                }
                field("Nature of Adjustment"; Rec."Nature of Adjustment")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies different adjustment types. For example, Credit Availment/Credit Reversal.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("P&osting")
            {
                Caption = 'P&osting';
                action("<Action1500030>")
                {
                    Caption = 'Post';
                    Image = PostOrder;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Finalize and prepare the document';

                    trigger OnAction()
                    begin
                        if not Confirm(PostCreditLiabilityQst) then
                            exit;

                        GSTSettlement.PostLiabilityAdjustmentJnl(Rec);
                        Rec.DeleteAll();
                        CurrPage.Close();
                    end;
                }
                action(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to a document.';

                    trigger OnAction()
                    begin
                        Rec.ShowDocDim();
                    end;
                }
                action("Line Dimension")
                {
                    Caption = 'Line Dimension';
                    Image = Dimensions;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign and analyze transaction history.';

                    trigger OnAction()
                    begin
                        Rec.ShowDocDim();
                        CurrPage.SaveRecord();
                    end;
                }
            }
        }
    }

    var
        GSTSettlement: Codeunit "GST Settlement";
        PostCreditLiabilityQst: Label 'Do you want to Post GST Credit & Liability Adjustment?';
}
