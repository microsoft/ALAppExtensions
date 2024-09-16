namespace Microsoft.SubscriptionBilling;

page 8051 "Service Contract Setup"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Service Contract Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Service Contract Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Ser. Start Date for Inv. Picks"; Rec."Serv. Start Date for Inv. Pick")
                {
                    Tooltip = 'Specifies the date field, that will be used as Service Start Date of the Service Commitment, if the item is shipped in a inventory pick.';
                }
                field("Overdue Date Formula"; Rec."Overdue Date Formula")
                {
                    ToolTip = 'Specifies the default date formula which will be used for filtering overdue Service Commitments.';
                }
                field("Default Period Calculation"; Rec."Default Period Calculation")
                {
                    ToolTip = 'Determines which Period Calculation will initially be set in Service Commitment Package line.';
                }
            }
            group(Dimensions)
            {
                Caption = 'Dimensions';
                field("Aut. Insert C. Contr. DimValue"; Rec."Aut. Insert C. Contr. DimValue")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies whether the contract number is also automatically created as a dimension value when a customer contract is created.';
                }
            }
            group("Number Series")
            {
                Caption = 'Number Series';
                field("Customer Contract Nos."; Rec."Customer Contract Nos.")
                {
                    ToolTip = 'Specifies the code for the number series that will be used to assign numbers to customer contracts.';
                }
                field("Vendor Contract Nos."; Rec."Vendor Contract Nos.")
                {
                    ToolTip = 'Specifies the code for the number series that will be used to assign numbers to vendor contracts.';
                }
                field("Service Object Nos."; Rec."Service Object Nos.")
                {
                    ToolTip = 'Specifies the code for the number series that will be used to assign numbers to service objects.';
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
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.ContractTextsCreateDefaults();
            Rec.Insert(false);
        end;
    end;
}

