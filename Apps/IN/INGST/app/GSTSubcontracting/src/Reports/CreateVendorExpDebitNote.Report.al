// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Inventory.Item;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Vendor;

report 18466 "Create Vendor Exp. Debit Note"
{
    Caption = 'Create Vendor Exp. Debit Note';
    ProcessingOnly = true;
    UseRequestPage = false;

    dataset
    {
        dataitem("Purchase Line"; "Purchase Line")
        {
            dataitem("Sub Order Comp. List Vend"; "Sub Order Comp. List Vend")
            {
                DataItemLink = "Document No." = field("Document No."),
                               "Document Line No." = field("Line No."),
                               "Parent Item No." = field("No.");

                trigger OnAfterGetRecord()
                begin
                    CalcFields("Charge Recoverable");
                    DebitNoteAmount := "Charge Recoverable" - "Debit Note Amount";
                    if DebitNoteAmount <> 0 then begin
                        PurchaseLine.Reset();
                        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::"Credit Memo");
                        PurchaseLine.SetFilter("Document No.", PurchaseHeader."No.");
                        if PurchaseLine.FindFirst() then
                            NextLineNo += 10000
                        else
                            NextLineNo := 10000;

                        PurchaseLine.Init();
                        PurchaseLine."Document Type" := PurchaseHeader."Document Type";
                        PurchaseLine."Document No." := PurchaseHeader."No.";
                        PurchaseLine."Component Item No." := "Item No.";
                        PurchaseLine."Line No." := NextLineNo;
                        PurchaseLine.Description := 'Subcon. Order No. ' + "Purchase Line"."Document No." +
                          'Item No. ' + "Item No.";
                        PurchaseLine.Subcontracting := true;
                        PurchaseLine.Validate("Buy-from Vendor No.", "Purchase Line"."Buy-from Vendor No.");
                        PurchaseLine.Type := PurchaseLine.Type::"G/L Account";
                        PurchaseLine."No." := GetInventoryAdjAccount();
                        GLAccount.Get(PurchaseLine."No.");
                        PurchaseLine."Gen. Bus. Posting Group" := GLAccount."Gen. Bus. Posting Group";
                        PurchaseLine."Gen. Prod. Posting Group" := GLAccount."Gen. Prod. Posting Group";
                        PurchaseLine.Validate(Quantity, 1);
                        PurchaseLine.Validate("Unit Price (LCY)", DebitNoteAmount);
                        PurchaseLine.Validate("Direct Unit Cost", DebitNoteAmount);
                        PurchaseLine.Amount := DebitNoteAmount;
                        "Debit Note Amount" += DebitNoteAmount;
                        Modify();

                        PurchaseLine.Insert();
                        TotalAmount += DebitNoteAmount;
                        DebitNoteAmount := 0;
                    end;
                end;

                trigger OnPostDataItem()
                begin
                    if TotalAmount = 0 then
                        Error(BalanceRecoveryErr);

                    Message(PurchCrMemoCreationMsg, PurchaseHeader."No.");
                end;
            }

            trigger OnAfterGetRecord()
            begin
                PurchaseHeader.Init();
                PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::"Credit Memo";
                PurchaseHeader."No." := '';
                PurchaseHeader.Insert(true);
                PurchaseHeader.Validate("Buy-from Vendor No.", "Purchase Line"."Buy-from Vendor No.");
                PurchaseHeader."Subcon. Order No." := "Purchase Line"."Document No.";
                PurchaseHeader."Subcon. Order Line No." := "Purchase Line"."Line No.";
                PurchaseHeader.Modify();
            end;
        }
    }

    procedure GetInventoryAdjAccount(): Code[20]
    begin
        Vendor.Get("Purchase Line"."Buy-from Vendor No.");
        Item.Get("Sub Order Comp. List Vend"."Item No.");
        GPSetup.Get(Vendor."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group");
        GPSetup.TestField("Inventory Adjmt. Account");
        exit(GPSetup."Inventory Adjmt. Account");
    end;

    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        Item: Record Item;
        GPSetup: Record "General Posting Setup";
        GLAccount: Record "G/L Account";
        DebitNoteAmount: Decimal;
        TotalAmount: Decimal;
        NextLineNo: Integer;
        PurchCrMemoCreationMsg: Label 'Purchase Credit Memo No. %1 created.', Comment = '%1 = Document No';
        BalanceRecoveryErr: Label 'No Balance Recoverable.';
}
