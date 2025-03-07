namespace Microsoft.SubscriptionBilling;

page 8019 "Sales Service Commitments API"
{
    APIGroup = 'subsBilling';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    EntityName = 'salesServiceCommitment';
    EntitySetName = 'salesServiceCommitments';
    PageType = API;
    SourceTable = "Sales Subscription Line";
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
                field(documentType; Rec."Document Type")
                {
                }
                field(documentNo; Rec."Document No.")
                {
                }
                field(documentLineNo; Rec."Document Line No.")
                {
                }
                field(lineNo; Rec."Line No.")
                {
                }
                field(itemNo; Rec."Item No.")
                {
                }
                field(itemDescription; Rec."Item Description")
                {
                }
                field(partner; Rec.Partner)
                {
                }
                field(description; Rec.Description)
                {
                }
                field(calculationBaseType; Rec."Calculation Base Type")
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
                field(serviceAmount; Rec.Amount)
                {
                }
                field(unitCost; Rec."Unit Cost")
                {
                }
                field(unitCostLCY; Rec."Unit Cost (LCY)")
                {
                }
                field(serviceCommStartFormula; Rec."Sub. Line Start Formula")
                {
                }
                field(agreedServCommStartDate; Rec."Agreed Sub. Line Start Date")
                {
                }
                field(noticePeriod; Rec."Notice Period")
                {
                }
                field(extensionTerm; Rec."Extension Term")
                {
                }
                field(billingBasePeriod; Rec."Billing Base Period")
                {
                }
                field(billingRhythm; Rec."Billing Rhythm")
                {
                }
                field(invoicingVia; Rec."Invoicing via")
                {
                }
                field(template; Rec.Template)
                {
                }
                field(packageCode; Rec."Subscription Package Code")
                {
                }
                field(customerPriceGroup; Rec."Customer Price Group")
                {
                }
                field(discount; Rec.Discount)
                {
                }
                field(serviceObjectNo; Rec."Subscription Header No.")
                {
                }
                field(initialTerm; Rec."Initial Term")
                {
                }
                field(serviceCommitmentEntryNo; Rec."Subscription Line Entry No.")
                {
                }
                field(linkedToNo; Rec."Linked to No.")
                {
                }
                field(linkedToLineNo; Rec."Linked to Line No.")
                {
                }
                field(process; Rec.Process)
                {
                }
            }
        }
    }
}
