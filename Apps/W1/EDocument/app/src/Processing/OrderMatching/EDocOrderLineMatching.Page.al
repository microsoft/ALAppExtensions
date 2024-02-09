namespace Microsoft.eServices.EDocument.OrderMatch;

using Microsoft.eServices.EDocument;
using System.Utilities;
using Microsoft.Purchases.Document;

page 6167 "E-Doc. Order Line Matching"
{
    Caption = 'Purchase Order Matching';
    DataCaptionExpression = 'Purchase Order ' + Rec."Order No.";
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "E-Document";
    InsertAllowed = false;
    DeleteAllowed = false;
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            group("Document Details")
            {
                ShowCaption = false;
                field("Bill-to/Pay-to Name"; Rec."Bill-to/Pay-to Name")
                {
                    Caption = 'Vendor Name';
                    ToolTip = 'Specifies the customer/vendor name of the electronic document.';
                }
                field("Incoming E-Document No."; Rec."Incoming E-Document No.")
                {
                    Caption = 'E-Document No.';
                    ToolTip = 'Specifies the electronic document number.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    Caption = 'E-Document Date';
                    ToolTip = 'Specifies the electronic document date.';
                }
                field("Amount Excl. VAT"; Rec."Amount Excl. VAT")
                {
                    Caption = 'E-Document Amount';
                    ToolTip = 'Specifies the e-document amount excluding VAT.';
                }

            }
            group(Control8)
            {
                ShowCaption = false;
                part(ImportedLines; "E-Doc. Imported Line Sub")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Imported Lines';
                    SubPageLink = "E-Document Entry No." = field("Entry No");
                    UpdatePropagation = Both;
                }
                part(OrderLines; "E-Doc. Purchase Order Sub")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchase Order Lines';
                    SubPageLink = "Document Type" = filter("Order"), "Document No." = field("Order No."), Type = filter('G/L Account|Item');
                    UpdatePropagation = Both;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ApplyToPO)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Apply To Purchase Order';
                ToolTip = 'Applies the matching and updates purchase order lines';
                Image = ApplyEntries;

                trigger OnAction()
                begin
                    ApplyToPurchaseOrder();
                end;
            }
            action(MatchManual)
            {
                Caption = 'Match Manually';
                ToolTip = 'Manually match selected lines in both panes to link each imported line to one or more related purchase order lines.';
                ApplicationArea = All;
                Image = CheckRulesSyntax;

                trigger OnAction()
                begin
                    MatchManually();
                    SetUserInteractions();
                end;
            }
            action(MatchAutomatic)
            {
                Caption = 'Match Automatically';
                ToolTip = 'Automatically search and match lines that have same Type, No., Unit Price, Discount and Unit Of Measure.';
                ApplicationArea = All;
                Image = MapAccounts;

                trigger OnAction()
                begin
                    MatchAutomatically();
                    SetUserInteractions();
                end;
            }
            action(RemoveMatch)
            {
                Caption = 'Remove Match';
                ToolTip = 'Remove selection of matched purchase order lines.';
                ApplicationArea = All;
                Image = RemoveLine;

                trigger OnAction()
                begin
                    RemoveMatches();
                    SetUserInteractions();
                end;
            }
            action(RemoveAllMatch)
            {
                Caption = 'Reset Matching';
                ToolTip = 'Removes all matches made for E-Document.';
                ApplicationArea = All;
                Image = ResetStatus;

                trigger OnAction()
                begin
                    EDocMatchOrderLines.RemoveAllMatches(Rec);
                    SetUserInteractions();
                end;
            }
            action(ShowNonMatched)
            {
                Caption = 'Show Pending Lines';
                ToolTip = 'Show all e-document lines that have not been completely matched.';
                ApplicationArea = All;
                Image = AddWatch;

                trigger OnAction()
                begin
                    CurrPage.ImportedLines.Page.ShowIncompleteMatches();
                    CurrPage.OrderLines.Page.ShowIncompleteMatches();
                end;
            }
            action(ShowAll)
            {
                Caption = 'Show All Lines';
                ToolTip = 'Show all e-document lines.';
                ApplicationArea = All;
                Image = AddWatch;

                trigger OnAction()
                begin
                    CurrPage.ImportedLines.Page.ShowAll();
                    CurrPage.OrderLines.Page.ShowAll();
                end;
            }
        }
        area(Navigation)
        {
            action(PurchaseOrder)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Purchase Order';
                ToolTip = 'Opens the Purchase Order page with the related order';
                Image = Document;
                RunObject = page "Purchase Order";
                RunPageLink = "No." = field("Order No.");
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(ApplyToPO_Promoted; ApplyToPO) { }
            }
            group(Document)
            {
                actionref(Open_Promoted; PurchaseOrder) { }
            }
            group(Matching)
            {
                actionref(MatchManual_Promoted; MatchManual) { }
                actionref(MatchAuto_Promoted; MatchAutomatic) { }
                actionref(RemoveMatch_Promoted; RemoveMatch) { }
                actionref(RemoveAll_Promoted; RemoveAllMatch) { }
            }
            group(Show)
            {
                actionref(ShowAll_Promoted; ShowAll) { }
                actionref(ShowNonMatched_Promoted; ShowNonMatched) { }
            }
        }
    }

    var
        EDocMatchOrderLines: Codeunit "E-Doc. Line Matching";
        OpenPurchaseOrderMsg: Label 'Purchase order is not Open, which is required in order to match with e-document. Do you want to reopen purchase order?';
        LineDiscountVaryMatchMsg: Label 'Matched e-document lines (%1) has Line Discount % different from matched purchase order line. Please verify matches are correct.', Comment = '%1 - Line number';
        LineCostVaryMatchMsg: Label 'Matched e-document lines (%1) has Direct Unit Cost different from matched purchase order line. Please verify matches are correct.', Comment = '%1 - Line number';

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.OrderLines.Page.SetEDocumentBeingMatched(Rec);
        CurrPage.ImportedLines.Page.SetEDocumentBeingMatched(Rec);
        CurrPage.OrderLines.Page.ResetQtyOnNonMatchedLines();

        CheckPurchaseHeaderOpen();
    end;

    local procedure CheckPurchaseHeaderOpen()
    var
        PurchaseHeader: Record "Purchase Header";
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        PurchaseHeader.Get(Rec."Document Record ID");
        if PurchaseHeader.Status <> Enum::"Purchase Document Status"::Open then
            if ConfirmManagement.GetResponseOrDefault(OpenPurchaseOrderMsg, true) then
                PurchaseHeader.SetStatus(0) // Open
            else
                Error('');
    end;

    local procedure ApplyToPurchaseOrder()
    var
        TempEDocImportedLines: Record "E-Doc. Imported Line" temporary;
        PurchaseHeader: Record "Purchase Header";
        PurchaseOrderPage: Page "Purchase Order";
    begin
        CurrPage.ImportedLines.Page.GetRecords(TempEDocImportedLines);
        EDocMatchOrderLines.ApplyToPurchaseOrder(Rec, TempEDocImportedLines);

        Commit();
        PurchaseHeader.Get(Rec."Document Record ID");
        PurchaseOrderPage.SetRecord(PurchaseHeader);
        PurchaseOrderPage.Run();
        CurrPage.Close();
    end;

    local procedure RemoveMatches()
    var
        TempPurchaseLines: Record "Purchase Line" temporary;
        TempEDocMatches: Record "E-Doc. Order Match" temporary;
    begin
        CurrPage.OrderLines.Page.GetSelectedRecords(TempPurchaseLines);
        EDocMatchOrderLines.FindMatchesToRemove(Rec, TempPurchaseLines, TempEDocMatches);
        if not TempEDocMatches.IsEmpty() then
            EDocMatchOrderLines.PersistsUpdates(TempEDocMatches, true);
    end;

    local procedure MatchManually()
    var
        TempEDocImportedLines: Record "E-Doc. Imported Line" temporary;
        TempPurchaseLines: Record "Purchase Line" temporary;
        TempEDocMatches: Record "E-Doc. Order Match" temporary;
    begin
        CurrPage.ImportedLines.Page.GetSelectedRecords(TempEDocImportedLines);
        CurrPage.OrderLines.Page.GetSelectedRecords(TempPurchaseLines);

        EDocMatchOrderLines.MatchManually(TempEDocImportedLines, TempPurchaseLines, TempEDocMatches);
        if not TempEDocMatches.IsEmpty() then begin
            EDocMatchOrderLines.PersistsUpdates(TempEDocMatches, false);
            NotifyUserIfCostDifference(TempEDocMatches);
        end;
    end;

    local procedure MatchAutomatically()
    var
        TempEDocImportedLines: Record "E-Doc. Imported Line" temporary;
        TempPurchaseLines: Record "Purchase Line" temporary;
        TempEDocMatches: Record "E-Doc. Order Match" temporary;
    begin
        CurrPage.ImportedLines.Page.GetRecords(TempEDocImportedLines);
        CurrPage.OrderLines.Page.GetRecords(TempPurchaseLines);

        EDocMatchOrderLines.AskToOverwrite(Rec, TempEDocImportedLines, TempPurchaseLines);
        EDocMatchOrderLines.MatchAutomatically(Rec, TempEDocImportedLines, TempPurchaseLines, TempEDocMatches);
        if not TempEDocMatches.IsEmpty() then begin
            EDocMatchOrderLines.PersistsUpdates(TempEDocMatches, false);
            NotifyUserIfCostDifference(TempEDocMatches);
        end;
    end;

    local procedure SetUserInteractions()
    begin
        CurrPage.ImportedLines.Page.SetUserInteractions();
        CurrPage.OrderLines.Page.SetUserInteractions();
    end;

    local procedure NotifyUserIfCostDifference(var TempEDocMatches: Record "E-Doc. Order Match" temporary)
    var
        EDocImportedLine: Record "E-Doc. Imported Line";
        PurchaseLine: Record "Purchase Line";
        DiscountNotification, CostNotification : Notification;
        LineDiscountNos, DirectUnitCostNos : Text;
    begin
        if TempEDocMatches.FindSet() then
            repeat
                EDocImportedLine := TempEDocMatches.GetImportedLine();
                PurchaseLine := TempEDocMatches.GetPurchaseLine();
                if EDocImportedLine."Line Discount %" <> PurchaseLine."Line Discount %" then
                    LineDiscountNos += Format(EDocImportedLine."Line No.") + ',';
                if EDocImportedLine."Direct Unit Cost" <> PurchaseLine."Direct Unit Cost" then
                    DirectUnitCostNos += Format(EDocImportedLine."Line No.") + ',';
            until TempEDocMatches.Next() = 0;

        if LineDiscountNos.EndsWith(',') then begin
            LineDiscountNos := LineDiscountNos.Substring(1, StrLen(LineDiscountNos) - 1);
            SendNotification(DiscountNotification, StrSubstNo(LineDiscountVaryMatchMsg, LineDiscountNos));
        end;
        if DirectUnitCostNos.EndsWith(',') then begin
            DirectUnitCostNos := DirectUnitCostNos.Substring(1, StrLen(DirectUnitCostNos) - 1);
            SendNotification(CostNotification, StrSubstNo(LineCostVaryMatchMsg, DirectUnitCostNos));
        end;
    end;

    local procedure SendNotification(SelectionNotification: Notification; Message: Text)
    begin
        SelectionNotification.Scope(NotificationScope::LocalScope);
        SelectionNotification.Message(Message);
        SelectionNotification.Send();
    end;

}