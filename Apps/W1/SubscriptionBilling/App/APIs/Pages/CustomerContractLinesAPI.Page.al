page 8045 "Customer Contract Lines API"
{
    APIGroup = 'subsBilling';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    EntityName = 'customerContractLines';
    EntitySetName = 'customerContractLines';
    PageType = API;
    SourceTable = "Customer Contract Line";
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
                part(CustContractDeferralAPI; "Cust. Contract Deferral API")
                {
                    Caption = 'customerContractDeferrals', Locked = true;
                    EntityName = 'customerContractDeferrals';
                    EntitySetName = 'customerContractDeferrals';
                    SubPageLink = "Contract No." = field("Contract No."), "Contract Line No." = field("Line No.");
                }
            }
        }
    }
}
