namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.Dimension;

page 8068 "Customer Contract Line Subp."
{
    PageType = ListPart;
    SourceTable = "Cust. Sub. Contract Line";
    Caption = 'Lines';
    AutoSplitKey = true;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(ContractLines)
            {
                field("Contract Line Type"; Rec."Contract Line Type")
                {
                    ToolTip = 'Specifies the contract line type.';
                    ValuesAllowed = Comment, Item, "G/L Account";

                    trigger OnValidate()
                    begin
                        UpdateEditableOnRow();
                        CurrPage.Update();
                    end;
                }
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the No. of the Item or G/L Account of the Subscription.';
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Invoicing Item No."; ServiceCommitment."Invoicing Item No.")
                {
                    ToolTip = 'Specifies the value of the Invoicing Item No. field.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Invoicing Item No."));
                    end;
                }
                field("Service Start Date"; ServiceCommitment."Subscription Line Start Date")
                {
                    Caption = 'Subscription Line Start Date';
                    ToolTip = 'Specifies the date from which the Subscription Line is valid and will be invoiced.';
                    Editable = not IsCommentLineEditable;
                    Enabled = not IsCommentLineEditable;

                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Subscription Line Start Date"));
                    end;
                }
                field("Next Billing Date"; ServiceCommitment."Next Billing Date")
                {
                    Caption = 'Next Billing Date';
                    ToolTip = 'Specifies the date of the next billing possible.';
                    Editable = false;
                    StyleExpr = NextBillingDateStyleExpr;
                }
                field("Service Object No."; Rec."Subscription Header No.")
                {
                    Visible = false;
                    ToolTip = 'Specifies the number of the Subscription.';
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;

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
                    ToolTip = 'Specifies the Serial No. assigned to the Subscription.';
                }
                field("Service Object Description"; Rec."Subscription Description")
                {
                    ToolTip = 'Specifies a description of the Subscription.';

                    trigger OnValidate()
                    begin
                        if not Rec.IsCommentLine() then
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
                    ToolTip = 'Displays the primary attribute of the related Subscription.';
                }
                field("Service Object Customer Reference"; ServiceObject."Customer Reference")
                {
                    Caption = 'Customer Reference';
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the reference by which the customer identifies the Subscription.';
                }
                field("Service Commitment Description"; Rec."Subscription Line Description")
                {
                    ToolTip = 'Specifies the description of the Subscription Line.';
                }
                field("Service Object Quantity"; ServiceCommitment.Quantity)
                {
                    Caption = 'Quantity';
                    ToolTip = 'Specifies the number of units of Subscription.';

                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo(Quantity));
                    end;
                }
                field("Calculation Base Amount"; ServiceCommitment."Calculation Base Amount")
                {
                    MinValue = 0;
                    Caption = 'Calculation Base Amount';
                    ToolTip = 'Specifies the base amount from which the price will be calculated.';
                    BlankZero = true;
                    Editable = not IsCommentLineEditable;
                    Enabled = not IsCommentLineEditable;

                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Calculation Base Amount"));
                    end;
                }
                field("Calculation Base %"; ServiceCommitment."Calculation Base %")
                {
                    MinValue = 0;
                    Caption = 'Calculation Base %';
                    ToolTip = 'Specifies the percent at which the price of the Subscription Line will be calculated. 100% means that the price corresponds to the Base Price.';
                    BlankZero = true;
                    Editable = not IsCommentLineEditable;
                    Enabled = not IsCommentLineEditable;

                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Calculation Base %"));
                    end;
                }
                field("Unit Cost (LCY)"; ServiceCommitment."Unit Cost (LCY)")
                {
                    ToolTip = 'Specifies the unit cost of the item.';
                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Unit Cost (LCY)"));
                    end;
                }
                field(Price; ServiceCommitment.Price)
                {
                    Caption = 'Price';
                    ToolTip = 'Specifies the price of the Subscription Line with quantity of 1 in the billing period. The price is calculated from Base Price and Base Price %.';
                    Editable = false;
                    BlankZero = true;
                }
                field("Price (LCY)"; ServiceCommitment."Price (LCY)")
                {
                    Caption = 'Price (LCY)';
                    ToolTip = 'Specifies the price of the Subscription Line in client currency related to quantity of 1 in the billing period. The price is calculated from Base Price and Base Price %.';
                    Visible = false;
                    BlankZero = true;
                    Editable = not IsCommentLineEditable;
                    Enabled = not IsCommentLineEditable;

                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Price (LCY)"));
                    end;
                }
                field("Discount %"; ServiceCommitment."Discount %")
                {
                    Caption = 'Discount %';
                    ToolTip = 'Specifies the percent of the discount for the Subscription Line.';
                    BlankZero = true;
                    MinValue = 0;
                    MaxValue = 100;
                    Editable = (not IsCommentLineEditable) and (not IsDiscountLine);
                    Enabled = (not IsCommentLineEditable) and (not IsDiscountLine);

                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Discount %"));
                    end;
                }
                field("Discount Amount"; ServiceCommitment."Discount Amount")
                {
                    Caption = 'Discount Amount';
                    ToolTip = 'Specifies the amount of the discount for the Subscription Line.';
                    BlankZero = true;
                    MinValue = 0;
                    Editable = (not IsCommentLineEditable) and (not IsDiscountLine);
                    Enabled = (not IsCommentLineEditable) and (not IsDiscountLine);

                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Discount Amount"));
                    end;
                }
                field("Discount Amount (LCY)"; ServiceCommitment."Discount Amount (LCY)")
                {
                    Caption = 'Discount Amount (LCY)';
                    ToolTip = 'Specifies the discount amount in client currency that is granted on the Subscription Line.';
                    Visible = false;
                    BlankZero = true;
                    Editable = (not IsCommentLineEditable) and (not IsDiscountLine);
                    Enabled = (not IsCommentLineEditable) and (not IsDiscountLine);
                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Discount Amount (LCY)"));
                    end;
                }
                field("Service Amount"; ServiceCommitment.Amount)
                {
                    Caption = 'Amount';
                    ToolTip = 'Specifies the amount for the Subscription Line including discount.';
                    BlankZero = true;
                    Editable = not IsCommentLineEditable;
                    Enabled = not IsCommentLineEditable;

                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo(Amount));
                    end;
                }
                field("Service Amount (LCY)"; ServiceCommitment."Amount (LCY)")
                {
                    Caption = 'Amount (LCY)';
                    ToolTip = 'Specifies the amount in client currency for the Subscription Line including discount.';
                    Visible = false;
                    BlankZero = true;
                    Editable = not IsCommentLineEditable;
                    Enabled = not IsCommentLineEditable;

                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Amount (LCY)"));
                    end;
                }
                field("Billing Base Period"; ServiceCommitment."Billing Base Period")
                {
                    Caption = 'Billing Base Period';
                    ToolTip = 'Specifies for which period the Amount is valid. If you enter 1M here, a period of one month, or 12M, a period of 1 year, to which Amount refers to.';

                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Billing Base Period"));
                    end;
                }
                field("Billing Rhythm"; ServiceCommitment."Billing Rhythm")
                {
                    Caption = 'Billing Rhythm';
                    ToolTip = 'Specifies the Dateformula for rhythm in which the Subscription Line is invoiced. Using a Dateformula rhythm can be, for example, a monthly, a quarterly or a yearly invoicing.';
                    Editable = not IsCommentLineEditable;
                    Enabled = not IsCommentLineEditable;

                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Billing Rhythm"));
                    end;
                }
                field("Service End Date"; ServiceCommitment."Subscription Line End Date")
                {
                    Caption = 'Subscription Line End Date';
                    StyleExpr = NextBillingDateStyleExpr;
                    ToolTip = 'Specifies the date up to which the Subscription Line is valid.';
                    Editable = not IsCommentLineEditable;
                    Enabled = not IsCommentLineEditable;

                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Subscription Line End Date"));
                    end;
                }
                field("Next Price Update"; ServiceCommitment."Next Price Update")
                {
                    ToolTip = 'Specifies the date of the next price update.';
                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Next Price Update"));
                    end;
                }
                field("Planned Serv. Comm. exists"; Rec."Planned Sub. Line exists")
                {
                    ToolTip = 'Specifies if a planned Renewal exists for the Subscription Line.';
                }
                field("Cancellation Possible Until"; ServiceCommitment."Cancellation Possible Until")
                {
                    Caption = 'Cancellation Possible Until';
                    ToolTip = 'Specifies the last date for a timely termination. The date is determined by the initial term, extension term and a notice period. An initial term of 12 months and a 3-month notice period means that the deadline for a notice of termination is after 9 months. An extension period of 12 months postpones this date by 12 months.';

                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Cancellation Possible Until"));
                    end;
                }
                field("Term Until"; ServiceCommitment."Term Until")
                {
                    Caption = 'Term Until';
                    ToolTip = 'Specifies the earliest regular date for the end of the Subscription Line, taking into account the initial term, extension term and a notice period. An initial term of 24 months results in a fixed term of 2 years. An extension period of 12 months postpones this date by 12 months.';

                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Term Until"));
                    end;
                }
                field("Notice Period"; ServiceCommitment."Notice Period")
                {
                    Caption = 'Notice Period';
                    ToolTip = 'Specifies a date formula for the lead time that a notice must have before the subscription line ends. The rhythm of the update of "Notice possible to" and "Term until" is determined using the extension term. For example, with an extension period of 1M, the notice period is repeatedly postponed by one month.';
                    Visible = false;
                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Notice Period"));
                    end;
                }
                field("Initial Term"; ServiceCommitment."Initial Term")
                {
                    Caption = 'Initial Term';
                    ToolTip = 'Specifies a date formula for calculating the minimum term of the Subscription Line. If the minimum term is filled and no extension term is entered, the end of Subscription Line is automatically set to the end of the initial term.';
                    Editable = false;
                    Visible = false;
                }
                field("Extension Term"; ServiceCommitment."Extension Term")
                {
                    Caption = 'Subsequent Term';
                    ToolTip = 'Specifies a date formula for automatic renewal after initial term and the rhythm of the update of "Notice possible to" and "Term Until". If the field is empty and the initial term or notice period is filled, the end of Subscription Line is automatically set to the end of the initial term or notice period.';
                    Editable = false;
                    Visible = false;
                }
                field("Exclude from Price Update"; ServiceCommitment."Exclude from Price Update")
                {
                    ToolTip = 'Specifies whether this line is considered in by the Contract Price Update. Setting it to yes will exclude the line from all price updates.';
                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Exclude from Price Update"));
                    end;
                }
                field("Package Code"; ServiceCommitment."Subscription Package Code")
                {
                    Caption = 'Package Code';
                    ToolTip = 'Specifies the code of the Subscription Package.';
                    Editable = false;
                    Visible = false;
                }
                field(Template; ServiceCommitment.Template)
                {
                    Caption = 'Template';
                    ToolTip = 'Specifies the code of the Subscription Package Line Template.';
                    Editable = false;
                    Visible = false;
                }
                field(Discount; ServiceCommitment.Discount)
                {
                    Editable = false;
                    ToolTip = 'Specifies whether the Subscription Line is used as a basis for periodic invoicing or discounts.';
                }
                field("Create Contract Deferrals"; ServiceCommitment."Create Contract Deferrals")
                {
                    ToolTip = 'Specifies whether this Subscription Line should generate contract deferrals. If it is set to No, no deferrals are generated and the invoices are posted directly to profit or loss.';
                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Create Contract Deferrals"));
                    end;
                }
                field("Price Binding Period"; ServiceCommitment."Price Binding Period")
                {
                    Visible = false;
                    ToolTip = 'Specifies the initial period, in which the price will not be changed by the price update function. The "Next Price Update" will be set based on the Subscription Line Start Date and Price Binding Period, for every new Subscription Line.';
                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Price Binding Period"));
                    end;
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
                field("Currency Code"; ServiceCommitment."Currency Code")
                {
                    Caption = 'Currency Code';
                    ToolTip = 'Specifies the currency of amounts in the Subscription Line.';
                    Visible = false;
                    Editable = not IsCommentLineEditable;
                    Enabled = not IsCommentLineEditable;

                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Currency Code"));
                    end;
                }
                field("Currency Factor"; ServiceCommitment."Currency Factor")
                {
                    Caption = 'Currency Factor';
                    ToolTip = 'Specifies the currency factor valid for the Subscription Line, which is used to convert amounts to the client currency.';
                    Visible = false;
                    BlankZero = true;
                    Editable = not IsCommentLineEditable;
                    Enabled = not IsCommentLineEditable;

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
                    Editable = not IsCommentLineEditable;
                    Enabled = not IsCommentLineEditable;

                    trigger OnValidate()
                    begin
                        UpdateServiceCommitmentOnPage(ServiceCommitment.FieldNo("Currency Factor Date"));
                    end;
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
                        ServiceCommitment.EditDimensionSet();
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
                        ContractsGeneralMgt.ShowBillingLines(Rec."Subscription Contract No.", Rec."Line No.", Enum::"Service Partner"::Customer);
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
                        ContractsGeneralMgt.ShowArchivedBillingLinesForServiceCommitment(Rec."Subscription Line Entry No.");
                    end;
                }
                action("Usage Data")
                {
                    ApplicationArea = All;
                    Caption = 'Usage Data';
                    Image = DataEntry;
                    Scope = Repeater;
                    ToolTip = 'Shows the related usage data.';
                    Enabled = UsageDataEnabled;

                    trigger OnAction()
                    var
                        UsageDataBilling: Record "Usage Data Billing";
                    begin
                        UsageDataBilling.ShowForContractLine("Service Partner"::Customer, Rec."Subscription Contract No.", Rec."Line No.");
                    end;
                }
                action(UsageDataBillingMetadata)
                {
                    ApplicationArea = All;
                    Caption = 'Usage Data Metadata';
                    Image = DataEntry;
                    Scope = Repeater;
                    ToolTip = 'Shows the metadata related to the Subscription Line.';
                    Enabled = UsageDataEnabled;

                    trigger OnAction()
                    begin
                        ServiceCommitment.ShowUsageDataBillingMetadata();
                    end;
                }
            }
            action(MergeContractLines)
            {
                Image = Copy;
                Caption = 'Merge Contract Lines';
                ToolTip = 'The function merges the selected contract lines if the dimensions as well as the date of next calculation are the same and the subjects and Subscription Lines are similar.';

                trigger OnAction()
                var
                    CustomerContractLine: Record "Cust. Sub. Contract Line";
                begin
                    CurrPage.SetSelectionFilter(CustomerContractLine);
                    Rec.MergeContractLines(CustomerContractLine);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        InitializePageVariables();
        SetNextBillingDateStyle();
        Rec.LoadServiceCommitmentForContractLine(ServiceCommitment);
    end;

    trigger OnAfterGetCurrRecord()
    var
        UsageDataBilling: Record "Usage Data Billing";
    begin
        UpdateEditableOnRow();
        UsageDataEnabled := UsageDataBilling.ExistForContractLine("Service Partner"::Customer, Rec."Subscription Contract No.", Rec."Line No.");
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(ServiceCommitment);
        Clear(ServiceObject);
    end;

    var
        ContractsGeneralMgt: Codeunit "Sub. Contracts General Mgt.";
        NextBillingDateStyleExpr: Text;
        IsDiscountLine: Boolean;
        IsCommentLineEditable: Boolean;
        UsageDataEnabled: Boolean;

    protected var
        ServiceObject: Record "Subscription Header";
        ServiceCommitment: Record "Subscription Line";

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
        if (Today() > ServiceCommitment."Subscription Line End Date") and (ServiceCommitment."Next Billing Date" > ServiceCommitment."Subscription Line End Date") and (ServiceCommitment."Subscription Line End Date" <> 0D) then
            NextBillingDateStyleExpr := 'Ambiguous';
        OnAfterSetNextBillingDateStyle(Rec, ServiceCommitment, NextBillingDateStyleExpr);
    end;

    local procedure UpdateEditableOnRow()
    begin
        IsCommentLineEditable := Rec.IsCommentLine();
        IsDiscountLine := ServiceCommitment.Discount;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetNextBillingDateStyle(CustSubContractLine: Record "Cust. Sub. Contract Line"; SubscriptionLine: Record "Subscription Line"; var NextBillingDateStyleExpr: Text)
    begin
    end;
}