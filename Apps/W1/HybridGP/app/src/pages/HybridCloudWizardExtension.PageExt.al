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
}