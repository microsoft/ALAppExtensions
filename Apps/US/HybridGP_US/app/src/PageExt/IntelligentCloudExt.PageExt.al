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
                Caption = 'Run All Validation';
                ToolTip = 'Re-run all migration validation';
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

            action(RunMainVal)
            {
                ApplicationArea = All;
                Caption = 'Run Main Validation';
                ToolTip = 'Re-run migration validation';
                Image = Process;

                trigger OnAction()
                var
                    MigrationValidationError: Record "Migration Validation Error";
                begin
                    MigrationValidationError.SetRange("Company Name", CompanyName());
                    MigrationValidationError.SetRange("Validator Code", 'GP');
                    if not MigrationValidationError.IsEmpty() then
                        MigrationValidationError.DeleteAll();

                    Codeunit.Run(Codeunit::"GP Migration Validator");
                    CurrPage."Replication Statistics".Page.RefreshStats();
                end;
            }

            action(Run1099Val)
            {
                ApplicationArea = All;
                Caption = 'Run 1099 Validation';
                ToolTip = 'Re-run 1099 migration validation';
                Image = Process;

                trigger OnAction()
                var
                    MigrationValidationError: Record "Migration Validation Error";
                begin
                    MigrationValidationError.SetRange("Company Name", CompanyName());
                    MigrationValidationError.SetRange("Validator Code", 'GP-US');
                    if not MigrationValidationError.IsEmpty() then
                        MigrationValidationError.DeleteAll();

                    Codeunit.Run(Codeunit::"GP US Migration Validator");
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
                actionref(RunMainVal_Promoted; RunMainVal)
                {
                }
                actionref(Run1099Val_Promoted; Run1099Val)
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