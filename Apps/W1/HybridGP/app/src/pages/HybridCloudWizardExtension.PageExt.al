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
                group("GPMigrationSettings.2.0")
                {
                    ShowCaption = false;
                    group("GPMigrationSettings.2.1")
                    {
                        ShowCaption = false;
                        InstructionalText = 'Select the two segments from Dynamics GP you would like as the global dimensions. The remaining segments will automatically be set up as shortcut dimensions.';
                    }
                    group("GPMigrationSettings.2.2")
                    {
                        ShowCaption = false;
                        InstructionalText = 'Choose whether to migrate inactive customers and vendors or uncheck the boxes to only migrate those that are active.';
                    }
                }
            }
        }
    }
}