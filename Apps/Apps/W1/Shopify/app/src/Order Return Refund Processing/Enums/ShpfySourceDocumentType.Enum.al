namespace Microsoft.Integration.Shopify;

enum 30142 "Shpfy Source Document Type" implements "Shpfy IDocument Source"
{
    Extensible = true;
    DefaultImplementation = "Shpfy IDocument Source" = "Shpfy IDocSource Default";

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Order")
    {
        Caption = 'Order';
    }
    value(2; Return)
    {
        Caption = 'Return';
    }
    value(3; Refund)
    {
        Caption = 'Refund';
        Implementation = "Shpfy IDocument Source" = "Shpfy IDocSource Refund";
    }
}