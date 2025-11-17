namespace Microsoft.DataMigration.GP;

using Microsoft.DataMigration;

pageextension 41101 "Intelligent Cloud Ext." extends "Intelligent Cloud Management"
{
    layout
    {
        addlast(FactBoxes)
        {
            part("1099 Migration Log"; "GP 1099 Migration Log Factbox")
            {
                Caption = 'GP Vendor 1099 Migration Log';
                ApplicationArea = All;
                Visible = FactBoxesVisible;
            }
        }
    }

    actions
    {
        addlast(Processing)
        {
            action(RunAllVal)
            {
                ApplicationArea = All;
                Caption = 'Run Validation';
                ToolTip = 'Re-run migration validation';
                Image = Process;

                trigger OnAction()
                var
                    MigrationValidationError: Record "Migration Validation Error";
                    MigrationValidationMgmt: Codeunit "Migration Validation Mgmt.";
                    HybridGPWizard: Codeunit "Hybrid GP Wizard";
                begin
                    MigrationValidationError.SetRange("Company Name", CompanyName());
                    if not MigrationValidationError.IsEmpty() then
                        MigrationValidationError.DeleteAll();

                    MigrationValidationMgmt.StartValidation(HybridGPWizard.ProductId(), true);
                    CurrPage."Replication Statistics".Page.RefreshStats();
                end;
            }
        }

        addlast(Promoted)
        {
            group(Processing_Testing)
            {
                Caption = 'Testing';
                ShowAs = Standard;
                Image = TestFile;

                actionref(RunAllal_Promoted; RunAllVal)
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridGPWizard: Codeunit "Hybrid GP Wizard";
    begin
        if IntelligentCloudSetup.Get() then
            FactBoxesVisible := IntelligentCloudSetup."Product ID" = HybridGPWizard.ProductId();
    end;

    var
        FactBoxesVisible: Boolean;
}