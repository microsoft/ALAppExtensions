namespace Microsoft.SubscriptionBilling;

page 8004 "Planned Service Commitments"
{
    ApplicationArea = All;
    Caption = 'Planned Service Commitments';
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = true;
    PageType = List;
    SourceTable = "Planned Service Commitment";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Service Object No."; Rec."Service Object No.")
                {
                    ToolTip = 'Specifies the number of the service object no.';

                    trigger OnDrillDown()
                    var
                        ServiceObject: Record "Service Object";
                    begin
                        ServiceObject.OpenServiceObjectCard(Rec."Service Object No.");
                    end;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the entry number of the service commitment.';
                    Visible = false;
                }
                field("Sales Quote No."; Rec."Sales Quote No.")
                {
                    ToolTip = 'Specifies the Document No. of the Sales Quote from which the record originates.';
                }
                field("Sales Quote Line No."; Rec."Sales Quote Line No.")
                {
                    ToolTip = 'Specifies the Line No. of the Sales Quote from which the record originates.';
                    Visible = false;
                }
                field("Package Code"; Rec."Package Code")
                {
                    Visible = false;
                    ToolTip = 'Specifies the code of the service commitment package.';
                }
                field(Template; Rec.Template)
                {
                    Visible = false;
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
                field("Perform Update On"; Rec."Perform Update On")
                {
                    ToolTip = 'Specifies the date, the price update will take affect if no date is specified in the contract line. If empty the "Next Price Update" of the contract line is used.';
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
                field("Price Binding Period"; Rec."Price Binding Period")
                {
                    Visible = false;
                    ToolTip = 'Specifies the period the price will not be changed after the price update. It sets a new "Next Price Update" in the contract line after the price update has been performed.';
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
                field("Calculation Base Amount (LCY)"; Rec."Calculation Base Amount (LCY)")
                {
                    ToolTip = 'Specifies the basis on which the price is calculated in client currency.';
                    Visible = false;
                }
                field("Price (LCY)"; Rec."Price (LCY)")
                {
                    ToolTip = 'Specifies the price of the service in client currency related to quantity of 1 in the billing period. The price is calculated from Base Price and Base Price %.';
                    Visible = false;
                }
                field("Discount Amount (LCY)"; Rec."Discount Amount (LCY)")
                {
                    ToolTip = 'Specifies the discount amount in client currency that is granted on the service.';
                    Visible = false;
                }
                field("Service Amount (LCY)"; Rec."Service Amount (LCY)")
                {
                    ToolTip = 'Specifies the amount in client currency for the service including discount.';
                    Visible = false;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the currency of amounts in the service.';
                    Visible = false;
                }
                field("Currency Factor"; Rec."Currency Factor")
                {
                    ToolTip = 'Specifies the currency factor valid for the service, which is used to convert amounts to the client currency.';
                    Visible = false;
                }
                field("Currency Factor Date"; Rec."Currency Factor Date")
                {
                    ToolTip = 'Specifies the date when the currency factor was last updated.';
                    Visible = false;
                }
                field("Billing Base Period"; Rec."Billing Base Period")
                {
                    ToolTip = 'Specifies for which period the Service Amount is valid. If you enter 1M here, a period of one month, or 12M, a period of 1 year, to which Service Amount refers to.';
                }
                field("Billing Rhythm"; Rec."Billing Rhythm")
                {
                    ToolTip = 'Specifies the Dateformula for the rhytm in which the service is invoiced. Using a Dateformula rhythm can be, for example, a monthly, a quarterly or a yearly invoicing.';
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
                field("Notice Period"; Rec."Notice Period")
                {
                    Visible = false;
                    Editable = false;
                    ToolTip = 'Specifies a date formula for the lead time that a notice must have before the service commitment ends. The rhythm of the update of "Notice possible to" and "Term Until" is determined using the extension term. For example, with an extension period of 1M, the notice period is repeatedly postponed by one month.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Service Object Customer No.");
    end;

    var
        ContractsGeneralMgt: Codeunit "Contracts General Mgt.";
}