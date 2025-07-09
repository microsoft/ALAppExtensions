namespace Microsoft.SubscriptionBilling;

page 8014 "Service Commitments List"
{
    ApplicationArea = All;
    Caption = 'Subscription Lines';
    PageType = List;
    SourceTable = "Subscription Line";
    UsageCategory = Lists;
    Editable = false;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Partner; Rec.Partner)
                {
                    ToolTip = 'Specifies whether the Subscription Line will will be calculated as a credit (Purchase Invoice) or as debit (Sales Invoice).';
                }
                field("Contract No."; Rec."Subscription Contract No.")
                {
                    ToolTip = 'Specifies the contract to which the Subscription Line is to be assigned.';
                }
                field("Service Object No."; Rec."Subscription Header No.")
                {
                    ToolTip = 'Specifies the value of the Subscription No. field.';
                }
                field("Service Start Date"; Rec."Subscription Line Start Date")
                {
                    ToolTip = 'Specifies the date from which the Subscription Line is valid and will be invoiced.';
                }
                field("Service End Date"; Rec."Subscription Line End Date")
                {
                    ToolTip = 'Specifies the date up to which the Subscription Line is valid.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the Subscription Line.';
                }
                field("Next Billing Date"; Rec."Next Billing Date")
                {
                    ToolTip = 'Specifies the date of the next billing possible.';
                }
                field("Quantity Decimal"; Rec.Quantity)
                {
                    ToolTip = 'Specifies the value of the Quantity field.';
                }
                field("Unit Cost (LCY)"; Rec."Unit Cost (LCY)")
                {
                    ToolTip = 'Specifies the unit cost of the item.';
                }
                field(Price; Rec.Price)
                {
                    ToolTip = 'Specifies the price of the Subscription Line with quantity of 1 in the billing period. The price is calculated from Base Price and Base Price %.';
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
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                    Visible = false;
                }
                field("Package Code"; Rec."Subscription Package Code")
                {
                    ToolTip = 'Specifies the code of the Subscription Package. If a Vendor Subscription Contract line has the same Subscription No. and Package Code as a Customer Subscription Contract line, the Customer Subscription Contract dimension value is copied to the Vendor Subscription Contract line.';
                    Visible = false;
                }
                field(Template; Rec.Template)
                {
                    ToolTip = 'Specifies the code of the Subscription Package Line Template.';
                    Visible = false;
                }
                field("Calculation Base Amount"; Rec."Calculation Base Amount")
                {
                    ToolTip = 'Specifies the base amount from which the price will be calculated.';
                    Visible = false;
                }
                field("Calculation Base %"; Rec."Calculation Base %")
                {
                    ToolTip = 'Specifies the percent at which the price of the Subscription Line will be calculated. 100% means that the price corresponds to the Base Price.';
                    Visible = false;
                }
                field("Discount %"; Rec."Discount %")
                {
                    ToolTip = 'Specifies the percent of the discount for the Subscription Line.';
                    Visible = false;
                }
                field("Invoicing via"; Rec."Invoicing via")
                {
                    ToolTip = 'Specifies whether the Subscription Line is invoiced via a contract. Subscription Lines with invoicing via sales are not charged. Only the items are billed.';
                    Visible = false;
                }
                field("Invoicing Item No."; Rec."Invoicing Item No.")
                {
                    ToolTip = 'Specifies the value of the Invoicing Item No. field.';
                    Visible = false;
                }
                field("Notice Period"; Rec."Notice Period")
                {
                    ToolTip = 'Specifies a date formula for the lead time that a notice must have before the Subscription Line ends. The rhythm of the update of "Notice possible to" and "Term Until" is determined using the extension term. For example, with an extension period of 1M, the notice period is repeatedly postponed by one month.';
                    Visible = false;
                }
                field("Initial Term"; Rec."Initial Term")
                {
                    ToolTip = 'Specifies a date formula for calculating the minimum term of the Subscription Line. If the minimum term is filled and no extension term is entered, the end of Subscription Line is automatically set to the end of the initial term.';
                    Visible = false;
                }
                field("Extension Term"; Rec."Extension Term")
                {
                    ToolTip = 'Specifies a date formula for automatic renewal after initial term and the rhythm of the update of "Notice possible to" and "Term Until". If the field is empty and the initial term or notice period is filled, the end of Subscription Line is automatically set to the end of the initial term or notice period.';
                    Visible = false;
                }
                field("Billing Rhythm"; Rec."Billing Rhythm")
                {
                    ToolTip = 'Specifies the Dateformula for rhythm in which the Subscription Line is invoiced. Using a Dateformula rhythm can be, for example, a monthly, a quarterly or a yearly invoicing.';
                    Visible = false;
                }
                field("Cancellation Possible Until"; Rec."Cancellation Possible Until")
                {
                    ToolTip = 'Specifies the last date for a timely termination. The date is determined by the initial term, extension term and a notice period. An initial term of 12 months and a 3-month notice period means that the deadline for a notice of termination is after 9 months. An extension period of 12 months postpones this date by 12 months.';
                    Visible = false;
                }
                field("Term Until"; Rec."Term Until")
                {
                    ToolTip = 'Specifies the earliest regular date for the end of the Subscription Line, taking into account the initial term, extension term and a notice period. An initial term of 24 months results in a fixed term of 2 years. An extension period of 12 months postpones this date by 12 months.';
                    Visible = false;
                }
                field("Service Object Customer No."; Rec."Sub. Header Customer No.")
                {
                    ToolTip = 'Specifies the value of the Subscription Customer No. field.';
                    Visible = false;
                }
                field("Contract Line No."; Rec."Subscription Contract Line No.")
                {
                    ToolTip = 'Specifies the value of the Contract Line No. field.';
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("Price (LCY)"; Rec."Price (LCY)")
                {
                    ToolTip = 'Specifies the price of the Subscription Line in client currency related to quantity of 1 in the billing period. The price is calculated from Base Price and Base Price %.';
                    Visible = false;
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
                field(Discount; Rec.Discount)
                {
                    ToolTip = 'Specifies whether the Subscription Line is used as a basis for periodic invoicing or discounts.';
                    Visible = false;
                }
                field("Create Contract Deferrals"; Rec."Create Contract Deferrals")
                {
                    ToolTip = 'Specifies whether this Subscription Line should generate contract deferrals. If it is set to No, no deferrals are generated and the invoices are posted directly to profit or loss.';
                }
                field("Period Calculation"; Rec."Period Calculation")
                {
                    Visible = false;
                    ToolTip = 'Specifies the Period Calculation, which controls how a period is determined for billing. The calculation of a month from 28.02. can extend to 27.03. (Align to Start of Month) or 30.03. (Align to End of Month).';
                }
                field("Customer Price Group"; Rec."Customer Price Group")
                {
                    ToolTip = 'Specifies the value of the Customer Price Group field.';
                    Visible = false;
                }
                field("Planned Serv. Comm. exists"; Rec."Planned Sub. Line exists")
                {
                    ToolTip = 'Specifies if a planned Renewal exists for the Subscription Line.';
                    Visible = false;
                }
                field("Renewal Term"; Rec."Renewal Term")
                {
                    ToolTip = 'Specifies a date formula by which the Contract Line is renewed and the end of the Contract Line is extended. It is automatically preset with the initial term of the Subscription Line and can be changed manually.';
                    Visible = false;
                }
                field("Dimension Set ID"; Rec."Dimension Set ID")
                {
                    ToolTip = 'Specifies the value of the Dimension Set ID field.';
                    Visible = false;
                }
                field("Source Type"; Rec."Source Type")
                {
                    ToolTip = 'Specifies the type of the Subscription.';
                    Visible = false;
                }
                field("Source No."; Rec."Source No.")
                {
                    ToolTip = 'Specifies the No. of the Item or G/L Account of the Subscription.';
                    Visible = false;
                }
                field("Created in Contract line"; Rec."Created in Contract line")
                {
                    ToolTip = 'Specifies whether the Subscription was created by creating a Contract line manually.';
                    Visible = false;
                }
#if not CLEAN26
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.';
                    ObsoleteReason = 'Replaced by field Source No.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '26.0';
                    Visible = false;
                }
#endif
                field("Service Object Description"; Rec."Subscription Description")
                {
                    ToolTip = 'Specifies the value of the Subscription Description field.';
                    Visible = false;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies on which date the record was created.';
                    Visible = false;
                }
                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                    ToolTip = 'Specifies by whom the record was created.';
                    Visible = false;
                }
                field(SystemId; Rec.SystemId)
                {
                    ToolTip = 'Specifies the value of the SystemId field.';
                    Visible = false;
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ToolTip = 'Specifies the date on which the record was last modified.';
                    Visible = false;
                }
                field(SystemModifiedBy; Rec.SystemModifiedBy)
                {
                    ToolTip = 'Specifies by whom the record was last modified.';
                    Visible = false;
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(ShowServiceObject)
            {
                ApplicationArea = All;
                Caption = 'Show Subscription';
                ToolTip = 'Opens the Subscription.';
                Image = Document;

                trigger OnAction()
                var
                    ServiceObject: Record "Subscription Header";
                begin
                    ServiceObject.OpenServiceObjectCard(Rec."Subscription Header No.");
                end;
            }
            action(ShowContract)
            {
                ApplicationArea = All;
                Caption = 'Show Contract';
                ToolTip = 'Opens the contract.';
                Image = ContractPayment;

                trigger OnAction()
                var
                    ContractsGenMgt: Codeunit "Sub. Contracts General Mgt.";
                begin
                    ContractsGenMgt.OpenContractCard(Rec.Partner, Rec."Subscription Contract No.");
                end;
            }
        }
        area(Promoted)
        {
            actionref(ShowServiceObject_Promoted; ShowServiceObject)
            {
            }
            actionref(ShowContract_Promoted; ShowContract)
            {
            }
        }
    }
}
