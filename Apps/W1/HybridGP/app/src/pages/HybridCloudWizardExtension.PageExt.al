pageextension 4014 "Hybrid Cloud Wizard Extension" extends "Hybrid Cloud Setup Wizard"
{
    layout
    {
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
                Page.Run(Page::"GP Migration Configuration");
            end;
        }
    }
}