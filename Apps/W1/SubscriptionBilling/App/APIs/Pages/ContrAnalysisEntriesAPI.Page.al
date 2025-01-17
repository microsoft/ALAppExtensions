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
    SourceTable = "Contract Analysis Entry";
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
                field(serviceObjectNo; Rec."Service Object No.")
                {
                }
                field(serviceObjectItemNo; Rec."Service Object Item No.")
                {
                }
                field(serviceObjectDescription; Rec."Service Object Description")
                {
                }
                field(serviceCommitmentLineNo; Rec."Service Commitment Entry No.")
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
                field(calculationBasePerc; Rec."Calculation Base %")
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
                field(serviceAmount; Rec."Service Amount")
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
                field(contractNo; Rec."Contract No.")
                {
                }
                field(contractLineNo; Rec."Contract Line No.")
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
