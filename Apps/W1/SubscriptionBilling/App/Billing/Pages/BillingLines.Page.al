namespace Microsoft.SubscriptionBilling;

page 8074 "Billing Lines"
{
    Caption = 'Billing Lines';
    LinksAllowed = false;
    PageType = List;
    SourceTable = "Billing Line";
    SourceTableView = sorting("Partner No.", "Contract No.", "Contract Line No.", "Billing from");
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
                    ToolTip = 'Specifies the number of the partner who will receive the contractual services and be billed by default.';
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
                    ToolTip = 'Specifies the name of the partner who will receive the contractual services and be billed by default.';
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        ContractsGeneralMgt.OpenPartnerCard(Rec.Partner, Rec."Partner No.");
                    end;
                }
                field("Contract No."; Rec."Contract No.")
                {
                    ToolTip = 'Specifies the number of the Contract No.';
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
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
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;

                    trigger OnDrillDown()
                    begin
                        ContractsGeneralMgt.OpenContractCard(Rec.Partner, Rec."Contract No.");
                    end;
                }
                field("Service Object No."; Rec."Service Object No.")
                {
                    ToolTip = 'Specifies the number of the service object no.';
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;

                    trigger OnDrillDown()
                    begin
                        ServiceObject.OpenServiceObjectCard(Rec."Service Object No.");
                    end;
                }
                field("Service Object Description"; Rec."Service Object Description")
                {
                    ToolTip = 'Specifies a description of the service object.';
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
                }
                field("Service Commitment Description"; Rec."Service Commitment Description")
                {
                    ToolTip = 'Specifies the description of the service.';
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
                }
                field("Service Start Date"; Rec."Service Start Date")
                {
                    ToolTip = 'Specifies the date from which the service is valid and will be invoiced.';
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
                }
                field("Service End Date"; Rec."Service End Date")
                {
                    ToolTip = 'Specifies the date up to which the service is valid.';
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
                }
                field("Billing from"; Rec."Billing from")
                {
                    ToolTip = 'Specifies the date from which the service is billed.';
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
                }
                field("Billing to"; Rec."Billing to")
                {
                    ToolTip = 'Specifies the date to which the service is billed.';
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
                }
                field("Service Object Quantity"; Rec."Service Obj. Quantity Decimal")
                {
                    ToolTip = 'Quantity from service object.';
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ToolTip = 'Specifies the Unit Price for the service billing period without discount.';
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
                }
                field("Discount %"; Rec."Discount %")
                {
                    ToolTip = 'Specifies the Discount % for the service billing period.';
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
                }
                field("Service Amount"; Rec."Service Amount")
                {
                    ToolTip = 'Specifies the amount for the service including discount.';
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
                }
                field("Billing Rhythm"; Rec."Billing Rhythm")
                {
                    ToolTip = 'Specifies the Dateformula for rhythm in which the service is invoiced. Using a Dateformula rhythm can be, for example, a monthly, a quarterly or a yearly invoicing.';
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
                }
                field("Update Required"; Rec."Update Required")
                {
                    ToolTip = 'Specifies whether the associated service has been changed. The "Create Billing Proposal" function must be called up again before the billing document is created.';
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
                }
                field(Discount; Rec.Discount)
                {
                    Style = StrongAccent;
                    StyleExpr = UpdateRequiredStyleExpr;
                    ToolTip = 'Specifies whether the Service Commitment is used as a basis for periodic invoicing or discounts.';
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
        ContractDescriptionTxt := ContractsGeneralMgt.GetContractDescription(Rec.Partner, Rec."Contract No.");
        PartnerNameTxt := ContractsGeneralMgt.GetPartnerName(Rec.Partner, Rec."Partner No.");
        UpdateRequiredStyleExpr := Rec."Update Required";
    end;

    var
        ServiceObject: Record "Service Object";
        ContractsGeneralMgt: Codeunit "Contracts General Mgt.";
        ContractDescriptionTxt: Text;
        PartnerNameTxt: Text;
        UpdateRequiredStyleExpr: Boolean;
}