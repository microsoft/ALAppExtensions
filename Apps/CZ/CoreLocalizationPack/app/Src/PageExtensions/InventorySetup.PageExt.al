pageextension 11716 "Inventory Setup CZL" extends "Inventory Setup"
{
    layout
    {
        addafter(Numbering)
        {
            group("Physical Inventory CZL")
            {
                Caption = 'Physical Inventory';
                field("Def.Tmpl. for Phys.Pos.Adj CZL"; Rec."Def.Tmpl. for Phys.Pos.Adj CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the template name for physical inventory positive adjustments.';
                }
                field("Def.Tmpl. for Phys.Neg.Adj CZL"; Rec."Def.Tmpl. for Phys.Neg.Adj CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the template name for physical inventory negative adjustments.';
                }
            }
        }
    }
    actions
    {
        addlast(navigation)
        {
            action("Inventory Movement Templates CZL")
            {
                Caption = 'Inventory Movement Templates';
                RunObject = page "Invt. Movement Templates CZL";
                Image = Template;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Set up the templates for item movements, that you can select from in the Item Journal, Job Journal and Physical Inventory.';
            }
        }
    }
}
