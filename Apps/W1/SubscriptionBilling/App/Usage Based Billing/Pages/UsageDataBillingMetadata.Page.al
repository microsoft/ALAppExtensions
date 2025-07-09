namespace Microsoft.SubscriptionBilling;

page 8096 "Usage Data Billing Metadata"
{
    ApplicationArea = All;
    Caption = 'Usage Data Billing Metadata';
    PageType = List;
    SourceTable = "Usage Data Billing Metadata";
    UsageCategory = Administration;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Service Object No."; Rec."Subscription No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the related Subscription.';
                }
                field("Service Commitment Entry No."; Rec."Subscription Line Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the related Subscription Line line.';
                }
                field("Supplier Charge Start Date"; Rec."Supplier Charge Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the start date of the usage provided by the supplier';
                }
                field("Supplier Charge End Date"; Rec."Supplier Charge End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the end date of the usage provided by the supplier.';
                }
                field("Original Invoiced to Date"; Rec."Original Invoiced to Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date up to which the Subscription Line was originally invoiced.';
                }
                field(Invoiced; Rec.Invoiced)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the related usage data billing is invoiced.';
                }
                field(Rebilling; Rec.Rebilling)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the related usage data billing comes out of a rebilling scenario.';
                }
                field("Billing Document Type"; Rec."Billing Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which document type was used to post the associated usage data.';
                }
                field("Billing Document No."; Rec."Billing Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which document no. was used to post the associated usage data.';
                }
            }
        }
    }
}
