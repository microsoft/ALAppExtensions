#pragma warning disable AA0247
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
                field(SalesAccount; Rec.SalesAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Account';
                }
                field(SalesCreditMemoAccount; Rec.SalesCreditMemoAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Credit Memo Account';
                }
                field(SalesLineDiscAccount; Rec.SalesLineDiscAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Line Disc. Account';
                }
                field(SalesInvDiscAccount; Rec.SalesInvDiscAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Inv. Disc. Account';
                }
                field(PurchAccount; Rec.PurchAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purch. Account';
                }
                field(PurchCreditMemoAccount; Rec.PurchCreditMemoAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purch. Credit Memo Account';
                }
                field(PurchLineDiscAccount; Rec.PurchLineDiscAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purch. Line Disc. Account';
                }
                field(PurchInvDiscAccount; Rec.PurchInvDiscAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purch. Inv. Disc. Account';
                }
                field(COGSAccount; Rec.COGSAccount)
                {
                    ApplicationArea = All;
                    Caption = 'COGS Account';
                }
                field(InventoryAdjmtAccount; Rec.InventoryAdjmtAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Inventory Adjmt. Account';
                }
                field(InventoryAccount; Rec.InventoryAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Inventory Account';
                }
                field(ReceivablesAccount; Rec.ReceivablesAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Receivables Account';
                }
                field(ServiceChargeAccount; Rec.ServiceChargeAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Service Charge Acc.';
                }
                field(PayablesAccount; Rec.PayablesAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Payables Account';
                }
                field(PurchServiceChargeAccount; Rec.PurchServiceChargeAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purch. Service Charge Acc.';
                }
#pragma warning restore
            }
        }
    }
}
