#pragma warning disable AA0247
page 8087 "Contr. Analysis Entries API"
{
    APIGroup = 'subsBilling';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    ModifyAllowed = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    EntityName = 'contractAnalysisEntries';
    EntitySetName = 'contractAnalysisEntries';
    PageType = API;
    SourceTable = "Sub. Contr. Analysis Entry";
    ODataKeyFields = SystemId;
    Editable = false;
    DataAccessIntent = ReadOnly;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(systemId; Rec.SystemId)
                {
                }
                field(serviceObjectNo; Rec."Subscription Header No.")
                {
                }
#if not CLEAN26
                field(serviceObjectItemNo; Rec."Service Object Item No.")
                {
                    ObsoleteReason = 'Replaced by field Service Object Source No.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '26.0';
                    Visible = false;
                }
#endif
                field(serviceObjectSourceType; Rec."Sub. Header Source Type")
                {
                }
                field(serviceObjectSourceNo; Rec."Sub. Header Source No.")
                {
                }
                field(serviceObjectDescription; Rec."Subscription Description")
                {
                }
                field(serviceCommitmentLineNo; Rec."Subscription Line Entry No.")
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
                field(calculationBasePerc; Rec."Calculation Base %")
                {
                }
                field(unitCost; Rec."Unit Cost")
                {
                }
                field(unitCostLCY; Rec."Unit Cost (LCY)")
                {
                }
                field(price; Rec."Price")
                {
                }
                field(discountPerc; Rec."Discount %")
                {
                }
                field(discountAmount; Rec."Discount Amount")
                {
                }
                field(serviceAmount; Rec.Amount)
                {
                }
                field(analysisDate; Rec."Analysis Date")
                {
                }
                field(monthlyRecurrRevenueLCY; Rec."Monthly Recurr. Revenue (LCY)")
                {
                }
                field(monthlyRecurringCostLCY; Rec."Monthly Recurring Cost (LCY)")
                {
                }
                field(billingBasePeriod; Rec."Billing Base Period")
                {
                }
                field(invoicingItemNo; Rec."Invoicing Item No.")
                {
                }
                field(partner; Rec.Partner)
                {
                }
                field(partnerNo; Rec."Partner No.")
                {
                }
                field(contractNo; Rec."Subscription Contract No.")
                {
                }
                field(contractLineNo; Rec."Subscription Contract Line No.")
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
                field(quantityDecimal; Rec.Quantity)
                {
                }
                field(renewalTerm; Rec."Renewal Term")
                {
                }
                field(dimensionSetID; Rec."Dimension Set ID")
                {
                }
                field(usageBasedBilling; Rec."Usage Based Billing")
                {
                }
            }
        }
    }
}
