namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.Dimension;

page 8064 "Service Commitments"
{
    Caption = 'Service Commitments';
    PageType = ListPart;
    SourceTable = "Service Commitment";
    AutoSplitKey = true;
    InsertAllowed = false;
    DeleteAllowed = true;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Package Code"; Rec."Package Code")
                {
                    Visible = false;
                    ToolTip = 'Specifies the code of the service commitment package. If a vendor contract line has the same Service Object No. and Package Code as a customer contract line, the customer contract dimension value is copied to the vendor contract line.';
                }
                field(Template; Rec.Template)
                {
                    Visible = false;
                    ToolTip = 'Specifies the code of the service commitment template.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the service.';
                }
                field("Service Start Date"; Rec."Service Start Date")
                {
                    ToolTip = 'Specifies the date from which the service is valid and will be invoiced.';
                    trigger OnValidate()
                    begin
                        Rec.UpdateServiceCommitment(Rec.FieldNo("Service Start Date"));
                        CurrPage.Update();
                    end;
                }
                field("Service End Date"; Rec."Service End Date")
                {
                    ToolTip = 'Specifies the date up to which the service is valid.';
                }
                field("Planned Serv. Comm. exists"; Rec."Planned Serv. Comm. exists")
                {
                    ToolTip = 'Specifies if a planned Renewal exists for the service commitment.';
                }
                field("Next Billing Date"; Rec."Next Billing Date")
                {
                    ToolTip = 'Specifies the date of the next billing possible.';
                }
                field("Calculation Base Amount"; Rec."Calculation Base Amount")
                {
                    ToolTip = 'Specifies the base amount from which the price will be calculated.';
                    trigger OnValidate()
                    begin
                        Rec.UpdateServiceCommitment(Rec.FieldNo("Calculation Base Amount"));
                        CurrPage.Update();
                    end;
                }
                field("Calculation Base %"; Rec."Calculation Base %")
                {
                    ToolTip = 'Specifies the percent at which the price of the service will be calculated. 100% means that the price corresponds to the Base Price.';
                    trigger OnValidate()
                    begin
                        Rec.UpdateServiceCommitment(Rec.FieldNo("Calculation Base %"));
                        CurrPage.Update();
                    end;
                }
                field(Price; Rec.Price)
                {
                    ToolTip = 'Specifies the price of the service with quantity of 1 in the billing period. The price is calculated from Base Price and Base Price %.';
                    trigger OnValidate()
                    begin
                        Rec.UpdateServiceCommitment(Rec.FieldNo(Price));
                        CurrPage.Update();
                    end;
                }
                field("Discount %"; Rec."Discount %")
                {
                    ToolTip = 'Specifies the percent of the discount for the service.';
                    trigger OnValidate()
                    begin
                        Rec.UpdateServiceCommitment(Rec.FieldNo("Discount %"));
                        CurrPage.Update();
                    end;
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ToolTip = 'Specifies the amount of the discount for the service.';
                    trigger OnValidate()
                    begin
                        Rec.UpdateServiceCommitment(Rec.FieldNo("Discount Amount"));
                        CurrPage.Update();
                    end;
                }
                field("Service Amount"; Rec."Service Amount")
                {
                    ToolTip = 'Specifies the amount for the service including discount.';
                    trigger OnValidate()
                    begin
                        Rec.UpdateServiceCommitment(Rec.FieldNo("Service Amount"));
                        CurrPage.Update();
                    end;
                }
                field("Calculation Base Amount (LCY)"; Rec."Calculation Base Amount (LCY)")
                {
                    ToolTip = 'Specifies the basis on which the price is calculated in client currency.';
                    Visible = false;
                }
                field("Price (LCY)"; Rec."Price (LCY)")
                {
                    ToolTip = 'Specifies the price of the service in client currency related to quantity of 1 in the billing period. The price is calculated from Base Price and Base Price %.';
                    Visible = false;
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
                field("Billing Base Period"; Rec."Billing Base Period")
                {
                    ToolTip = 'Specifies for which period the Service Amount is valid. If you enter 1M here, a period of one month, or 12M, a period of 1 year, to which Service Amount refers to.';
                    trigger OnValidate()
                    begin
                        Rec.UpdateServiceCommitment(Rec.FieldNo("Billing Base Period"));
                    end;
                }
                field("Billing Rhythm"; Rec."Billing Rhythm")
                {
                    ToolTip = 'Specifies the Dateformula for hythm in which the service is invoiced. Using a Dateformula rhythm can be, for example, a monthly, a quarterly or a yearly invoicing.';
                    trigger OnValidate()
                    begin
                        Rec.UpdateServiceCommitment(Rec.FieldNo("Billing Rhythm"));
                        CurrPage.Update();
                    end;
                }
                field("Invoicing via"; Rec."Invoicing via")
                {
                    ToolTip = 'Specifies whether the service commitment is invoiced via a contract. Service commitments with invoicing via sales are not charged. Only the items are billed.';
                }
                field(Partner; Rec.Partner)
                {
                    ToolTip = 'Specifies whether the service will will be calculated as a credit (Purchase Invoice) or as debit (Sales Invoice).';
                }
                field("Contract No."; Rec."Contract No.")
                {
                    ToolTip = 'Specifies in which contract the service will be calculated.';
                    Editable = false;

                    trigger OnAssistEdit()
                    begin
                        ContractsGeneralMgt.OpenContractCard(Rec.Partner, Rec."Contract No.");
                    end;
                }
                field("Initial Term"; Rec."Initial Term")
                {
                    ToolTip = 'Specifies a date formula for calculating the minimum term of the service commitment. If the minimum term is filled and no extension term is entered, the end of service commitment is automatically set to the end of the initial term.';
                }
                field("Extension Term"; Rec."Extension Term")
                {
                    ToolTip = 'Specifies a date formula for automatic renewal after initial term and the rhythm of the update of "Notice possible to" and "Term Until". If the field is empty and the initial term or notice period is filled, the end of service is automatically set to the end of the initial term or notice period.';
                }
                field("Renewal Term"; Rec."Renewal Term")
                {
                    ToolTip = 'Specifies a date formula by which the Contract Line is renewed and the end of the Contract Line is extended. It is automatically preset with the initial term of the service and can be changed manually.';
                    Visible = false;
                }
                field("Cancellation Possible Until"; Rec."Cancellation Possible Until")
                {
                    ToolTip = 'Specifies the last date for a timely termination. The date is determined by the initial term, extension term and a notice period. An initial term of 12 months and a 3-month notice period means that the deadline for a notice of termination is after 9 months. An extension period of 12 months postpones this date by 12 months.';
                }
                field("Term Until"; Rec."Term Until")
                {
                    ToolTip = 'Specifies the earliest regular date for the end of the service, taking into account the initial term, extension term and a notice period. An initial term of 24 months results in a fixed term of 2 years. An extension period of 12 months postpones this date by 12 months.';
                }
                field("Notice Period"; Rec."Notice Period")
                {
                    Visible = false;
                    Editable = false;
                    ToolTip = 'Specifies a date formula for the lead time that a notice must have before the service commitment ends. The rhythm of the update of "Notice possible to" and "Term Until" is determined using the extension term. For example, with an extension period of 1M, the notice period is repeatedly postponed by one month.';
                }
                field(Discount; Rec.Discount)
                {
                    Editable = false;
                    ToolTip = 'Specifies whether the Service Commitment is used as a basis for periodic invoicing or discounts.';
                }
                field("Next Price Update"; Rec."Next Price Update")
                {
                    Visible = false;
                    Editable = not Rec."Exclude from Price Update";
                    ToolTip = 'Specifies the date of the next price update.';
                }
                field("Exclude from Price Update"; Rec."Exclude from Price Update")
                {
                    Visible = false;
                    ToolTip = 'Specifies whether this line is considered in by the Contract Price Update. Setting it to yes will exclude the line from all price updates.';
                }
                field("Period Calculation"; Rec."Period Calculation")
                {
                    Visible = false;
                    ToolTip = 'The Period Calculation controls how a period is determined for billing. The calculation of a month from 28.02. can extend to 27.03. (Align to Start of Month) or 30.03. (Align to End of Month).';
                }
                field("Price Binding Period"; Rec."Price Binding Period")
                {
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
                field(SupplierReferenceEntryNo; Rec."Supplier Reference Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the sequence number of the related reference.';
                }

            }
        }
    }
    actions
    {
        area(Processing)
        {
            group(ServiceCommitments)
            {
                Caption = 'Service Commitments';
                Image = "Item";
                action(Dimensions)
                {
                    AccessByPermission = tabledata Dimension = R;
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    Scope = Repeater;
                    ShortcutKey = 'Shift+Ctrl+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        Rec.EditDimensionSet();
                    end;
                }
                action(DisconnectfromSubscription)
                {
                    ApplicationArea = All;
                    Caption = 'Disconnect from Subscription';
                    ToolTip = 'Disconnects the service from the subscription.';
                    Enabled = Rec."Supplier Reference Entry No." <> 0;
                    Image = DeleteQtyToHandle;

                    trigger OnAction()
                    var
                        UsageBasedBillingMgmt: Codeunit "Usage Based Billing Mgmt.";
                    begin
                        UsageBasedBillingMgmt.DisconnectServiceCommitmentFromSubscription(Rec);
                    end;
                }
                action("Usage Data")
                {
                    ApplicationArea = All;
                    Caption = 'Usage Data';
                    Image = DataEntry;
                    Scope = Repeater;
                    ToolTip = 'Shows the related usage data.';

                    trigger OnAction()
                    var
                        UsageDataBilling: Record "Usage Data Billing";
                    begin
                        UsageDataBilling.SetRange(Partner, Rec.Partner);
                        UsageDataBilling.SetRange("Service Object No.", Rec."Service Object No.");
                        UsageDataBilling.SetRange("Service Commitment Entry No.", Rec."Entry No.");
                        Page.RunModal(Page::"Usage Data Billings", UsageDataBilling);
                    end;
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Service Object Customer No.");
        PricingUnitCostSurchargeEditable := Rec."Usage Based Pricing" = Enum::"Usage Based Pricing"::"Unit Cost Surcharge";
    end;

    var
        ContractsGeneralMgt: Codeunit "Contracts General Mgt.";
        PricingUnitCostSurchargeEditable: Boolean;
}
