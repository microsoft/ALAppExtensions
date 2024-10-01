#if not CLEAN26
namespace Microsoft.DataMigration.GP;

page 4026 "GP Posting Accounts"
{
    Caption = 'GP Posting Accounts';
    PageType = Card;
    SourceTable = "GP Posting Accounts";
    DeleteAllowed = false;
    InsertAllowed = false;
    PromotedActionCategories = 'Posting Accounts';
    ApplicationArea = All;
    UsageCategory = None;
    ObsoleteState = Pending;
    ObsoleteReason = 'Removing the GP staging table pages because they cause confusion and should not be used.';
    ObsoleteTag = '26.0';

    layout
    {
        area(content)
        {
            group(General)
            {
                field(SalesAccount; Rec.SalesAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Account';
                    ToolTip = 'Sales Account';
                }
                field(SalesLineDiscAccount; Rec.SalesLineDiscAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Line Disc. Account';
                    ToolTip = 'Sales Line Disc. Account';
                }
                field(SalesInvDiscAccount; Rec.SalesInvDiscAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Inv. Disc. Account';
                    ToolTip = 'Sales Inv. Disc. Account';
                }

                field(SalesPmtDiscDebitAccount; Rec.SalesPmtDiscDebitAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purch. Account';
                    ToolTip = 'Purch. Account';
                }
                field(PurchAccount; Rec.PurchAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purch. Account';
                    ToolTip = 'Purch. Account';
                }
                field(PurchInvDiscAccount; Rec.PurchInvDiscAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purch. Inv. Disc. Account';
                    ToolTip = 'Purch. Inv. Disc. Account';
                }
                field(COGSAccount; Rec.COGSAccount)
                {
                    ApplicationArea = All;
                    Caption = 'COGS Account';
                    ToolTip = 'COGS Account';
                }
                field(InventoryAdjmtAccount; Rec.InventoryAdjmtAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Inventory Adjmt. Account';
                    ToolTip = 'Inventory Adjmt. Account';
                }
                field(SalesCreditMemoAccount; Rec.SalesCreditMemoAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Credit Memo Account';
                    ToolTip = 'Sales Credit Memo Account';
                }
                field(PurchPmtDiscDebitAcc; Rec.PurchPmtDiscDebitAcc)
                {
                    ApplicationArea = All;
                    Caption = 'Purchase Payment Discount Debit Account';
                    ToolTip = 'Purchase Payment Discount Debit Account';
                }

                field(PurchPrepaymentsAccount; Rec.PurchPrepaymentsAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purchase Prepayments Account';
                    ToolTip = 'Purchase Prepayments Account';
                }

                field(PurchaseVarianceAccount; Rec.PurchaseVarianceAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purchase Variance Account';
                    ToolTip = 'Purchase Variance Account';
                }

                field(InventoryAccount; Rec.InventoryAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Inventory Account';
                    ToolTip = 'Inventory Account';
                }
                field(ReceivablesAccount; Rec.ReceivablesAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Receivables Account';
                    ToolTip = 'Receivables Account';
                }
                field(ServiceChargeAccount; Rec.ServiceChargeAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Service Charge Acc.';
                    ToolTip = 'Service Charge Acc.';
                }
                field(PaymentDiscDebitAccount; Rec.PaymentDiscDebitAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Payment Disc. Debit Acc.';
                    ToolTip = 'Payment Disc. Debit Acc.';
                }
                field(PayablesAccount; Rec.PayablesAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Payables Account';
                    ToolTip = 'Payables Account';
                }
                field(PurchServiceChargeAccount; Rec.PurchServiceChargeAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purch. Service Charge Acc.';
                    ToolTip = 'Purch. Service Charge Acc.';
                }
                field(PurchPmtDiscDebitAccount; Rec.PurchPmtDiscDebitAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purch. Payment Disc. Debit Acc.';
                    ToolTip = 'Purch. Payment Disc. Debit Acc.';
                }
            }
        }
    }
}
#endif