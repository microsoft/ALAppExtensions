namespace Microsoft.DataMigration.GP;

page 40056 "GP Company Migration Settings"
{
    ApplicationArea = All;
    Caption = 'GP Company Migration Settings';
    PageType = Worksheet;
    SourceTable = "GP Company Additional Settings";
    SourceTableView = sorting(Name) where("Name" = filter(<> ''));
    UsageCategory = Lists;
    Editable = true;
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
                    Editable = false;
                    ToolTip = 'Specify the name of the Company.';
                }
                field("Global Dimension 1"; Rec."Global Dimension 1")
                {
                    ToolTip = 'Specify the segment from Dynamics GP you would like as the first global dimension in Business Central.';
                }
                field("Global Dimension 2"; Rec."Global Dimension 2")
                {
                    ToolTip = 'Specify the segment from Dynamics GP you would like as the second global dimension in Business Central.';
                }
                field("Migrate GL Module"; Rec."Migrate GL Module")
                {
                    ToolTip = 'Specify whether to migrate the GL module.';
                }
                field("Migrate Bank Module"; Rec."Migrate Bank Module")
                {
                    ToolTip = 'Specify whether to migrate the Bank module.';
                }
                field("Migrate Customer Classes"; Rec."Migrate Customer Classes")
                {
                    ToolTip = 'Specify whether to migrate customer classes.';
                }
                field("Migrate Hist. AP Trx."; Rec."Migrate Hist. AP Trx.")
                {
                    ToolTip = 'Specify whether to migrate historical AP transactions.';
                }
                field("Migrate Hist. AR Trx."; Rec."Migrate Hist. AR Trx.")
                {
                    ToolTip = 'Specify whether to migrate historical AR transactions.';
                }
                field("Migrate Hist. GL Trx."; Rec."Migrate Hist. GL Trx.")
                {
                    ToolTip = 'Specify whether to migrate historical GL transactions.';
                }
                field("Migrate Hist. Inv. Trx."; Rec."Migrate Hist. Inv. Trx.")
                {
                    ToolTip = 'Specify whether to migrate historical inventory transactions.';
                }
                field("Migrate Hist. Purch. Trx."; Rec."Migrate Hist. Purch. Trx.")
                {
                    ToolTip = 'Specify whether to migrate historical Purchase receivable transactions.';
                }
                field("Migrate Inactive Checkbooks"; Rec."Migrate Inactive Checkbooks")
                {
                    ToolTip = 'Specify whether to migrate inactive checkbooks.';
                }
                field("Migrate Inactive Customers"; Rec."Migrate Inactive Customers")
                {
                    ToolTip = 'Specify whether to migrate inactive customers.';
                }
                field("Migrate Inactive Items"; Rec."Migrate Inactive Items")
                {
                    ToolTip = 'Specify whether to migrate inactive items.';
                }
                field("Migrate Discontinued Items"; Rec."Migrate Discontinued Items")
                {
                    ToolTip = 'Specify whether to migrate discontinued items.';
                }
                field("Migrate Kit Items"; Rec."Migrate Kit Items")
                {
                    ToolTip = 'Specifies the value of the Migrate Kit Items field.';
                }
                field("Migrate Inactive Vendors"; Rec."Migrate Inactive Vendors")
                {
                    ToolTip = 'Specify whether to migrate inactive vendors.';
                }
                field("Migrate Temporary Vendors"; Rec."Migrate Temporary Vendors")
                {
                    ToolTip = 'Specify whether to migrate temporary vendors.';
                }
                field("Migrate Inventory Module"; Rec."Migrate Inventory Module")
                {
                    ToolTip = 'Specify whether to migrate the Inventory module.';
                }
                field("Migrate Item Classes"; Rec."Migrate Item Classes")
                {
                    ToolTip = 'Specify whether to migrate item classes.';
                }
                field("Migrate Only Bank Master"; Rec."Migrate Only Bank Master")
                {
                    ToolTip = 'Specify whether to migrate Bank master data only.';
                }
                field("Migrate Only GL Master"; Rec."Migrate Only GL Master")
                {
                    ToolTip = 'Specify whether to migrate GL master data only.';
                }
                field("Migrate Only Inventory Master"; Rec."Migrate Only Inventory Master")
                {
                    ToolTip = 'Specify whether to migrate Inventory master data only.';
                }
                field("Migrate Only Payables Master"; Rec."Migrate Only Payables Master")
                {
                    ToolTip = 'Specify whether to migrate Payables master data only.';
                }
                field("Migrate Only Rec. Master"; Rec."Migrate Only Rec. Master")
                {
                    ToolTip = 'Specify whether to migrate Receivables master data only.';
                }
                field("Migrate Open POs"; Rec."Migrate Open POs")
                {
                    ToolTip = 'Specify whether to migrate open Purchase Orders.';
                }
                field("Migrate Payables Module"; Rec."Migrate Payables Module")
                {
                    ToolTip = 'Specify whether to migrate the Payables module.';
                }
                field("Migrate Receivables Module"; Rec."Migrate Receivables Module")
                {
                    ToolTip = 'Specify whether to migrate the Receivables module.';
                }
                field("Migrate Vendor Classes"; Rec."Migrate Vendor Classes")
                {
                    ToolTip = 'Specify whether to migrate vendor classes.';
                }
                field("Migration Completed"; Rec."Migration Completed")
                {
                    ToolTip = 'Specifies the value of the Migration Completed field.';
                }
                field("Oldest GL Year to Migrate"; Rec."Oldest GL Year to Migrate")
                {
                    ToolTip = 'Specify the oldest General Ledger year to be migrated. The year selected and all future years will be migrated to Business Central.';
                }
                field("Oldest Hist. Year to Migrate"; Rec."Oldest Hist. Year to Migrate")
                {
                    ToolTip = 'Specify the oldest historical year to be migrated for snapshot records.';
                }
                field("Skip Posting Account Batches"; Rec."Skip Posting Account Batches")
                {
                    ToolTip = 'Specify whether to disable auto posting Account batches.';
                }
                field("Skip Posting Bank Batches"; Rec."Skip Posting Bank Batches")
                {
                    ToolTip = 'Specify whether to disable auto posting Bank batches.';
                }
                field("Skip Posting Customer Batches"; Rec."Skip Posting Customer Batches")
                {
                    ToolTip = 'Specify whether to disable auto posting Customer batches.';
                }
                field("Skip Posting Vendor Batches"; Rec."Skip Posting Vendor Batches")
                {
                    ToolTip = 'Specify whether to disable auto posting Vendor batches.';
                }
                field("Skip Posting Item Batches"; Rec."Skip Posting Item Batches")
                {
                    ToolTip = 'Specify whether to disable auto posting Item batches.';
                }
            }
        }
    }
}