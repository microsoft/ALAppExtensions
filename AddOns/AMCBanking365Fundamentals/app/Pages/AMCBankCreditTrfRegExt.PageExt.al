pageextension 20108 "AMC Bank Credit Trf. Reg. Ext" extends "Credit Transfer Registers"
{
    layout
    {
        addlast(Group)
        {
            field("XTL Journal"; "AMC Bank XTL Journal")
            {
                ApplicationArea = Basic, Suite;
                Importance = Additional;
                ToolTip = 'XTL Journal associated with the Credit Transfer Register';
            }
        }
    }

}