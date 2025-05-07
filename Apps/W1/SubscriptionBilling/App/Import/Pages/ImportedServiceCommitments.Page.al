namespace Microsoft.SubscriptionBilling;

page 8009 "Imported Service Commitments"
{
    PageType = Worksheet;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Imported Subscription Line";
    Caption = 'Imported Subscription Lines';

    layout
    {
        area(Content)
        {
            repeater(ImportedServiceCommitments)
            {
                field("Service Object No."; Rec."Subscription Header No.")
                {
                    ToolTip = 'Specifies the Subscription, the Subscription Line will be created for.';
                    ShowMandatory = true;
                }
                field("Service Object Line No."; Rec."Subscription Line Entry No.")
                {
                    ToolTip = 'Specifies the line number of the Subscription Line. If empty, a Line No. will be assigned automatically.';
                }
                field(Partner; Rec.Partner)
                {
                    ToolTip = 'Specifies whether the Subscription Line will will be calculated as a credit (Purchase Invoice) or as debit (Sales Invoice).';
                }
                field("Contract No."; Rec."Subscription Contract No.")
                {
                    ToolTip = 'Specifies the number of the contract in which Subscription Lines will be created as contract lines. Subscription Lines with Invoicing via = Sales cannot be called into a Contract.';
                }
                field("Contract Line No."; Rec."Subscription Contract Line No.")
                {
                    ToolTip = 'Specifies the Line No. of the contract line. If empty a Line No. will be assigned automatically.';
                }
                field("Contract Line Type"; Rec."Sub. Contract Line Type")
                {
                    ToolTip = 'Specifies the contract line type.';
                    ValuesAllowed = Comment, Item, "G/L Account";
                }
                field("Package Code"; Rec."Subscription Package Code")
                {
                    ToolTip = 'Specifies the code of the Subscription Package. If a Vendor Subscription Contract line has the same Subscription No. and Package Code as a Customer Subscription Contract line, the Customer Subscription Contract dimension value is copied to the Vendor Subscription Contract line.';
                }
                field("Template Code"; Rec."Template Code")
                {
                    ToolTip = 'Specifies the code of the Subscription Package Line Template.';
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the Subscription Line.';
                }
                field("Service Start Date"; Rec."Subscription Line Start Date")
                {
                    ToolTip = 'Specifies the date from which the Subscription Line is valid and will be invoiced.';
                    ShowMandatory = true;
                }
                field("Service End Date"; Rec."Subscription Line End Date")
                {
                    ToolTip = 'Specifies the date up to which the Subscription Line is valid.';
                }
                field("Next Billing Date"; Rec."Next Billing Date")
                {
                    ToolTip = 'Specifies the date of the next billing possible.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the number of units of Subscription.';
                }
                field("Calculation Base Amount"; Rec."Calculation Base Amount")
                {
                    ToolTip = 'Specifies the base amount from which the price will be calculated.';
                }
                field("Calculation Base %"; Rec."Calculation Base %")
                {
                    ToolTip = 'Specifies the percent at which the price of the Subscription Line will be calculated. 100% means that the price corresponds to the Base Price.';
                }
                field("Discount %"; Rec."Discount %")
                {
                    ToolTip = 'Specifies the percent of the discount for the Subscription Line.';
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
                    ShowMandatory = true;
                }
                field("Invoicing via"; Rec."Invoicing via")
                {
                    ToolTip = 'Specifies whether the Subscription Line is invoiced via a contract. Subscription Lines with invoicing via sales are not charged. Only the items are billed.';
                }
                field("Invoicing Item No."; Rec."Invoicing Item No.")
                {
                    ToolTip = 'Specifies which item will be used in contract invoice for invoicing of the periodic Subscription Line.';
                }
                field("Notice Period"; Rec."Notice Period")
                {
                    Visible = false;
                    Editable = false;
                    ToolTip = 'Specifies a date formula for the lead time that a notice must have before the Subscription Line ends. The rhythm of the update of "Notice possible to" and "Term Until" is determined using the extension term. For example, with an extension period of 1M, the notice period is repeatedly postponed by one month.';
                }
                field("Initial Term"; Rec."Initial Term")
                {
                    ToolTip = 'Specifies a date formula for calculating the minimum term of the Subscription Line. If the minimum term is filled and no extension term is entered, the end of Subscription Line is automatically set to the end of the initial term.';
                }
                field("Extension Term"; Rec."Extension Term")
                {
                    ToolTip = 'Specifies a date formula for automatic renewal after initial term and the rhythm of the update of "Notice possible to" and "Term Until". If the field is empty and the initial term or notice period is filled, the end of Subscription Line is automatically set to the end of the initial term or notice period.';
                }
                field("Billing Rhythm"; Rec."Billing Rhythm")
                {
                    ToolTip = 'Specifies the Date formula for Rhythm in which the Subscription Line is invoiced. Using a Dateformula rhythm can be, for example, a monthly, a quarterly or a yearly invoicing.';
                    ShowMandatory = true;
                }
                field("Discount Amount (LCY)"; Rec."Discount Amount (LCY)")
                {
                    ToolTip = 'Specifies the discount amount in client currency that is granted on the Subscription Line.';
                    Visible = false;
                }
                field("Service Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ToolTip = 'Specifies the amount in client currency for the Subscription Line including discount.';
                    Visible = false;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the currency of amounts in the Subscription Line.';
                    Visible = false;
                }
                field("Currency Factor"; Rec."Currency Factor")
                {
                    ToolTip = 'Specifies the currency factor valid for the Subscription Line, which is used to convert amounts to the client currency.';
                    Visible = false;
                }
                field("Currency Factor Date"; Rec."Currency Factor Date")
                {
                    ToolTip = 'Specifies the date when the currency factor was last updated.';
                    Visible = false;
                }
                field("Calculation Base Amount (LCY)"; Rec."Calculation Base Amount (LCY)")
                {
                    ToolTip = 'Specifies the basis on which the price is calculated in client currency.';
                    Visible = false;
                }
                field(UsageBasedBilling; Rec."Usage Based Billing")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether usage data is used as the basis for billing via contracts.';
                    Visible = false;
                }
                field(sageBasedPricing; Rec."Usage Based Pricing")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the method for customer based pricing.';
                    Visible = false;
                }
                field(PricingUnitCostSurcharPerc; Rec."Pricing Unit Cost Surcharge %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the surcharge in percent for the debit-side price calculation, if a EK surcharge is to be used.';
                    Visible = false;
                }
                field(SupplierReferenceEntryNo; Rec."Supplier Reference Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the sequence number of the related reference.';
                    Visible = false;
                }

                field("Service Commitment created"; Rec."Subscription Line created")
                {
                    ToolTip = 'Specifies whether the Subscription Line has been created.';
                }
                field("Contract Line created"; Rec."Sub. Contract Line created")
                {
                    ToolTip = 'Specifies whether a contract line has been created for the Subscription Line.';
                }
                field("Error Text"; Rec."Error Text")
                {
                    ToolTip = 'Specifies the error in processing the record.';
                }
                field("Processed by"; Rec."Processed by")
                {
                    ToolTip = 'Specifies who processed the record.';
                }
                field("Processed at"; Rec."Processed at")
                {
                    ToolTip = 'Specifies when the record was processed.';
                }
                field("Next Price Update"; Rec."Next Price Update")
                {
                    ToolTip = 'Specifies the date of the next price update.';
                    Editable = not Rec."Exclude from Price Update";
                    Visible = false;
                }
                field("Exclude from Price Update"; Rec."Exclude from Price Update")
                {
                    ToolTip = 'Specifies whether this line is considered in by the Contract Price Update. Setting it to yes will exclude the line from all price updates.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Create Contract Deferrals"; Rec."Create Contract Deferrals")
                {
                    ToolTip = 'Specifies whether this Subscription Line should generate contract deferrals. If it is set to No, no deferrals are generated and the invoices are posted directly to profit or loss.';
                }
            }
        }
    }

    actions
    {
        area(Promoted)
        {
            actionref(PromotedCreateServiceCommitments; CreateServiceCommitments)
            {
            }
        }
        area(Processing)
        {
            action(CreateServiceCommitments)
            {
                ApplicationArea = All;
                Caption = 'Create Subscription Lines';
                ToolTip = 'Creates Subscription Lines and Contract lines.';
                Image = CreateBinContent;

                trigger OnAction()
                begin
                    Report.Run(Report::"Cr. Serv. Comm. And Contr. L.", false, false);
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
