// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

page 42006 "SL Posting Accounts"
{
    ApplicationArea = All;
    Caption = 'Posting Accounts';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    PromotedActionCategories = 'Posting Accounts';
    SourceTable = "SL Account Staging Setup";
    UsageCategory = Lists;
    layout
    {
        area(Content)
        {
            group(General)
            {
                field(SalesAccount; Rec.SalesAccount)
                {
                    Caption = 'Sales Account';
                    ToolTip = 'Sales Account';
                }
                field(SalesLineDiscAccount; Rec.SalesLineDiscAccount)
                {
                    Caption = 'Sales Line Disc. Account';
                    ToolTip = 'Sales Line Disc. Account';
                }
                field(SalesInvDiscAccount; Rec.SalesInvDiscAccount)
                {
                    Caption = 'Sales Inv. Disc. Account';
                    ToolTip = 'Sales Inv. Disc. Account';
                }
                field(SalesPmtDiscDebitAccount; Rec.SalesPmtDiscDebitAccount)
                {
                    Caption = 'Purch. Account';
                    ToolTip = 'Purch. Account';
                }
                field(PurchAccount; Rec.PurchAccount)
                {
                    Caption = 'Purch. Account';
                    ToolTip = 'Purch. Account';
                }
                field(PurchInvDiscAccount; Rec.PurchInvDiscAccount)
                {
                    Caption = 'Purch. Inv. Disc. Account';
                    ToolTip = 'Purch. Inv. Disc. Account';
                }
                field(COGSAccount; Rec.COGSAccount)
                {
                    Caption = 'COGS Account';
                    ToolTip = 'COGS Account';
                }
                field(InventoryAdjmtAccount; Rec.InventoryAdjmtAccount)
                {
                    Caption = 'Inventory Adjmt. Account';
                    ToolTip = 'Inventory Adjmt. Account';
                }
                field(SalesCreditMemoAccount; Rec.SalesCreditMemoAccount)
                {
                    Caption = 'Sales Credit Memo Account';
                    ToolTip = 'Sales Credit Memo Account';
                }
                field(PurchPmtDiscDebitAcc; Rec.PurchPmtDiscDebitAcc)
                {
                    Caption = 'Purchase Payment Discount Debit Account';
                    ToolTip = 'Purchase Payment Discount Debit Account';
                }
                field(PurchPrepaymentsAccount; Rec.PurchPrepaymentsAccount)
                {
                    Caption = 'Purchase Prepayments Account';
                    ToolTip = 'Purchase Prepayments Account';
                }
                field(PurchaseVarianceAccount; Rec.PurchaseVarianceAccount)
                {
                    Caption = 'Purchase Variance Account';
                    ToolTip = 'Purchase Variance Account';
                }
                field(InventoryAccount; Rec.InventoryAccount)
                {
                    Caption = 'Inventory Account';
                    ToolTip = 'Inventory Account';
                }
                field(ReceivablesAccount; Rec.ReceivablesAccount)
                {
                    Caption = 'Receivables Account';
                    ToolTip = 'Receivables Account';
                }
                field(ServiceChargeAccount; Rec.ServiceChargeAccount)
                {
                    Caption = 'Service Charge Acc.';
                    ToolTip = 'Service Charge Acc.';
                }
                field(PaymentDiscDebitAccount; Rec.PaymentDiscDebitAccount)
                {
                    Caption = 'Payment Disc. Debit Acc.';
                    ToolTip = 'Payment Disc. Debit Acc.';
                }
                field(PayablesAccount; Rec.PayablesAccount)
                {
                    Caption = 'Payables Account';
                    ToolTip = 'Payables Account';
                }
                field(PurchServiceChargeAccount; Rec.PurchServiceChargeAccount)
                {
                    Caption = 'Purch. Service Charge Acc.';
                    ToolTip = 'Purch. Service Charge Acc.';
                }
                field(PurchPmtDiscDebitAccount; Rec.PurchPmtDiscDebitAccount)
                {
                    Caption = 'Purch. Payment Disc. Debit Acc.';
                    ToolTip = 'Purch. Payment Disc. Debit Acc.';
                }
            }
        }
    }
}