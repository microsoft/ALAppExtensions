namespace Microsoft.SubscriptionBilling;

page 8058 "Service Comm. Package Lines"
{
    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "Subscription Package Line";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Partner; Rec.Partner)
                {
                    Style = Strong;
                    StyleExpr = Bold;
                    ToolTip = 'Specifies whether a Subscription Line should be invoiced to a vendor (purchase invoice) or to a customer (sales invoice).';
                }
                field(Template; Rec.Template)
                {
                    Style = Strong;
                    StyleExpr = Bold;
                    ToolTip = 'Specifies a code to identify this Subscription Package Line Template.';
                }
                field(Description; Rec.Description)
                {
                    Style = Strong;
                    StyleExpr = Bold;
                    ToolTip = 'Specifies a description of the package line.';
                }
                field("Invoicing via"; Rec."Invoicing via")
                {
                    Style = Strong;
                    StyleExpr = Bold;
                    ToolTip = 'Specifies whether the Subscription Line is invoiced via a contract. Subscription Lines with invoicing via sales are not charged. Only the items are billed.';
                }
                field("Invoicing Item No."; Rec."Invoicing Item No.")
                {
                    Style = Strong;
                    StyleExpr = Bold;
                    ToolTip = 'Specifies which item will be used in contract invoice for invoicing of the periodic Subscription Line.';
                }
                field("Calculation Base Type"; Rec."Calculation Base Type")
                {
                    Style = Strong;
                    StyleExpr = Bold;
                    ToolTip = 'Specifies how the price for Subscription Line is calculated. "Item Price" uses the list price defined on the Item. "Document Price" uses the price from the sales document. "Document Price And Discount" uses the price and the discount from the sales document.';
                }
                field("Calculation Base %"; Rec."Calculation Base %")
                {
                    Style = Strong;
                    StyleExpr = Bold;
                    ToolTip = 'Specifies the percentage at which the price of the Subscription Line is calculated. 100% means that the the price is the same as the calculation base (item or document).';
                }
                field("Billing Base Period"; Rec."Billing Base Period")
                {
                    Style = Strong;
                    StyleExpr = Bold;
                    ToolTip = 'Specifies the period to which the Subscription Line amount relates. For example, enter 1M if the amount relates to one month or 12M if the amount relates to 1 year.';
                }
                field("Billing Rhythm"; Rec."Billing Rhythm")
                {
                    Style = Strong;
                    StyleExpr = Bold;
                    ToolTip = 'Specifies the rhythm in which the Subscription Line is calculated. Using a date formula, the rhythm can be defined as monthly, quarterly or annual calculation.';
                }
                field("Service Comm. Start Formula"; Rec."Sub. Line Start Formula")
                {
                    Style = Strong;
                    StyleExpr = Bold;
                    ToolTip = 'Specifies when a Subscription Line is valid. The validity can be automatically changed to the first of the following month using date formula. If the field remains empty, the Subscription Line is valid after shipment.';
                }
                field("Initial Term"; Rec."Initial Term")
                {
                    Style = Strong;
                    StyleExpr = Bold;
                    ToolTip = 'Specifies a date formula for calculating the minimum term of the Subscription Line. If the minimum term is filled and no extension term is entered, the end of Subscription Line is automatically set to the end of the initial term.';
                }
                field("Extension Term"; Rec."Extension Term")
                {
                    Style = Strong;
                    StyleExpr = Bold;
                    ToolTip = 'Specifies a date formula for automatic renewal after initial term and the rhythm of the update of "Notice possible to" and "Term Until". If the field is empty and the initial term or notice period is filled, the end of Subscription Line is automatically set to the end of the initial term or notice period.';
                }
                field("Notice Period"; Rec."Notice Period")
                {
                    Style = Strong;
                    StyleExpr = Bold;
                    ToolTip = 'Specifies a date formula for the lead time that a notice must have before the Subscription Line ends. The rhythm of the update of "Notice possible to" and "Term Until" is determined using the extension term. For example, with an extension period of 1M, the notice period is repeatedly postponed by one month.';
                }
                field(Discount; Rec.Discount)
                {
                    Style = Strong;
                    StyleExpr = Bold;
                    ToolTip = 'Specifies whether the Subscription Line is used as a basis for periodic invoicing or discounts.';
                }
                field("Create Contract Deferrals"; Rec."Create Contract Deferrals")
                {
                    Style = Strong;
                    StyleExpr = Bold;
                    ToolTip = 'Specifies whether deferrals are created for new Subscription lines.';
                }
                field("Period Calculation"; Rec."Period Calculation")
                {
                    Style = Strong;
                    StyleExpr = Bold;
                    Visible = false;
                    ToolTip = 'Specifies the Period Calculation, which controls how a period is determined for billing. The calculation of a month from 28.02. can extend to 27.03. (Align to Start of Month) or 30.03. (Align to End of Month).';
                }
                field("Price Binding Period"; Rec."Price Binding Period")
                {
                    Style = Strong;
                    StyleExpr = Bold;
                    Visible = false;
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

    trigger OnOpenPage()
    begin
        if ItemNo <> '' then
            SetDefaultFilters();
    end;

    trigger OnAfterGetRecord()
    begin
        Bold := (ItemNo <> '') and (PackageCode <> '') and (Rec."Subscription Package Code" = PackageCode);
        PricingUnitCostSurchargeEditable := Rec."Usage Based Pricing" = Enum::"Usage Based Pricing"::"Unit Cost Surcharge";
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Bold := false;
        ServiceContractSetup.Get();
        Rec."Period Calculation" := ServiceContractSetup."Default Period Calculation";
        Rec."Billing Base Period" := ServiceContractSetup."Default Billing Base Period";
        Rec."Billing Rhythm" := ServiceContractSetup."Default Billing Rhythm";
        Rec."Create Contract Deferrals" := ServiceContractSetup."Create Contract Deferrals";
    end;

    var
        ServiceContractSetup: Record "Subscription Contract Setup";
        ShowAllPackageLines: Boolean;
        PricingUnitCostSurchargeEditable: Boolean;
        ItemNo: Code[20];
        PackageCode: Code[20];

    protected var

        Bold: Boolean;

    internal procedure SetItemNo(NewItemNo: Code[20])
    begin
        ItemNo := NewItemNo;
    end;

    internal procedure SetShowAllPackageLines(NewShowAllPackageLines: Boolean)
    begin
        ShowAllPackageLines := NewShowAllPackageLines;
    end;

    internal procedure SetPackageCode(NewPackageCode: Code[20])
    begin
        PackageCode := NewPackageCode;
        SetDefaultFilters();
    end;

    local procedure SetDefaultFilters()
    var
        ItemServCommitmentPackage: Record "Item Subscription Package";
        PackageFilter: Text;
    begin
        if ShowAllPackageLines then begin
            PackageFilter := ItemServCommitmentPackage.GetPackageFilterForItem(ItemNo);
            if PackageFilter = '' then
                Rec.SetRange("Subscription Package Code", '')
            else
                Rec.SetFilter("Subscription Package Code", PackageFilter);
        end else
            Rec.SetRange("Subscription Package Code", PackageCode);
        CurrPage.Update(false);
    end;
}