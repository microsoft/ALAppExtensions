namespace Microsoft.SubscriptionBilling;

page 8009 "Imported Service Commitments"
{
    PageType = Worksheet;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Imported Service Commitment";
    Caption = 'Imported Service Commitments';

    layout
    {
        area(Content)
        {
            repeater(ImportedServiceCommitments)
            {
                field("Service Object No."; Rec."Service Object No.")
                {
                    ToolTip = 'Specifies the Service Object, the Service Commitment will be created for.';
                    ShowMandatory = true;
                }
                field("Service Object Line No."; Rec."Service Commitment Entry No.")
                {
                    ToolTip = 'Specifies the line number of the Service Commitment. If empty, a Line No. will be assigned automatically.';
                }
                field(Partner; Rec.Partner)
                {
                    ToolTip = 'Specifies whether the service will will be calculated as a credit (Purchase Invoice) or as debit (Sales Invoice).';
                }
                field("Contract No."; Rec."Contract No.")
                {
                    ToolTip = 'Specifies the number of the contract in which service commitments will be created as contract lines. Service commitments with Invoicing via = Sales cannot be called into a Contract.';
                }
                field("Contract Line No."; Rec."Contract Line No.")
                {
                    ToolTip = 'Specifies the Line No. of the contract line. If empty a Line No. will be assigned automatically.';
                }
                field("Contract Line Type"; Rec."Contract Line Type")
                {
                    ToolTip = 'Specifies the contract line type.';
                }
                field("Package Code"; Rec."Package Code")
                {
                    ToolTip = 'Specifies the code of the service commitment package. If a vendor contract line has the same Service Object No. and Package Code as a customer contract line, the customer contract dimension value is copied to the vendor contract line.';
                }
                field("Template Code"; Rec."Template Code")
                {
                    ToolTip = 'Specifies the code of the service commitment template.';
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the service.';
                }
                field("Service Start Date"; Rec."Service Start Date")
                {
                    ToolTip = 'Specifies the date from which the service is valid and will be invoiced.';
                    ShowMandatory = true;
                }
                field("Service End Date"; Rec."Service End Date")
                {
                    ToolTip = 'Specifies the date up to which the service is valid.';
                }
                field("Next Billing Date"; Rec."Next Billing Date")
                {
                    ToolTip = 'Specifies the date of the next billing possible.';
                }
                field(Quantity; Rec."Quantity Decimal")
                {
                    ToolTip = 'Number of units of service object.';
                }
                field("Calculation Base Amount"; Rec."Calculation Base Amount")
                {
                    ToolTip = 'Specifies the base amount from which the price will be calculated.';
                }
                field("Calculation Base %"; Rec."Calculation Base %")
                {
                    ToolTip = 'Specifies the percent at which the price of the service will be calculated. 100% means that the price corresponds to the Base Price.';
                }
                field("Discount %"; Rec."Discount %")
                {
                    ToolTip = 'Specifies the percent of the discount for the service.';
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ToolTip = 'Specifies the amount of the discount for the service.';
                }
                field("Service Amount"; Rec."Service Amount")
                {
                    ToolTip = 'Specifies the amount for the service including discount.';
                }
                field("Billing Base Period"; Rec."Billing Base Period")
                {
                    ToolTip = 'Specifies for which period the Service Amount is valid. If you enter 1M here, a period of one month, or 12M, a period of 1 year, to which Service Amount refers to.';
                    ShowMandatory = true;
                }
                field("Invoicing via"; Rec."Invoicing via")
                {
                    ToolTip = 'Specifies whether the service commitment is invoiced via a contract. Service commitments with invoicing via sales are not charged. Only the items are billed.';
                }
                field("Invoicing Item No."; Rec."Invoicing Item No.")
                {
                    ToolTip = 'Specifies which item will be used in contract invoice for invoicing of the periodic service commmitment.';
                }
                field("Notice Period"; Rec."Notice Period")
                {
                    Visible = false;
                    Editable = false;
                    ToolTip = 'Specifies a date formula for the lead time that a notice must have before the service commitment ends. The rhythm of the update of "Notice possible to" and "Term Until" is determined using the extension term. For example, with an extension period of 1M, the notice period is repeatedly postponed by one month.';
                }
                field("Initial Term"; Rec."Initial Term")
                {
                    ToolTip = 'Specifies a date formula for calculating the minimum term of the service commitment. If the minimum term is filled and no extension term is entered, the end of service commitment is automatically set to the end of the initial term.';
                }
                field("Extension Term"; Rec."Extension Term")
                {
                    ToolTip = 'Specifies a date formula for automatic renewal after initial term and the rhythm of the update of "Notice possible to" and "Term Until". If the field is empty and the initial term or notice period is filled, the end of service is automatically set to the end of the initial term or notice period.';
                }
                field("Billing Rhythm"; Rec."Billing Rhythm")
                {
                    ToolTip = 'Specifies the Dateformula for hythm in which the service is invoiced. Using a Dateformula rhythm can be, for example, a monthly, a quarterly or a yearly invoicing.';
                    ShowMandatory = true;
                }
                field("Discount Amount (LCY)"; Rec."Discount Amount (LCY)")
                {
                    ToolTip = 'Specifies the discount amount in client currency that is granted on the service.';
                    Visible = false;
                }
                field("Service Amount (LCY)"; Rec."Service Amount (LCY)")
                {
                    ToolTip = 'Specifies the amount in client currency for the service including discount.';
                    Visible = false;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the currency of amounts in the service.';
                    Visible = false;
                }
                field("Currency Factor"; Rec."Currency Factor")
                {
                    ToolTip = 'Specifies the currency factor valid for the service, which is used to convert amounts to the client currency.';
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

                field("Service Commitment created"; Rec."Service Commitment created")
                {
                    ToolTip = 'Specifies whether the Service Commitment has been created.';
                }
                field("Contract Line created"; Rec."Contract Line created")
                {
                    ToolTip = 'Specifies whether a contract line has been created for the Service Commitment.';
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
                Caption = 'Create Service Commitments';
                ToolTip = 'Creates Service Commitments and Contract lines.';
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
