pageextension 42000 "SL Intelligent Cloud Extension" extends "Intelligent Cloud Management"
{
    layout
    {
        addlast(FactBoxes)
        {
            part("SL Show Errors"; "SL Hybrid Errors Factbox")
            {
                ApplicationArea = All;
                Visible = FactBoxesVisible;
            }
        }
    }

    actions
    {
        addafter(RunReplicationNow)
        {
            action(SLConfigureMigration)
            {
                ApplicationArea = All;
                Caption = 'Configure SL Migration';
                Enabled = HasCompletedSetupWizard;
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Configure migration settings for SL';

                trigger OnAction()
                var
                    SLMigrationConfiguration: Page "SL Migration Configuration";
                begin
                    SLMigrationConfiguration.ShouldShowManagementPromptOnClose(false);
                    SLMigrationConfiguration.Run();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridCompany: Record "Hybrid Company";
        HybridSLWizard: Codeunit "SL Hybrid Wizard";
    begin
        if IntelligentCloudSetup.Get() then
            if IntelligentCloudSetup."Product ID" = HybridSLWizard.ProductIdTxt() then
                FactBoxesVisible := true
            else
                FactBoxesVisible := false;

        HybridCompany.SetRange(Replicate, true);
        HasCompletedSetupWizard := not HybridCompany.IsEmpty();
    end;

    var
        FactBoxesVisible: Boolean;
        HasCompletedSetupWizard: Boolean;
}