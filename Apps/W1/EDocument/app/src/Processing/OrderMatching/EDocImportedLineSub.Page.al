namespace Microsoft.eServices.EDocument.OrderMatch;

using Microsoft.eServices.EDocument;

page 6165 "E-Doc. Imported Line Sub"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "E-Doc. Imported Line";
    DeleteAllowed = false;
    InsertAllowed = false;
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                ShowCaption = false;
                field("Line No."; Rec."Line No.")
                {
                    StyleExpr = StyleTxt;
                    Editable = false;
                    ToolTip = 'Specifies imported line number.';
                }
                field("No."; Rec."No.")
                {
                    StyleExpr = StyleTxt;
                    Editable = false;
                    ToolTip = 'Specifies what you received, such as a product or a general ledger account.';
                }
                field(Description; Rec.Description)
                {
                    StyleExpr = StyleTxt;
                    Editable = false;
                    ToolTip = 'Specifies the description of what was received.';
                }
                field("Unit Of Measure Code"; Rec."Unit Of Measure Code")
                {
                    StyleExpr = StyleTxt;
                    Editable = false;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours.';
                }
                field(Quantity; Rec.Quantity)
                {
                    Caption = 'Quantity';
                    StyleExpr = StyleTxt;
                    Editable = false;
                    ToolTip = 'Specifies the quantity that was received.';
                }
                field("Matched Quantity"; Rec."Matched Quantity")
                {
                    Editable = false;
                    ToolTip = 'Specifies the quantity that matched to purchase order lines.';

                    trigger OnDrillDown()
                    begin
                        if Rec."Matched Quantity" > 0 then
                            Rec.DisplayMatches();
                    end;

                }
                field("Unit Price"; Rec."Direct Unit Cost")
                {
                    Editable = false;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the price of one unit of what you received.';
                }
                field("Discount %"; Rec."Line Discount %")
                {
                    Editable = false;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the discount percentage that is granted for the line.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(CreatePurchaseOrderLine)
            {
                ApplicationArea = All;
                Caption = 'Create purchase order Line';
                ToolTip = 'Create purchase order line based on this imported line.';
                Image = NewRow;
                Ellipsis = true;
                Scope = Repeater;
                Visible = IsPurchaseOrder;

                trigger OnAction()
                var
                    EDocLineMatching: Codeunit "E-Doc. Line Matching";
                begin
                    if Rec.Quantity = Rec."Matched Quantity" then
                        Error(CannotCreateLinesForMatchedLinesErr);
                    EDocLineMatching.CreatePurchaseOrderLine(EDocumentBeingMatched, Rec);
                end;
            }
        }
    }

    var
        EDocumentBeingMatched: Record "E-Document";
        StyleTxt: Text;
        IsPurchaseOrder: Boolean;
        CannotCreateLinesForMatchedLinesErr: Label 'You cannot create purchase order lines for E-Document lines that are already matched.';

    trigger OnAfterGetRecord()
    begin
        SetUserInteractions();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        IsPurchaseOrder := EDocumentBeingMatched."Document Type" = Enum::"E-Document Type"::"Purchase Order";
    end;


    internal procedure GetRecords(var TempEDocumentImportedLine: Record "E-Doc. Imported Line" temporary)
    var
        EDocumentImportedLine: Record "E-Doc. Imported Line";
    begin
        Clear(TempEDocumentImportedLine);
        EDocumentImportedLine.SetRange("E-Document Entry No.", EDocumentBeingMatched."Entry No");
        if EDocumentImportedLine.FindSet() then
            repeat
                TempEDocumentImportedLine.TransferFields(EDocumentImportedLine);
                TempEDocumentImportedLine.Insert();
            until EDocumentImportedLine.Next() = 0;
    end;

    internal procedure GetSelectedRecords(var TempEDocumentImportedLine: Record "E-Doc. Imported Line" temporary)
    var
        EDocumentImportedLine: Record "E-Doc. Imported Line";
    begin
        Clear(TempEDocumentImportedLine);
        CurrPage.SetSelectionFilter(EDocumentImportedLine);
        if EDocumentImportedLine.FindSet() then
            repeat
                TempEDocumentImportedLine.TransferFields(EDocumentImportedLine);
                TempEDocumentImportedLine.Insert();
            until EDocumentImportedLine.Next() = 0;
    end;

    internal procedure SetEDocumentBeingMatched(var EDocument: Record "E-Document")
    begin
        EDocumentBeingMatched := EDocument;
    end;

    internal procedure SetUserInteractions()
    begin
        StyleTxt := Rec.GetStyle();
    end;

    internal procedure ShowIncompleteMatches()
    begin
        Rec.Reset();
        Rec.SetRange("E-Document Entry No.", EDocumentBeingMatched."Entry No");
        if Rec.FindSet() then
            repeat
                if not Rec."Fully Matched" then
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