namespace Microsoft.SubscriptionBilling;

page 8073 "Archived Billing Lines"
{
    Caption = 'Archived Billing Lines';
    Editable = false;
    PageType = List;
    SourceTable = "Billing Line Archive";
    SourceTableView = sorting("Subscription Contract No.", "Subscription Contract Line No.", "Billing from");
    UsageCategory = None;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(BillingLines)
            {
                field("Partner No."; Rec."Partner No.")
                {
                    ToolTip = 'Specifies the number of the partner who will receive the contract components and be billed by default.';
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        ContractsGeneralMgt.OpenPartnerCard(Rec.Partner, Rec."Partner No.");
                    end;
                }
                field("Partner Name"; PartnerNameTxt)
                {
                    Caption = 'Partner Name';
                    ToolTip = 'Specifies the name of the partner who will receive the contract components and be billed by default.';
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        ContractsGeneralMgt.OpenPartnerCard(Rec.Partner, Rec."Partner No.");
                    end;
                }
                field("Contract No."; Rec."Subscription Contract No.")
                {
                    ToolTip = 'Specifies the number of the Subscription Contract.';
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        ContractsGeneralMgt.OpenContractCard(Rec.Partner, Rec."Subscription Contract No.");
                    end;
                }
                field(ContractDescriptionField; ContractDescriptionTxt)
                {
                    Caption = 'Subscription Contract Description';
                    ToolTip = 'Specifies the description of the Subscription Contract.';

                    trigger OnDrillDown()
                    begin
                        ContractsGeneralMgt.OpenContractCard(Rec.Partner, Rec."Subscription Contract No.");
                    end;
                }
                field("Billing from"; Rec."Billing from")
                {
                    ToolTip = 'Specifies the date from which the Subscription Line is billed.';
                }
                field("Billing to"; Rec."Billing to")
                {
                    ToolTip = 'Specifies the date to which the Subscription Line is billed.';
                }
                field("Service Amount"; Rec.Amount)
                {
                    ToolTip = 'Specifies the amount for the Subscription Line including discount.';
                }
                field("Unit Cost (LCY)"; Rec."Unit Cost (LCY)")
                {
                    ToolTip = 'Specifies the unit cost for the billing period.';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ToolTip = 'Specifies the Unit Price for the subscription line billing period without discount.';
                }
                field("Service Object Quantity"; Rec."Service Object Quantity")
                {
                    ToolTip = 'Specifies the quantity from the Subscription.';
                }
                field("Discount %"; Rec."Discount %")
                {
                    ToolTip = 'Specifies the Discount % for the subscription line billing period.';
                }
                field("Service Commitment Description"; Rec."Subscription Line Description")
                {
                    ToolTip = 'Specifies the description of the Subscription Line.';
                }
                field("Billing Rhythm"; Rec."Billing Rhythm")
                {
                    ToolTip = 'Specifies the Dateformula for rhythm in which the Subscription Line is invoiced. Using a Dateformula rhythm can be, for example, a monthly, a quarterly or a yearly invoicing.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Shows the document type of the document created for posting.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Shows the document number of the document created for posting.';
                }
                field("Document Line No."; Rec."Document Line No.")
                {
                    ToolTip = 'Shows the document line number of the document, it was posted in.';
                }
                field("Service Start Date"; Rec."Subscription Line Start Date")
                {
                    ToolTip = 'Specifies the date from which the Subscription Line is valid and will be invoiced.';
                }
                field("Service End Date"; Rec."Subscription Line End Date")
                {
                    ToolTip = 'Specifies the date up to which the Subscription Line is valid.';
                }
                field("Service Object No."; Rec."Subscription Header No.")
                {
                    ToolTip = 'Specifies the number of the Subscription.';

                    trigger OnDrillDown()
                    begin
                        ServiceObject.OpenServiceObjectCard(Rec."Subscription Header No.");
                    end;
                }
                field("Service Object Description"; Rec."Subscription Description")
                {
                    ToolTip = 'Specifies a description of the Subscription.';
                }
                field("Billing Template Code"; Rec."Billing Template Code")
                {
                    ToolTip = 'Specifies the template code.';
                    Visible = false;
                }
                field(Discount; Rec.Discount)
                {
                    Visible = false;
                    Editable = false;
                    ToolTip = 'Specifies whether the Subscription Line is used as a basis for periodic invoicing or discounts.';
                }
                field("User ID"; Rec."User ID")
                {
                    ToolTip = 'Shows the user who created the line.';
                    Visible = false;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ContractDescriptionTxt := ContractsGeneralMgt.GetContractDescription(Rec.Partner, Rec."Subscription Contract No.");
        PartnerNameTxt := ContractsGeneralMgt.GetPartnerName(Rec.Partner, Rec."Partner No.");
    end;

    var
        ServiceObject: Record "Subscription Header";
        ContractsGeneralMgt: Codeunit "Sub. Contracts General Mgt.";
        ContractDescriptionTxt: Text;
        PartnerNameTxt: Text;
}