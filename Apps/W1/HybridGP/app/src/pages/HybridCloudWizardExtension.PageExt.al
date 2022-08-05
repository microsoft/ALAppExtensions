pageextension 4014 "Hybrid Cloud Wizard Extension" extends "Hybrid Cloud Setup Wizard"
{
    layout
    {
        addafter(Step5)
        {
            group(GPSpecificSettingsStep)
            {
                ShowCaption = false;
                Visible = ProductSpecificSettingsVisible and ("Product ID" = 'DynamicsGP');

                group("GPMigrationSettings.1.0")
                {
                    ShowCaption = false;
                    part(pageGPMigrationSettings; "GP Migration Settings List")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = '';
                        UpdatePropagation = Both;
                    }
                }
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        EnvironmentInformation: Codeunit "Environment Information";
        GuidedExperience: Codeunit "Guided Experience";
    begin
        if not (CloseAction = Action::OK) then
            exit(true);

        if not EnvironmentInformation.IsSaaS() then
            exit(true);

        if not GuidedExperience.Exists("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"Hybrid Cloud Setup Wizard") then
            exit;

        if GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, PAGE::"Hybrid Cloud Setup Wizard") then begin
            Message(ContinueToConfigurationMsg);
            Page.Run(Page::"GP Migration Configuration");
            exit(true);
        end else
            if not Confirm(HybridNotSetupQst, false) then
                exit(false);
    end;

    var
        ContinueToConfigurationMsg: Label 'Click OK to continue configuring the GP Migration.', Locked = true;
        HybridNotSetupQst: Label 'Your Cloud Migration environment has not been set up.\\Are you sure that you want to exit?', Locked = true;
}