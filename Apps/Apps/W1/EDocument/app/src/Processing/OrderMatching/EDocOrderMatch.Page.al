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
                field("EDoc Description"; Rec."E-Document Description")
                {
                    Caption = 'E-Document Description';
                    ToolTip = 'Specifies the description of matched E-Document line.';
                }
                field("Description"; Rec."PO Description")
                {
                    Caption = 'Purchase order Description';
                    ToolTip = 'Specifies the description of matched Purchase Order Line.';
                }
                field("Matched Quantity"; Rec."Precise Quantity")
                {
                    Caption = 'Matched Quantity';
                    ToolTip = 'Specifies the quantity that was matched for the imported line to the purchase order line.';
                }
                field("E-Document Direct Unit Cost"; Rec."E-Document Direct Unit Cost")
                {
                    Caption = 'E-Document Unit Cost';
                    ToolTip = 'Specifies the direct unit cost of the E-Document line.';
                }
                field("PO Direct Unit Cost"; Rec."PO Direct Unit Cost")
                {
                    Caption = 'Purchase Order Unit Cost';
                    ToolTip = 'Specifies the direct unit cost of the purchase order line.';
                }
            }
        }
    }
}