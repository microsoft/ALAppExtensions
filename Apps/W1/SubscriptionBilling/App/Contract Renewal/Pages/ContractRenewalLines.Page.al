namespace Microsoft.SubscriptionBilling;

page 8003 "Contract Renewal Lines"
{
    Caption = 'Contract Renewal Lines';
    LinksAllowed = false;
    PageType = List;
    SourceTable = "Contract Renewal Line";
    Editable = false;
    UsageCategory = None;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(BillingLines)
            {
                field("Contract No."; Rec."Contract No.")
                {
                    ToolTip = 'Specifies the number of the Contract.';
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        ContractsGeneralMgt.OpenContractCard(Rec.Partner, Rec."Contract No.");
                    end;
                }
                field(ContractDescriptionField; ContractDescriptionTxt)
                {
                    Caption = 'Contract Description';
                    ToolTip = 'Specifies the products or service being offered.';
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        ContractsGeneralMgt.OpenContractCard(Rec.Partner, Rec."Contract No.");
                    end;
                }
                field("Service Object No."; Rec."Service Object No.")
                {
                    ToolTip = 'Specifies the number of the service object.';

                    trigger OnDrillDown()
                    begin
                        ServiceObject.OpenServiceObjectCard(Rec."Service Object No.");
                    end;
                }
                field("Service Object Description"; Rec."Service Object Description")
                {
                    ToolTip = 'Specifies a description of the service object.';
                }
                field("Service Commitment Description"; Rec."Service Commitment Description")
                {
                    ToolTip = 'Specifies the description of the service.';
                }
                field("Service Start Date"; Rec."Service Start Date")
                {
                    ToolTip = 'Specifies the date from which the service is valid and will be invoiced.';
                }
                field("Service End Date"; Rec."Service End Date")
                {
                    ToolTip = 'Specifies the date up to which the service is valid.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ContractDescriptionTxt := ContractsGeneralMgt.GetContractDescription(Rec.Partner, Rec."Contract No.");
    end;

    var
        ServiceObject: Record "Service Object";
        ContractsGeneralMgt: Codeunit "Contracts General Mgt.";
        ContractDescriptionTxt: Text;
}