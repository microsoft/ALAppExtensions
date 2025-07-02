namespace Microsoft.SubscriptionBilling;

page 8076 "Serv. Comm. WO Vend. Contract"
{

    Caption = 'Subscription Lines without Vendor Subscription Contract';
    PageType = Worksheet;
    SourceTable = "Subscription Line";
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
                    ToolTip = 'Specifies the name that Subscription were shipped to. Once a Subscription Line has been transferred to the contract, all Subscription Lines with the same Ship-to Name will be displayed in bold.';
                    Editable = false;
                    StyleExpr = ShipToStyleExpr;

                    trigger OnAssistEdit()
                    begin
                        ServiceObject.OpenServiceObjectCard(Rec."Subscription Header No.");
                    end;
                }
                field(ServiceObjectDescription; ServiceObject.Description)
                {
                    Caption = 'Subscription description';
                    ToolTip = 'Specifies a description of the Subscription.';
                    Editable = false;

                    trigger OnAssistEdit()
                    begin
                        ServiceObject.OpenServiceObjectCard(Rec."Subscription Header No.");
                    end;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the Subscription Line.';
                    Editable = false;
                }
                field("Contract No."; Rec."Subscription Contract No.")
                {
                    Caption = 'Assign to Contract No.';
                    ToolTip = 'Specifies the contract to which the Subscription Line is to be assigned.';
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Service Start Date"; Rec."Subscription Line Start Date")
                {
                    ToolTip = 'Specifies the date from which the Subscription Line is valid and will be invoiced.';
                    Editable = false;
                }
                field(Quantity; ServiceObject.Quantity)
                {
                    ToolTip = 'Specifies the number of units of Subscription.';
                    Editable = false;
                    BlankZero = true;
                    Caption = 'Quantity';
                }
                field(Price; Rec.Price)
                {
                    ToolTip = 'Specifies the price of the Subscription Line with quantity of 1 in the billing period. The price is calculated from Base Price and Base Price %.';
                    Editable = false;
                }
                field("Service Amount"; Rec.Amount)
                {
                    ToolTip = 'Specifies the amount for the Subscription Line including discount.';
                    Editable = false;
                }
                field("Billing Base Period"; Rec."Billing Base Period")
                {
                    Editable = false;
                    ToolTip = 'Specifies for which period the Amount is valid. If you enter 1M here, a period of one month, or 12M, a period of 1 year, to which Amount refers to.';
                }
                field("Billing Rhythm"; Rec."Billing Rhythm")
                {
                    ToolTip = 'Specifies the Dateformula for rhythm in which the Subscription Line is invoiced. Using a Dateformula rhythm can be, for example, a monthly, a quarterly or a yearly invoicing.';
                    Editable = false;
                }
                field("Period Calculation"; Rec."Period Calculation")
                {
                    Visible = false;
                    Editable = false;
                    ToolTip = 'Specifies the Period Calculation, which controls how a period is determined for billing. The calculation of a month from 28.02. can extend to 27.03. (Align to Start of Month) or 30.03. (Align to End of Month).';
                }
                field(ServiceObjectContact; ServiceObject."End-User Contact")
                {
                    Caption = 'Contact';
                    ToolTip = 'Specifies the name of the contact using the Subscription Line.';
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
                Caption = 'Assign selected Subscription Lines';
                ToolTip = 'Assigns all marked Subscription Lines to the contract selected in "Assign to Contract No.".';

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
                Caption = 'Assign all Subscription Lines';
                ToolTip = 'Assign all Subscription Lines to the contract selected in "Assign to Contract No.".';

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
        if not ServiceObject.Get(Rec."Subscription Header No.") then
            ServiceObject.Init();
        if not VendorContract.Get(Rec."Subscription Contract No.") then
            VendorContract.Init();
    end;

    var
        ServiceObject: Record "Subscription Header";
        VendorContract: Record "Vendor Subscription Contract";
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
        ServiceCommitment: Record "Subscription Line";
    begin
        Rec.Reset();
        ServiceCommitment.SetRange("Invoicing via", Enum::"Invoicing Via"::Contract);
        ServiceCommitment.SetRange("Subscription Contract No.", '');
        ServiceCommitment.SetRange(Partner, Enum::"Service Partner"::Vendor);
        if ServiceCommitment.FindSet() then
            repeat
                if not Rec.Get(ServiceCommitment."Entry No.") then begin
                    Rec.TransferFields(ServiceCommitment);
                    if VendorContractNo <> '' then
                        Rec."Subscription Contract No." := VendorContractNo;
                    Rec.Insert(false);
                end;
            until ServiceCommitment.Next() = 0;
        Rec.SetFilter("Subscription Line End Date", '>%1|%2', WorkDate(), 0D);
    end;
}
