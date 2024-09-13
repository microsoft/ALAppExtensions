page 8047 "Vendor Contract Lines API"
{
    APIGroup = 'subsBilling';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    EntityName = 'vendorContractLines';
    EntitySetName = 'vendorContractLines';
    PageType = API;
    SourceTable = "Vendor Contract Line";
    Editable = false;
    DataAccessIntent = ReadOnly;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(contractNo; Rec."Contract No.")
                {
                }
                field(contractLineNo; Rec."Line No.")
                {
                }
                field(serviceObjectNo; Rec."Service Object No.")
                {
                }
                field(serviceCommitmentLineNo; Rec."Service Commitment Entry No.")
                {
                }
                part(VendContractDeferralsAPI; "Vend. Contract Deferrals API")
                {
                    Caption = 'vendorContractDeferrals', Locked = true;
                    EntityName = 'vendorContractDeferrals';
                    EntitySetName = 'vendorContractDeferrals';
                    SubPageLink = "Contract No." = field("Contract No."), "Contract Line No." = field("Line No.");
                }
            }
        }
    }
}
