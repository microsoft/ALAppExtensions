pageextension 18447 "GST Posted Service Cr Memos" extends "Posted Service Credit Memos"
{
    layout
    {
        addafter("Document Exchange Status")
        {
            field("GST Reason Type"; Rec."GST Reason Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the reason of return or credit memo of a posted document where gst is applicable. For example Deficiency in Service/Correction in Invoice etc.';
            }
        }
    }
}