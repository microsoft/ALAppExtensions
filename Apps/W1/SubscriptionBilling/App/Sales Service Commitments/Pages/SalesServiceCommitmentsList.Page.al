namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Document;
using Microsoft.Utilities;

page 8015 "Sales Service Commitments List"
{
    ApplicationArea = All;
    Caption = 'Sales Subscription Lines';
    PageType = List;
    SourceTable = "Sales Subscription Line";
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
                    ToolTip = 'Specifies the value of the Document Type field.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the value of the Document No. field.';
                }
                field(Partner; Rec.Partner)
                {
                    ToolTip = 'Specifies whether a Subscription Line should be invoiced to a vendor (purchase invoice) or to a customer (sales invoice).';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the package line.';
                }
                field("Initial Term"; Rec."Initial Term")
                {
                    ToolTip = 'Specifies a date formula for calculating the minimum term of the Subscription Line. If the minimum term is filled and no extension term is entered, the end of Subscription Line is automatically set to the end of the initial term.';
                }
                field("Extension Term"; Rec."Extension Term")
                {
                    ToolTip = 'Specifies a date formula for automatic renewal after initial term and the rhythm of the update of "Notice possible to" and "Term Until". If the field is empty and the initial term or notice period is filled, the end of Subscription Line is automatically set to the end of the initial term or notice period.';
                }
                field(Price; Rec.Price)
                {
                    ToolTip = 'Specifies the price of the Subscription Line with quantity of 1 in the billing period. The price is calculated from Base Price and Base Price %.';
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ToolTip = 'Specifies the amount of the discount for the Subscription Line.';
                }
                field("Service Amount"; Rec.Amount)
                {
                    ToolTip = 'Specifies the amount for the Subscription Line including discount.';
                }
                field("Billing Base Period"; Rec."Billing Base Period")
                {
                    ToolTip = 'Specifies for which period the Amount is valid. If you enter 1M here, a period of one month, or 12M, a period of 1 year, to which Amount refers to.';
                }
                field("Agreed Serv. Comm. Start Date"; Rec."Agreed Sub. Line Start Date")
                {
                    ToolTip = 'Specifies the individually agreed start of the Subscription Line. Enter a date here to overwrite the determination of the start of Subscription Line with the start of Subscription Line formula upon delivery. If the field remains empty, the start of the Subscription Line is determined upon delivery.';
                    Visible = false;
                }
                field("Billing Rhythm"; Rec."Billing Rhythm")
                {
                    ToolTip = 'Specifies the Dateformula for rhythm in which the Subscription Line is invoiced. Using a Dateformula rhythm can be, for example, a monthly, a quarterly or a yearly invoicing.';
                    Visible = false;
                }
                field("Calculation Base %"; Rec."Calculation Base %")
                {
                    ToolTip = 'Specifies the percent at which the price of the Subscription Line will be calculated. 100% means that the price corresponds to the Base Price.';
                    Visible = false;
                }
                field("Calculation Base Amount"; Rec."Calculation Base Amount")
                {
                    ToolTip = 'Specifies the base amount from which the price will be calculated.';
                    Visible = false;
                }
                field("Calculation Base Type"; Rec."Calculation Base Type")
                {
                    ToolTip = 'Specifies how the price for Subscription Line is calculated. "Item Price" uses the list price defined on the Item. "Document Price" uses the price from the sales document. "Document Price And Discount" uses the price and the discount from the sales document.';
                    Visible = false;
                }
                field("Customer Price Group"; Rec."Customer Price Group")
                {
                    ToolTip = 'Specifies the value of the Customer Price Group field.';
                    Visible = false;
                }
                field(Discount; Rec.Discount)
                {
                    ToolTip = 'Specifies whether the Subscription Line is used as a basis for periodic invoicing or discounts.';
                    Visible = false;
                }
                field("Create Contract Deferrals"; Rec."Create Contract Deferrals")
                {
                    ToolTip = 'Specifies whether deferrals are created for new Subscription lines.';
                }
                field("Discount %"; Rec."Discount %")
                {
                    ToolTip = 'Specifies the percent of the discount for the Subscription Line.';
                    Visible = false;
                }
                field("Document Line No."; Rec."Document Line No.")
                {
                    ToolTip = 'Specifies the value of the Document Line No. field.';
                    Visible = false;
                }
                field("Invoicing via"; Rec."Invoicing via")
                {
                    ToolTip = 'Specifies whether the Subscription Line is invoiced via a contract. Subscription Lines with invoicing via sales are not charged. Only the items are billed.';
                    Visible = false;
                }
                field("Item Description"; Rec."Item Description")
                {
                    ToolTip = 'Specifies a description of the product to be sold.';
                    Visible = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the number of an item.';
                    Visible = false;
                }
                field("Line No."; Rec."Line No.")
                {
                    ToolTip = 'Specifies the value of the Line No. field.';
                    Visible = false;
                }
                field("Notice Period"; Rec."Notice Period")
                {
                    ToolTip = 'Specifies a date formula for the lead time that a notice must have before the Subscription Line ends. The rhythm of the update of "Notice possible to" and "Term Until" is determined using the extension term. For example, with an extension period of 1M, the notice period is repeatedly postponed by one month.';
                    Visible = false;
                }
                field("Package Code"; Rec."Subscription Package Code")
                {
                    ToolTip = 'Specifies a code to identify this Subscription Package.';
                    Visible = false;
                }
                field("Service Comm. Start Formula"; Rec."Sub. Line Start Formula")
                {
                    ToolTip = 'Specifies the value of the Subscription Line Start Formula field.';
                    Visible = false;
                }
                field("Service Commitment Entry No."; Rec."Subscription Line Entry No.")
                {
                    ToolTip = 'Specifies the value of the Subscription Line Entry No. field.';
                    Visible = false;
                }
                field("Service Object No."; Rec."Subscription Header No.")
                {
                    ToolTip = 'Specifies the value of the Subscription No. field.';
                    Visible = false;
                }
                field("Period Calculation"; Rec."Period Calculation")
                {
                    Visible = false;
                    ToolTip = 'Specifies the Period Calculation, which controls how a period is determined for billing. The calculation of a month from 28.02. can extend to 27.03. (Align to Start of Month) or 30.03. (Align to End of Month).';
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
                field(Template; Rec.Template)
                {
                    ToolTip = 'Specifies a code to identify this Subscription Package Line Template.';
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
                    if SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
                        PageManagement.PageRun(SalesHeader);
                end;
            }
        }
        area(Promoted)
        {
            actionref(ShowSalesDocument_Promoted; ShowSalesDocument)
            {
            }
        }
    }
}
