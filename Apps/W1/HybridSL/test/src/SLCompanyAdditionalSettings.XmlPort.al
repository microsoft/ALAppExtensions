// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147612 "SL Company Additional Settings"
{
    Caption = 'SL Company Additional Settings';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(Root)
        {
            tableelement("SL Company Additional Settings"; "SL Company Additional Settings")
            {
                AutoSave = false;
                XmlName = 'SLCompanyAdditionalSettings';

                textelement(Name)
                {
                }
                textelement(MigrateInactiveCustomers)
                {
                }
                textelement(MigrateInactiveVendors)
                {
                }
                textelement(MigrateVendorClasses)
                {
                }
                textelement(MigrateCustomerClasses)
                {
                }
                textelement(MigrateItemClasses)
                {
                }
                textelement(OldestGLYeartoMigrate)
                {
                }
                textelement(MigratePayablesModule)
                {
                }
                textelement(MigrateReceivablesModule)
                {
                }
                textelement(MigrateInventoryModule)
                {
                }
                textelement(GlobalDimension1)
                {
                }
                textelement(GlobalDimension2)
                {
                }
                textelement(MigrateOpenPOs)
                {
                }
                textelement(MigrateOnlyGLMaster)
                {
                }
                textelement(MigrateOnlyPayablesMaster)
                {
                }
                textelement(MigrateOnlyRecMaster)
                {
                }
                textelement(MigrateOnlyInventoryMaster)
                {
                }
                textelement(MigrateInactiveItems)
                {
                }
                textelement(MigrateDiscontinuedItems)
                {
                }
                textelement(OldestHistYeartoMigrate)
                {
                }
                textelement(MigrateHistGLTrx)
                {
                }
                textelement(MigrateHistARTrx)
                {
                }
                textelement(MigrateHistAPTrx)
                {
                }
                textelement(MigrateHistInvTrx)
                {
                }
                textelement(MigrateHistPurchTrx)
                {
                }
                textelement(MigrationCompleted)
                {
                }
                textelement(SkipPostingAccountBatches)
                {
                }
                textelement(SkipPostingCustomerBatches)
                {
                }
                textelement(SkipPostingVendorBatches)
                {
                }
                textelement(MigrateGLModule)
                {
                }
                textelement(SkipPostingItemBatches)
                {
                }
                textelement(HasHybridCompany)
                {
                }
                textelement(IncludeProjectModule)
                {
                }
                textelement(ProjectMasterOnly)
                {
                }
                textelement(TaskMasterOnly)
                {
                }
                textelement(ResourceMasterOnly)
                {
                }
                textelement(IncludePlanStatusProjects)
                {
                    MinOccurs = Once;
                }
                textelement(IncludeHoldStatusResources)
                {
                }

                trigger OnPreXmlItem()
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;
                end;

                trigger OnBeforeInsertRecord()
                var
                    SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    SLCompanyAdditionalSettings.Name := Name;
                    Evaluate(SLCompanyAdditionalSettings."Migrate Inactive Customers", MigrateInactiveCustomers, 9);
                    Evaluate(SLCompanyAdditionalSettings."Migrate Inactive Vendors", MigrateInactiveVendors, 9);
                    Evaluate(SLCompanyAdditionalSettings."Migrate Vendor Classes", MigrateVendorClasses, 9);
                    Evaluate(SLCompanyAdditionalSettings."Migrate Customer Classes", MigrateCustomerClasses, 9);
                    Evaluate(SLCompanyAdditionalSettings."Migrate Item Classes", MigrateItemClasses, 9);
                    Evaluate(SLCompanyAdditionalSettings."Oldest GL Year to Migrate", OldestGLYeartoMigrate, 9);
                    Evaluate(SLCompanyAdditionalSettings."Migrate Payables Module", MigratePayablesModule, 9);
                    Evaluate(SLCompanyAdditionalSettings."Migrate Receivables Module", MigrateReceivablesModule, 9);
                    Evaluate(SLCompanyAdditionalSettings."Migrate Inventory Module", MigrateInventoryModule, 9);
                    SLCompanyAdditionalSettings."Global Dimension 1" := GlobalDimension1;
                    SLCompanyAdditionalSettings."Global Dimension 2" := GlobalDimension2;
                    Evaluate(SLCompanyAdditionalSettings."Migrate Open POs", MigrateOpenPOs, 9);
                    Evaluate(SLCompanyAdditionalSettings."Migrate Only GL Master", MigrateOnlyGLMaster, 9);
                    Evaluate(SLCompanyAdditionalSettings."Migrate Only Payables Master", MigrateOnlyPayablesMaster, 9);
                    Evaluate(SLCompanyAdditionalSettings."Migrate Only Rec. Master", MigrateOnlyRecMaster, 9);
                    Evaluate(SLCompanyAdditionalSettings."Migrate Only Inventory Master", MigrateOnlyInventoryMaster, 9);
                    Evaluate(SLCompanyAdditionalSettings."Migrate Inactive Items", MigrateInactiveItems, 9);
                    Evaluate(SLCompanyAdditionalSettings."Migrate Discontinued Items", MigrateDiscontinuedItems, 9);
                    Evaluate(SLCompanyAdditionalSettings."Oldest Hist. Year to Migrate", OldestHistYeartoMigrate, 9);
                    Evaluate(SLCompanyAdditionalSettings."Migrate Hist. GL Trx.", MigrateHistGLTrx, 9);
                    Evaluate(SLCompanyAdditionalSettings."Migrate Hist. AR Trx.", MigrateHistARTrx, 9);
                    Evaluate(SLCompanyAdditionalSettings."Migrate Hist. AP Trx.", MigrateHistAPTrx, 9);
                    Evaluate(SLCompanyAdditionalSettings."Migrate Hist. Inv. Trx.", MigrateHistInvTrx, 9);
                    Evaluate(SLCompanyAdditionalSettings."Migrate Hist. Purch. Trx.", MigrateHistPurchTrx, 9);
                    Evaluate(SLCompanyAdditionalSettings."Migration Completed", MigrationCompleted, 9);
                    Evaluate(SLCompanyAdditionalSettings."Skip Posting Account Batches", SkipPostingAccountBatches, 9);
                    Evaluate(SLCompanyAdditionalSettings."Skip Posting Customer Batches", SkipPostingCustomerBatches, 9);
                    Evaluate(SLCompanyAdditionalSettings."Skip Posting Vendor Batches", SkipPostingVendorBatches, 9);
                    Evaluate(SLCompanyAdditionalSettings."Migrate GL Module", MigrateGLModule, 9);
                    Evaluate(SLCompanyAdditionalSettings."Skip Posting Item Batches", SkipPostingItemBatches, 9);
                    Evaluate(SLCompanyAdditionalSettings."Has Hybrid Company", HasHybridCompany, 9);
                    Evaluate(SLCompanyAdditionalSettings."Include Project Module", IncludeProjectModule, 9);
                    Evaluate(SLCompanyAdditionalSettings."Project Master Only", ProjectMasterOnly, 9);
                    Evaluate(SLCompanyAdditionalSettings."Task Master Only", TaskMasterOnly, 9);
                    Evaluate(SLCompanyAdditionalSettings."Resource Master Only", ResourceMasterOnly, 9);
                    Evaluate(SLCompanyAdditionalSettings."Include Plan Status Projects", IncludePlanStatusProjects);
                    Evaluate(SLCompanyAdditionalSettings."Include Hold Status Resources", IncludeHoldStatusResources, 9);
                    SLCompanyAdditionalSettings.Insert(true);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLCompanyAdditionalSettings.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
}
