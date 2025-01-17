page 8090 "Contract Analysis Entries"
{
    ApplicationArea = All;
    Caption = 'Contract Analysis Entries';
    PageType = List;
    SourceTable = "Contract Analysis Entry";
    UsageCategory = ReportsAndAnalysis;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the number of the entry assigned to it from the specified number series when it was created.';
                }
                field("Service Object No."; Rec."Service Object No.")
                {
                    ToolTip = 'Specifies the contract to which the service is to be assigned.';
                }
                field("Service Object Item No."; Rec."Service Object Item No.")
                {
                    ToolTip = 'Specifies the Item No. of the service object.';
                }
                field("Service Object Description"; Rec."Service Object Description")
                {
                    ToolTip = 'Specifies the value of the Service Object Description field.';
                }
                field("Service Commitment Entry No."; Rec."Service Commitment Entry No.")
                {
                    ToolTip = 'Specifies the value of the Service Commitment Line No. field.';
                }
                field("Package Code"; Rec."Package Code")
                {
                    ToolTip = 'Specifies the code of the service commitment package. If a vendor contract line has the same Service Object No. and Package Code as a customer contract line, the customer contract dimension value is copied to the vendor contract line.';
                }
                field(Template; Rec.Template)
                {
                    ToolTip = 'Specifies the code of the service commitment template.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the service.';
                }
                field("Service Start Date"; Rec."Service Start Date")
                {
                    ToolTip = 'Specifies the date from which the service is valid and will be invoiced.';
                }
                field("Service End Date"; Rec."Service End Date")
                {
                    ToolTip = 'Specifies the date up to which the service is valid.';
                }
                field("Next Billing Date"; Rec."Next Billing Date")
                {
                    ToolTip = 'Specifies the date of the next billing possible.';
                }
                field("Calculation Base Amount"; Rec."Calculation Base Amount")
                {
                    ToolTip = 'Specifies the base amount from which the price will be calculated.';
                }
                field("Calculation Base %"; Rec."Calculation Base %")
                {
                    ToolTip = 'Specifies the percent at which the price of the service will be calculated. 100% means that the price corresponds to the Base Price.';
                }
                field("Price"; Rec."Price")
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
                field("Analysis Date"; Rec."Analysis Date")
                {
                    ToolTip = 'Specifies the period in which the entry is evaluated.';
                }
                field("Monthly Recurr. Revenue (LCY)"; Rec."Monthly Recurr. Revenue (LCY)")
                {
                    ToolTip = 'Specifies the monthly recurring amount in local currency.';
                }
                field("Monthly Recurring Cost (LCY)"; Rec."Monthly Recurring Cost (LCY)")
                {
                    ToolTip = 'Specifies the monthly recurring costs in local currency.';
                }
                field("Billing Base Period"; Rec."Billing Base Period")
                {
                    ToolTip = 'Specifies for which period the Service Amount is valid. If you enter 1M here, a period of one month, or 12M, a period of 1 year, to which Service Amount refers to.';
                }
                field("Invoicing Item No."; Rec."Invoicing Item No.")
                {
                    ToolTip = 'Specifies the value of the Invoicing Item No. field.';
                }
                field(Partner; Rec.Partner)
                {
                    ToolTip = 'Specifies whether the service will will be calculated as a credit (Purchase Invoice) or as debit (Sales Invoice).';
                }
                field("Partner No."; Rec."Partner No.")
                {
                    ToolTip = 'Specifies the number of the partner who will receive the contractual services and be billed by default.';
                }
                field("Contract No."; Rec."Contract No.")
                {
                    ToolTip = 'Specifies the contract to which the service is to be assigned.';
                }
                field("Contract Line No."; Rec."Contract Line No.")
                {
                    ToolTip = 'Specifies the value of the Contract Line No. field.';
                }
                field("Notice Period"; Rec."Notice Period")
                {
                    ToolTip = 'Specifies a date formula for the lead time that a notice must have before the service commitment ends. The rhythm of the update of "Notice possible to" and "Term Until" is determined using the extension term. For example, with an extension period of 1M, the notice period is repeatedly postponed by one month.';
                }
                field("Initial Term"; Rec."Initial Term")
                {
                    ToolTip = 'Specifies a date formula for calculating the minimum term of the service commitment. If the minimum term is filled and no extension term is entered, the end of service commitment is automatically set to the end of the initial term.';
                }
                field("Extension Term"; Rec."Extension Term")
                {
                    ToolTip = 'Specifies a date formula for automatic renewal after initial term and the rhythm of the update of "Notice possible to" and "Term Until". If the field is empty and the initial term or notice period is filled, the end of service is automatically set to the end of the initial term or notice period.';
                }
                field("Billing Rhythm"; Rec."Billing Rhythm")
                {
                    ToolTip = 'Specifies the Dateformula for rhythm in which the service is invoiced. Using a Dateformula rhythm can be, for example, a monthly, a quarterly or a yearly invoicing.';
                }
                field("Cancellation Possible Until"; Rec."Cancellation Possible Until")
                {
                    ToolTip = 'Specifies the last date for a timely termination. The date is determined by the initial term, extension term and a notice period. An initial term of 12 months and a 3-month notice period means that the deadline for a notice of termination is after 9 months. An extension period of 12 months postpones this date by 12 months.';
                }
                field("Term Until"; Rec."Term Until")
                {
                    ToolTip = 'Specifies the earliest regular date for the end of the service, taking into account the initial term, extension term and a notice period. An initial term of 24 months results in a fixed term of 2 years. An extension period of 12 months postpones this date by 12 months.';
                }
                field("Price (LCY)"; Rec."Price (LCY)")
                {
                    ToolTip = 'Specifies the price of the service in client currency related to quantity of 1 in the billing period. The price is calculated from Base Price and Base Price %.';
                }
                field("Discount Amount (LCY)"; Rec."Discount Amount (LCY)")
                {
                    ToolTip = 'Specifies the discount amount in client currency that is granted on the service.';
                }
                field("Service Amount (LCY)"; Rec."Service Amount (LCY)")
                {
                    ToolTip = 'Specifies the amount in client currency for the service including discount.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the currency of amounts in the service.';
                }
                field("Currency Factor"; Rec."Currency Factor")
                {
                    ToolTip = 'Specifies the currency factor valid for the service, which is used to convert amounts to the client currency.';
                }
                field("Currency Factor Date"; Rec."Currency Factor Date")
                {
                    ToolTip = 'Specifies the date when the currency factor was last updated.';
                }
                field("Calculation Base Amount (LCY)"; Rec."Calculation Base Amount (LCY)")
                {
                    ToolTip = 'Specifies the basis on which the price is calculated in client currency.';
                }
                field(Discount; Rec.Discount)
                {
                    ToolTip = 'Specifies whether the Service Commitment is used as a basis for periodic invoicing or discounts.';
                }
                field("Quantity Decimal"; Rec."Quantity Decimal")
                {
                    ToolTip = 'Specifies the value of the Quantity field.';
                }
                field("Renewal Term"; Rec."Renewal Term")
                {
                    ToolTip = 'Specifies a date formula by which the Contract Line is renewed and the end of the Contract Line is extended. It is automatically preset with the initial term of the service and can be changed manually.';
                }
                field("Dimension Set ID"; Rec."Dimension Set ID")
                {
                    ToolTip = 'Specifies the value of the Dimension Set ID field.';
                }
                field("Usage Based Billing"; Rec."Usage Based Billing")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether usage data is used as the basis for billing via contracts.';
                }
            }
        }
    }
}
