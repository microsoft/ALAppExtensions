namespace Microsoft.DataMigration.GP;

using Microsoft.DataMigration;

pageextension 4014 "Hybrid Cloud Wizard Extension" extends "Hybrid Cloud Setup Wizard"
{
    layout
    {
#if not CLEAN22
        addafter(Step5)
        {
            group(GPSpecificSettingsStep)
            {
                ShowCaption = false;
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteReason = 'Replaced by page GP Migration Configuration';
                ObsoleteTag = '22.0';

                group("GPMigrationSettings.1.0")
                {
                    ShowCaption = false;
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced by page GP Migration Configuration';
                    ObsoleteTag = '22.0';

                    part(pageGPMigrationSettings; "GP Migration Settings List")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = '';
                        UpdatePropagation = Both;
                        ObsoleteState = Pending;
                        ObsoleteReason = 'Replaced by page GP Migration Configuration';
#pragma warning disable AS0072
                        ObsoleteTag = '22.0';
#pragma warning restore AS0072
                    }
                }
                group("GPMigrationSettings.2.0")
                {
                    ShowCaption = false;
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced by page GP Migration Configuration';
                    ObsoleteTag = '22.0';

                    group("GPMigrationSettings.2.1")
                    {
                        ShowCaption = false;
                        InstructionalText = 'Select the two segments from Dynamics GP you would like as the global dimensions. The remaining segments will automatically be set up as shortcut dimensions.';
                        ObsoleteState = Pending;
                        ObsoleteReason = 'Replaced by page GP Migration Configuration';
#pragma warning disable AS0072
                        ObsoleteTag = '22.0';
#pragma warning restore AS0072
                    }
                    group("GPMigrationSettings.2.2")
                    {
                        ShowCaption = false;
                        InstructionalText = 'Choose whether to migrate inactive customers, vendors and checkbooks, or uncheck the boxes to only migrate those that are active.';
                        ObsoleteState = Pending;
                        ObsoleteReason = 'Replaced by page GP Migration Configuration';
#pragma warning disable AS0072
                        ObsoleteTag = '22.0';
#pragma warning restore AS0072
                    }
                }
            }
        }
#endif

        modify(AllDone)
        {
            Visible = Rec."Product ID" <> 'DynamicsGP';
        }

        addafter(AllDone)
        {
            group(GPSpecificDoneMessage)
            {
                Visible = Rec."Product ID" = 'DynamicsGP';
                Caption = 'Continue to company configuration';
                InstructionalText = 'Click Finish to continue to the company configuration for the GP migration.';
            }
        }
    }

    actions
    {
        modify(ActionFinish)
        {
            trigger OnAfterAction()
            begin
                if Rec."Product ID" = 'DynamicsGP' then
                    Page.Run(Page::"GP Migration Configuration");
            end;
        }
    }
}