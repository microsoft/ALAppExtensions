// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

page 47017 "SL Company Add. Settings List"
{
    ApplicationArea = All;
    Caption = 'SL Company Additional Settings List';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = true;
    PageType = ListPart;
    SourceTable = "SL Company Additional Settings";
    SourceTableView = sorting(Name) where(Name = filter(<> ''), "Migration Completed" = const(false), "Has Hybrid Company" = const(true));

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Name; Rec.Name)
                {
                    Caption = 'Company';
                    Editable = false;
                    ToolTip = 'Specify the name of the Company.';
                }
                field("Global Dimension 1"; Rec."Global Dimension 1")
                {
                    Caption = 'Dimension 1';
                    ToolTip = 'Specify the segment from Dynamics SL you would like as the first global dimension in Business Central.';
                    Width = 6;
                }
                field("Global Dimension 2"; Rec."Global Dimension 2")
                {
                    Caption = 'Dimension 2';
                    ToolTip = 'Specify the segment from Dynamics SL you would like as the second global dimension in Business Central.';
                    Width = 6;
                }
                field("Oldest GL Year To Migrate"; Rec."Oldest GL Year to Migrate")
                {
                    Caption = 'Oldest GL Year';
                    ToolTip = 'Specify the oldest General Ledger year to be migrated. The year selected and all future years will be migrated to Business Central.';
                    Width = 4;
                }
                field("Migrate Open POs"; Rec."Migrate Open POs")
                {
                    Caption = 'Open POs';
                    Enabled = false;
                    ToolTip = 'Specify whether to migrate open Purchase Orders. This is a future feature.';
                }
                field("Migrate GL Module"; Rec."Migrate GL Module")
                {
                    Caption = 'GL Module';
                    ToolTip = 'Specify whether to migrate the GL module.';
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
                field("Migrate Inactive Items"; Rec."Migrate Inactive Items")
                {
                    Caption = 'Inactive Items';
                    ToolTip = 'Specify whether to migrate inactive items.';
                }
                field("Migrate Delete Status Items"; Rec."Migrate Discontinued Items")
                {
                    Caption = 'Delete Status Items';
                    ToolTip = 'Specify whether to migrate discontinued items.';
                }
                field("Migrate Customer Classes"; Rec."Migrate Customer Classes")
                {
                    Caption = 'Customer Classes';
                    Enabled = false;
                    ToolTip = 'Specify whether to migrate customer classes. This is a future feature.';
                }
                field("Migrate Vendor Classes"; Rec."Migrate Vendor Classes")
                {
                    Caption = 'Vendor Classes';
                    Enabled = false;
                    ToolTip = 'Specify whether to migrate vendor classes. This is a future feature.';
                }
                field("Migrate Product Classes"; Rec."Migrate Item Classes")
                {
                    Caption = 'Product Classes';
                    Enabled = false;
                    ToolTip = 'Specify whether to migrate item classes. This is a future feature.';
                }
                field("Oldest Hist. Year to Migrate"; Rec."Oldest Hist. Year to Migrate")
                {
                    Caption = 'Oldest Snapshot year';
                    ToolTip = 'Specify the oldest historical year to be migrated for snapshot records.';
                    Width = 4;
                }
                field("Migrate Hist. GL Trx."; Rec."Migrate Hist. GL Trx.")
                {
                    Caption = 'Snapshot GL Trx.';
                    ToolTip = 'Specify whether to migrate historical GL transactions.';
                }
                field("Migrate Hist. AR Trx."; Rec."Migrate Hist. AR Trx.")
                {
                    Caption = 'Snapshot AR Trx.';
                    ToolTip = 'Specify whether to migrate historical AR transactions.';
                }
                field("Migrate Hist. AP Trx."; Rec."Migrate Hist. AP Trx.")
                {
                    Caption = 'Snapshot AP Trx.';
                    ToolTip = 'Specify whether to migrate historical AP transactions.';
                }
                field("Migrate Hist. Inv. Trx."; Rec."Migrate Hist. Inv. Trx.")
                {
                    Caption = 'Snapshot Inv. Trx.';
                    ToolTip = 'Specify whether to migrate historical inventory transactions.';
                }
                field("Migrate Hist. Purch. Trx."; Rec."Migrate Hist. Purch. Trx.")
                {
                    Caption = 'Snapshot Purch. Trx.';
                    ToolTip = 'Specify whether to migrate historical Purchase receivable transactions. This is a future feature.';
                }
                field("Skip Posting Account Batches"; Rec."Skip Posting Account Batches")
                {
                    Caption = 'Skip Posting Account Trx.';
                    ToolTip = 'Specify whether to disable auto posting Account batches.';
                }
                field("Skip Posting Customer Batches"; Rec."Skip Posting Customer Batches")
                {
                    Caption = 'Skip Posting Customer Trx.';
                    ToolTip = 'Specify whether to disable auto posting Customer batches.';
                }
                field("Skip Posting Vendor Batches"; Rec."Skip Posting Vendor Batches")
                {
                    Caption = 'Skip Posting Vendor Trx.';
                    ToolTip = 'Specify whether to disable auto posting Vendor batches.';
                }
                field("Skip Posting Item Batches"; Rec."Skip Posting Item Batches")
                {
                    Caption = 'Skip Posting Item Trx.';
                    ToolTip = 'Specify whether to disable auto posting Item batches.';
                }
            }
        }
    }
}