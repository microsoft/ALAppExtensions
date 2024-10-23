page 8048 "Vend. Contract Deferrals API"
{
    APIGroup = 'subsBilling';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    ModifyAllowed = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    EntityName = 'vendorContractDeferrals';
    EntitySetName = 'vendorContractDeferrals';
    PageType = API;
    SourceTable = "Vendor Contract Deferral";
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
                field(contractNo; Rec."Contract No.")
                {
                }
                field(documentType; Rec."Document Type")
                {
                }
                field(documentNo; Rec."Document No.")
                {
                }
                field(contractType; Rec."Contract Type")
                {
                }
                field(released; Rec."Released")
                {
                }
                field(postingDate; Rec."Posting Date")
                {
                }
                field(amount; Rec.Amount)
                {
                }
                field(vendorrNo; Rec."Vendor No.")
                {
                }
                field(userID; Rec."User ID")
                {
                }
                field(discountAmount; Rec."Discount Amount")
                {
                }
                field(deferralBaseAmount; Rec."Deferral Base Amount")
                {
                }
                field(discountPercent; Rec."Discount %")
                {
                }
                field(payToVendorNo; Rec."Pay-to Vendor No.")
                {
                }
                field(documentLineNo; Rec."Document Line No.")
                {
                }
                field(documentPostingDate; Rec."Document Posting Date")
                {
                }
                field(releasePostingDate; Rec."Release Posting Date")
                {
                }
                field(gLEntryNo; Rec."G/L Entry No.")
                {
                }
                field(numberOfDays; Rec."Number of Days")
                {
                }
                field(contractLineNo; Rec."Contract Line No.")
                {
                }
                field(serviceObjectDescription; Rec."Service Object Description")
                {
                }
                field(serviceCommitmentDescription; Rec."Service Commitment Description")
                {
                }
                field(discount; Rec.Discount)
                {
                }
                field(dimensionSetID; Rec."Dimension Set ID")
                {
                }
            }
        }
    }
}
