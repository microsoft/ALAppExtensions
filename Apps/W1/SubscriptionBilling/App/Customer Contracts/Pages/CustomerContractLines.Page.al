namespace Microsoft.SubscriptionBilling;

page 8075 "Customer Contract Lines"
{
    PageType = List;
    SourceTable = "Cust. Sub. Contract Line";
    Caption = 'Customer Subscription Contract Lines';
    Editable = false;
    UsageCategory = None;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(ContractLines)
            {
                field("Contract Line Type"; Rec."Contract Line Type")
                {
                    ToolTip = 'Specifies the contract line type.';
                }
                field("Service Start Date"; ServiceCommitment."Subscription Line Start Date")
                {
                    Caption = 'Subscription Line Start Date';
                    ToolTip = 'Specifies the date from which the Subscription Line is valid and will be invoiced.';
                }
                field("Service End Date"; ServiceCommitment."Subscription Line End Date")
                {
                    Caption = 'Subscription Line End Date';
                    ToolTip = 'Specifies the date up to which the Subscription Line is valid.';
                }
                field("Service Object No."; Rec."Subscription Header No.")
                {
                    Visible = false;
                    ToolTip = 'Specifies the number of the Subscription.';

                    trigger OnAssistEdit()
                    begin
                        Rec.OpenServiceObjectCard();
                    end;
                }
                field("Service Object Description"; Rec."Subscription Description")
                {
                    ToolTip = 'Specifies a description of the Subscription.';

                    trigger OnAssistEdit()
                    begin
                        Rec.OpenServiceObjectCard();
                    end;
                }
                field("Service Object Customer Reference"; ServiceObject."Customer Reference")
                {
                    Caption = 'Customer Reference';
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the reference by which the customer identifies the Subscription.';
                }
                field("Service Object Serial No."; ServiceObject."Serial No.")
                {
                    Caption = 'Serial No.';
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the Serial No. assigned to the Subscription.';
                }
                field(ServiceObjectPrimaryAttribute; ServiceObject.GetPrimaryAttributeValue())
                {
                    Caption = 'Primary Attribute';
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Displays the primary attribute of the related Subscription.';
                }
                field("Service Commitment Description"; Rec."Subscription Line Description")
                {
                    ToolTip = 'Specifies the description of the Subscription Line.';
                }
                field("Service Object Quantity"; Rec."Service Object Quantity")
                {
                    ToolTip = 'Specifies the number of units of Subscription.';

                    trigger OnDrillDown()
                    begin
                        Rec.OpenServiceObjectCard();
                    end;
                }
                field(Price; ServiceCommitment.Price)
                {
                    Caption = 'Price';
                    ToolTip = 'Specifies the price of the Subscription Line with quantity of 1 in the billing period. The price is calculated from Base Price and Base Price %.';
                    Editable = false;
                    BlankZero = true;
                }
                field("Discount %"; ServiceCommitment."Discount %")
                {
                    Caption = 'Discount %';
                    ToolTip = 'Specifies the percent of the discount for the Subscription Line.';
                    BlankZero = true;
                    MinValue = 0;
                    MaxValue = 100;
                    DecimalPlaces = 0 : 5;
                }
                field("Discount Amount"; ServiceCommitment."Discount Amount")
                {
                    Caption = 'Discount Amount';
                    ToolTip = 'Specifies the amount of the discount for the Subscription Line.';
                    BlankZero = true;
                    MinValue = 0;
                }
                field("Service Amount"; ServiceCommitment.Amount)
                {
                    Caption = 'Amount';
                    ToolTip = 'Specifies the amount for the Subscription Line including discount.';
                    BlankZero = true;
                }
                field("Next Billing Date"; ServiceCommitment."Next Billing Date")
                {
                    Caption = 'Next Billing Date';
                    ToolTip = 'Specifies the date of the next billing possible.';
                    Editable = false;
                    StyleExpr = NextBillingDateStyleExpr;
                }
                field("Calculation Base Amount"; ServiceCommitment."Calculation Base Amount")
                {
                    MinValue = 0;
                    Caption = 'Calculation Base Amount';
                    ToolTip = 'Specifies the base amount from which the price will be calculated.';
                    BlankZero = true;
                }
                field("Calculation Base %"; ServiceCommitment."Calculation Base %")
                {
                    MinValue = 0;
                    Caption = 'Calculation Base %';
                    ToolTip = 'Specifies the percent at which the price of the Subscription Line will be calculated. 100% means that the price corresponds to the Base Price.';
                    BlankZero = true;
                }
                field("Billing Base Period"; ServiceCommitment."Billing Base Period")
                {
                    Caption = 'Billing Base Period';
                    ToolTip = 'Specifies for which period the Amount is valid. If you enter 1M here, a period of one month, or 12M, a period of 1 year, to which Amount refers to.';
                }
                field("Cancellation Possible Until"; ServiceCommitment."Cancellation Possible Until")
                {
                    Caption = 'Cancellation Possible Until';
                    ToolTip = 'Specifies the last date for a timely termination. The date is determined by the initial term, extension term and a notice period. An initial term of 12 months and a 3-month notice period means that the deadline for a notice of termination is after 9 months. An extension period of 12 months postpones this date by 12 months.';
                }
                field("Term Until"; ServiceCommitment."Term Until")
                {
                    Caption = 'Term Until';
                    ToolTip = 'Specifies the earliest regular date for the end of the Subscription Line, taking into account the initial term, extension term and a notice period. An initial term of 24 months results in a fixed term of 2 years. An extension period of 12 months postpones this date by 12 months.';
                }
                field("Initial Term"; ServiceCommitment."Initial Term")
                {
                    Caption = 'Initial Term';
                    ToolTip = 'Specifies a date formula for calculating the minimum term of the Subscription Line. If the minimum term is filled and no extension term is entered, the end of Subscription Line is automatically set to the end of the initial term.';
                }
                field("Extension Term"; ServiceCommitment."Extension Term")
                {
                    Caption = 'Subsequent Term';
                    ToolTip = 'Specifies a date formula for automatic renewal after initial term and the rhythm of the update of "Notice possible to" and "Term Until". If the field is empty and the initial term or notice period is filled, the end of Subscription Line is automatically set to the end of the initial term or notice period.';
                }
                field("Billing Rhythm"; ServiceCommitment."Billing Rhythm")
                {
                    Caption = 'Billing Rhythm';
                    ToolTip = 'Specifies the Dateformula for rhythm in which the Subscription Line is invoiced. Using a Dateformula rhythm can be, for example, a monthly, a quarterly or a yearly invoicing.';
                }
                field("Package Code"; ServiceCommitment."Subscription Package Code")
                {
                    Caption = 'Package Code';
                    ToolTip = 'Specifies the code of the Subscription Package.';
                }
                field(Template; ServiceCommitment.Template)
                {
                    Caption = 'Template';
                    ToolTip = 'Specifies the code of the Subscription Package Line Template.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        InitializePageVariables();
        SetNextBillingDateStyle();
        Rec.LoadServiceCommitmentForContractLine(ServiceCommitment);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(ServiceCommitment);
        Clear(ServiceObject);
    end;

    var
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
        NextBillingDateStyleExpr: Text;

    local procedure InitializePageVariables()
    var
    begin
        Rec.GetServiceCommitment(ServiceCommitment);
        Rec.GetServiceObject(ServiceObject);
    end;

    local procedure SetNextBillingDateStyle()
    begin
        if (ServiceCommitment."Next Billing Date" > ServiceCommitment."Subscription Line End Date") and (ServiceCommitment."Subscription Line End Date" <> 0D) then
            NextBillingDateStyleExpr := 'AttentionAccent';
        OnAfterSetNextBillingDateStyle(Rec, ServiceCommitment, NextBillingDateStyleExpr);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetNextBillingDateStyle(CustSubContractLine: Record "Cust. Sub. Contract Line"; SubscriptionLine: Record "Subscription Line"; var NextBillingDateStyleExpr: Text)
    begin
    end;
}