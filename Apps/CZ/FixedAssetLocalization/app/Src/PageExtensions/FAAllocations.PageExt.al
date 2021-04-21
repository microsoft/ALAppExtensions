pageextension 31169 "FA Allocations CZF" extends "FA Allocations"
{
    layout
    {
        addafter("Allocation %")
        {
            field("Reason/Maintenance Code CZF"; Rec."Reason/Maintenance Code CZF")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies the reason code on the entry.';
            }
        }
    }
}
