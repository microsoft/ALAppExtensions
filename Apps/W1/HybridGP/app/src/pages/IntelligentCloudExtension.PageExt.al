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
                ApplicationArea = Basic, Suite;
                Caption = 'Configure GP Migration';
                ToolTip = 'Configure migration settings for GP.';
                Promoted = true;
                PromotedCategory = Process;
                Image = Setup;

                trigger OnAction()
                var
                    HybridCompany: Record "Hybrid Company";
                    GPSegmentName: Record "GP Segment Name";
                begin
                    // Cloud Migration Setup wizard has to be ran first
                    if (HybridCompany.Count() = 0) then begin
                        Message(CloudMigrationSetupNotRanMsg);
                        exit;
                    end;

                    // Staging data must be loaded
                    if (GPSegmentName.Count() = 0) then begin
                        Message(StagingDataNotLoadedMsg);
                        exit;
                    end;

                    Page.Run(Page::"GP Migration Configuration");
                end;
            }
        }

        modify(RunDataUpgrade)
        {
            trigger OnBeforeAction()
            var
                GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
            begin
                GPCompanyAdditionalSettings.SetFilter("Name", '<>%1', '');
                GPCompanyAdditionalSettings.FindSet();

                repeat
                    if (GPCompanyAdditionalSettings."Global Dimension 1" = '') then
                        Error(CompanyNotConfiguredMsg);

                    if (GPCompanyAdditionalSettings."Global Dimension 2" = '') then
                        Error(CompanyNotConfiguredMsg);

                until GPCompanyAdditionalSettings.Next() = 0;
            end;
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
        CloudMigrationSetupNotRanMsg: Label 'No companies selected for migration. You must first run the "Cloud Migration Setup" wizard.', Locked = true;
        StagingDataNotLoadedMsg: Label 'Staging data not present. Please click "Run Migration Now" to load staging data.', Locked = true;
        CompanyNotConfiguredMsg: Label 'Not all companies are configured. Run "Configure GP Migration", and make sure all companies have dimensions configured.', Locked = true;

}