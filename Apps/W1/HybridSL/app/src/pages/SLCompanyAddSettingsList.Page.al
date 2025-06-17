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
                    Editable = false;
                }
                field("Global Dimension 1"; Rec."Global Dimension 1")
                {
                    Width = 6;
                }
                field("Global Dimension 2"; Rec."Global Dimension 2")
                {
                    Width = 6;
                }
                field("Oldest GL Year To Migrate"; Rec."Oldest GL Year to Migrate")
                {
                    Width = 4;
                }
                field("Migrate GL Module"; Rec."Migrate GL Module")
                {
                }
                field("Migrate Payables Module"; Rec."Migrate Payables Module")
                {
                }
                field("Migrate Open POs"; Rec."Migrate Open POs")
                {
                    Enabled = false;
                    Visible = false;
                }
                field("Migrate Receivables Module"; Rec."Migrate Receivables Module")
                {
                }
                field("Migrate Inventory Module"; Rec."Migrate Inventory Module")
                {
                }
                field("Include Project Module"; Rec."Include Project Module")
                {
                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then begin
                            Rec.Validate("Project Master Only", Rec."Include Project Module");
                            Rec.Validate("Include Plan Status Projects", Rec."Include Project Module");
                            Rec.Validate("Task Master Only", Rec."Include Project Module");
                            Rec.Validate("Resource Master Only", Rec."Include Project Module");
                            Rec.Validate("Include Hold Status Resources", Rec."Include Project Module");
                        end;
                    end;
                }
                field("Migrate Only GL Master"; Rec."Migrate Only GL Master")
                {
                }
                field("Migrate Only Payables Master"; Rec."Migrate Only Payables Master")
                {
                }
                field("Migrate Only Rec. Master"; Rec."Migrate Only Rec. Master")
                {
                }
                field("Migrate Only Inventory Master"; Rec."Migrate Only Inventory Master")
                {
                }
                field("Resource Master Only"; Rec."Resource Master Only")
                {
                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            if Rec."Resource Master Only" then
                                Rec.Validate("Include Project Module", Rec."Resource Master Only")
                            else
                                Rec.Validate("Include Hold Status Resources", Rec."Resource Master Only");
                    end;
                }
                field("Include Hold Status Resources"; Rec."Include Hold Status Resources")
                {
                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            if Rec."Include Hold Status Resources" then begin
                                Rec.Validate("Resource Master Only", Rec."Include Hold Status Resources");
                                Rec.Validate("Include Project Module", Rec."Include Hold Status Resources");
                            end;
                    end;
                }
                field("Project Master Only"; Rec."Project Master Only")
                {
                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            if Rec."Project Master Only" then begin
                                Rec.Validate("Task Master Only", Rec."Project Master Only");
                                Rec.Validate("Include Project Module", Rec."Project Master Only");
                            end
                            else begin
                                Rec.Validate("Include Plan Status Projects", Rec."Project Master Only");
                                Rec.Validate("Task Master Only", Rec."Project Master Only");
                            end;
                    end;
                }
                field("Include Plan Status Projects"; Rec."Include Plan Status Projects")
                {
                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            if Rec."Include Plan Status Projects" then begin
                                Rec.Validate("Project Master Only", Rec."Include Plan Status Projects");
                                Rec.Validate("Include Project Module", Rec."Include Plan Status Projects");
                            end;
                    end;
                }
                field("Task Master Only"; Rec."Task Master Only")
                {
                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            if Rec."Task Master Only" then begin
                                Rec.Validate("Project Master Only", Rec."Task Master Only");
                                Rec.Validate("Include Project Module", Rec."Task Master Only");
                            end;
                    end;
                }
                field("Migrate Inactive Customers"; Rec."Migrate Inactive Customers")
                {
                }
                field("Migrate Inactive Vendors"; Rec."Migrate Inactive Vendors")
                {
                }
                field("Migrate Inactive Items"; Rec."Migrate Inactive Items")
                {
                }
                field("Migrate Delete Status Items"; Rec."Migrate Discontinued Items")
                {
                }
                field("Migrate Customer Classes"; Rec."Migrate Customer Classes")
                {
                }
                field("Migrate Vendor Classes"; Rec."Migrate Vendor Classes")
                {
                }
                field("Migrate Product Classes"; Rec."Migrate Item Classes")
                {
                    Enabled = false;
                    Visible = false;
                }
                field("Oldest Hist. Year to Migrate"; Rec."Oldest Hist. Year to Migrate")
                {
                    Width = 4;
                }
                field("Migrate Hist. GL Trx."; Rec."Migrate Hist. GL Trx.")
                {
                }
                field("Migrate Hist. AR Trx."; Rec."Migrate Hist. AR Trx.")
                {
                }
                field("Migrate Hist. AP Trx."; Rec."Migrate Hist. AP Trx.")
                {
                }
                field("Migrate Hist. Inv. Trx."; Rec."Migrate Hist. Inv. Trx.")
                {
                }
                field("Migrate Hist. Purch. Trx."; Rec."Migrate Hist. Purch. Trx.")
                {
                }
                field("Skip Posting Account Batches"; Rec."Skip Posting Account Batches")
                {
                }
                field("Skip Posting Customer Batches"; Rec."Skip Posting Customer Batches")
                {
                }
                field("Skip Posting Vendor Batches"; Rec."Skip Posting Vendor Batches")
                {
                }
                field("Skip Posting Item Batches"; Rec."Skip Posting Item Batches")
                {
                }
            }
        }
    }

    internal procedure PrepSettingsForFieldUpdate(): Boolean
    begin
        SLCompanyAdditionalSettings.SetFilter(Name, '<>%1', '');
        SLCompanyAdditionalSettings.SetRange("Migration Completed", false);
        exit(SLCompanyAdditionalSettings.FindSet());
    end;

    var
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
}