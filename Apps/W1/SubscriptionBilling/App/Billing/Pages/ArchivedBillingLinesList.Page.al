namespace Microsoft.SubscriptionBilling;

page 8017 "Archived Billing Lines List"
{
    ApplicationArea = All;
    Caption = 'Archived Billing Lines';
    PageType = List;
    SourceTable = "Billing Line Archive";
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
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
                field(Partner; Rec.Partner)
                {
                    ToolTip = 'Specifies the value of the Partner field.';
                }
                field("Contract No."; Rec."Subscription Contract No.")
                {
                    ToolTip = 'Specifies the number of the Subscription Contract.';
                }
                field("Billing from"; Rec."Billing from")
                {
                    ToolTip = 'Specifies the date from which the Subscription Line is billed.';
                }
                field("Billing to"; Rec."Billing to")
                {
                    ToolTip = 'Specifies the date to which the Subscription Line is billed.';
                }
                field("Service Object Description"; Rec."Subscription Description")
                {
                    ToolTip = 'Specifies a description of the Subscription.';
                }
                field("Service Commitment Description"; Rec."Subscription Line Description")
                {
                    ToolTip = 'Specifies the description of the Subscription Line.';
                }
                field("Service Obj. Quantity Decimal"; Rec."Service Object Quantity")
                {
                    ToolTip = 'Specifies the quantity from the Subscription.';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ToolTip = 'Specifies the Unit Price for the subscription line billing period without discount.';
                }
                field("Discount %"; Rec."Discount %")
                {
                    ToolTip = 'Specifies the Discount % for the subscription line billing period.';
                }
                field("Service Amount"; Rec.Amount)
                {
                    ToolTip = 'Specifies the amount for the Subscription Line including discount.';
                }
                field("Billing Rhythm"; Rec."Billing Rhythm")
                {
                    ToolTip = 'Specifies the Dateformula for rhythm in which the Subscription Line is invoiced. Using a Dateformula rhythm can be, for example, a monthly, a quarterly or a yearly invoicing.';
                    Visible = false;
                }
                field("Billing Template Code"; Rec."Billing Template Code")
                {
                    ToolTip = 'Specifies the template code.';
                    Visible = false;
                }
                field("Contract Line No."; Rec."Subscription Contract Line No.")
                {
                    ToolTip = 'Specifies the value of the Contract Line No. field.';
                    Visible = false;
                }
                field("Correction Document No."; Rec."Correction Document No.")
                {
                    ToolTip = 'Specifies the value of the Correction Document No. field.';
                    Visible = false;
                }
                field("Correction Document Type"; Rec."Correction Document Type")
                {
                    ToolTip = 'Specifies the value of the Correction Document Type field.';
                    Visible = false;
                }
                field(Discount; Rec.Discount)
                {
                    ToolTip = 'Specifies whether the Subscription Line is used as a basis for periodic invoicing or discounts.';
                    Visible = false;
                }
                field("Line No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                    Visible = false;
                }
                field("Partner No."; Rec."Partner No.")
                {
                    ToolTip = 'Specifies the number of the partner who will receive the contract components and be billed by default.';
                    Visible = false;
                }
                field("Service Commitment Entry No."; Rec."Subscription Line Entry No.")
                {
                    ToolTip = 'Specifies the value of the Subscription Line Entry No. field.';
                    Visible = false;
                }
                field("Service End Date"; Rec."Subscription Line End Date")
                {
                    ToolTip = 'Specifies the date up to which the Subscription Line is valid.';
                    Visible = false;
                }
                field("Service Object No."; Rec."Subscription Header No.")
                {
                    ToolTip = 'Specifies the number of the Subscription.';
                    Visible = false;
                }
                field("Service Start Date"; Rec."Subscription Line Start Date")
                {
                    ToolTip = 'Specifies the date from which the Subscription Line is valid and will be invoiced.';
                    Visible = false;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies on which date the record was created.';
                    Visible = false;
                }
                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                    ToolTip = 'Specifies by whom the record was created.';
                    Visible = false;
                }
                field(SystemId; Rec.SystemId)
                {
                    ToolTip = 'Specifies the value of the SystemId field.';
                    Visible = false;
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ToolTip = 'Specifies the date on which the record was last modified.';
                    Visible = false;
                }
                field(SystemModifiedBy; Rec.SystemModifiedBy)
                {
                    ToolTip = 'Specifies by whom the record was last modified.';
                    Visible = false;
                }
                field("User ID"; Rec."User ID")
                {
                    ToolTip = 'Shows the user who created the line.';
                    Visible = false;
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(ShowSalesDocument)
            {
                ApplicationArea = All;
                Caption = 'Show Sales Document';
                ToolTip = 'Opens the sales document.';
                Image = Document;

                trigger OnAction()
                begin
                    Rec.ShowDocumentCard();
                end;
            }
            action(ShowContract)
            {
                ApplicationArea = All;
                Caption = 'Show Contract';
                ToolTip = 'Opens the contract.';
                Image = ContractPayment;

                trigger OnAction()
                var
                    ContractsGenMgt: Codeunit "Sub. Contracts General Mgt.";
                begin
                    ContractsGenMgt.OpenContractCard(Rec.Partner, Rec."Subscription Contract No.");
                end;
            }
            action(ShowServiceObject)
            {
                ApplicationArea = All;
                Caption = 'Show Subscription';
                ToolTip = 'Opens the Subscription.';
                Image = Document;

                trigger OnAction()
                var
                    ServiceObject: Record "Subscription Header";
                begin
                    ServiceObject.OpenServiceObjectCard(Rec."Subscription Header No.");
                end;
            }
        }
        area(Promoted)
        {
            actionref(ShowSalesDocument_Promoted; ShowSalesDocument)
            {
            }
            actionref(ShowContract_Promoted; ShowContract)
            {
            }
            actionref(ShowServiceObject_Promoted; ShowServiceObject)
            {
            }
        }
    }

}
