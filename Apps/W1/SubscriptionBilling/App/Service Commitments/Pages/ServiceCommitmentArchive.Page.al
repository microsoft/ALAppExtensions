namespace Microsoft.SubscriptionBilling;

page 8094 "Service Commitment Archive"
{
    Caption = 'Service Commitment Archive';
    PageType = List;
    SourceTable = "Service Commitment Archive";
    Editable = false;
    ModifyAllowed = false;
    InsertAllowed = false;
    UsageCategory = None;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(General)
            {
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
                field("Quantity (Service Object)"; Rec."Quantity Decimal (Service Ob.)")
                {
                    ToolTip = 'Specifies the units of the service object before the change.';
                }
                field("Serial No. (Service Object)"; Rec."Serial No. (Service Object)")
                {
                    ToolTip = 'Specifies the serial no. of the service object before the change.';
                }
                field("Service Amount"; Rec."Service Amount")
                {
                    ToolTip = 'Specifies the amount for the service including discount.';
                }

                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the currency of amounts in the service.';
                    Visible = false;
                }
                field("Billing Base Period"; Rec."Billing Base Period")
                {
                    ToolTip = 'Specifies for which period the Service Amount is valid. If you enter 1M here, a period of one month, or 12M, a period of 1 year, to which Service Amount refers to.';
                }
                field("Billing Rhythm"; Rec."Billing Rhythm")
                {
                    ToolTip = 'Specifies the Dateformula for hythm in which the service is invoiced. Using a Dateformula rhythm can be, for example, a monthly, a quarterly or a yearly invoicing.';
                }
                field("Invoicing via"; Rec."Invoicing via")
                {
                    ToolTip = 'Specifies whether the service will be invoiced using contract or sales document.';
                }
                field(Partner; Rec.Partner)
                {
                    ToolTip = 'Specifies whether the service will will be calculated as a credit (Purchase Invoice) or as debit (Sales Invoice).';
                }
                field("Contract No."; Rec."Contract No.")
                {
                    ToolTip = 'Specifies in which contract the service will be calculated.';
                    Editable = false;

                    trigger OnAssistEdit()
                    begin
                        ContractsGeneralMgt.OpenContractCard(Rec.Partner, Rec."Contract No.");
                    end;
                }
                field("Initial Term"; Rec."Initial Term")
                {
                    ToolTip = 'Specifies a date formula for calculating the minimum term of the service commitment. If the minimum term is filled and no extension term is entered, the end of service commitment is automatically set to the end of the initial term.';
                }
                field("Extension Term"; Rec."Extension Term")
                {
                    ToolTip = 'Specifies a date formula for automatic renewal after initial term and the rhythm of the update of "Notice possible to" and "Term Until". If the field is empty and the initial term or notice period is filled, the end of service is automatically set to the end of the initial term or notice period.';
                }
                field("Cancellation Possible Until"; Rec."Cancellation Possible Until")
                {
                    ToolTip = 'Specifies the last date for a timely termination. The date is determined by the initial term, extension term and a notice period. An initial term of 12 months and a 3-month notice period means that the deadline for a notice of termination is after 9 months. An extension period of 12 months postpones this date by 12 months.';
                }
                field("Term Until"; Rec."Term Until")
                {
                    ToolTip = 'Specifies the earliest regular date for the end of the service, taking into account the initial term, extension term and a notice period. An initial term of 24 months results in a fixed term of 2 years. An extension period of 12 months postpones this date by 12 months.';
                }
                field(Discount; Rec.Discount)
                {
                    Editable = false;
                    ToolTip = 'Specifies whether the Service Commitment is used as a basis for periodic invoicing or discounts.';
                }
                field("Perform Update On"; Rec."Perform Update On")
                {
                    ToolTip = 'Specifies the date, the price update will take affect if no date is specified in the contract line. If empty the "Next Price Update" of the contract line is used.';
                    Visible = false;
                }
                field("Next Price Update"; Rec."Next Price Update")
                {
                    ToolTip = 'Specifies the date of the next price update.';
                    Visible = false;
                }
                field("Type Of Update"; Rec."Type Of Update")
                {
                    ToolTip = 'Specifies, whether the Planned Service Commitment has been created by a Price Update.';
                    Visible = false;
                }
            }
        }
    }
    var
        ContractsGeneralMgt: Codeunit "Contracts General Mgt.";
}
