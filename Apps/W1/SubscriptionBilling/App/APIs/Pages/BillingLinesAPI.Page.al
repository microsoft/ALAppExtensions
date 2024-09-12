namespace Microsoft.SubscriptionBilling;

page 8021 "Billing Lines API"
{
    APIGroup = 'subsBilling';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    EntityName = 'billingLine';
    EntitySetName = 'billingLines';
    PageType = API;
    SourceTable = "Billing Line";
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
                field(contractNo; Rec."Contract No.")
                {
                }
                field(contractLineNo; Rec."Contract Line No.")
                {
                }
                field(serviceObjectNo; Rec."Service Object No.")
                {
                }
                field(serviceCommitmentEntryNo; Rec."Service Commitment Entry No.")
                {
                }
                field(serviceObjectDescription; Rec."Service Object Description")
                {
                }
                field(serviceCommitmentDescription; Rec."Service Commitment Description")
                {
                }
                field(serviceStartDate; Rec."Service Start Date")
                {
                }
                field(serviceEndDate; Rec."Service End Date")
                {
                }
                field(partner; Rec.Partner)
                {
                }
                field(discount; Rec.Discount)
                {
                }
                field(serviceObjQuantityDecimal; Rec."Service Obj. Quantity Decimal")
                {
                }
                field(billingFrom; Rec."Billing from")
                {
                }
                field(billingTo; Rec."Billing to")
                {
                }
                field(serviceAmount; Rec."Service Amount")
                {
                }
                field(billingRhythm; Rec."Billing Rhythm")
                {
                }
                field(updateRequired; Rec."Update Required")
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
                field(currencyCode; Rec."Currency Code")
                {
                }
                field(indent; Rec.Indent)
                {
                }
                field(detailOverview; Rec."Detail Overview")
                {
                }
            }
        }
    }
}
