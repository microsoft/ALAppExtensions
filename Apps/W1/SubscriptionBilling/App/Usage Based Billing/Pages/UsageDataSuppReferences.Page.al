namespace Microsoft.SubscriptionBilling;

page 8043 "Usage Data Supp. References"
{
    ApplicationArea = All;
    SourceTable = "Usage Data Supplier Reference";
    Caption = 'Usage Data Supplier References';
    UsageCategory = Lists;
    PageType = List;
    LinksAllowed = false;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the sequential number assigned to the record when it was created.';
                    Visible = false;
                }
                field("Supplier No."; Rec."Supplier No.")
                {
                    ToolTip = 'Specifies the number of the supplier to which this reference refers.';
                }
                field("Supplier Description"; Rec."Supplier Description")
                {
                    ToolTip = 'Specifies the description of the supplier to which this reference refers.';
                }
                field("Type"; Rec."Type")
                {
                    ToolTip = 'Specifies what type of reference this is.';
                }
                field("Supplier Reference"; Rec."Supplier Reference")
                {
                    ToolTip = 'Specifies the reference for the supplier.';
                }

            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if Rec.GetFilter(Type) <> '' then
            Rec.Type := Rec.GetRangeMin(Type);
    end;
}
