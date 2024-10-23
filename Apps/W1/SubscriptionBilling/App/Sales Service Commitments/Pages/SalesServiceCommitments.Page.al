namespace Microsoft.SubscriptionBilling;

page 8082 "Sales Service Commitments"
{
    Caption = 'Sales Service Commitments';
    PageType = List;
    SourceTable = "Sales Service Commitment";
    InsertAllowed = false;
    SourceTableView = sorting("Package Code");
    UsageCategory = None;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(SalesServiceCommitmentLines)
            {
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the number of an item.';
                    Visible = false;
                }
                field("Item Description"; Rec."Item Description")
                {
                    ToolTip = 'Specifies a description of the product to be sold.';
                }
                field(Partner; Rec.Partner)
                {
                    ToolTip = 'Specifies whether a service commitment should be invoiced to a vendor (purchase invoice) or to a customer (sales invoice).';
                }
                field("Linked to No."; Rec."Linked to No.")
                {
                    ToolTip = 'Specifies the associated Contract the Service Commitment will be assigned to. If the sales line was created by a Contract Renewal, the Contract No. cannot be edited.';
                }
                field("Linked to Line No."; Rec."Linked to Line No.")
                {
                    ToolTip = 'Specifies the associated Contract line the Service Commitment will renew.';
                    Visible = false;
                }
                field(Process; Rec.Process)
                {
                    ToolTip = 'Specifies the type of operation and state of the process.';
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the package line.';
                }
                field("Package Code"; Rec."Package Code")
                {
                    ToolTip = 'Specifies a code to identify this service commitment package.';
                }
                field("Calculation Base Type"; Rec."Calculation Base Type")
                {
                    ToolTip = 'Specifies how the price for service commitment is calculated. "Item Price" uses the list price defined on the Item. "Document Price" uses the price from the sales document. "Document Price And Discount" uses the price and the discount from the sales document.';
                }
                field("Calculation Base Amount"; Rec."Calculation Base Amount")
                {
                    ToolTip = 'Specifies the base amount from which the price will be calculated.';
                }
                field("Calculation Base %"; Rec."Calculation Base %")
                {
                    ToolTip = 'Specifies the percent at which the price of the service will be calculated. 100% means that the price corresponds to the Base Price.';
                }
                field(Price; Rec.Price)
                {
                    ToolTip = 'Specifies the price of the service with quantity of 1 in the billing period. The price is calculated from Base Price and Base Price %.';
                }
                field("Discount %"; Rec."Discount %")
                {
                    ToolTip = 'Specifies the percent of the discount for the service.';
                    Editable = not IsDiscountLine;
                    Enabled = not IsDiscountLine;
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ToolTip = 'Specifies the amount of the discount for the service.';
                    Editable = not IsDiscountLine;
                    Enabled = not IsDiscountLine;
                }
                field("Service Amount"; Rec."Service Amount")
                {
                    ToolTip = 'Specifies the amount for the service including discount.';
                }
                field("Agreed Serv. Comm. Start Date"; Rec."Agreed Serv. Comm. Start Date")
                {
                    ToolTip = 'Indicates the individually agreed start of the service. Enter a date here to overwrite the determination of the start of service with the start of service formula upon delivery. If the field remains empty, the start of the service is determined upon delivery.';
                }
                field("Initial Term"; Rec."Initial Term")
                {
                    ToolTip = 'Specifies a date formula for calculating the minimum term of the service commitment. If the minimum term is filled and no extension term is entered, the end of service commitment is automatically set to the end of the initial term.';
                }
                field("Notice Period"; Rec."Notice Period")
                {
                    ToolTip = 'Specifies a date formula for the lead time that a notice must have before the service commitment ends. The rhythm of the update of "Notice possible to" and "Term Until" is determined using the extension term. For example, with an extension period of 1M, the notice period is repeatedly postponed by one month.';
                }
                field("Extension Term"; Rec."Extension Term")
                {
                    ToolTip = 'Specifies a date formula for automatic renewal after initial term and the rhythm of the update of "Notice possible to" and "Term Until". If the field is empty and the initial term or notice period is filled, the end of service is automatically set to the end of the initial term or notice period.';
                }
                field("Billing Base Period"; Rec."Billing Base Period")
                {
                    ToolTip = 'Specifies for which period the Service Amount is valid. If you enter 1M here, a period of one month, or 12M, a period of 1 year, to which Service Amount refers to.';
                }
                field("Billing Rhythm"; Rec."Billing Rhythm")
                {
                    ToolTip = 'Specifies the Dateformula for rhythm in which the service is invoiced. Using a Dateformula rhythm can be, for example, a monthly, a quarterly or a yearly invoicing.';
                }
                field("Invoicing via"; Rec."Invoicing via")
                {
                    Visible = false;
                    ToolTip = 'Specifies whether the service commitment is invoiced via a contract. Service commitments with invoicing via sales are not charged. Only the items are billed.';
                }
                field(Template; Rec.Template)
                {
                    Visible = false;
                    ToolTip = 'Specifies a code to identify this service commitment template.';
                }
                field(Discount; Rec.Discount)
                {
                    Editable = false;
                    ToolTip = 'Specifies whether the Service Commitment is used as a basis for periodic invoicing or discounts.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    Visible = false;
                    Editable = false;
                    ToolTip = 'Document Type.';
                }
                field("Document No."; Rec."Document No.")
                {
                    Visible = false;
                    Editable = false;
                    ToolTip = 'Document No.';
                }
                field("Document Line No."; Rec."Document Line No.")
                {
                    Visible = false;
                    Editable = false;
                    ToolTip = 'Document Line No.';
                }
                field("Period Calculation"; Rec."Period Calculation")
                {
                    Visible = false;
                    ToolTip = 'The Period Calculation controls how a period is determined for billing. The calculation of a month from 28.02. can extend to 27.03. (Align to Start of Month) or 30.03. (Align to End of Month).';
                }
                field("Price Binding Period"; Rec."Price Binding Period")
                {
                    Editable = false;
                    ToolTip = 'Specifies the period the price will not be changed after the price update. It sets a new "Next Price Update" in the contract line after the price update has been performed.';
                }
                field(UsageBasedBilling; Rec."Usage Based Billing")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether usage data is used as the basis for billing via contracts.';
                }
                field(sageBasedPricing; Rec."Usage Based Pricing")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the method for customer based pricing.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(PricingUnitCostSurcharPerc; Rec."Pricing Unit Cost Surcharge %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the surcharge in percent for the debit-side price calculation, if a EK surcharge is to be used.';
                    Editable = PricingUnitCostSurchargeEditable;
                }
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        IsDiscountLine := Rec.Discount;
        PricingUnitCostSurchargeEditable := Rec."Usage Based Pricing" = Enum::"Usage Based Pricing"::"Unit Cost Surcharge";
    end;

    var
        IsDiscountLine: Boolean;
        PricingUnitCostSurchargeEditable: Boolean;
}