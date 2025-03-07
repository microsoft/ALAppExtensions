namespace Microsoft.SubscriptionBilling;

page 8022 "Archived Billing Lines API"
{
    APIGroup = 'subsBilling';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    EntityName = 'archivedBillingLine';
    EntitySetName = 'archivedBillingLines';
    PageType = API;
    SourceTable = "Billing Line Archive";
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
                field(entryNo; Rec."Entry No.")
                {
                }
                field(userID; Rec."User ID")
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
                field(serviceObjectNo; Rec."Subscription Header No.")
                {
                }
                field(serviceCommitmentEntryNo; Rec."Subscription Line Entry No.")
                {
                }
                field(serviceObjectDescription; Rec."Subscription Description")
                {
                }
                field(serviceCommitmentDescription; Rec."Subscription Line Description")
                {
                }
                field(serviceStartDate; Rec."Subscription Line Start Date")
                {
                }
                field(serviceEndDate; Rec."Subscription Line End Date")
                {
                }
                field(partner; Rec.Partner)
                {
                }
                field(discount; Rec.Discount)
                {
                }
                field(billingFrom; Rec."Billing from")
                {
                }
                field(billingTo; Rec."Billing to")
                {
                }
                field(serviceAmount; Rec.Amount)
                {
                }
                field(billingRhythm; Rec."Billing Rhythm")
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
                field(unitCost; Rec."Unit Cost")
                {
                }
                field(unitCostLCY; Rec."Unit Cost (LCY)")
                {
                }
                field(unitPrice; Rec."Unit Price")
                {
                }
                field(discountPctg; Rec."Discount %")
                {
                }
                field(correctionDocumentType; Rec."Correction Document Type")
                {
                }
                field(correctionDocumentNo; Rec."Correction Document No.")
                {
                }
                field(billingTemplateCode; Rec."Billing Template Code")
                {
                }
                field(serviceObjQuantityDecimal; Rec."Service Object Quantity")
                {
                }
            }
        }
    }
}
