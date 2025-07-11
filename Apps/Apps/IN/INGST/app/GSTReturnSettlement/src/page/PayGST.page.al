// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ReturnSettlement;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GST.Distribution;

page 18322 "Pay GST"
{
    Caption = 'Pay GST';
    ApplicationArea = Basic, Suite;
    PageType = List;
    SourceTable = "GST Payment Buffer";
    SourceTableView = sorting("GST Registration No.", "Document No.", "GST Component Code") ORDER(ascending);
    DeleteAllowed = false;
    InsertAllowed = false;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("GST Component Code"; Rec."GST Component Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST component code for which the payment is being done.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description on the GST component code.';
                }
                field("GST Registration No."; Rec."GST Registration No.")
                {
                    Visible = false;
                    ApplicationArea = Basic, Suite;
                    Tooltip = 'Specifies GST registration number to discharge the tax liability to the government.';
                }
                field("GST Input Service Distribution"; Rec."GST Input Service Distribution")
                {
                    Visible = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the GST registration number belongs to GST input service distributor.';
                }
                field("Period end Date"; Rec."Period end Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the period end date. Entries byond this date will not be considered.';
                }
                field("Payment Liability"; Rec."Payment Liability")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value which defines the liability of payment for the component code.';
                }
                field("GST TCS Liability"; Rec."GST TCS Liability")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of GST TCS Liability against component code.';
                }
                field("Net Payment Liability"; Rec."Net Payment Liability")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Net Payment Liability against the component code.';
                }
                field("Unadjutsed Liability"; Rec."Unadjutsed Liability")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of Unadjusted Liability for the component code.';
                }
                field("Credit Availed"; Rec."Credit Availed")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the credit amount that has been availed for the component code.';
                }
                field("Distributed Credit"; Rec."Distributed Credit")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of Distributed Credit for the component code.';
                }
                field("GST TDS Credit Available"; Rec."GST TDS Credit Available")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of GST TDS Credit available against the component code.';
                }
                field("GST TDS Credit Utilized"; Rec."GST TDS Credit Utilized")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of GST TDS Credit utilized against the component code.';
                }
                field("GST TCS Credit Available"; Rec."GST TCS Credit Available")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of GST TCS Credit available against the component code.';
                }
                field("GST TCS Credit Utilized"; Rec."GST TCS Credit Utilized")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of GST TCS Credit utilized against the component code.';
                }
                field("Total Credit Available"; Rec."Total Credit Available")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Total Credit Available against the component code';
                }
                field("UnAdjutsed Credit"; Rec."UnAdjutsed Credit")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of UnAdjusted Credit against the component code.';
                }
                field("Credit Utilized"; Rec."Credit Utilized")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of Credit Utilized for the component code.';
                }
                field("Payment Amount"; Rec."Payment Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of Payment Amount for the component code.';
                }
                field("Payment Liability - Rev. Chrg."; Rec."Payment Liability - Rev. Chrg.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Payment Liability- Reverse Charge against the component code.';
                }
                field("Payment Amount - Rev. Chrg."; Rec."Payment Amount - Rev. Chrg.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Payment Amount- Reverse Charge against the component code.';
                }
                field(Interest; Rec.Interest)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of interest payable against component code.';
                }
                field("Interest Account No."; Rec."Interest Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies interest payable general ledger account number against component code.';
                }
                field(Penalty; Rec.Penalty)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of penalty payable against component code.';
                }
                field("Penalty Account No."; Rec."Penalty Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the penalty payable general ledger account number against component code.';
                }
                field(Fees; Rec.Fees)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of fees payable against component code.';
                }
                field("Fees Account No."; Rec."Fees Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the fees payable general ledger account number against component code.';
                }
                field(Others; Rec.Others)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of Others payables against component code.';
                }
                field("Others Account No."; Rec."Others Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Other payables general ledger account number against the component code.';
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of account where the entry will be posted.';
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the general ledger account number where the entry will be posted.';
                }
                field("Total Payment Amount"; Rec."Total Payment Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Total Payment Amount against the component code.';
                }
                field("Bank Reference No."; Rec."Bank Reference No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Bank Reference number for the payment made against GST payment.';
                }
                field("Bank Reference Date"; Rec."Bank Reference Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Bank Reference Date on which the payment is made.';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;

                action(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Alt+D';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the process to view or edit dimentions, that can be assigned to transactions to distribute cost and analyze transaction history.';

                    trigger OnAction()
                    begin
                        ShowDimensions();
                        CurrPage.SAVERECORD();
                    end;
                }
            }
        }
        area(processing)
        {
            action(Post)
            {
                Caption = 'P&ost';
                ApplicationArea = Basic, Suite;
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'F9';
                ToolTip = 'Finalize the document or journal by posting the amounts to the related accounts in your company books.';

                trigger OnAction()
                begin
                    if GSTSettlement.PostGSTPayment(Rec."GST Registration No.", Rec."Document No.", NoMsg) then begin
                        Message(GSTPaymetMsg);
                        CurrPage.Close();
                    end else
                        if not NoMsg then
                            Message(NothingToPostMsg);
                end;
            }
            action("Calculation Details")
            {
                Caption = 'D&etails';
                ApplicationArea = Basic, Suite;
                Image = ViewDetails;
                ToolTip = 'Specifies the page through which GST net payment of liability can be settled.';

                trigger OnAction()
                var
                    GSTPaymentBufferDetails: Record "GST Payment Buffer Details";
                    PayGSTCalculationDetails: Page "Pay GST Calculation Details";
                begin
                    Clear(GSTSettlement);
                    GSTSettlement.ValidateCreditUtilizedAmt(Rec."GST Registration No.", Rec."Document No.");
                    Commit();

                    Clear(PayGSTCalculationDetails);
                    PayGSTCalculationDetails.SetParameter(Rec."GST Registration No.", Rec."Document No.");
                    PayGSTCalculationDetails.SetTableView(GSTPaymentBufferDetails);
                    PayGSTCalculationDetails.RunModal();
                end;
            }
        }
    }

    trigger OnClosePage()
    var
        GSTPaymentBuffer: Record "GST Payment Buffer";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GSTPaymentBuffer.SetRange("Document No.", DocumentNo);
        GSTPaymentBuffer.DeleteAll();

        GenJournalLine.Reset();
        GenJournalLine.SetRange("Document No.", Rec."Document No.");
        GenJournalLine.DeleteAll();
    end;

    trigger OnOpenPage()
    begin
        Rec.FilterGroup(2);
        Rec.SetRange("GST Registration No.", GSTNNo);
        Rec.SetRange("Document No.", DocumentNo);
        Rec.FilterGroup(0);
    end;

    var
        GSTSettlement: Codeunit "GST Settlement";
        GSTNNo: Code[20];
        DocumentNo: Code[20];
        NoMsg: Boolean;
        GSTPaymetMsg: Label 'GST Payment Lines Posted Successfully.';
        NothingToPostMsg: Label 'There is nothing to post.';
        GSTRegistrationMsg: Label '%1', Comment = '%1 GST registration No.';

    procedure SetParameter(GSTN: Code[20]; PaymentDocumentNo: Code[20])
    begin
        GSTNNo := GSTN;
        DocumentNo := PaymentDocumentNo;
    end;

    local procedure ShowDimensions()
    var
        DimensionManagement: Codeunit DimensionManagement;
    begin
        Rec."Dimension Set ID" :=
          DimensionManagement.EditDimensionSet(
              Rec."Dimension Set ID",
              StrSubstNo(GSTRegistrationMsg, Rec."GST Registration No."));
    end;
}
