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
        addbefore(RunReplicationNow)
        {
            action(ConfigureGPMigration)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Configure GP Migration';
                ToolTip = 'Configure migration settings for GP.';
                Promoted = true;
                PromotedCategory = Process;
                RunObject = page "GP Migration Configuration";
                Image = Setup;
            }
        }
    }

    trigger OnOpenPage()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridGPWizard: Codeunit "Hybrid GP Wizard";
    begin
        if IntelligentCloudSetup.Get() then
            if IntelligentCloudSetup."Product ID" = HybridGPWizard.ProductId() then
                FactBoxesVisible := true
            else
                FactBoxesVisible := false;
    end;

    var
        FactBoxesVisible: Boolean;

}