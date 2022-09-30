pageextension 4015 "Intelligent Cloud Extension" extends "Intelligent Cloud Management"
{
    layout
    {
        addlast(FactBoxes)
        {
            part("Show Errors"; "Hybrid GP Errors Factbox")
            {
                ApplicationArea = Basic, Suite;
                Visible = FactBoxesVisible;
            }
        }
    }

    actions
    {
        addafter(RunReplicationNow)
        {
            action(ConfigureGPMigration)
            {
                Enabled = HasCompletedSetupWizard;
                ApplicationArea = Basic, Suite;
                Caption = 'Configure GP Migration';
                ToolTip = 'Configure migration settings for GP.';
                Promoted = true;
                PromotedCategory = Process;
                Image = Setup;

                trigger OnAction()
                var
                    GPMigrationConfiguration: Page "GP Migration Configuration";
                begin
                    GPMigrationConfiguration.ShouldShowManagementPromptOnClose(false);
                    GPMigrationConfiguration.Run();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridCompany: Record "Hybrid Company";
        HybridGPWizard: Codeunit "Hybrid GP Wizard";
    begin
        if IntelligentCloudSetup.Get() then
            FactBoxesVisible := IntelligentCloudSetup."Product ID" = HybridGPWizard.ProductId();

        HybridCompany.SetRange(Replicate, true);
        HasCompletedSetupWizard := HybridCompany.FindFirst();
    end;

    var
        FactBoxesVisible: Boolean;
        HasCompletedSetupWizard: Boolean;
}