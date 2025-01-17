namespace Microsoft.SubscriptionBilling;

page 8083 "Sales Serv. Comm. Archive List"
{
    Caption = 'Sales Service Commitment Archive List';
    PageType = List;
    Editable = false;
    SourceTable = "Sales Service Comm. Archive";
    UsageCategory = None;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(SalesServiceCommitmentArchiveLines)
            {
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the number of an item.';
                    Visible = false;
                }
                field("Item Description"; Rec."Item Description")
                {
                    ToolTip = 'Specifies a description of the product to be sold.';
                }
                field(Partner; Rec.Partner)
                {
                    ToolTip = 'Specifies whether a service commitment should be invoiced to a vendor (purchase invoice) or to a customer (sales invoice).';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the package line.';
                }
                field("Calculation Base Type"; Rec."Calculation Base Type")
                {
                    ToolTip = 'Specifies how the price for service commitment is calculated. "Item Price" uses the list price defined on the Item. "Document Price" uses the price from the sales document. "Document Price And Discount" uses the price and the discount from the sales document.';
                }
                field("Calculation Base Amount"; Rec."Calculation Base Amount")
                {
                    ToolTip = 'Specifies the base amount from which the price will be calculated.';
                }
                field("Calculation Base %"; Rec."Calculation Base %")
                {
                    ToolTip = 'Specifies the percent at which the price of the service will be calculated. 100% means that the price corresponds to the Base Price.';
                }
                field(Price; Rec.Price)
                {
                    ToolTip = 'Specifies the price of the service with quantity of 1 in the billing period. The price is calculated from Base Price and Base Price %.';
                }
                field("Discount %"; Rec."Discount %")
                {
                    ToolTip = 'Specifies the percent of the discount for the service.';
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ToolTip = 'Specifies the amount of the discount for the service.';
                }
                field("Service Amount"; Rec."Service Amount")
                {
                    ToolTip = 'Specifies the amount for the service including discount.';
                }
                field("Agreed Serv. Comm. Start Date"; Rec."Agreed Serv. Comm. Start Date")
                {
                    ToolTip = 'Specifies the individually agreed start of the service. Enter a date here to overwrite the determination of the start of service with the start of service formula upon delivery. If the field remains empty, the start of the service is determined upon delivery.';
                }
                field("Initial Term"; Rec."Initial Term")
                {
                    ToolTip = 'Specifies a date formula for calculating the minimum term of the service commitment. If the minimum term is filled and no extension term is entered, the end of service commitment is automatically set to the end of the initial term.';
                }
                field("Notice Period"; Rec."Notice Period")
                {
                    ToolTip = 'Specifies a date formula for the lead time that a notice must have before the service commitment ends. The rhythm of the update of "Notice possible to" and "Term Until" is determined using the extension term. For example, with an extension period of 1M, the notice period is repeatedly postponed by one month.';
                }
                field("Extension Term"; Rec."Extension Term")
                {
                    ToolTip = 'Specifies a date formula for automatic renewal after initial term and the rhythm of the update of "Notice possible to" and "Term Until". If the field is empty and the initial term or notice period is filled, the end of service is automatically set to the end of the initial term or notice period.';
                }
                field("Billing Base Period"; Rec."Billing Base Period")
                {
                    ToolTip = 'Specifies for which period the Service Amount is valid. If you enter 1M here, a period of one month, or 12M, a period of 1 year, to which Service Amount refers to.';
                }
                field("Billing Rhythm"; Rec."Billing Rhythm")
                {
                    ToolTip = 'Specifies the Dateformula for rhythm in which the service is invoiced. Using a Dateformula rhythm can be, for example, a monthly, a quarterly or a yearly invoicing.';
                }
                field("Invoicing via"; Rec."Invoicing via")
                {
                    ToolTip = 'Specifies whether the service commitment is invoiced via a contract. Service commitments with invoicing via sales are not charged. Only the items are billed.';
                }
                field(Template; Rec.Template)
                {
                    ToolTip = 'Specifies a code to identify this service commitment template.';
                }
                field("Package Code"; Rec."Package Code")
                {
                    ToolTip = 'Specifies a code to identify this service commitment package.';
                }
            }
        }
    }
}