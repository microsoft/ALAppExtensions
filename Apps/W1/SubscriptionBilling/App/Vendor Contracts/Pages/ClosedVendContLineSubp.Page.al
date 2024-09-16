namespace Microsoft.SubscriptionBilling;

page 8089 "Closed Vend. Cont. Line Subp."
{

    PageType = ListPart;
    SourceTable = "Vendor Contract Line";
    Caption = 'Closed Vendor Contract Lines';
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
                    StyleExpr = LineFormatStyleExpression;
                    ToolTip = 'Indicates that the associated service has ended.';
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Service Start Date"; ServiceCommitment."Service Start Date")
                {
                    StyleExpr = LineFormatStyleExpression;
                    Caption = 'Service Start Date';
                    ToolTip = 'Specifies the date from which the service is valid and will be invoiced.';
                    Editable = false;
                }
                field("Service End Date"; ServiceCommitment."Service End Date")
                {
                    StyleExpr = LineFormatStyleExpression;
                    Caption = 'Service End Date';
                    ToolTip = 'Specifies the date up to which the service is valid.';
                    Editable = false;
                }
                field("Service Object No."; Rec."Service Object No.")
                {
                    StyleExpr = LineFormatStyleExpression;
                    Visible = false;
                    ToolTip = 'Specifies the number of the service object no.';
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
                    ToolTip = 'Specifies the Serial No. assigned to the service object.';
                }
                field("Service Object Description"; Rec."Service Object Description")
                {
                    StyleExpr = LineFormatStyleExpression;
                    ToolTip = 'Specifies a description of the service object.';
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
                    ToolTip = 'Specifies the reference by which the customer identifies the service object.';
                }
                field("Service Commitment Description"; Rec."Service Commitment Description")
                {
                    StyleExpr = LineFormatStyleExpression;
                    ToolTip = 'Specifies the description of the service.';
                    Editable = false;
                }
                field("Service Object Quantity"; Rec."Service Obj. Quantity Decimal")
                {
                    StyleExpr = LineFormatStyleExpression;
                    ToolTip = 'Number of units of service object.';
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        Rec.OpenServiceObjectCard();
                    end;
                }
                field(Price; ServiceCommitment.Price)
                {
                    StyleExpr = LineFormatStyleExpression;
                    Caption = 'Price';
                    ToolTip = 'Specifies the price of the service with quantity of 1 in the billing period. The price is calculated from Base Price and Base Price %.';
                    Editable = false;
                    BlankZero = true;
                }
                field("Discount %"; ServiceCommitment."Discount %")
                {
                    StyleExpr = LineFormatStyleExpression;
                    Caption = 'Discount %';
                    ToolTip = 'Specifies the percent of the discount for the service.';
                    BlankZero = true;
                    MinValue = 0;
                    MaxValue = 100;
                    Editable = false;
                }
                field("Discount Amount"; ServiceCommitment."Discount Amount")
                {
                    StyleExpr = LineFormatStyleExpression;
                    Caption = 'Discount Amount';
                    ToolTip = 'Specifies the amount of the discount for the service.';
                    BlankZero = true;
                    MinValue = 0;
                    Editable = false;
                }
                field("Service Amount"; ServiceCommitment."Service Amount")
                {
                    StyleExpr = LineFormatStyleExpression;
                    Caption = 'Service Amount';
                    ToolTip = 'Specifies the amount for the service including discount.';
                    BlankZero = true;
                    Editable = false;
                }
                field("Price (LCY)"; ServiceCommitment."Price (LCY)")
                {
                    StyleExpr = LineFormatStyleExpression;
                    Caption = 'Price (LCY)';
                    ToolTip = 'Specifies the price of the service in client currency related to quantity of 1 in the billing period. The price is calculated from Base Price and Base Price %.';
                    Visible = false;
                    BlankZero = true;
                    Editable = false;
                }
                field("Discount Amount (LCY)"; ServiceCommitment."Discount Amount (LCY)")
                {
                    StyleExpr = LineFormatStyleExpression;
                    Caption = 'Discount Amount (LCY)';
                    ToolTip = 'Specifies the discount amount in client currency that is granted on the service.';
                    Visible = false;
                    BlankZero = true;
                    Editable = false;
                }
                field("Service Amount (LCY)"; ServiceCommitment."Service Amount (LCY)")
                {
                    StyleExpr = LineFormatStyleExpression;
                    Caption = 'Service Amount (LCY)';
                    ToolTip = 'Specifies the amount in client currency for the service including discount.';
                    Visible = false;
                    BlankZero = true;
                    Editable = false;
                }
                field("Currency Code"; ServiceCommitment."Currency Code")
                {
                    StyleExpr = LineFormatStyleExpression;
                    Caption = 'Currency Code';
                    ToolTip = 'Specifies the currency of amounts in the service.';
                    Visible = false;
                    Editable = false;
                }
                field("Currency Factor"; ServiceCommitment."Currency Factor")
                {
                    StyleExpr = LineFormatStyleExpression;
                    Caption = 'Currency Factor';
                    ToolTip = 'Specifies the currency factor valid for the service, which is used to convert amounts to the client currency.';
                    Visible = false;
                    BlankZero = true;
                    Editable = false;
                }
                field("Currency Factor Date"; ServiceCommitment."Currency Factor Date")
                {
                    StyleExpr = LineFormatStyleExpression;
                    Caption = 'Currency Factor Date';
                    ToolTip = 'Specifies the date when the currency factor was last updated.';
                    Visible = false;
                    Editable = false;
                }
                field("Next Billing Date"; ServiceCommitment."Next Billing Date")
                {
                    StyleExpr = LineFormatStyleExpression;
                    Caption = 'Next Billing Date';
                    ToolTip = 'Specifies the date of the next billing possible.';
                    Editable = false;
                }
                field("Calculation Base Amount"; ServiceCommitment."Calculation Base Amount")
                {
                    StyleExpr = LineFormatStyleExpression;
                    MinValue = 0;
                    Caption = 'Calculation Base Amount';
                    ToolTip = 'Specifies the base amount from which the price will be calculated.';
                    BlankZero = true;
                    Editable = false;
                }
                field("Calculation Base %"; ServiceCommitment."Calculation Base %")
                {
                    StyleExpr = LineFormatStyleExpression;
                    MinValue = 0;
                    Caption = 'Calculation Base %';
                    ToolTip = 'Specifies the percent at which the price of the service will be calculated. 100% means that the price corresponds to the Base Price.';
                    BlankZero = true;
                    Editable = false;
                }
                field("Billing Base Period"; ServiceCommitment."Billing Base Period")
                {
                    StyleExpr = LineFormatStyleExpression;
                    Caption = 'Billing Base Period';
                    ToolTip = 'Specifies for which period the Service Amount is valid. If you enter 1M here, a period of one month, or 12M, a period of 1 year, to which Service Amount refers to.';
                    Editable = false;
                }
                field("Cancellation Possible Until"; ServiceCommitment."Cancellation Possible Until")
                {
                    StyleExpr = LineFormatStyleExpression;
                    Caption = 'Cancellation Possible Until';
                    ToolTip = 'Specifies the last date for a timely termination. The date is determined by the initial term, extension term and a notice period. An initial term of 12 months and a 3-month notice period means that the deadline for a notice of termination is after 9 months. An extension period of 12 months postpones this date by 12 months.';
                    Editable = false;
                }
                field("Term Until"; ServiceCommitment."Term Until")
                {
                    StyleExpr = LineFormatStyleExpression;
                    Caption = 'Term Until';
                    ToolTip = 'Specifies the earliest regular date for the end of the service, taking into account the initial term, extension term and a notice period. An initial term of 24 months results in a fixed term of 2 years. An extension period of 12 months postpones this date by 12 months.';
                    Editable = false;
                }
                field("Initial Term"; ServiceCommitment."Initial Term")
                {
                    StyleExpr = LineFormatStyleExpression;
                    Caption = 'Initial Term';
                    ToolTip = 'Specifies a date formula for calculating the minimum term of the service commitment. If the minimum term is filled and no extension term is entered, the end of service commitment is automatically set to the end of the initial term.';
                    Editable = false;
                    Visible = false;
                }
                field("Extension Term"; ServiceCommitment."Extension Term")
                {
                    StyleExpr = LineFormatStyleExpression;
                    Caption = 'Subsequent Term';
                    ToolTip = 'Specifies a date formula for automatic renewal after initial term and the rhythm of the update of "Notice possible to" and "Term Until". If the field is empty and the initial term or notice period is filled, the end of service is automatically set to the end of the initial term or notice period.';
                    Editable = false;
                    Visible = false;
                }
                field("Billing Rhythm"; ServiceCommitment."Billing Rhythm")
                {
                    StyleExpr = LineFormatStyleExpression;
                    Caption = 'Billing Rhythm';
                    ToolTip = 'Specifies the Dateformula for rhythm in which the service is invoiced. Using a Dateformula rhythm can be, for example, a monthly, a quarterly or a yearly invoicing.';
                    Editable = false;
                }
                field("Package Code"; ServiceCommitment."Package Code")
                {
                    StyleExpr = LineFormatStyleExpression;
                    Caption = 'Package Code';
                    ToolTip = 'Specifies the code of the service commitment package.';
                    Editable = false;
                    Visible = false;
                }
                field(Template; ServiceCommitment.Template)
                {
                    StyleExpr = LineFormatStyleExpression;
                    Caption = 'Template';
                    ToolTip = 'Specifies the code of the service commitment template.';
                    Editable = false;
                    Visible = false;
                }
                field("Contract Line Type"; Rec."Contract Line Type")
                {
                    StyleExpr = LineFormatStyleExpression;
                    ToolTip = 'Specifies the contract line type.';
                    Editable = false;
                    Visible = false;
                }
                field(Discount; ServiceCommitment.Discount)
                {
                    StyleExpr = LineFormatStyleExpression;
                    Editable = false;
                    ToolTip = 'Specifies whether the Service Commitment is used as a basis for periodic invoicing or discounts.';
                }
                field("Period Calculation"; ServiceCommitment."Period Calculation")
                {
                    Visible = false;
                    Editable = false;
                    ToolTip = 'The Period Calculation controls how a period is determined for billing. The calculation of a month from 28.02. can extend to 27.03. (Align to Start of Month) or 30.03. (Align to End of Month).';
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
                        ContractsGeneralMgt.ShowArchivedBillingLinesForServiceCommitment(Rec."Service Commitment Entry No.");
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        InitializePageVariables();
        Rec.LoadAmountsForContractLine(ServiceCommitment.Price, ServiceCommitment."Discount %", ServiceCommitment."Discount Amount", ServiceCommitment."Service Amount");
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
        LineFormatStyleExpression: Text;

    local procedure InitializePageVariables()
    begin
        Rec.GetServiceCommitment(ServiceCommitment);
        Rec.GetServiceObject(ServiceObject);
    end;
}