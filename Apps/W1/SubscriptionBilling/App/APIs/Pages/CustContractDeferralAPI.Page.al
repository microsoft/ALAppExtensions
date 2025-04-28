#pragma warning disable AA0247
page 8046 "Cust. Contract Deferral API"
{
    APIGroup = 'subsBilling';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    ModifyAllowed = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    EntityName = 'customerContractDeferrals';
    EntitySetName = 'customerContractDeferrals';
    PageType = API;
    SourceTable = "Cust. Sub. Contract Deferral";
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
                field(contractNo; Rec."Subscription Contract No.")
                {
                }
                field(documentType; Rec."Document Type")
                {
                }
                field(documentNo; Rec."Document No.")
                {
                }
                field(contractType; Rec."Subscription Contract Type")
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
                field(customerNo; Rec."Customer No.")
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
                field(billToCustomerNo; Rec."Bill-to Customer No.")
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
                field(contractLineNo; Rec."Subscription Contract Line No.")
                {
                }
                field(serviceObjectDescription; Rec."Subscription Description")
                {
                }
                field(serviceCommitmentDescription; Rec."Subscription Line Description")
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
