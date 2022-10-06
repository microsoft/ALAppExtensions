page 4051 "GP Company Add. Settings List"
{
    Caption = 'GP Company Additional Settings List';
    PageType = ListPart;
    SourceTable = "GP Company Additional Settings";
    SourceTableView = sorting(Name) where("Name" = filter(<> ''));
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Name; Rec.Name)
                {
                    Caption = 'Company';
                    ToolTip = 'Specifies the name of the Company.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Global Dimension 1"; Rec."Global Dimension 1")
                {
                    Caption = 'Dimension 1';
                    ToolTip = 'Specifies the segment from Dynamics GP you would like as the first global dimension in Business Central.';
                    ApplicationArea = All;
                    Width = 6;
                }
                field("Global Dimension 2"; Rec."Global Dimension 2")
                {
                    Caption = 'Dimension 2';
                    ToolTip = 'Specifies the segment from Dynamics GP you would like as the second global dimension in Business Central.';
                    ApplicationArea = All;
                    Width = 6;
                }
                field("Oldest GL Year To Migrate"; Rec."Oldest GL Year To Migrate")
                {
                    Caption = 'Oldest GL Year';
                    ToolTip = 'Specifies the oldest General Ledger year to be migrated. The year selected and all future years will be migrated to Business Central.';
                    ApplicationArea = All;
                    Width = 4;
                }
                field("Migrate Open POs"; Rec."Migrate Open POs")
                {
                    Caption = 'Open POs';
                    ToolTip = 'Specifies whether to migrate open Purchase Orders.';
                    ApplicationArea = All;
                }
                field("Migrate Bank Module"; Rec."Migrate Bank Module")
                {
                    Caption = 'Bank Module';
                    ToolTip = 'Specifies whether to migrate the Bank module.';
                    ApplicationArea = All;
                }
                field("Migrate Payables Module"; Rec."Migrate Payables Module")
                {
                    Caption = 'Payables Module';
                    ToolTip = 'Specifies whether to migrate the Payables module.';
                    ApplicationArea = All;
                }
                field("Migrate Receivables Module"; Rec."Migrate Receivables Module")
                {
                    Caption = 'Receivables Module';
                    ToolTip = 'Specifies whether to migrate the Receivables module.';
                    ApplicationArea = All;
                }
                field("Migrate Inventory Module"; Rec."Migrate Inventory Module")
                {
                    Caption = 'Inventory Module';
                    ToolTip = 'Specifies whether to migrate the Inventory module.';
                    ApplicationArea = All;
                }
                field("Migrate Inactive Customers"; Rec."Migrate Inactive Customers")
                {
                    Caption = 'Inactive Customers';
                    ToolTip = 'Specifies whether to migrate inactive customers.';
                    ApplicationArea = All;
                }
                field("Migrate Inactive Vendors"; Rec."Migrate Inactive Vendors")
                {
                    Caption = 'Inactive Vendors';
                    ToolTip = 'Specifies whether to migrate inactive vendors.';
                    ApplicationArea = All;
                }
                field("Migrate Inactive Checkbooks"; Rec."Migrate Inactive Checkbooks")
                {
                    Caption = 'Inactive Checkbooks';
                    ToolTip = 'Specifies whether to migrate inactive checkbooks.';
                    ApplicationArea = All;
                }
                field("Migrate Customer Classes"; Rec."Migrate Customer Classes")
                {
                    Caption = 'Customer Classes';
                    ToolTip = 'Specifies whether to migrate customer classes.';
                    ApplicationArea = All;
                }
                field("Migrate Vendor Classes"; Rec."Migrate Vendor Classes")
                {
                    Caption = 'Vendor Classes';
                    ToolTip = 'Specifies whether to migrate vendor classes.';
                    ApplicationArea = All;
                }
                field("Migrate Item Classes"; Rec."Migrate Item Classes")
                {
                    Caption = 'Item Classes';
                    ToolTip = 'Specifies whether to migrate item classes.';
                    ApplicationArea = All;
                }
            }
        }
    }
}