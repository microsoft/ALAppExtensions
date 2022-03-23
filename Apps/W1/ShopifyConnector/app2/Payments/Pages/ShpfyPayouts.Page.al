/// <summary>
/// Page Shpfy Payouts (ID 30125).
/// </summary>
page 30125 "Shpfy Payouts"
{

    ApplicationArea = All;
    Caption = 'Shopify Payouts';
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Inspect';
    SourceTable = "Shpfy Payout";
    SourceTableView = sorting(Id) order(descending);
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Date"; Rec.Date)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when the payout was issued.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total amount of the payout. This data was obtained from Shopify.';
                }
                field(Currency; Rec.Currency)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the currency of the payout.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status of the payout. This can be scheduled, in transit, paid, failed, cancelled.';
                }
                field(AdjustmentsFeeAmount; Rec."Adjustments Fee Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the adjustments fee amount. This data was obtained from Shopify.';
                }
                field(AdjustmentsGrossAmount; Rec."Adjustments Gross Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the adjustments gross amount. This data was obtained from Shopify.';
                }
                field("Charges Fee Amount"; Rec."Charges Fee Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the charges fee amount. This data was obtained from Shopify.';
                }
                field(ChargesGrossAmount; Rec."Charges Gross Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the charges gross amount. This data was obtained from Shopify.';
                }
                field(RefundsFeeAmount; Rec."Refunds Fee Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the refunds fee amount. This data was obtained from Shopify.';
                }
                field(RefundsGrossAmount; Rec."Refunds Gross Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the refunds gross amount. This data was obtained from Shopify.';
                }
                field(ReservedFundsFeeAmount; Rec."Reserved Funds Fee Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the reserved fee amount. This data was obtained from Shopify.';
                }
                field(ReservedFundsGrossAmount; Rec."Reserved Funds Gross Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the reserved gross amount. This data was obtained from Shopify.';
                }
                field(RetriedPayoutsFeeAmount; Rec."Retried Payouts Fee Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the retried payouts fee amount. This data was obtained from Shopify.';
                }
                field(RetriedPayoutsGrossAmount; Rec."Retried Payouts Gross Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the retried payouts gross amount. This data was obtained from Shopify.';
                }
            }
            part(Transactions; "Shpfy Payment Transactions")
            {
                ApplicationArea = All;
                SubPageLink = "Payout Id" = field(Id);
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(RetrievedShopifyData)
            {
                ApplicationArea = All;
                Caption = 'Retrieved Shopify Data';
                Image = Entry;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'View the data retrieved from Shopify.';

                trigger OnAction();
                var
                    DataCapture: Record "Shpfy Data Capture";
                begin
                    DataCapture.SetCurrentKey("Linked To Table", "Linked To Id");
                    DataCapture.SetRange("Linked To Table", Database::"Shpfy Payout");
                    DataCapture.SetRange("Linked To Id", Rec.SystemId);
                    Page.Run(Page::"Shpfy Data Capture List", DataCapture);
                end;
            }
        }
    }

}
