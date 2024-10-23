namespace Microsoft.SubscriptionBilling;

page 8018 "Service Commitments API"
{
    APIGroup = 'subsBilling';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    EntityName = 'serviceCommitment';
    EntitySetName = 'serviceCommitments';
    PageType = API;
    SourceTable = "Service Commitment";
    ODataKeyFields = SystemId;
    Extensible = false;
    Editable = false;
    DataAccessIntent = ReadOnly;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(systemId; Rec.SystemId)
                {
                }
                field(serviceObjectNo; Rec."Service Object No.")
                {
                }
                field(entryNo; Rec."Entry No.")
                {
                }
                field(packageCode; Rec."Package Code")
                {
                }
                field(template; Rec.Template)
                {
                }
                field(description; Rec.Description)
                {
                }
                field(serviceStartDate; Rec."Service Start Date")
                {
                }
                field(serviceEndDate; Rec."Service End Date")
                {
                }
                field(nextBillingDate; Rec."Next Billing Date")
                {
                }
                field(calculationBaseAmount; Rec."Calculation Base Amount")
                {
                }
                field(calculationBase; Rec."Calculation Base %")
                {
                }
                field(price; Rec.Price)
                {
                }
                field(discountPctg; Rec."Discount %")
                {
                }
                field(discountAmount; Rec."Discount Amount")
                {
                }
                field(serviceAmount; Rec."Service Amount")
                {
                }
                field(billingBasePeriod; Rec."Billing Base Period")
                {
                }
                field(invoicingVia; Rec."Invoicing via")
                {
                }
                field(invoicingItemNo; Rec."Invoicing Item No.")
                {
                }
                field(partner; Rec.Partner)
                {
                }
                field(contractNo; Rec."Contract No.")
                {
                }
                field(noticePeriod; Rec."Notice Period")
                {
                }
                field(initialTerm; Rec."Initial Term")
                {
                }
                field(extensionTerm; Rec."Extension Term")
                {
                }
                field(billingRhythm; Rec."Billing Rhythm")
                {
                }
                field(cancellationPossibleUntil; Rec."Cancellation Possible Until")
                {
                }
                field(termUntil; Rec."Term Until")
                {
                }
                field(serviceObjectCustomerNo; Rec."Service Object Customer No.")
                {
                }
                field(contractLineNo; Rec."Contract Line No.")
                {
                }
                field(customerPriceGroup; Rec."Customer Price Group")
                {
                }
                field(shortcutDimension1Code; Rec."Shortcut Dimension 1 Code")
                {
                }
                field(shortcutDimension2Code; Rec."Shortcut Dimension 2 Code")
                {
                }
                field(priceLCY; Rec."Price (LCY)")
                {
                }
                field(discountAmountLCY; Rec."Discount Amount (LCY)")
                {
                }
                field(serviceAmountLCY; Rec."Service Amount (LCY)")
                {
                }
                field(currencyCode; Rec."Currency Code")
                {
                }
                field(currencyFactor; Rec."Currency Factor")
                {
                }
                field(currencyFactorDate; Rec."Currency Factor Date")
                {
                }
                field(calculationBaseAmountLCY; Rec."Calculation Base Amount (LCY)")
                {
                }
                field(discount; Rec.Discount)
                {
                }
                field(quantityDecimal; Rec."Quantity Decimal")
                {
                }
                field(plannedServCommExists; Rec."Planned Serv. Comm. exists")
                {
                }
                field(renewalTerm; Rec."Renewal Term")
                {
                }
                field(dimensionSetID; Rec."Dimension Set ID")
                {
                }
                field(itemNo; Rec."Item No.")
                {
                }
                field(serviceObjectDescription; Rec."Service Object Description")
                {
                }
            }
        }
    }
}
