pageextension 18632 "Fixed Asset Classes Ext" extends "FA Classes"
{
    actions
    {
        addlast(Navigation)
        {
            action("&Blocks")
            {
                Caption = '&Blocks';
                ApplicationArea = FixedAssets;
                Image = Category;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Fixed Asset Blocks";
                RunPageLink = "FA Class Code" = field(Code);
                ToolTip = 'Specifies the blocks assigned to Fixed Asset Class.';
            }
        }
    }
}