// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ReturnSettlement;

page 18318 "GST Credit Adjustment Journal"
{
    Caption = 'GST Credit Adjustment Journal';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    SourceTable = "GST Credit Adjustment Journal";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("GST Registration No."; Rec."GST Registration No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company''s GST registration number issued by authorized body.';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vendor code for which credit adjustment has to be done.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of document that the entry belongs to.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry''s document number.';
                }
                field("Document Line No."; Rec."Document Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document line number.';

                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of entries as Item or service.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a document number that refers to the customer''s or vendor''s numbering system.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry''s posting date.';
                }
                field("GST Jurisdiction Type"; Rec."GST Jurisdiction Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type related to GST jurisdiction. For example, interstate/intrastate.';
                }
                field("Total GST Amount"; Rec."Total GST Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total GST amount calculated for credit adjustment journal.';
                }
                field("Location State Code"; Rec."Location State Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the sate code mentioned in location used in the transaction.';
                }
                field("Total GST Credit Amount"; Rec."Total GST Credit Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total GST credit limit available.';
                }
                field("Nature of Adjustment"; Rec."Nature of Adjustment")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies different adjustment types. For example, Credit Availment/Credit Reversal.';
                }
                field("Dimension Set ID"; Rec."Dimension Set ID")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Enabled = false;
                    Visible = false;
                    ToolTip = 'Specifies the combination of dimension in a set';
                }
                field("Available Adjustment %"; Rec."Available Adjustment %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the available rate of credit for adjustment. Do not enter percent sign, only the number. For example, if the available adjustment rate is 10%, enter 10 into this field.';
                }
                field("Available Adjustment Amount"; Rec."Available Adjustment Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the available amount of credit for adjustment.';
                }
                field("Adjustment %"; Rec."Adjustment %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the adjustment rate. Do not enter percent sign, only the number. For example, if the adjustment rate is 10%, enter 10 into this field.';
                }
                field("Adjustment Amount"; Rec."Adjustment Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the adjustment amount.';
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
                action(Post)
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
                        CheckMandatoryFields();
                        GSTSettlement.PostCreditAdjustmentJnl(Rec);
                        Rec.DeleteAll();
                        CurrPage.CLOSE();
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

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if not Rec.IsEmpty() then begin
            if not Confirm(PageCloseQst) then
                Error(NoRecsDeletedErr);
            Rec.DeleteAll();
        end;
    end;

    local procedure CheckMandatoryFields()
    begin
        if Rec."Adjust Document No." = '' then
            Error(AdjDocErr);

        if Rec."GST Registration No." = '' then
            Error(GSTINNoErr);

        if Rec."Adjustment Posting Date" = 0D then
            Error(PostingDateErr);

        Rec.TestField("Total GST Amount");
        Rec.TestField("Total GST Credit Amount");
    end;

    var
        GSTSettlement: Codeunit "GST Settlement";
        GSTINNoErr: Label 'GSTIN No. must not be empty.';
        PageCloseQst: Label 'The records will be deleted from GST Credit Adjustment Journal. Do you want to continue?';
        PostingDateErr: Label 'You can not change the Period Month or Period Year in the GST Credit Adjustment Journal, since there are some records with Posting Date as %1.', Comment = '%1 = Posting Date';
        NoRecsDeletedErr: Label 'No records are deleted.';
        AdjDocErr: Label 'Adjust Document No. must not be empty.';
}
