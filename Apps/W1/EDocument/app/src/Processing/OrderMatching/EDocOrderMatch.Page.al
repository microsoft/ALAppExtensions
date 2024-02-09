namespace Microsoft.eServices.EDocument.OrderMatch;

page 6164 "E-Doc. Order Match"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "E-Doc. Order Match";
    Caption = 'E-Document Match Details';
    DataCaptionExpression = 'E-Document ' + Format(Rec."E-Document Entry No.");
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Matches)
            {
                field("Imported Line No."; Rec."E-Document Line No.")
                {
                    Caption = 'E-Document Line No.';
                    ToolTip = 'Specifies E-Document Imported Line No.';
                }
                field("Document Line No."; Rec."Document Line No.")
                {
                    Caption = 'Purchase Order Line No.';
                    ToolTip = 'Specifies Purchase Order Line No.';
                }
                field("Description"; Rec.Description)
                {
                    Caption = 'Description';
                    ToolTip = 'Specifies the description of what is being matched.';
                }
                field("Matched Quantity"; Rec.Quantity)
                {
                    Caption = 'Matched Quantity';
                    ToolTip = 'Specifies the quantity that was matched for the imported line to the purchase order line.';
                }
            }
        }
    }
}