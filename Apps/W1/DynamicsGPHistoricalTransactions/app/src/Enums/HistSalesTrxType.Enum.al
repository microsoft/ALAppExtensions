enum 40000 "Hist. Sales Trx. Type"
{
    Extensible = true;

    value(0; "Unknown") { Caption = 'Unknown'; }
    value(1; "Quote") { Caption = 'Quote'; }
    value(2; "Order") { Caption = 'Order'; }
    value(3; "Invoice") { Caption = 'Invoice'; }
    value(4; "Return Order") { Caption = 'Return Order'; }
    value(5; "Back Order") { Caption = 'Back Order'; }
    value(6; "Fulfillment Order") { Caption = 'Fulfillment Order'; }
}