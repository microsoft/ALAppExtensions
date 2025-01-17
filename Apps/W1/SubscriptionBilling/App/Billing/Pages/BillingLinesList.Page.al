namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Document;
using Microsoft.Utilities;

page 8016 "Billing Lines List"
{
    ApplicationArea = All;
    Caption = 'Billing Lines';
    PageType = List;
    SourceTable = "Billing Line";
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
                    ToolTip = 'Shows the document line number of the document created for posting.';
                }
                field(Partner; Rec.Partner)
                {
                    ToolTip = 'Specifies the value of the Partner field.';
                }
                field("Contract No."; Rec."Contract No.")
                {
                    ToolTip = 'Specifies the number of the Contract No.';
                }
                field("Billing from"; Rec."Billing from")
                {
                    ToolTip = 'Specifies the date from which the service is billed.';
                }
                field("Billing to"; Rec."Billing to")
                {
                    ToolTip = 'Specifies the date to which the service is billed.';
                }
                field("Service Object Description"; Rec."Service Object Description")
                {
                    ToolTip = 'Specifies a description of the service object.';
                }
                field("Service Commitment Description"; Rec."Service Commitment Description")
                {
                    ToolTip = 'Specifies the description of the service.';
                }
                field("Service Obj. Quantity Decimal"; Rec."Service Obj. Quantity Decimal")
                {
                    ToolTip = 'Quantity from service object.';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ToolTip = 'Specifies the Unit Price for the service billing period without discount.';
                }
                field("Discount %"; Rec."Discount %")
                {
                    ToolTip = 'Specifies the Discount % for the service billing period.';
                }
                field("Service Amount"; Rec."Service Amount")
                {
                    ToolTip = 'Specifies the amount for the service including discount.';
                }
                field("Billing Rhythm"; Rec."Billing Rhythm")
                {
                    ToolTip = 'Specifies the Dateformula for rhythm in which the service is invoiced. Using a Dateformula rhythm can be, for example, a monthly, a quarterly or a yearly invoicing.';
                    Visible = false;
                }
                field("Billing Template Code"; Rec."Billing Template Code")
                {
                    ToolTip = 'Specifies the template code.';
                    Visible = false;
                }
                field("Contract Line No."; Rec."Contract Line No.")
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
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the value of the Code field.';
                    Visible = false;
                }
                field("Detail Overview"; Rec."Detail Overview")
                {
                    ToolTip = 'Specifies the value of the Detail Overview field.';
                    Visible = false;
                }
                field(Discount; Rec.Discount)
                {
                    ToolTip = 'Specifies whether the Service Commitment is used as a basis for periodic invoicing or discounts.';
                    Visible = false;
                }
                field(Indent; Rec.Indent)
                {
                    ToolTip = 'Specifies the value of the Indent field.';
                    Visible = false;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                    Visible = false;
                }
                field("Partner No."; Rec."Partner No.")
                {
                    ToolTip = 'Specifies the number of the partner who will receive the contractual services and be billed by default.';
                    Visible = false;
                }
                field("Service Commitment Entry No."; Rec."Service Commitment Entry No.")
                {
                    ToolTip = 'Specifies the value of the Service Commitment Entry No. field.';
                    Visible = false;
                }
                field("Service End Date"; Rec."Service End Date")
                {
                    ToolTip = 'Specifies the date up to which the service is valid.';
                    Visible = false;
                }
                field("Service Object No."; Rec."Service Object No.")
                {
                    ToolTip = 'Specifies the number of the service object no.';
                    Visible = false;
                }
                field("Service Start Date"; Rec."Service Start Date")
                {
                    ToolTip = 'Specifies the date from which the service is valid and will be invoiced.';
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
                field("Update Required"; Rec."Update Required")
                {
                    ToolTip = 'Specifies whether the associated service has been changed. The "Create Billing Proposal" function must be called up again before the billing document is created.';
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
                var
                    SalesHeader: Record "Sales Header";
                    PageManagement: Codeunit "Page Management";
                begin
                    if SalesHeader.Get(Rec.GetSalesDocumentTypeFromBillingDocumentType(), Rec."Document No.") then
                        PageManagement.PageRun(SalesHeader);
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
                    ContractsGenMgt: Codeunit "Contracts General Mgt.";
                begin
                    ContractsGenMgt.OpenContractCard(Rec.Partner, Rec."Contract No.");
                end;
            }
            action(ShowServiceObject)
            {
                ApplicationArea = All;
                Caption = 'Show Service Object';
                ToolTip = 'Opens the Service Object.';
                Image = Document;

                trigger OnAction()
                var
                    ServiceObject: Record "Service Object";
                begin
                    ServiceObject.OpenServiceObjectCard(Rec."Service Object No.");
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
