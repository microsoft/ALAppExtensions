page 1938 "MigrationGP Posting Accounts"
{
    PageType = Card;
    SourceTable = "MigrationGP Account Setup";
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
                }
                field(SalesLineDiscAccount; SalesLineDiscAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Line Disc. Account';
                }
                field(SalesInvDiscAccount; SalesInvDiscAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Inv. Disc. Account';
                }

                field(SalesPmtDiscDebitAccount; SalesPmtDiscDebitAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purch. Account';
                }
                field(PurchAccount; PurchAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purch. Account';
                }
                field(PurchInvDiscAccount; PurchInvDiscAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purch. Inv. Disc. Account';
                }
                field(COGSAccount; COGSAccount)
                {
                    ApplicationArea = All;
                    Caption = 'COGS Account';
                }
                field(InventoryAdjmtAccount; InventoryAdjmtAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Inventory Adjmt. Account';
                }
                field(SalesCreditMemoAccount; SalesCreditMemoAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Credit Memo Account';
                }
                field(PurchPmtDiscDebitAcc; PurchPmtDiscDebitAcc)
                {
                    ApplicationArea = All;
                    Caption = 'Purchase Payment Discount Debit Account';
                }

                field(PurchPrepaymentsAccount; PurchPrepaymentsAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purchase Prepayments Account';
                }

                field(PurchaseVarianceAccount; PurchaseVarianceAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purchase Variance Account';
                }

                field(InventoryAccount; InventoryAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Inventory Account';
                }
                field(ReceivablesAccount; ReceivablesAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Receivables Account';
                }
                field(ServiceChargeAccount; ServiceChargeAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Service Charge Acc.';
                }
                field(PaymentDiscDebitAccount; PaymentDiscDebitAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Payment Disc. Debit Acc.';
                }
                field(PayablesAccount; PayablesAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Payables Account';
                }
                field(PurchServiceChargeAccount; PurchServiceChargeAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purch. Service Charge Acc.';
                }
                field(PurchPmtDiscDebitAccount; PurchPmtDiscDebitAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purch. Payment Disc. Debit Acc.';
                }
            }
        }
    }
}