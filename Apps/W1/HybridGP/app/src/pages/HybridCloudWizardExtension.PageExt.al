namespace Microsoft.DataMigration.GP;

using Microsoft.DataMigration;

pageextension 4014 "Hybrid Cloud Wizard Extension" extends "Hybrid Cloud Setup Wizard"
{
    layout
    {
        addafter(SelectedProductDescription)
        {
            group("AssessmentGroup")
            {
                Visible = Rec."Product ID" = 'DynamicsGP';
                Caption = 'Have you ran the assessment tool?';

                field(AssessmentIntro; AssessmentIntroTxt)
                {
                    ApplicationArea = All;
                    Editable = false;
                    MultiLine = true;
                    ShowCaption = false;
                }

                field(AssessmentLink; AssessmentLinkTxt)
                {
                    ApplicationArea = All;
                    Editable = false;
                    MultiLine = true;
                    ShowCaption = false;
                    ExtendedDatatype = URL;
                }
            }
        }

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

    var
        AssessmentIntroTxt: Label 'Prior to starting your GP migration, consider utilizing the cloud migration assessment tool. This tool will help identify potential migration issues allowing you to proactively resolve them before initiating the migration process. To learn more, click the link below.';
        AssessmentLinkTxt: Label 'https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/administration/migrate-gp-overview#end-to-end-process', Locked = true;
}