namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.Dimension;

page 8078 "Vendor Contract Line Subpage"
{

    PageType = ListPart;
    SourceTable = "Vendor Contract Line";
    Caption = 'Vendor Contract Lines';
    AutoSplitKey = true;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(ContractLines)
            {
                field("Service Start Date"; ServiceCommitment."Service Start Date")
                {
                    Caption = 'Service Start Date';
                    ToolTip = 'Specifies the date from which the service is valid and will be invoiced.';

                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Service Start Date"));
                    end;
                }
                field("Service End Date"; ServiceCommitment."Service End Date")
                {
                    Caption = 'Service End Date';
                    StyleExpr = NextBillingDateStyleExpr;
                    ToolTip = 'Specifies the date up to which the service is valid.';

                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Service End Date"));
                    end;
                }
                field("Planned Serv. Comm. exists"; Rec."Planned Serv. Comm. exists")
                {
                    ToolTip = 'Specifies if a planned Renewal exists for the service commitment.';
                }
                field("Service Object No."; Rec."Service Object No.")
                {
                    Visible = false;
                    ToolTip = 'Specifies the number of the service object no.';

                    trigger OnAssistEdit()
                    begin
                        Rec.OpenServiceObjectCard();
                    end;
                }
                field("Service Object Serial No."; ServiceObject."Serial No.")
                {
                    Caption = 'Serial No.';
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the Serial No. assigned to the service object.';
                }
                field("Service Object Description"; Rec."Service Object Description")
                {
                    ToolTip = 'Specifies a description of the service object.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;

                    trigger OnAssistEdit()
                    begin
                        Rec.OpenServiceObjectCard();
                    end;
                }
                field(ServiceObjectPrimaryAttribute; ServiceObject.GetPrimaryAttributeValue())
                {
                    Caption = 'Primary Attribute';
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Displays the primary attribute of the related Service Object.';
                }
                field("Service Commitment Description"; Rec."Service Commitment Description")
                {
                    ToolTip = 'Specifies the description of the service.';
                }
                field("Service Object Customer Reference"; ServiceObject."Customer Reference")
                {
                    Caption = 'Customer Reference';
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the reference by which the customer identifies the service object.';
                }
                field("Service Object Quantity"; Rec."Service Obj. Quantity Decimal")
                {
                    ToolTip = 'Number of units of service object.';

                    trigger OnDrillDown()
                    begin
                        Rec.OpenServiceObjectCard();
                    end;
                }
                field(Price; ServiceCommitment.Price)
                {
                    Caption = 'Price';
                    ToolTip = 'Specifies the price of the service with quantity of 1 in the billing period. The price is calculated from Base Price and Base Price %.';
                    Editable = false;
                    BlankZero = true;
                }
                field("Discount %"; ServiceCommitment."Discount %")
                {
                    Caption = 'Discount %';
                    ToolTip = 'Specifies the percent of the discount for the service.';
                    BlankZero = true;
                    MinValue = 0;
                    MaxValue = 100;
                    Editable = not IsDiscountLine;
                    Enabled = not IsDiscountLine;

                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Discount %"));
                    end;
                }
                field("Discount Amount"; ServiceCommitment."Discount Amount")
                {
                    Caption = 'Discount Amount';
                    ToolTip = 'Specifies the amount of the discount for the service.';
                    BlankZero = true;
                    MinValue = 0;
                    Editable = not IsDiscountLine;
                    Enabled = not IsDiscountLine;

                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Discount Amount"));
                    end;
                }
                field("Service Amount"; ServiceCommitment."Service Amount")
                {
                    Caption = 'Service Amount';
                    ToolTip = 'Specifies the amount for the service including discount.';
                    BlankZero = true;

                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Service Amount"));
                    end;
                }
                field("Price (LCY)"; ServiceCommitment."Price (LCY)")
                {
                    Caption = 'Price (LCY)';
                    ToolTip = 'Specifies the price of the service in client currency related to quantity of 1 in the billing period. The price is calculated from Base Price and Base Price %.';
                    Visible = false;
                    BlankZero = true;

                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Price (LCY)"));
                    end;
                }
                field("Discount Amount (LCY)"; ServiceCommitment."Discount Amount (LCY)")
                {
                    Caption = 'Discount Amount (LCY)';
                    ToolTip = 'Specifies the discount amount in client currency that is granted on the service.';
                    Visible = false;
                    BlankZero = true;
                    Editable = not IsDiscountLine;
                    Enabled = not IsDiscountLine;

                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Discount Amount (LCY)"));
                    end;
                }
                field("Service Amount (LCY)"; ServiceCommitment."Service Amount (LCY)")
                {
                    Caption = 'Service Amount (LCY)';
                    ToolTip = 'Specifies the amount in client currency for the service including discount.';
                    Visible = false;
                    BlankZero = true;

                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Service Amount (LCY)"));
                    end;
                }
                field("Currency Code"; ServiceCommitment."Currency Code")
                {
                    Caption = 'Currency Code';
                    ToolTip = 'Specifies the currency of amounts in the service.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Currency Code"));
                    end;
                }
                field("Currency Factor"; ServiceCommitment."Currency Factor")
                {
                    Caption = 'Currency Factor';
                    ToolTip = 'Specifies the currency factor valid for the service, which is used to convert amounts to the client currency.';
                    Visible = false;
                    BlankZero = true;

                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Currency Factor"));
                    end;
                }
                field("Currency Factor Date"; ServiceCommitment."Currency Factor Date")
                {
                    Caption = 'Currency Factor Date';
                    ToolTip = 'Specifies the date when the currency factor was last updated.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Currency Factor Date"));
                    end;
                }
                field("Next Billing Date"; ServiceCommitment."Next Billing Date")
                {
                    Caption = 'Next Billing Date';
                    ToolTip = 'Specifies the date of the next billing possible.';
                    Editable = false;
                    StyleExpr = NextBillingDateStyleExpr;
                }
                field("Calculation Base Amount"; ServiceCommitment."Calculation Base Amount")
                {
                    MinValue = 0;
                    Caption = 'Calculation Base Amount';
                    ToolTip = 'Specifies the base amount from which the price will be calculated.';
                    BlankZero = true;

                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Calculation Base Amount"));
                    end;
                }
                field("Calculation Base %"; ServiceCommitment."Calculation Base %")
                {
                    MinValue = 0;
                    Caption = 'Calculation Base %';
                    ToolTip = 'Specifies the percent at which the price of the service will be calculated. 100% means that the price corresponds to the Base Price.';
                    BlankZero = true;

                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Calculation Base %"));
                    end;
                }
                field("Billing Base Period"; ServiceCommitment."Billing Base Period")
                {
                    Caption = 'Billing Base Period';
                    ToolTip = 'Specifies for which period the Service Amount is valid. If you enter 1M here, a period of one month, or 12M, a period of 1 year, to which Service Amount refers to.';
                    Editable = false;
                }
                field("Cancellation Possible Until"; ServiceCommitment."Cancellation Possible Until")
                {
                    Caption = 'Cancellation Possible Until';
                    ToolTip = 'Specifies the last date for a timely termination. The date is determined by the initial term, extension term and a notice period. An initial term of 12 months and a 3-month notice period means that the deadline for a notice of termination is after 9 months. An extension period of 12 months postpones this date by 12 months.';
                    Editable = false;
                }
                field("Term Until"; ServiceCommitment."Term Until")
                {
                    Caption = 'Term Until';
                    ToolTip = 'Specifies the earliest regular date for the end of the service, taking into account the initial term, extension term and a notice period. An initial term of 24 months results in a fixed term of 2 years. An extension period of 12 months postpones this date by 12 months.';
                    Editable = false;
                }
                field("Initial Term"; ServiceCommitment."Initial Term")
                {
                    Caption = 'Initial Term';
                    ToolTip = 'Specifies a date formula for calculating the minimum term of the service commitment. If the minimum term is filled and no extension term is entered, the end of service commitment is automatically set to the end of the initial term.';
                    Editable = false;
                    Visible = false;
                }
                field("Extension Term"; ServiceCommitment."Extension Term")
                {
                    Caption = 'Subsequent Term';
                    ToolTip = 'Specifies a date formula for automatic renewal after initial term and the rhythm of the update of "Notice possible to" and "Term Until". If the field is empty and the initial term or notice period is filled, the end of service is automatically set to the end of the initial term or notice period.';
                    Editable = false;
                    Visible = false;
                }
                field("Billing Rhythm"; ServiceCommitment."Billing Rhythm")
                {
                    Caption = 'Billing Rhythm';
                    ToolTip = 'Specifies the Dateformula for rhythm in which the service is invoiced. Using a Dateformula rhythm can be, for example, a monthly, a quarterly or a yearly invoicing.';

                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Billing Rhythm"));
                    end;
                }
                field("Package Code"; ServiceCommitment."Package Code")
                {
                    Caption = 'Package Code';
                    ToolTip = 'Specifies the code of the service commitment package.';
                    Editable = false;
                    Visible = false;
                }
                field(Template; ServiceCommitment.Template)
                {
                    Caption = 'Template';
                    ToolTip = 'Specifies the code of the service commitment template.';
                    Editable = false;
                    Visible = false;
                }
                field("Contract Line Type"; Rec."Contract Line Type")
                {
                    ToolTip = 'Specifies the contract line type.';
                    Editable = false;
                    Visible = false;
                }
                field(Discount; ServiceCommitment.Discount)
                {
                    Editable = false;
                    ToolTip = 'Specifies whether the Service Commitment is used as a basis for periodic invoicing or discounts.';
                }
                field("Next Price Update"; ServiceCommitment."Next Price Update")
                {
                    ToolTip = 'Specifies the date of the next price update.';
                }
                field("Exclude from Price Update"; ServiceCommitment."Exclude from Price Update")
                {
                    Visible = false;
                    ToolTip = 'Specifies whether this line is considered in by the Contract Price Update. Setting it to yes will exclude the line from all price updates.';
                }
                field("Period Calculation"; ServiceCommitment."Period Calculation")
                {
                    Visible = false;
                    ToolTip = 'The Period Calculation controls how a period is determined for billing. The calculation of a month from 28.02. can extend to 27.03. (Align to Start of Month) or 30.03. (Align to End of Month).';

                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Period Calculation"));
                    end;
                }
                field("Price Binding Period"; ServiceCommitment."Price Binding Period")
                {
                    Editable = false;
                    ToolTip = 'Specifies the period the price will not be changed after the price update. It sets a new "Next Price Update" in the contract line after the price update has been performed.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            group(ContractLine)
            {
                Caption = 'Contract Line';
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
                        UpdateServiceCommitmentDimension();
                    end;
                }
                action(ShowBillingLines)
                {
                    Caption = 'Billing Lines';
                    Image = AllLines;
                    ToolTip = 'Show Billing Lines.';
                    Scope = Repeater;

                    trigger OnAction()
                    begin
                        ContractsGeneralMgt.ShowBillingLines(Rec."Contract No.", Rec."Line No.", Enum::"Service Partner"::Vendor);
                    end;
                }
                action(ShowArchivedBillingLines)
                {
                    Caption = 'Archived Billing Lines';
                    Image = ViewDocumentLine;
                    ToolTip = 'Show archived Billing Lines.';
                    Scope = Repeater;

                    trigger OnAction()
                    begin
                        ContractsGeneralMgt.ShowArchivedBillingLinesForServiceCommitment(Rec."Service Commitment Entry No.");
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
                        UsageDataBilling.SetRange(Partner, "Service Partner"::Vendor);
                        UsageDataBilling.SetRange("Contract No.", Rec."Contract No.");
                        UsageDataBilling.SetRange("Contract Line No.", Rec."Line No.");
                        Page.RunModal(Page::"Usage Data Billings", UsageDataBilling);
                    end;
                }
            }
            action(MergeContractLines)
            {
                Image = Copy;
                Caption = 'Merge Contract Lines';
                ToolTip = 'The function merges the selected contract lines if the dimensions as well as the date of next calculation are the same and the subjects and services are similar.';

                trigger OnAction()
                var
                    VendorContractLine: Record "Vendor Contract Line";
                begin
                    CurrPage.SetSelectionFilter(VendorContractLine);
                    Rec.MergeContractLines(VendorContractLine);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        InitializePageVariables();
        SetNextBillingDateStyle();
        Rec.LoadAmountsForContractLine(ServiceCommitment.Price, ServiceCommitment."Discount %", ServiceCommitment."Discount Amount", ServiceCommitment."Service Amount");
    end;

    trigger OnAfterGetCurrRecord()
    begin
        IsDiscountLine := ServiceCommitment.Discount;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(ServiceCommitment);
        Clear(ServiceObject);
    end;

    var
        ServiceCommitment: Record "Service Commitment";
        ServiceObject: Record "Service Object";
        ContractsGeneralMgt: Codeunit "Contracts General Mgt.";
        NextBillingDateStyleExpr: Text;
        IsDiscountLine: Boolean;

    local procedure InitializePageVariables()
    var
    begin
        Rec.GetServiceCommitment(ServiceCommitment);
        Rec.GetServiceObject(ServiceObject);
    end;

    local procedure UpdateServiceCommitmentOnPage(CalledByFieldNo: Integer)
    begin
        ServiceCommitment.UpdateServiceCommitment(CalledByFieldNo);
        CurrPage.Update();
    end;

    local procedure SetNextBillingDateStyle()
    begin
        if (Today() > ServiceCommitment."Service End Date") and (ServiceCommitment."Next Billing Date" > ServiceCommitment."Service End Date") and (ServiceCommitment."Service End Date" <> 0D) then
            NextBillingDateStyleExpr := 'Ambiguous'
        else
            NextBillingDateStyleExpr := 'None';
    end;

    local procedure UpdateServiceCommitmentDimension()
    begin
        ServiceCommitment.EditDimensionSet();
        CurrPage.Update();
    end;
}