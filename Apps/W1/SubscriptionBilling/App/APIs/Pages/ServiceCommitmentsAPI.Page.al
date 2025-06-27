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
    SourceTable = "Subscription Line";
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
                field(serviceObjectNo; Rec."Subscription Header No.")
                {
                }
                field(entryNo; Rec."Entry No.")
                {
                }
                field(packageCode; Rec."Subscription Package Code")
                {
                }
                field(template; Rec.Template)
                {
                }
                field(description; Rec.Description)
                {
                }
                field(serviceStartDate; Rec."Subscription Line Start Date")
                {
                }
                field(serviceEndDate; Rec."Subscription Line End Date")
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
                field(unitCost; Rec."Unit Cost")
                {
                }
                field(unitCostLCY; Rec."Unit Cost (LCY)")
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
                field(serviceAmount; Rec.Amount)
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
                field(contractNo; Rec."Subscription Contract No.")
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
                field(serviceObjectCustomerNo; Rec."Sub. Header Customer No.")
                {
                }
                field(contractLineNo; Rec."Subscription Contract Line No.")
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
                field(serviceAmountLCY; Rec."Amount (LCY)")
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
                field(createContractDeferrals; Rec."Create Contract Deferrals")
                {
                }
                field(quantityDecimal; Rec.Quantity)
                {
                }
                field(plannedServCommExists; Rec."Planned Sub. Line exists")
                {
                }
                field(renewalTerm; Rec."Renewal Term")
                {
                }
                field(dimensionSetID; Rec."Dimension Set ID")
                {
                }
#if not CLEAN26
                field(itemNo; Rec."Item No.")
                {
                    ObsoleteReason = 'Replaced by field Source No.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '26.0';
                    Visible = false;
                }
#endif
                field(sourceType; Rec."Source Type")
                {
                }
                field(sourceNo; Rec."Source No.")
                {
                }
                field(serviceObjectDescription; Rec."Subscription Description")
                {
                }
            }
        }
    }
}
