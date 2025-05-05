namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.GeneralLedger.Setup;

page 8051 "Service Contract Setup"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Subscription Contract Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Subscription Contract Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Ser. Start Date for Inv. Picks"; Rec."Sub. Line Start Date Inv. Pick")
                {
                    ToolTip = 'Specifies the date field, that will be used as Subscription Start Date of the Subscription Line, if the item is shipped in a inventory pick.';
                }
                field("Overdue Date Formula"; Rec."Overdue Date Formula")
                {
                    ToolTip = 'Specifies the default date formula which will be used for filtering overdue Subscription Lines.';
                }
                field("Default Period Calculation"; Rec."Default Period Calculation")
                {
                    ToolTip = 'Specifies which Period Calculation will initially be set in Subscription Package line.';
                }
                field("Default Billing Base Period"; Rec."Default Billing Base Period")
                {
                    ToolTip = 'Specifies the default period to which the Subscription Line amount relates. For example, enter 1M if the amount relates to one month or 12M if the amount relates to 1 year.';
                }
                field("Default Billing Rhythm"; Rec."Default Billing Rhythm")
                {
                    ToolTip = 'Specifies the default rhythm in which the Subscription Line is calculated. Using a date formula, the rhythm can be defined as monthly, quarterly or annual calculation.';
                }
                field("Create Contract Deferrals"; Rec."Create Contract Deferrals")
                {
                    ToolTip = 'Specifies whether deferrals are created for new Subscription lines by default.';
                }
            }
            group(Dimensions)
            {
                Caption = 'Dimensions';
                field("Aut. Insert C. Contr. DimValue"; Rec."Aut. Insert C. Contr. DimValue")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies whether the contract number is also automatically created as a dimension value when a Customer Subscription Contract is created.';
                }
                field("Dimension Code Cust. Contr."; Rec."Dimension Code Cust. Contr.")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the Dimension Code that is used for Customer Subscription Contracts.';
                }
            }
            group("Number Series")
            {
                Caption = 'Number Series';
                field("Customer Contract Nos."; Rec."Cust. Sub. Contract Nos.")
                {
                    ToolTip = 'Specifies the code for the number series that will be used to assign numbers to Customer Subscription Contracts.';
                }
                field("Vendor Contract Nos."; Rec."Vend. Sub. Contract Nos.")
                {
                    ToolTip = 'Specifies the code for the number series that will be used to assign numbers to Vendor Subscription Contracts.';
                }
                field("Service Object Nos."; Rec."Subscription Header No.")
                {
                    ToolTip = 'Specifies the code for the number series that will be used to assign numbers to Subscriptions.';
                }
            }
            group(InvoiceDetails)
            {
                Caption = 'Invoice Details';

                field("Origin Name collective Invoice"; Rec."Origin Name collective Invoice")
                {
                    ToolTip = 'Specifies which customer information (name) is transferred to collective invoices. This setting is applies for collective invoices only.';
                }
                group(ArrangeTexts)
                {
                    Caption = 'Arrange Texts';

                    field("Contract Invoice Description"; Rec."Contract Invoice Description")
                    {
                        ToolTip = 'Specifies which information is used for Sales Invoice line description.';
                    }
                    field("Contract Invoice Add. Line 1"; Rec."Contract Invoice Add. Line 1")
                    {
                        ToolTip = 'Specifies which information is used for the first additional line.';
                    }
                    field("Contract Invoice Add. Line 2"; Rec."Contract Invoice Add. Line 2")
                    {
                        ToolTip = 'Specifies which information is used for the second additional line.';
                    }
                    field("Contract Invoice Add. Line 3"; Rec."Contract Invoice Add. Line 3")
                    {
                        ToolTip = 'Specifies which information is used for the third additional line.';
                    }
                    field("Contract Invoice Add. Line 4"; Rec."Contract Invoice Add. Line 4")
                    {
                        ToolTip = 'Specifies which information is used for the fourth additional line.';
                    }
                    field("Contract Invoice Add. Line 5"; Rec."Contract Invoice Add. Line 5")
                    {
                        ToolTip = 'Specifies which information is used for the fifth additional line.';
                    }
                }
            }
            group("Gen. Journal Templates")
            {
                Caption = 'Journal Templates';
                Visible = IsJournalTemplatesVisible;

                field("Def. Rel. Jnl. Template Name"; Rec."Def. Rel. Jnl. Template Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the journal template to use for posting of deferrals release.';
                }
                field("Def. Rel. Jnl. Batch Name"; Rec."Def. Rel. Jnl. Batch Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the journal batch to use for posting of deferrals release.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.InitRecord();

        GLSetup.Get();
        IsJournalTemplatesVisible := GLSetup."Journal Templ. Name Mandatory";
    end;

    var
        GLSetup: Record "General Ledger Setup";
        IsJournalTemplatesVisible: Boolean;
}

