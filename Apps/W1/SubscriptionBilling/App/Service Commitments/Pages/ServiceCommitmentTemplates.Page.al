namespace Microsoft.SubscriptionBilling;

page 8055 "Service Commitment Templates"
{

    ApplicationArea = All;
    Caption = 'Subscription Package Line Templates';
    PageType = List;
    SourceTable = "Sub. Package Line Template";
    UsageCategory = Administration;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Code; Rec.Code)
                {
                    ShowMandatory = true;
                    ToolTip = 'Specifies a code to identify this Subscription Package Line Template.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the Subscription Package Line Template.';
                }
                field("Invoicing via"; Rec."Invoicing via")
                {
                    ToolTip = 'Specifies whether the Subscription Line is invoiced via a contract. Subscription Lines with invoicing via sales are not charged. Only the items are billed.';
                }
                field("Invoicing Item No."; Rec."Invoicing Item No.")
                {
                    ToolTip = 'Specifies which item will be used in contract invoice for invoicing of the periodic Subscription Line.';
                }
                field("Calculation Base Type"; Rec."Calculation Base Type")
                {
                    ToolTip = 'Specifies how the price for Subscription Line is calculated. "Item Price" uses the list price defined on the Item. "Document Price" uses the price from the sales document. "Document Price And Discount" uses the price and the discount from the sales document.';
                }
                field("Calculation Base %"; Rec."Calculation Base %")
                {
                    ToolTip = 'Specifies the percentage at which the price of the Subscription Line is calculated. 100% means that the the price is the same as the calculation base (item or document).';
                }
                field("Billing Base Period"; Rec."Billing Base Period")
                {
                    ToolTip = 'Specifies the period to which the Subscription Line amount relates. For example, enter 1M if the amount relates to one month or 12M if the amount relates to 1 year.';
                }
                field(Discount; Rec.Discount)
                {
                    ToolTip = 'Specifies whether the Subscription Line is used as a basis for periodic invoicing or discounts.';
                }
                field(UsageBasedBilling; Rec."Usage Based Billing")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether usage data is used as the basis for billing via contracts.';
                }
                field("Create Contract Deferrals"; Rec."Create Contract Deferrals")
                {
                    ToolTip = 'Specifies whether deferrals are created for new Subscription Package lines.';
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
    trigger OnAfterGetRecord()
    begin
        PricingUnitCostSurchargeEditable := Rec."Usage Based Pricing" = Enum::"Usage Based Pricing"::"Unit Cost Surcharge";
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SubscriptionContractSetup.Get();
        Rec."Create Contract Deferrals" := SubscriptionContractSetup."Create Contract Deferrals";
    end;

    var
        SubscriptionContractSetup: Record "Subscription Contract Setup";
        PricingUnitCostSurchargeEditable: Boolean;
}
