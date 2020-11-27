pageextension 11713 "Item Reclass. Journal CZL" extends "Item Reclass. Journal"
{
    layout
    {
        addafter("Document Date")
        {
            field("Invt. Movement Template CZL"; Rec."Invt. Movement Template CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the template for item movement.';

                trigger OnLookup(var Text: Text): Boolean
                var
                    InvtMovementTemplate: Record "Invt. Movement Template CZL";
                begin
                    InvtMovementTemplate.SetRange("Entry Type", Rec."Entry Type"::Transfer);
                    if Page.RunModal(0, InvtMovementTemplate) = Action::LookupOK then
                        Rec.Validate("Invt. Movement Template CZL", InvtMovementTemplate.Name);
                end;
            }
        }
    }
}
