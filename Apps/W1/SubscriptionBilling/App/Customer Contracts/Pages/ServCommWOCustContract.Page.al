namespace Microsoft.SubscriptionBilling;

page 8069 "Serv. Comm. WO Cust. Contract"
{
    Caption = 'Service Commitments without Customer Contract';
    PageType = Worksheet;
    SourceTable = "Service Commitment";
    SourceTableTemporary = true;
    ApplicationArea = All;
    UsageCategory = Lists;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(ServiceObjectCustomer; ServiceObject."End-User Customer Name")
                {
                    Caption = 'Customer';
                    ToolTip = 'Specifies the name of the customer who is using the service.';
                    Editable = false;

                    trigger OnAssistEdit()
                    begin
                        CustomerManagement.OpenCustomerCard(ServiceObject."End-User Customer No.");
                    end;
                }
                field(ServiceObjectShipToName; ServiceObject."Ship-to Name")
                {
                    Caption = 'Ship-to Name';
                    ToolTip = 'Specifies the name that service object were shipped to. Once a service commitment has been transferred to the contract, all service commitments with the same Ship-to Name will be displayed in bold.';
                    Editable = false;
                    StyleExpr = ShipToStyleExpr;

                    trigger OnAssistEdit()
                    begin
                        ServiceObject.OpenServiceObjectCard(Rec."Service Object No.");
                    end;
                }
                field(ServiceObjectDescription; ServiceObject.Description)
                {
                    Caption = 'Service object description';
                    ToolTip = 'Specifies a description of the service object.';
                    Editable = false;

                    trigger OnAssistEdit()
                    begin
                        ServiceObject.OpenServiceObjectCard(Rec."Service Object No.");
                    end;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the service.';
                    Editable = false;
                }
                field("Contract No."; Rec."Contract No.")
                {
                    Caption = 'Assign to Contract No.';
                    ToolTip = 'Specifies the contract to which the service is to be assigned.';

                    trigger OnValidate()
                    begin
                        UpdateShipToStyle();
                    end;
                }
                field("Service Start Date"; Rec."Service Start Date")
                {
                    ToolTip = 'Specifies the date from which the service is valid and will be invoiced.';
                    Editable = false;
                }
                field(Quantity; ServiceObject."Quantity Decimal")
                {
                    ToolTip = 'Number of units of service object.';
                    Editable = false;
                    BlankZero = true;
                    Caption = 'Quantity';
                }
                field(Price; Rec.Price)
                {
                    ToolTip = 'Specifies the price of the service with quantity of 1 in the billing period. The price is calculated from Base Price and Base Price %.';
                    Editable = false;
                }
                field("Service Amount"; Rec."Service Amount")
                {
                    ToolTip = 'Specifies the amount for the service including discount.';
                    Editable = false;
                }
                field("Billing Base Period"; Rec."Billing Base Period")
                {
                    Editable = false;
                    ToolTip = 'Specifies for which period the Service Amount is valid. If you enter 1M here, a period of one month, or 12M, a period of 1 year, to which Service Amount refers to.';
                }
                field("Billing Rhythm"; Rec."Billing Rhythm")
                {
                    ToolTip = 'Specifies the Dateformula for rhythm in which the service is invoiced. Using a Dateformula rhythm can be, for example, a monthly, a quarterly or a yearly invoicing.';
                    Editable = false;
                }
                field("Period Calculation"; Rec."Period Calculation")
                {
                    Visible = false;
                    Editable = false;
                    ToolTip = 'The Period Calculation controls how a period is determined for billing. The calculation of a month from 28.02. can extend to 27.03. (Align to Start of Month) or 30.03. (Align to End of Month).';
                }
                field(ServiceObjectContact; ServiceObject."End-User Contact")
                {
                    Caption = 'Contact';
                    ToolTip = 'Specifies the name of the contact using the service.';
                    Editable = false;

                    trigger OnAssistEdit()
                    begin
                        ContactManagement.OpenContactCard(ServiceObject."End-User Contact No.");
                    end;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(AssignSelectedServiceCommitmentsAction)
            {
                Image = TransferToLines;
                Caption = 'Assign selected services';
                ToolTip = 'Assigns all marked services to the contract selected in "Assign to Contract No.".';

                trigger OnAction()
                begin
                    CurrPage.SetSelectionFilter(Rec);
                    CustomerContract.CreateCustomerContractLinesFromServiceCommitments(Rec);
                    RefreshServiceCommitments();
                end;
            }
            action(AssignAllServiceCommitmentsAction)
            {
                Image = AllLines;
                Caption = 'Assign all services';
                ToolTip = 'Assign all services to the contract selected in "Assign to Contract No.".';

                trigger OnAction()
                begin
                    CustomerContract.CreateCustomerContractLinesFromServiceCommitments(Rec);
                    RefreshServiceCommitments();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(AssignSelectedServiceCommitmentsAction_Promoted; AssignSelectedServiceCommitmentsAction)
                {
                }
                actionref(AssignAllServiceCommitmentsAction_Promoted; AssignAllServiceCommitmentsAction)
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        RefreshServiceCommitments();
    end;

    trigger OnAfterGetRecord()
    begin
        if not ServiceObject.Get(Rec."Service Object No.") then
            ServiceObject.Init();
        Rec.CalcFields("Service Object Customer No."); //needed as the Table Relation of "Contract No." uses this field
        UpdateShipToStyle();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateShipToStyle();
    end;

    var
        ServiceObject: Record "Service Object";
        CustomerContract: Record "Customer Contract";
        ContactManagement: Codeunit "Contact Management";
        CustomerManagement: Codeunit "Customer Management";
        ShipToStyleExpr: Text;
        CustomerContractNo: Code[20];

    internal procedure SetCustomerContractNo(NewCustomerContractNo: Code[20])
    begin
        CustomerContractNo := NewCustomerContractNo;
    end;

    local procedure RefreshServiceCommitments()
    var
        ServiceCommitment: Record "Service Commitment";
        CustomerContract2: Record "Customer Contract";
    begin
        Rec.Reset();
        Rec.DeleteAll(false);
        ServiceCommitment.SetRange("Invoicing via", Enum::"Invoicing Via"::Contract);
        ServiceCommitment.SetRange("Contract No.", '');
        ServiceCommitment.SetRange(Partner, Enum::"Service Partner"::Customer);
        if CustomerContractNo <> '' then begin
            CustomerContract2.Get(CustomerContractNo);
            ServiceCommitment.SetRange("Service Object Customer No.", CustomerContract2."Sell-to Customer No.");
        end;
        if ServiceCommitment.FindSet() then
            repeat
                if not Rec.Get(ServiceCommitment."Entry No.") then begin
                    Rec.TransferFields(ServiceCommitment);
                    if CustomerContractNo <> '' then
                        Rec."Contract No." := CustomerContractNo;
                    Rec.Insert(false);
                end;
            until ServiceCommitment.Next() = 0;
        Rec.SetFilter("Service End Date", '>%1|%2', WorkDate(), 0D);
    end;

    local procedure UpdateShipToStyle()
    begin
        ShipToStyleExpr := 'Strong';
        if not GetCustomerContract() then
            exit;
        if (ServiceObject."Ship-to Code" <> CustomerContract."Ship-to Code") or
           not CustomerContract.IsShipToAddressEqualToServiceObjectShipToAddress(ServiceObject)
        then
            if CustomerContract.CustomerContractLinesExists() then
                ShipToStyleExpr := '';
    end;

    local procedure GetCustomerContract(): Boolean
    begin
        if Rec."Contract No." = '' then begin
            Clear(CustomerContract);
            exit(false);
        end;
        if CustomerContract."No." <> Rec."Contract No." then
            CustomerContract.Get(Rec."Contract No.");
        exit(true);
    end;
}