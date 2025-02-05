pageextension 47002 "SL Hybrid Cloud Wizard Ext." extends "Hybrid Cloud Setup Wizard"
{
    layout
    {
        modify(AllDone)
        {
            Visible = Rec."Product ID" <> 'DynamicsSL';
        }

        addafter(AllDone)
        {
            group(SLSpecificDoneMessage)
            {
                Caption = 'Continue to company configuration';
                InstructionalText = 'Click Finish to continue to the company configuration for the SL migration.';
                Visible = Rec."Product ID" = 'DynamicsSL';
            }
        }
    }

    actions
    {
        modify(ActionFinish)
        {
            trigger OnAfterAction()
            begin
                if Rec."Product ID" = 'DynamicsSL' then
                    Page.Run(Page::"SL Migration Configuration");
            end;
        }
    }
}