/// <summary>
/// Page Shpfy Payment Transactions (ID 30124).
/// </summary>
page 30124 "Shpfy Payment Transactions"
{

    Caption = 'Shopify Payment Transactions';
    Editable = false;
    PageType = ListPart;
    PromotedActionCategories = 'New,Process,Report,Inspect';
    SourceTable = "Shpfy Payment Transaction";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(ProcessedAt; Rec."Processed At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date and time at which the transaction is processed.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of the payment transaction.';
                }
                field(Test; Rec.Test)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the transaction was created for a test mode Order or payment.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the gross amount of the transaction.';
                }
                field(Fee; Rec.Fee)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total amount of fees deducted from the transaction amount.';
                }
                field("Net Amount"; Rec."Net Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the net amount of the transaction.';
                }
                field(Currency; Rec.Currency)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the currency of the transaction.';
                }
                field(SourceId; Rec."Source Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the id of the resource leading to the transaction.';
                }
                field(SourceType; Rec."Source Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of resource leading to the transaction. The options are Charge, Refund, Dispute, Reserve, Adjustment, Payout.';
                }
                field(SourceOrderId; Rec."Source Order Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the id the order that resulted in this balance transaction.';
                }
                field(InvoiceNo; Rec."Invoice No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Invoice number to which the transaction relates.';
                }
                field(SourceOrderTransactionId; Rec."Source Order Transaction Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the id the order transaction that resulted in this balance transaction.';
                }
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
                    DataCapture.SetRange("Linked To Table", Database::"Shpfy Payment Transaction");
                    DataCapture.SetRange("Linked To Id", Rec.SystemId);
                    Page.Run(Page::"Shpfy Data Capture List", DataCapture);
                end;
            }
        }
    }
}

