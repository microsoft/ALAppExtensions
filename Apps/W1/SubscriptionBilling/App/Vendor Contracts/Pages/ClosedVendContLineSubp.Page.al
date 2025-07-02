namespace Microsoft.SubscriptionBilling;

page 8089 "Closed Vend. Cont. Line Subp."
{

    PageType = ListPart;
    SourceTable = "Vend. Sub. Contract Line";
    Caption = 'Closed Lines';
    AutoSplitKey = true;
    InsertAllowed = false;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(ContractLines)
            {
                field(Closed; Rec.Closed)
                {
                    ToolTip = 'Specifies that the associated Subscription Line has ended.';
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Contract Line Type"; Rec."Contract Line Type")
                {
                    ToolTip = 'Specifies the contract line type.';
                    Editable = false;
                }
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the No. of the Item or G/L Account of the Subscription.';
                    Editable = false;
                }
                field("Invoicing Item No."; ServiceCommitment."Invoicing Item No.")
                {
                    ToolTip = 'Specifies the value of the Invoicing Item No. field.';
                    Editable = false;
                    Visible = false;
                }
                field("Service Start Date"; ServiceCommitment."Subscription Line Start Date")
                {
                    Caption = 'Subscription Line Start Date';
                    ToolTip = 'Specifies the date from which the Subscription Line is valid and will be invoiced.';
                    Editable = false;
                }
                field("Next Billing Date"; ServiceCommitment."Next Billing Date")
                {
                    Caption = 'Next Billing Date';
                    ToolTip = 'Specifies the date of the next billing possible.';
                    Editable = false;
                }
                field("Service Object No."; Rec."Subscription Header No.")
                {
                    Visible = false;
                    ToolTip = 'Specifies the number of the Subscription.';
                    Editable = false;
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
                    Editable = false;
                    trigger OnAssistEdit()
                    begin
                        Rec.OpenServiceObjectCard();
                    end;
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
                    Editable = false;
                }
                field("Service Object Quantity"; Rec."Service Object Quantity")
                {
                    Editable = false;
                    ToolTip = 'Specifies the number of units of Subscription.';

                    trigger OnDrillDown()
                    begin
                        Rec.OpenServiceObjectCard();
                    end;
                }
                field("Calculation Base Amount"; ServiceCommitment."Calculation Base Amount")
                {
                    MinValue = 0;
                    Caption = 'Calculation Base Amount';
                    ToolTip = 'Specifies the base amount from which the price will be calculated.';
                    BlankZero = true;
                    Editable = false;
                }
                field("Calculation Base %"; ServiceCommitment."Calculation Base %")
                {
                    MinValue = 0;
                    Caption = 'Calculation Base %';
                    ToolTip = 'Specifies the percent at which the price of the Subscription Line will be calculated. 100% means that the price corresponds to the Base Price.';
                    BlankZero = true;
                    Editable = false;
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
                    Editable = false;
                }
                field("Discount %"; ServiceCommitment."Discount %")
                {
                    Caption = 'Discount %';
                    ToolTip = 'Specifies the percent of the discount for the Subscription Line.';
                    BlankZero = true;
                    MinValue = 0;
                    MaxValue = 100;
                    Editable = false;
                }
                field("Discount Amount"; ServiceCommitment."Discount Amount")
                {
                    Caption = 'Discount Amount';
                    ToolTip = 'Specifies the amount of the discount for the Subscription Line.';
                    BlankZero = true;
                    MinValue = 0;
                    Editable = false;
                }
                field("Discount Amount (LCY)"; ServiceCommitment."Discount Amount (LCY)")
                {
                    Caption = 'Discount Amount (LCY)';
                    ToolTip = 'Specifies the discount amount in client currency that is granted on the Subscription Line.';
                    Visible = false;
                    BlankZero = true;
                    Editable = false;
                }
                field("Service Amount"; ServiceCommitment.Amount)
                {
                    Caption = 'Amount';
                    ToolTip = 'Specifies the amount for the Subscription Line including discount.';
                    BlankZero = true;
                    Editable = false;
                }
                field("Service Amount (LCY)"; ServiceCommitment."Amount (LCY)")
                {
                    Caption = 'Amount (LCY)';
                    ToolTip = 'Specifies the amount in client currency for the Subscription Line including discount.';
                    Visible = false;
                    BlankZero = true;
                    Editable = false;
                }
                field("Billing Base Period"; ServiceCommitment."Billing Base Period")
                {
                    Caption = 'Billing Base Period';
                    ToolTip = 'Specifies for which period the Amount is valid. If you enter 1M here, a period of one month, or 12M, a period of 1 year, to which Amount refers to.';
                    Editable = false;
                }
                field("Billing Rhythm"; ServiceCommitment."Billing Rhythm")
                {
                    Caption = 'Billing Rhythm';
                    ToolTip = 'Specifies the Dateformula for rhythm in which the Subscription Line is invoiced. Using a Dateformula rhythm can be, for example, a monthly, a quarterly or a yearly invoicing.';
                    Editable = false;
                }
                field("Service End Date"; ServiceCommitment."Subscription Line End Date")
                {
                    Caption = 'Subscription Line End Date';
                    ToolTip = 'Specifies the date up to which the Subscription Line is valid.';
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
                    ToolTip = 'Specifies the earliest regular date for the end of the Subscription Line, taking into account the initial term, extension term and a notice period. An initial term of 24 months results in a fixed term of 2 years. An extension period of 12 months postpones this date by 12 months.';
                    Editable = false;
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
                    Visible = false;
                    Editable = false;
                    ToolTip = 'Specifies whether the Subscription Line is used as a basis for periodic invoicing or discounts.';
                }
                field("Create Contract Deferrals"; ServiceCommitment."Create Contract Deferrals")
                {
                    Editable = false;
                    ToolTip = 'Specifies whether this Subscription Line should generate contract deferrals. If it is set to No, no deferrals are generated and the invoices are posted directly to profit or loss.';
                }
                field("Period Calculation"; ServiceCommitment."Period Calculation")
                {
                    Visible = false;
                    Editable = false;
                    ToolTip = 'Specifies the Period Calculation, which controls how a period is determined for billing. The calculation of a month from 28.02. can extend to 27.03. (Align to Start of Month) or 30.03. (Align to End of Month).';
                }
                field("Currency Code"; ServiceCommitment."Currency Code")
                {
                    Caption = 'Currency Code';
                    ToolTip = 'Specifies the currency of amounts in the Subscription Line.';
                    Visible = false;
                    Editable = false;
                }
                field("Currency Factor"; ServiceCommitment."Currency Factor")
                {
                    Caption = 'Currency Factor';
                    ToolTip = 'Specifies the currency factor valid for the Subscription Line, which is used to convert amounts to the client currency.';
                    Visible = false;
                    BlankZero = true;
                    Editable = false;
                }
                field("Currency Factor Date"; ServiceCommitment."Currency Factor Date")
                {
                    Caption = 'Currency Factor Date';
                    ToolTip = 'Specifies the date when the currency factor was last updated.';
                    Visible = false;
                    Editable = false;
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
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        InitializePageVariables();
        Rec.LoadServiceCommitmentForContractLine(ServiceCommitment);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(ServiceCommitment);
        Clear(ServiceObject);
    end;

    var
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
        ContractsGeneralMgt: Codeunit "Sub. Contracts General Mgt.";

    local procedure InitializePageVariables()
    begin
        Rec.GetServiceCommitment(ServiceCommitment);
        Rec.GetServiceObject(ServiceObject);
    end;
}