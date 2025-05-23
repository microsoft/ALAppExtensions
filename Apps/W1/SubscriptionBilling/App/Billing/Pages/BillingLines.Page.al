namespace Microsoft.SubscriptionBilling;

page 8074 "Billing Lines"
{
    Caption = 'Billing Lines';
    LinksAllowed = false;
    PageType = List;
    SourceTable = "Billing Line";
    SourceTableView = sorting("Partner No.", "Subscription Contract No.", "Subscription Contract Line No.", "Billing from");
    Editable = false;
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
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
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
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        ContractsGeneralMgt.OpenPartnerCard(Rec.Partner, Rec."Partner No.");
                    end;
                }
                field("Contract No."; Rec."Subscription Contract No.")
                {
                    ToolTip = 'Specifies the number of the Subscription Contract.';
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
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
                    Editable = false;
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;

                    trigger OnDrillDown()
                    begin
                        ContractsGeneralMgt.OpenContractCard(Rec.Partner, Rec."Subscription Contract No.");
                    end;
                }
                field("Service Object No."; Rec."Subscription Header No.")
                {
                    ToolTip = 'Specifies the number of the Subscription.';
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;

                    trigger OnDrillDown()
                    begin
                        ServiceObject.OpenServiceObjectCard(Rec."Subscription Header No.");
                    end;
                }
                field("Service Object Description"; Rec."Subscription Description")
                {
                    ToolTip = 'Specifies a description of the Subscription.';
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
                }
                field("Service Commitment Description"; Rec."Subscription Line Description")
                {
                    ToolTip = 'Specifies the description of the Subscription Line.';
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
                }
                field("Service Start Date"; Rec."Subscription Line Start Date")
                {
                    ToolTip = 'Specifies the date from which the Subscription Line is valid and will be invoiced.';
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
                }
                field("Service End Date"; Rec."Subscription Line End Date")
                {
                    ToolTip = 'Specifies the date up to which the Subscription Line is valid.';
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
                }
                field("Billing from"; Rec."Billing from")
                {
                    ToolTip = 'Specifies the date from which the Subscription Line is billed.';
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
                }
                field("Billing to"; Rec."Billing to")
                {
                    ToolTip = 'Specifies the date to which the Subscription Line is billed.';
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
                }
                field("Service Object Quantity"; Rec."Service Object Quantity")
                {
                    ToolTip = 'Specifies the quantity from the Subscription.';
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
                }
                field("Unit Cost (LCY)"; Rec."Unit Cost (LCY)")
                {
                    ToolTip = 'Specifies the unit cost for the billing period.';
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ToolTip = 'Specifies the Unit Price for the subscription line billing period without discount.';
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
                }
                field("Discount %"; Rec."Discount %")
                {
                    ToolTip = 'Specifies the Discount % for the subscription line billing period.';
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
                }
                field("Service Amount"; Rec.Amount)
                {
                    ToolTip = 'Specifies the amount for the Subscription Line including discount.';
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
                }
                field("Billing Rhythm"; Rec."Billing Rhythm")
                {
                    ToolTip = 'Specifies the Dateformula for rhythm in which the Subscription Line is invoiced. Using a Dateformula rhythm can be, for example, a monthly, a quarterly or a yearly invoicing.';
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
                }
                field("Update Required"; Rec."Update Required")
                {
                    ToolTip = 'Specifies whether the associated Subscription Line has been changed. The "Create Billing Proposal" function must be called up again before the billing document is created.';
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
                }
                field(Discount; Rec.Discount)
                {
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
                    ToolTip = 'Specifies whether the Subscription Line is used as a basis for periodic invoicing or discounts.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Shows the document type of the document created for posting.';
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Shows the document number of the document created for posting.';
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;

                    trigger OnDrillDown()
                    begin
                        Rec.OpenDocumentCard();
                    end;
                }
                field("Document Line No."; Rec."Document Line No.")
                {
                    ToolTip = 'Shows the document line number of the document created for posting.';
                }
                field("User ID"; Rec."User ID")
                {
                    ToolTip = 'Shows the user who created the line.';
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
                    Visible = false;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ContractDescriptionTxt := ContractsGeneralMgt.GetContractDescription(Rec.Partner, Rec."Subscription Contract No.");
        PartnerNameTxt := ContractsGeneralMgt.GetPartnerName(Rec.Partner, Rec."Partner No.");
        UpdateRequiredStyleExpr := Rec."Update Required";
    end;

    var
        ServiceObject: Record "Subscription Header";
        ContractsGeneralMgt: Codeunit "Sub. Contracts General Mgt.";
        ContractDescriptionTxt: Text;
        PartnerNameTxt: Text;
        UpdateRequiredStyleExpr: Boolean;
}