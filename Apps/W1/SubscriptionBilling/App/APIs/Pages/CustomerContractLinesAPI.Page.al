#pragma warning disable AA0247
page 8045 "Customer Contract Lines API"
{
    APIGroup = 'subsBilling';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    EntityName = 'customerContractLines';
    EntitySetName = 'customerContractLines';
    PageType = API;
    SourceTable = "Cust. Sub. Contract Line";
    Editable = false;
    DataAccessIntent = ReadOnly;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(contractNo; Rec."Subscription Contract No.")
                {
                }
                field(contractLineNo; Rec."Line No.")
                {
                }
                field(serviceObjectNo; Rec."Subscription Header No.")
                {
                }
                field(serviceCommitmentLineNo; Rec."Subscription Line Entry No.")
                {
                }
                part(CustContractDeferralAPI; "Cust. Contract Deferral API")
                {
                    Caption = 'customerContractDeferrals', Locked = true;
                    EntityName = 'customerContractDeferrals';
                    EntitySetName = 'customerContractDeferrals';
                    SubPageLink = "Subscription Contract No." = field("Subscription Contract No."), "Subscription Contract Line No." = field("Line No.");
                }
            }
        }
    }
}
