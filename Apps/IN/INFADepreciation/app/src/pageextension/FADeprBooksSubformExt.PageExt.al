pageextension 18633 "FA Depr. Books Subform Ext" extends "FA Depreciation Books Subform"
{
    layout
    {
        addlast(Control1)
        {
            field("First User Defined Depr. Date"; Rec."First User-Defined Depr. Date")
            {
                ToolTip = 'Specifies the first depreciation date where depreciation method is manual.';
                ApplicationArea = FixedAssets;
            }
            field("Salvage Value"; Rec."Salvage Value")
            {
                ToolTip = 'Specifies the salvage value of the asset for the depreciation book.';
                ApplicationArea = FixedAssets;
            }
        }
    }
}