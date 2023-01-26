page 4051 "GP Company Add. Settings List"
{
    Caption = 'GP Company Additional Settings List';
    PageType = ListPart;
    ApplicationArea = All;
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
                    ToolTip = 'Specify the name of the Company.';
                    Editable = false;
                }
                field("Global Dimension 1"; Rec."Global Dimension 1")
                {
                    Caption = 'Dimension 1';
                    ToolTip = 'Specify the segment from Dynamics GP you would like as the first global dimension in Business Central.';
                    Width = 6;
                }
                field("Global Dimension 2"; Rec."Global Dimension 2")
                {
                    Caption = 'Dimension 2';
                    ToolTip = 'Specify the segment from Dynamics GP you would like as the second global dimension in Business Central.';
                    Width = 6;
                }
                field("Oldest GL Year To Migrate"; Rec."Oldest GL Year To Migrate")
                {
                    Caption = 'Oldest GL Year';
                    ToolTip = 'Specify the oldest GP year to be migrated. The year entered and all future years will be migrated to Business Central. This setting applies to GL Summary information as well as GP Historical Snapshot data.';
                    Width = 4;
                }
                field("Migrate Open POs"; Rec."Migrate Open POs")
                {
                    Caption = 'Open POs';
                    ToolTip = 'Specify whether to migrate open Purchase Orders.';
                }
                field("Migrate Bank Module"; Rec."Migrate Bank Module")
                {
                    Caption = 'Bank Module';
                    ToolTip = 'Specify whether to migrate the Bank module.';
                }
                field("Migrate Payables Module"; Rec."Migrate Payables Module")
                {
                    Caption = 'Payables Module';
                    ToolTip = 'Specify whether to migrate the Payables module.';
                }
                field("Migrate Receivables Module"; Rec."Migrate Receivables Module")
                {
                    Caption = 'Receivables Module';
                    ToolTip = 'Specify whether to migrate the Receivables module.';
                }
                field("Migrate Inventory Module"; Rec."Migrate Inventory Module")
                {
                    Caption = 'Inventory Module';
                    ToolTip = 'Specify whether to migrate the Inventory module.';
                }
                field("Migrate Only GL Master"; Rec."Migrate Only GL Master")
                {
                    Caption = 'GL Master Only';
                    ToolTip = 'Specify whether to migrate GL master data only.';
                }
                field("Migrate Only Bank Master"; Rec."Migrate Only Bank Master")
                {
                    Caption = 'Bank Master Only';
                    ToolTip = 'Specify whether to migrate Bank master data only.';
                }
                field("Migrate Only Payables Master"; Rec."Migrate Only Payables Master")
                {
                    Caption = 'Payables Master Only';
                    ToolTip = 'Specify whether to migrate Payables master data only.';
                }
                field("Migrate Only Rec. Master"; Rec."Migrate Only Rec. Master")
                {
                    Caption = 'Rec. Master Only';
                    ToolTip = 'Specify whether to migrate Receivables master data only.';
                }
                field("Migrate Only Inventory Master"; Rec."Migrate Only Inventory Master")
                {
                    Caption = 'Inventory Master Only';
                    ToolTip = 'Specify whether to migrate Inventory master data only.';
                }
                field("Migrate Inactive Customers"; Rec."Migrate Inactive Customers")
                {
                    Caption = 'Inactive Customers';
                    ToolTip = 'Specify whether to migrate inactive customers.';
                }
                field("Migrate Inactive Vendors"; Rec."Migrate Inactive Vendors")
                {
                    Caption = 'Inactive Vendors';
                    ToolTip = 'Specify whether to migrate inactive vendors.';
                }
                field("Migrate Inactive Checkbooks"; Rec."Migrate Inactive Checkbooks")
                {
                    Caption = 'Inactive Checkbooks';
                    ToolTip = 'Specify whether to migrate inactive checkbooks.';
                }
                field("Migrate Inactive Items"; Rec."Migrate Inactive Items")
                {
                    Caption = 'Inactive Items';
                    ToolTip = 'Specify whether to migrate inactive items.';
                }
                field("Migrate Discontinued Items"; Rec."Migrate Discontinued Items")
                {
                    Caption = 'Discontinued Items';
                    ToolTip = 'Specify whether to migrate discontinued items.';
                }
                field("Migrate Customer Classes"; Rec."Migrate Customer Classes")
                {
                    Caption = 'Customer Classes';
                    ToolTip = 'Specify whether to migrate customer classes.';
                }
                field("Migrate Vendor Classes"; Rec."Migrate Vendor Classes")
                {
                    Caption = 'Vendor Classes';
                    ToolTip = 'Specify whether to migrate vendor classes.';
                }
                field("Migrate Item Classes"; Rec."Migrate Item Classes")
                {
                    Caption = 'Item Classes';
                    ToolTip = 'Specify whether to migrate item classes.';
                }
                field("Oldest Hist. Year to Migrate"; Rec."Oldest Hist. Year to Migrate")
                {
                    Caption = 'Oldest Hist. Year';
                    ToolTip = 'Specify the oldest historical year to be migrated for GL summary information and historical snapshot records.';
                    Width = 4;
                }
                field("Migrate Hist. GL Trx."; Rec."Migrate Hist. GL Trx.")
                {
                    Caption = 'Hist. GL Trx.';
                    ToolTip = 'Specify whether to migrate historical GL transactions.';
                }
                field("Migrate Hist. AR Trx."; Rec."Migrate Hist. AR Trx.")
                {
                    Caption = 'Hist. AR Trx.';
                    ToolTip = 'Specify whether to migrate historical AR transactions.';
                }
                field("Migrate Hist. AP Trx."; Rec."Migrate Hist. AP Trx.")
                {
                    Caption = 'Hist. AP Trx.';
                    ToolTip = 'Specify whether to migrate historical AP transactions.';
                }
                field("Migrate Hist. Inv. Trx."; Rec."Migrate Hist. Inv. Trx.")
                {
                    Caption = 'Hist. Inv. Trx.';
                    ToolTip = 'Specify whether to migrate historical inventory transactions.';
                }
                field("Migrate Hist. Purch. Trx."; Rec."Migrate Hist. Purch. Trx.")
                {
                    Caption = 'Hist. Purch. Trx.';
                    ToolTip = 'Specify whether to migrate historical Purchase receivable transactions.';
                }
            }
        }
    }
}