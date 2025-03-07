namespace Microsoft.eServices.EDocument.OrderMatch;

using Microsoft.Purchases.Document;
using Microsoft.eServices.EDocument;

page 6168 "E-Doc. Purchase Order Sub"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "Purchase Line";
    DeleteAllowed = false;
    InsertAllowed = false;
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                ShowCaption = false;
                field("Line No."; Rec."Line No.")
                {
                    StyleExpr = StyleTxt;
                    Editable = false;
                    ToolTip = 'Specifies purchase order line number.';
                }
                field(Type; Rec.Type)
                {
                    StyleExpr = StyleTxt;
                    Editable = false;
                    ToolTip = 'Specifies the line type.';
                }
                field("No."; Rec."No.")
                {
                    StyleExpr = StyleTxt;
                    Editable = false;
                    ToolTip = 'Specifies what you are buying, such as a product or a general ledger account.';
                }
                field(Description; Rec.Description)
                {
                    StyleExpr = StyleTxt;
                    Editable = false;
                    ToolTip = 'Specifies what is being purchased.';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    StyleExpr = StyleTxt;
                    Editable = false;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours.';
                }
                field("Available Quantity"; AvailableQuantity)
                {
                    Caption = 'Available Quantity';
                    StyleExpr = StyleTxt;
                    Editable = false;
                    ToolTip = 'Specifies the quantity that can be matched to this line.';
                }
                field("Qty. to Invoice"; Rec."Qty. to Invoice")
                {
                    StyleExpr = StyleTxt;
                    Editable = false;
                    ToolTip = 'Specifies the quantity that is matched to this line. Matching imported lines to this line will increase its value with the quantity of the imported line.';
                }
                field("Direct Unit Cost"; Rec."Direct Unit Cost")
                {
                    StyleExpr = StyleTxt;
                    Editable = false;
                    ToolTip = 'Specifies the price of one unit of what you''re buying.';
                }
                field("Line Discount"; Rec."Line Discount %")
                {
                    StyleExpr = StyleTxt;
                    Editable = false;
                    ToolTip = 'Specifies the discount percentage that is granted for the item on the line.';
                }
            }
        }
    }

    var
        EDocumentBeingMatched: Record "E-Document";
        StyleTxt: Text;
        IsMatched: Boolean;
        AvailableQuantity: Decimal;

    trigger OnAfterGetRecord()
    begin
        IsMatched := Rec.HasEDocMatch(EDocumentBeingMatched."Entry No");
        if Rec.Type = Enum::"Purchase Line Type"::Item then
            AvailableQuantity := Rec."Quantity Received" - Rec."Quantity Invoiced"
        else
            AvailableQuantity := Rec."Quantity" - Rec."Quantity Invoiced";
        SetUserInteractions();
    end;

    internal procedure SetUserInteractions()
    begin
        StyleTxt := Rec.GetStyle();
        if IsMatched then
            StyleTxt := 'Favorable';
    end;

    internal procedure SetEDocumentBeingMatched(var EDocument: Record "E-Document")
    begin
        EDocumentBeingMatched := EDocument;
    end;

    internal procedure ResetQtyOnNonMatchedLines()
    var
        EDocOrderMatch: Record "E-Doc. Order Match";
        TempPurchaseLine: Record "Purchase Line" temporary;
        PurchaseLine: Record "Purchase Line";
    begin
        EDocOrderMatch.SetRange("E-Document Entry No.", EDocumentBeingMatched."Entry No");
        GetRecords(TempPurchaseLine);
        if TempPurchaseLine.FindSet() then
            repeat
                EDocOrderMatch.SetRange("Document Order No.", TempPurchaseLine."Document No.");
                EDocOrderMatch.SetRange("Document Line No.", TempPurchaseLine."Line No.");
                EDocOrderMatch.CalcSums("Precise Quantity");
                PurchaseLine.Copy(TempPurchaseLine);
                PurchaseLine.Validate("Qty. to Invoice", EDocOrderMatch."Precise Quantity");
                PurchaseLine.Modify();
            until TempPurchaseLine.Next() = 0;
    end;

    internal procedure GetRecords(var TempPurchaseLine: Record "Purchase Line" temporary)
    var
        PurchaseLine: Record "Purchase Line";
    begin
        Clear(TempPurchaseLine);
        PurchaseLine.SetRange("Document Type", Enum::"Purchase Document Type"::Order);
        PurchaseLine.SetRange("Document No.", EDocumentBeingMatched."Order No.");
        if PurchaseLine.FindSet() then
            repeat
                TempPurchaseLine.TransferFields(PurchaseLine);
                TempPurchaseLine.Insert();
            until PurchaseLine.Next() = 0;
    end;

    internal procedure GetSelectedRecords(var TempPurchaseLine: Record "Purchase Line" temporary)
    var
        PurchaseLine: Record "Purchase Line";
    begin
        Clear(TempPurchaseLine);
        CurrPage.SetSelectionFilter(PurchaseLine);
        if PurchaseLine.FindSet() then
            repeat
                TempPurchaseLine.TransferFields(PurchaseLine);
                TempPurchaseLine.Insert();
            until PurchaseLine.Next() = 0;
    end;

    internal procedure ShowIncompleteMatches()
    var
        AvailableQty: Decimal;
    begin
        Rec.Reset();
        Rec.SetRange("Document Type", Enum::"Purchase Document Type"::Order);
        Rec.SetRange("Document No.", EDocumentBeingMatched."Order No.");
        Rec.SetLoadFields("Quantity Received", "Quantity Invoiced", "Qty. to Invoice");
        if Rec.FindSet() then
            repeat
                AvailableQty := Rec."Quantity Received" - Rec."Quantity Invoiced";
                if AvailableQty <> Rec."Qty. to Invoice" then
                    Rec.Mark(true);
            until Rec.Next() = 0;
        Rec.MarkedOnly(true);
        CurrPage.Update(false);
    end;

    internal procedure ShowAll()
    begin
        Rec.ClearMarks();
        Rec.MarkedOnly(false);
        CurrPage.Update(false);
    end;

}