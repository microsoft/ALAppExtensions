page 1918 "MigrationQB Posting Accounts"
{
    PageType = Card;
    SourceTable = "MigrationQB Account Setup";
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
#pragma warning disable AA0218
                field(SalesAccount; SalesAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Account';
                }
                field(SalesCreditMemoAccount; SalesCreditMemoAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Credit Memo Account';
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
                field(PurchAccount; PurchAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purch. Account';
                }
                field(PurchCreditMemoAccount; PurchCreditMemoAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purch. Credit Memo Account';
                }
                field(PurchLineDiscAccount; PurchLineDiscAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purch. Line Disc. Account';
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
#pragma warning restore
            }
        }
    }
}