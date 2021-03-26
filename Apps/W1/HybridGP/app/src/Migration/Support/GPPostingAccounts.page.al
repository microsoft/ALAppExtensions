page 4026 "GP Posting Accounts"
{
    PageType = Card;
    SourceTable = "GP Posting Accounts";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'Posting Accounts';
    PromotedActionCategories = 'Posting Accounts';

    layout
    {
        area(content)
        {
            group(General)
            {
                field(SalesAccount; SalesAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Account';
                    ToolTip = 'Sales Account';
                }
                field(SalesLineDiscAccount; SalesLineDiscAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Line Disc. Account';
                    ToolTip = 'Sales Line Disc. Account';
                }
                field(SalesInvDiscAccount; SalesInvDiscAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Inv. Disc. Account';
                    ToolTip = 'Sales Inv. Disc. Account';
                }

                field(SalesPmtDiscDebitAccount; SalesPmtDiscDebitAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purch. Account';
                    ToolTip = 'Purch. Account';
                }
                field(PurchAccount; PurchAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purch. Account';
                    ToolTip = 'Purch. Account';
                }
                field(PurchInvDiscAccount; PurchInvDiscAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purch. Inv. Disc. Account';
                    ToolTip = 'Purch. Inv. Disc. Account';
                }
                field(COGSAccount; COGSAccount)
                {
                    ApplicationArea = All;
                    Caption = 'COGS Account';
                    ToolTip = 'COGS Account';
                }
                field(InventoryAdjmtAccount; InventoryAdjmtAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Inventory Adjmt. Account';
                    ToolTip = 'Inventory Adjmt. Account';
                }
                field(SalesCreditMemoAccount; SalesCreditMemoAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Credit Memo Account';
                    ToolTip = 'Sales Credit Memo Account';
                }
                field(PurchPmtDiscDebitAcc; PurchPmtDiscDebitAcc)
                {
                    ApplicationArea = All;
                    Caption = 'Purchase Payment Discount Debit Account';
                    ToolTip = 'Purchase Payment Discount Debit Account';
                }

                field(PurchPrepaymentsAccount; PurchPrepaymentsAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purchase Prepayments Account';
                    ToolTip = 'Purchase Prepayments Account';
                }

                field(PurchaseVarianceAccount; PurchaseVarianceAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purchase Variance Account';
                    ToolTip = 'Purchase Variance Account';
                }

                field(InventoryAccount; InventoryAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Inventory Account';
                    ToolTip = 'Inventory Account';
                }
                field(ReceivablesAccount; ReceivablesAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Receivables Account';
                    ToolTip = 'Receivables Account';
                }
                field(ServiceChargeAccount; ServiceChargeAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Service Charge Acc.';
                    ToolTip = 'Service Charge Acc.';
                }
                field(PaymentDiscDebitAccount; PaymentDiscDebitAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Payment Disc. Debit Acc.';
                    ToolTip = 'Payment Disc. Debit Acc.';
                }
                field(PayablesAccount; PayablesAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Payables Account';
                    ToolTip = 'Payables Account';
                }
                field(PurchServiceChargeAccount; PurchServiceChargeAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purch. Service Charge Acc.';
                    ToolTip = 'Purch. Service Charge Acc.';
                }
                field(PurchPmtDiscDebitAccount; PurchPmtDiscDebitAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purch. Payment Disc. Debit Acc.';
                    ToolTip = 'Purch. Payment Disc. Debit Acc.';
                }
            }
        }
    }
}