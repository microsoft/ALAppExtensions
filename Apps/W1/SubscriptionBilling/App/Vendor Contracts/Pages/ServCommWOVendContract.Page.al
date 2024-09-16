namespace Microsoft.SubscriptionBilling;

page 8076 "Serv. Comm. WO Vend. Contract"
{

    Caption = 'Service Commitments without Vendor Contract';
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

                field(ServiceCommitmentVendor; VendorContract."Buy-from Vendor Name")
                {
                    Caption = 'Vendor';
                    ToolTip = 'Specifies the name of the vendor who delivered the items.';
                    Editable = false;

                    trigger OnAssistEdit()
                    begin
                        VendorManagement.OpenVendorCard(VendorContract."Buy-from Vendor No.");
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
                        CurrPage.Update();
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
                    VendorContract.CreateVendorContractLinesFromServiceCommitments(Rec);
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
                    VendorContract.CreateVendorContractLinesFromServiceCommitments(Rec);
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
        if not VendorContract.Get(Rec."Contract No.") then
            VendorContract.Init();
    end;

    var
        ServiceObject: Record "Service Object";
        VendorContract: Record "Vendor Contract";
        ContactManagement: Codeunit "Contact Management";
        VendorManagement: Codeunit "Vendor Management";
        ShipToStyleExpr: Text;
        VendorContractNo: Code[20];

    internal procedure SetVendorContractNo(NewVendorContractNo: Code[20])
    begin
        VendorContractNo := NewVendorContractNo;
    end;

    local procedure RefreshServiceCommitments()
    var
        ServiceCommitment: Record "Service Commitment";
    begin
        Rec.Reset();
        ServiceCommitment.SetRange("Invoicing via", Enum::"Invoicing Via"::Contract);
        ServiceCommitment.SetRange("Contract No.", '');
        ServiceCommitment.SetRange(Partner, Enum::"Service Partner"::Vendor);
        if ServiceCommitment.FindSet() then
            repeat
                if not Rec.Get(ServiceCommitment."Entry No.") then begin
                    Rec.TransferFields(ServiceCommitment);
                    if VendorContractNo <> '' then
                        Rec."Contract No." := VendorContractNo;
                    Rec.Insert(false);
                end;
            until ServiceCommitment.Next() = 0;
        Rec.SetFilter("Service End Date", '>%1|%2', WorkDate(), 0D);
    end;
}
