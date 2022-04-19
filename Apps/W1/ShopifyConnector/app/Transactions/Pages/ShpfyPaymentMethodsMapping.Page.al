/// <summary>
/// Page Shpfy Payment Methods Mapping(ID 30132).
/// </summary>
page 30132 "Shpfy Payment Methods Mapping"
{

    Caption = 'Shopify Payment Methods Mapping';
    PageType = List;
    SourceTable = "Shpfy Payment Method Mapping";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Gateway; Rec.Gateway)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the Shopify Transaction Gateway.';
                }
                field(CreditCardCompany; Rec."Credit Card Company")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the Shopify Credit Card Company.';
                }
                field(PaymentMethod; Rec."Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the corresponding payment method in D365BC.';
                }
                field(Priority; Rec.Priority)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the priority when a customers pays with multiple payment methods. If there is more then one payment method, it will take the payment with the highest priority follow by the highest amount.';
                }
            }
        }
    }

}
