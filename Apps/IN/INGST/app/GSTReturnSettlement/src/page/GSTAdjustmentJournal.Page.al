// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ReturnSettlement;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GST.Base;
using Microsoft.Inventory.Item;
using Microsoft.Purchases.Vendor;

page 18329 "GST Adjustment Journal"
{
    AutoSplitKey = true;
    Caption = 'GST Adjustment Journal';
    UsageCategory = Tasks;
    ApplicationArea = Basic, Suite;
    DataCaptionFields = "Journal Batch Name";
    DelayedInsert = true;
    InsertAllowed = false;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "GST Journal Line";

    layout
    {
        area(content)
        {
            group(Control120)
            {
                ShowCaption = false;
                field(CurrentJnlBatchName; CurrentJnlBatchName)
                {
                    Caption = 'Batch Name';
                    ToolTip = 'Specifies the journa batch name.';
                    ApplicationArea = Basic, Suite;
                    Lookup = true;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        CurrPage.SaveRecord();
                        GSTJournalManagement.LookupNameGST(CurrentJnlBatchName, Rec);
                        CurrPage.Update(false);
                    end;

                    trigger OnValidate()
                    begin
                        GSTJournalManagement.CheckNameGST(CurrentJnlBatchName, Rec);
                        CurrentJnlBatchNameOnAfterVali();
                    end;
                }
                field(TransactionNo; TransactionNo)
                {
                    BlankZero = true;
                    Caption = 'DGL Entry No.';
                    ToolTip = 'Specifies the transaction number of the posted entry.';
                    ApplicationArea = Basic, Suite;
                    TableRelation = "Detailed GST Ledger Entry"."Entry No." WHERE("Entry Type" = FILTER("Initial Entry"),
                                                                                   "Transaction Type" = FILTER(Purchase | Transfer),
                                                                                   Type = FILTER(Item | "G/L Account"),
                                                                                   "Document Type" = FILTER(Invoice),
                                                                                   "GST Group Type" = FILTER(Goods),
                                                                                   "Item Charge Entry" = FILTER(false),
                                                                                   "GST Exempted Goods" = FILTER(false),
                                                                                   "Journal Entry" = FILTER(false));

                    trigger OnValidate()
                    var
                        GSTJournalLine: Record "GST Journal Line";
                        GSTJournalBatch: Record "GST Journal Batch";
                        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
                        Vend: Record "Vendor";
                        GeneralPostingSetup: Record "General Posting Setup";
                        GLAccount: Record "G/L Account";
                        InventoryPostingSetup: Record "Inventory Posting Setup";
                        Item: Record "Item";
                        LineNo: Integer;
                    begin
                        Counter := 0;
                        OriginalQuantity := 0;
                        GSTAmount := 0;
                        GSTBaseAmount := 0;
                        InputCreditOutputTaxAmount := 0;
                        GSTJournalBatch.Get(Rec."Journal Template Name", Rec."Journal Batch Name");

                        GSTJournalLine.LockTable();
                        GSTJournalLine.SetRange("Journal Template Name", Rec."Journal Template Name");
                        GSTJournalLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
                        if GSTJournalLine.FindLast() then
                            LineNo := GSTJournalLine."Line No." + 10000
                        else
                            LineNo := 10000;

                        DetailedGSTLedgerEntry.Get(TransactionNo);
                        CheckCurrentEntry(TransactionNo);
                        CheckExistingEntry(DetailedGSTLedgerEntry."Document No.", DetailedGSTLedgerEntry."Document Line No.");

                        TransactionNo := DetailedGSTLedgerEntry."Entry No.";

                        DetailedGSTLedgerEntrySource.Reset();
                        DetailedGSTLedgerEntrySource.SetCurrentKey("Document No.", "Document Line No.");
                        DetailedGSTLedgerEntrySource.SetRange("Document No.", DetailedGSTLedgerEntry."Document No.");
                        DetailedGSTLedgerEntrySource.SetRange("Entry Type", DetailedGSTLedgerEntrySource."Entry Type"::"Initial Entry");
                        DetailedGSTLedgerEntrySource.SetFilter("Transaction Type", '%1', DetailedGSTLedgerEntrySource."Transaction Type"::Purchase);
                        DetailedGSTLedgerEntrySource.SetFilter("Document Type", '%1', DetailedGSTLedgerEntrySource."Document Type"::Invoice);
                        DetailedGSTLedgerEntrySource.SetRange("GST Group Type", DetailedGSTLedgerEntrySource."GST Group Type"::Goods);
                        DetailedGSTLedgerEntrySource.SetRange("Document Line No.", DetailedGSTLedgerEntry."Document Line No.");
                        DetailedGSTLedgerEntrySource.SetRange("Item Charge Entry", false);
                        DetailedGSTLedgerEntrySource.SetRange("GST Exempted Goods", false);
                        if DetailedGSTLedgerEntrySource.FindSet() then
                            repeat
                                DetailedGSTLedgerEntryInfo.Get(DetailedGSTLedgerEntrySource."Entry No.");
                                if not DetailedGSTLedgerEntryInfo."RCM Exempt" then begin
                                    DetailedGSTLedgerEntryCheck.Reset();
                                    DetailedGSTLedgerEntryCheck.SetCurrentKey("Document No.", "Document Line No.");
                                    DetailedGSTLedgerEntryCheck.SetRange("Document No.", DetailedGSTLedgerEntrySource."Document No.");
                                    DetailedGSTLedgerEntryCheck.SetRange("Document Line No.", DetailedGSTLedgerEntrySource."Document Line No.");
                                    DetailedGSTLedgerEntryCheck.SetRange("Entry Type", DetailedGSTLedgerEntryCheck."Entry Type"::"Initial Entry");
                                    InserGSTAdjustmentBuffer(DetailedGSTLedgerEntrySource, LineNo);
                                end;
                            until DetailedGSTLedgerEntrySource.Next() = 0;

                        GSTJournalLine.Init();
                        GSTJournalLine."Document No." := DetailedGSTLedgerEntry."Document No.";
                        GSTJournalLine."Journal Template Name" := "Journal Template Name";
                        GSTJournalLine."Journal Batch Name" := "Journal Batch Name";
                        GSTJournalLine."Line No." := LineNo;
                        GSTJournalLine."Posting Date" := WorkDate();

                        DetailedGSTLedgerEntryInfo.Get(DetailedGSTLedgerEntry."Entry No.");
                        if DetailedGSTLedgerEntryInfo."Original Doc. Type" = DetailedGSTLedgerEntryInfo."Original Doc. Type"::"Transfer Receipt" then begin
                            Item.Get(DetailedGSTLedgerEntry."No.");
                            InventoryPostingSetup.Get(DetailedGSTLedgerEntry."Location Code", Item."Inventory Posting Group");
                            InventoryPostingSetup.TestField("Unrealized Profit Account");
                        end else begin
                            if DetailedGSTLedgerEntry."Source Type" = DetailedGSTLedgerEntry."Source Type"::Vendor then begin
                                Vend.Get(DetailedGSTLedgerEntry."Source No.");
                                GenBussinessPostingGroup := Vend."Gen. Bus. Posting Group";
                            end;
                            case DetailedGSTLedgerEntry.Type of
                                DetailedGSTLedgerEntry.Type::Item:
                                    begin
                                        Item.Get(DetailedGSTLedgerEntry."No.");
                                        GenProductPostingGroup := Item."Gen. Prod. Posting Group";
                                    end;
                                DetailedGSTLedgerEntry.Type::"G/L Account":
                                    begin
                                        GLAccount.Get(DetailedGSTLedgerEntry."No.");
                                        GenProductPostingGroup := GLAccount."Gen. Prod. Posting Group";
                                    end;
                            end;
                            GeneralPostingSetup.Get(GenBussinessPostingGroup, GenProductPostingGroup);
                            GeneralPostingSetup.TestField("Purch. Account");
                        end;

                        GSTJournalLine."Account Type" := GSTJournalLine."Account Type"::"G/L Account";
                        case DetailedGSTLedgerEntry.Type of
                            DetailedGSTLedgerEntry.Type::Item:
                                if DetailedGSTLedgerEntryInfo."Original Doc. Type" = DetailedGSTLedgerEntryInfo."Original Doc. Type"::"Transfer Receipt" then
                                    GSTJournalLine."Account No." := InventoryPostingSetup."Unrealized Profit Account"
                                else
                                    GSTJournalLine."Account No." := GeneralPostingSetup."Purch. Account";
                            DetailedGSTLedgerEntry.Type::"G/L Account":
                                GSTJournalLine."Account No." := DetailedGSTLedgerEntry."No.";
                        end;

                        GSTJournalLine."Document Type" := DetailedGSTLedgerEntry."Document Type";
                        GSTJournalLine."Document Line No." := DetailedGSTLedgerEntry."Document Line No.";
                        GSTJournalLine."Bal. Account No." := '';
                        GSTJournalLine.Description := Text00001Txt + DetailedGSTLedgerEntry."Document No.";
                        if Counter <> 0 then
                            GSTJournalLine."Original Quantity" := OriginalQuantity / Counter;
                        GSTJournalLine."GST Base Amount" := GSTBaseAmount;
                        GSTJournalLine."GST Amount" := GSTAmount;
                        GSTJournalLine."Total GST Amount" := GSTAmount;
                        GSTJournalLine.Quantity := DetailedGSTLedgerEntry.Quantity;
                        GSTJournalLine."Credit Amount" := GSTAmount;
                        GSTJournalLine."Total ITC Amount Available" := InputCreditOutputTaxAmount;
                        GSTJournalLine."Reason Code" := GSTJournalBatch."Reason Code";
                        GSTJournalLine."Source Code" := GSTJournalBatch."Source Code";
                        GSTJournalLine."No. Series" := GSTJournalBatch."No. Series";
                        GSTJournalLine."Posting No. Series" := GSTJournalBatch."Posting No. Series";
                        GSTJournalLine."Template Type" := GSTJournalBatch."Template Type";
                        GSTJournalLine."Location Code" := GSTJournalBatch."Location Code";
                        GSTJournalLine."Original Location" := DetailedGSTLedgerEntry."Location Code";
                        GSTJournalLine."Original Location GSTIN" := DetailedGSTLedgerEntry."Location  Reg. No.";
                        GSTJournalLine."DGL From Entry No." :=
                          GetFirstEntryNo(DetailedGSTLedgerEntry."Document No.", DetailedGSTLedgerEntry."Document Line No.");
                        GSTJournalLine."DGL From To No." :=
                          GetLastEnryNo(DetailedGSTLedgerEntry."Document No.", DetailedGSTLedgerEntry."Document Line No.");
                        GSTJournalLine."System-Created Entry" := true;
                        GSTJournalLine."GST Adjustment Entry" := true;
                        GSTJournalLine."GST Transaction No." := TransactionNo;
                        GSTJournalLine.TestField("Source Code");
                        GSTJournalLine.Insert();
                        TransactionNoOnAfterValidate();
                    end;
                }
            }
            repeater(Control1)
            {
                ShowCaption = false;
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry posting date.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of document that the entry belongs to.';
                    Editable = false;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number for the journal entry .';
                    Editable = false;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a document number that refers to the Customer or Vendors numbering system.';
                    Visible = false;
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of account that the entry on the adjustment journal line to be posted to.';
                    Editable = false;

                    trigger OnValidate()
                    begin
                        GSTJournalManagement.GetAccountsGST(Rec, AccName, BalAccName);
                    end;
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the general ledger account number where the entry will be posted.';
                    Editable = false;

                    trigger OnValidate()
                    begin
                        GSTJournalManagement.GetAccountsGST(Rec, AccName, BalAccName);
                        ShowShortcutDimCode(ShortcutDimCode);
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description on adjustment journal line to be adjusted.';
                    Editable = false;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total of amount including adjustment on the adjustment journal to be posted to.';
                    Editable = false;
                    Visible = false;
                }
                field("Document Line No."; Rec."Document Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document line number.';
                    Editable = false;
                    Visible = false;
                }
                field("Adjustment Type"; Rec."Adjustment Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of adjustment. For example  Lost/Destroyed, Consumed etc.';
                }
                field("GST Base Amount"; Rec."GST Base Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount that used for GST calculation base in the posted entry.';
                    Editable = false;
                }
                field("GST Amount"; Rec."GST Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount of the GST entry in LCY.';
                    Editable = false;
                }
                field("Total GST Amount"; Rec."Total GST Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total GST amount calculated for adjustment journal.';
                    Editable = false;
                }
                field("Original Quantity"; Rec."Original Quantity")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the original quantity of the entry.';
                    Editable = false;
                }
                field("Total ITC Amount Available"; Rec."Total ITC Amount Available")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total input tax credit amount available.';
                    Editable = false;
                }
                field("Input Credit/Output Tax Amount"; Rec."Input Credit/Output Tax Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the tax amount.';
                    Editable = false;
                }
                field("Amount to be Loaded on Invento"; Rec."Amount to be Loaded on Invento")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount to be loaded on inventory.';
                    Editable = false;
                }
                field("Original Location GSTIN"; Rec."Original Location GSTIN")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST registration number of the original location that entry belongs to.';
                    Editable = false;
                }
                field("Original Location"; Rec."Original Location")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the original location.';
                }
                field("Quantity to be Adjusted"; Rec."Quantity to be Adjusted")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity which need to be adjusted.';
                }
                field("Amount of Adjustment"; Rec."Amount of Adjustment")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount of adjustment.';
                    Editable = false;
                }
                field("Bal. Account Type"; Rec."Bal. Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of account where the balancing entry will be posted.';
                    Visible = false;
                }
                field("Bal. Account No."; Rec."Bal. Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the general ledger account number where the balancing entry will be posted.';
                    Visible = false;
                }
                field("Debit Amount"; Rec."Debit Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the debit amount.';
                    Editable = false;
                }
                field("Credit Amount"; Rec."Credit Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the credit amount.';
                    Editable = false;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code for shortcut dimension 1.';
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code for shortcut dimension 2.';
                }
                field("Salespers./Purch. Code"; Rec."Salespers./Purch. Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the salesperson or purchaser code.';
                }
                field("Source Code"; Rec."Source Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the source code that specifies where the entry was created.';
                }
                field("System-Created Entry"; Rec."System-Created Entry")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry is system created or not.';
                    Visible = false;
                }
                field("Journal Batch Name"; Rec."Journal Batch Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the journal batch name.';
                    Visible = false;
                }
                field("No. Series"; Rec."No. Series")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number series as document/posting number.';
                    Visible = false;
                }
                field("Posting No. Series"; Rec."Posting No. Series")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of number series that will be used to assign number to ledger entries that are posted from Journal using this template.';
                    Visible = false;
                }
                field("Template Type"; Rec."Template Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of template as GST Adjustment Journal for updated form journal batch.';
                    Visible = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the location code for a journal.';
                    Editable = false;
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the reason code, a supplementary source code that enables you to trace the entry.';
                    Editable = false;
                }
                field("Dimension Set ID"; Rec."Dimension Set ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the dimension set id.';
                    Editable = false;
                }
                field("DGL From Entry No."; Rec."DGL From Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the detailed GST ledger entry number.';
                    Editable = false;
                }
                field("DGL From To No."; Rec."DGL From To No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the detailed GST ledger entry number.';
                    Editable = false;
                }
            }
            group(Control30)
            {
                ShowCaption = false;
                field(AccName; AccName)
                {
                    Caption = 'Account Name';
                    ToolTip = 'Specifies the account name.';
                    ApplicationArea = Basic, Suite;
                    Editable = false;
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
                    ToolTip = 'Specifies the function where user can view or edit dimensions.';
                    ApplicationArea = Basic, Suite;
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction()
                    begin
                        ShowDimensions();
                        CurrPage.SaveRecord();
                    end;
                }
                action("GST Adjustment Detail")
                {
                    Caption = 'GST Adjustment Detail';
                    ToolTip = 'Specifies the function through which user can check the GST adjustment details.';
                    ApplicationArea = Basic, Suite;
                    Image = EditAdjustments;
                    RunObject = Page "GST Adjustment Detail";
                    RunPageLink = "Journal Template Name" = field("Journal Template Name"),
                                  "Journal Batch Name" = field("Journal Batch Name"),
                                  "Line No." = field("Line No.");
                }
                action(ItemTrackingLines)
                {
                    Caption = 'GST &Tracking Lines';
                    ToolTip = 'Specifies the function through which user can provide item tracking code if required.';
                    ApplicationArea = Basic, Suite;
                    Image = ItemTrackingLines;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'Ctrl+Alt+I';

                    trigger OnAction()
                    begin
                        OpenTracking();
                        CurrPage.Update(false);
                    end;
                }
            }
        }
        area(processing)
        {
            group("P&osting")
            {
                Caption = 'P&osting';
                Image = Post;
                action("P&ost")
                {
                    Caption = 'P&ost';
                    ToolTip = 'Specifies the function through which user can post the document.';
                    ApplicationArea = Basic, Suite;
                    Image = Post;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    begin
                        GSTJournalPost.PostGSTJournal(Rec);
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ShowShortcutDimCode(ShortcutDimCode);
        AfterGetCurrentRecord();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetUpNewLine(xRec, DummyBalance, false);
        Clear(ShortcutDimCode);
        Clear(AccName);
        AfterGetCurrentRecord();
    end;

    trigger OnOpenPage()
    var
        JnlSelected: Boolean;
    begin
        BalAccName := '';
        OpenedFromBatch := ("Journal Batch Name" <> '') and ("Journal Template Name" = '');
        if OpenedFromBatch then begin
            CurrentJnlBatchName := "Journal Batch Name";
            GSTJournalManagement.OpenGSTJnl(CurrentJnlBatchName, Rec);
            exit;
        end;
        GSTJournalManagement.GSTTemplateSelection(Page::"GST Adjustment Journal", 1, Rec, JnlSelected);
        if not JnlSelected then
            Error('');
        GSTJournalManagement.OpenGSTJnl(CurrentJnlBatchName, Rec);
    end;

    local procedure CurrentJnlBatchNameOnAfterVali()
    begin
        CurrPage.SaveRecord();
        GSTJournalManagement.SetNameGST(CurrentJnlBatchName, Rec);
        CurrPage.Update(false);
    end;

    local procedure AfterGetCurrentRecord()
    begin
        xRec := Rec;
        GSTJournalManagement.GetAccountsGST(Rec, AccName, BalAccName);
    end;

    local procedure InserGSTAdjustmentBuffer(DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry"; GSTJnlLineNo: Integer)
    var
        GSTAdjustmentBuffer: Record "GST Adjustment Buffer";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
    begin
        GSTAdjustmentBuffer.Reset();
        GSTAdjustmentBuffer.SetRange("Entry No.", DetailedGSTLedgerEntry."Entry No.");
        if not GSTAdjustmentBuffer.FindFirst() then begin
            GSTAdjustmentBuffer.Init();
            GSTAdjustmentBuffer."Journal Template Name" := "Journal Template Name";
            GSTAdjustmentBuffer."Journal Batch Name" := "Journal Batch Name";
            GSTAdjustmentBuffer."Document Type" := DetailedGSTLedgerEntry."Document Type";
            GSTAdjustmentBuffer."Document No." := DetailedGSTLedgerEntry."Document No.";
            GSTAdjustmentBuffer."Document Line No." := DetailedGSTLedgerEntry."Document Line No.";
            GSTAdjustmentBuffer."GST Jurisdiction Type" := DetailedGSTLedgerEntry."GST Jurisdiction Type";
            GSTAdjustmentBuffer."Transaction Type" := DetailedGSTLedgerEntry."Transaction Type";
            GSTAdjustmentBuffer."Line No." := GSTJnlLineNo;
            GSTAdjustmentBuffer."Entry No." := DetailedGSTLedgerEntry."Entry No.";
            GSTAdjustmentBuffer."Posting Date" := DetailedGSTLedgerEntry."Posting Date";
            GSTAdjustmentBuffer.Type := DetailedGSTLedgerEntry.Type;
            GSTAdjustmentBuffer."No." := DetailedGSTLedgerEntry."No.";
            GSTAdjustmentBuffer."Source Type" := DetailedGSTLedgerEntry."Source Type";
            GSTAdjustmentBuffer."Source No." := DetailedGSTLedgerEntry."Source No.";
            GSTAdjustmentBuffer."Location Code" := DetailedGSTLedgerEntry."Location Code";
            GSTAdjustmentBuffer.Quantity := DetailedGSTLedgerEntry.Quantity;
            GSTAdjustmentBuffer."GST %" := DetailedGSTLedgerEntry."GST %";
            GSTAdjustmentBuffer."GST Credit Type" := DetailedGSTLedgerEntry."GST Credit";
            GSTAdjustmentBuffer."GST Base Amount" := DetailedGSTLedgerEntrySource."GST Base Amount";
            GSTAdjustmentBuffer."GST Amount" := DetailedGSTLedgerEntrySource."GST Amount";
            GSTAdjustmentBuffer."Product Type" := DetailedGSTLedgerEntrySource."Product Type";
            GSTAdjustmentBuffer."Amount Loaded on Inventory" := DetailedGSTLedgerEntrySource."Amount Loaded on Item";
            GSTAdjustmentBuffer."Transaction No" := TransactionNo;
            GSTAdjustmentBuffer."GST Component Code" := DetailedGSTLedgerEntry."GST Component Code";
            GSTAdjustmentBuffer."DGL Entry No." := DetailedGSTLedgerEntry."Entry No.";
            GSTAdjustmentBuffer."Transaction Type" := DetailedGSTLedgerEntrySource."Transaction Type";
            DetailedGSTLedgerEntryInfo.Get(DetailedGSTLedgerEntry."Entry No.");
            GSTAdjustmentBuffer."Item Ledger Entry No." := DetailedGSTLedgerEntryInfo."Item Ledger Entry No.";
            GSTAdjustmentBuffer.Insert();
        end else begin
            GSTAdjustmentBuffer."GST Base Amount" := DetailedGSTLedgerEntrySource."GST Base Amount";
            GSTAdjustmentBuffer."GST Amount" := DetailedGSTLedgerEntrySource."GST Amount";
            GSTAdjustmentBuffer."Amount Loaded on Inventory" := DetailedGSTLedgerEntryCheck."Amount Loaded on Item";
            GSTAdjustmentBuffer.Modify();
        end;
        GSTAmount += DetailedGSTLedgerEntrySource."GST Amount";
        GSTBaseAmount := DetailedGSTLedgerEntrySource."GST Base Amount";
        if DetailedGSTLedgerEntrySource."GST Credit" = DetailedGSTLedgerEntrySource."GST Credit"::Availment then
            InputCreditOutputTaxAmount += DetailedGSTLedgerEntrySource."GST Amount";
        OriginalQuantity += DetailedGSTLedgerEntry."Remaining Quantity";
        Counter += 1;
    end;

    local procedure GetFirstEntryNo(DocumentNo: Code[20]; DocumentLineNo: Integer): Integer
    var
        DetailGSTLedgerEntry: Record "Detailed GST Ledger Entry";
    begin
        DetailGSTLedgerEntry.SetRange("Document No.", DocumentNo);
        DetailGSTLedgerEntry.SetRange("Entry Type", DetailGSTLedgerEntry."Entry Type"::"Initial Entry");
        DetailGSTLedgerEntry.SetRange("Transaction Type", DetailGSTLedgerEntry."Transaction Type"::Purchase);
        DetailGSTLedgerEntry.SetRange("Document Line No.", DocumentLineNo);
        if DetailGSTLedgerEntry.FindFirst() then
            exit(DetailGSTLedgerEntry."Entry No.");

        exit(1);
    end;

    local procedure GetLastEnryNo(DocumentNo: Code[20]; DocumentLineNo: Integer): Integer
    var
        DetailGSTLedgerEntry: Record "Detailed GST Ledger Entry";
    begin
        DetailGSTLedgerEntry.SetRange("Document No.", DocumentNo);
        DetailGSTLedgerEntry.SetRange("Entry Type", DetailGSTLedgerEntry."Entry Type"::"Initial Entry");
        DetailGSTLedgerEntry.SetRange("Document Line No.", DocumentLineNo);
        if DetailGSTLedgerEntry.FindLast() then
            exit(DetailGSTLedgerEntry."Entry No.");

        exit(1);
    end;

    local procedure TransactionNoOnAfterValidate()
    begin
        CurrPage.Update(false);
    end;

    local procedure CheckExistingEntry(DocumentNo: Code[20]; DocumentLineNo: Integer)
    var
        GSTJournalLine: Record "GST Journal Line";
    begin
        GSTJournalLine.SetRange("Document No.", DocumentNo);
        GSTJournalLine.SetRange("Document Line No.", DocumentLineNo);
        if GSTJournalLine.FindFirst() then
            Error(DocumentErr, GSTJournalLine."Document No.", GSTJournalLine."Document Line No.");
    end;

    local procedure CheckCurrentEntry(EntryNo: Integer)
    var
        DetailGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
    begin
        DetailGSTLedgerEntry.SetRange("Entry No.", EntryNo);
        DetailGSTLedgerEntry.SetRange("Entry Type", DetailGSTLedgerEntry."Entry Type"::"Initial Entry");
        DetailGSTLedgerEntry.SetFilter("Transaction Type", '%1|%2', DetailGSTLedgerEntry."Transaction Type"::Purchase, DetailGSTLedgerEntry."Transaction Type"::Transfer);
        DetailGSTLedgerEntry.SetFilter(Type, '%1|%2', DetailGSTLedgerEntry.Type::Item, DetailGSTLedgerEntry.Type::"G/L Account");
        DetailGSTLedgerEntry.SetRange("Document Type", DetailGSTLedgerEntry."Document Type"::Invoice);
        DetailGSTLedgerEntry.SetRange("GST Group Type", DetailGSTLedgerEntry."GST Group Type"::Goods);
        DetailGSTLedgerEntry.SetRange("Item Charge Entry", false);
        DetailGSTLedgerEntry.SetRange("GST Exempted Goods", false);
        DetailGSTLedgerEntry.SetRange("Journal Entry", false);
        if not DetailGSTLedgerEntry.FindFirst() then
            Error(TransactionErr, EntryNo)
        else begin
            DetailGSTLedgerEntryInfo.Get(DetailGSTLedgerEntry."Entry No.");
            DetailGSTLedgerEntryInfo.TestField("RCM Exempt", false);
            DetailGSTLedgerEntryInfo.TestField("Recurring Journal", false);
            if not (DetailGSTLedgerEntryInfo."Original Doc. Type" in [
                DetailGSTLedgerEntryInfo."Original Doc. Type"::Invoice,
                DetailGSTLedgerEntryInfo."Original Doc. Type"::"Transfer Receipt"])
            then
                Error(TransactionErr, EntryNo);
        end;
    end;

    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntrySource: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryCheck: Record "Detailed GST Ledger Entry";
        GSTJournalManagement: Codeunit "GST Journal Management";
        GSTJournalPost: Codeunit "GST Journal Post";
        CurrentJnlBatchName: Code[10];
        ShortcutDimCode: array[8] of Code[20];
        GenBussinessPostingGroup: Code[10];
        GenProductPostingGroup: Code[10];
        TransactionNo: Integer;
        Counter: Integer;
        AccName: Text[50];
        BalAccName: Text[50];
        DummyBalance: Decimal;
        OriginalQuantity: Decimal;
        GSTAmount: Decimal;
        GSTBaseAmount: Decimal;
        InputCreditOutputTaxAmount: Decimal;
        OpenedFromBatch: Boolean;
        DocumentErr: Label 'Document No. %1 and Document Line No. %2 already exsists.', Comment = '%1 =Code, %2 = Integer';
        Text00001Txt: Label 'GST Adj. Entry Doc. No. ';
        TransactionErr: Label 'Transaction number %1 does not exsists.', Comment = '%1 = Integer';
}

