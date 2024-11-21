namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Document;

pageextension 8076 "Sales Order Subform" extends "Sales Order Subform"
{
    layout
    {
        addafter("Line Amount")
        {
            field("Service Commitments"; Rec."Service Commitments")
            {
                ApplicationArea = All;
                ToolTip = 'Shows the number of service commitments (Subscription Billing) for the sales line.';
            }
            field("Customer Contract No."; CustomerContractNo)
            {
                ApplicationArea = All;
                Caption = 'Customer Contract No.';
                Editable = false;
                ToolTip = 'Specifies the associated Customer Contract the Service Commitment will be assigned to. If the sales line was created by a Contract Renewal, the Contract No. cannot be edited.';

                trigger OnAssistEdit()
                var
                    ContractsGeneralMgt: Codeunit "Contracts General Mgt.";
                    Partner: Enum "Service Partner";
                begin
                    ContractsGeneralMgt.OpenContractCard(Partner::Customer, CustomerContractNo);
                end;
            }
            field("Vendor Contract No."; VendorContractNo)
            {
                ApplicationArea = All;
                Caption = 'Vendor Contract No.';
                Editable = false;
                ToolTip = 'Specifies the associated Vendor Contract the Service Commitment will be assigned to. If the sales line was created by a Contract Renewal, the Contract No. cannot be edited.';

                trigger OnAssistEdit()
                var
                    ContractsGeneralMgt: Codeunit "Contracts General Mgt.";
                    Partner: Enum "Service Partner";
                begin
                    ContractsGeneralMgt.OpenContractCard(Partner::Vendor, VendorContractNo);
                end;
            }
        }
    }
    actions
    {
        addlast("Related Information")
        {
            action(ShowSalesServiceCommitments)
            {
                ApplicationArea = All;
                Caption = 'Service Commitments';
                Image = AllLines;
                RunObject = page "Sales Service Commitments";
                RunPageLink = "Document Type" = field("Document Type"), "Document No." = field("Document No."), "Document Line No." = field("Line No.");
                ToolTip = 'Shows the service commitments for the sales line.';
            }
        }
        addlast("F&unctions")
        {
            action(AddSalesServiceCommitment)
            {
                ApplicationArea = All;
                Caption = 'Add Service Commitments';
                Image = ExpandDepositLine;
                ToolTip = 'Shows all service commitments for the item. Service commitments can be added, changed or removed.';

                trigger OnAction()
                var
                    SalesServiceCommitmentMgmt: Codeunit "Sales Service Commitment Mgmt.";
                begin
                    SalesServiceCommitmentMgmt.AddAdditionalSalesServiceCommitmentsForSalesLine(Rec);
                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        InitializePageVariables();
    end;

    local procedure InitializePageVariables()
    var
    begin
        CustomerContractNo := Rec.RetrieveFirstContractNo("Service Partner"::Customer, Enum::Process::"Contract Renewal");
        VendorContractNo := Rec.RetrieveFirstContractNo("Service Partner"::Vendor, Enum::Process::"Contract Renewal");
    end;

    var
        CustomerContractNo: Code[20];
        VendorContractNo: Code[20];
}