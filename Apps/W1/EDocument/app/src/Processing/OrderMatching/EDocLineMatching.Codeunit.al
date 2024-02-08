namespace Microsoft.eServices.EDocument.OrderMatch;

using Microsoft.Bank.Reconciliation;
using Microsoft.eServices.EDocument;
using Microsoft.Purchases.Document;
using System.Utilities;


codeunit 6164 "E-Doc. Line Matching"
{
    Access = Internal;

    var
        EmptyRecordErr: Label 'Empty selection cannot be matched.';
        DiscountErr: Label 'Varied Discount found among selected %1 entries. Please review and deselect entries with different Discount in order to match selection', Comment = '%1 - Table name for selected entries';
        DiscountDiffErr: Label 'Varied Discount found in existing matching for Import line %1. Please review and undo previous matching in order to match selection', Comment = '%1 - Import line number';
        UnitCostErr: Label 'Varied Unit Costs found among selected %1 entries. Please review and deselect entries with different Unit Costs in order to match selection', Comment = '%1 - Table name for selected entries';
        UnitCostDiffErr: Label 'Varied Unit Cost found in existing matching for Import line %1. Please review and undo previous matching in order to match selection', Comment = '%1 - Import line number';
        MatchErr: Label '%1 discrepancy detected in 1 or more matches for Purchase Line %2. %3 is required across all matches.', Comment = '%1 - Field Caption, %2 - Purchase Line No., %3 - Field Caption';
        UOMErr: Label 'Varied Unit Of Measures found among selected %1 entries. Please review and deselect entries with different Unit Of Measures in order to match selection', Comment = '%1 - Table name for selected entries';
        UnmatchedImportLineErr: Label 'Matching of Imported Line %1 is incomplete. It is not fully matched to purchase order lines.', Comment = '%1 - Imported Line No.';
        OverwriteExistingMatchesTxt: Label 'There are lines for this e-document that are already matched with this purchase order.\\ Do you want to overwrite the existing matches?';
        PurchaseHeaderAlreadyLinkedErr: Label 'Cannot apply to purchase order as it is already linked to E-Document';


    procedure RunMatching(var EDocument: Record "E-Document")
    var
        EDocOrderLineMatching: Page "E-Doc. Order Line Matching";
    begin
        EDocOrderLineMatching.SetRecord(EDocument);
        EDocOrderLineMatching.RunModal();
    end;

    procedure ApplyToPurchaseOrder(var EDocument: Record "E-Document"; var TempEDocumentImportedLine: Record "E-Doc. Imported Line" temporary)
    var
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        EDocOrderMatch: Record "E-Doc. Order Match";
        EDocService: Record "E-Document Service";
        EDocumentLog: Codeunit "E-Document Log";
        EDocLogHelper: Codeunit "E-Document Log Helper";
        RecordRef: RecordRef;
    begin
        // Check that all imorted lines have been matched
        if TempEDocumentImportedLine.FindSet() then
            repeat
                if TempEDocumentImportedLine."Matched Quantity" <> TempEDocumentImportedLine.Quantity then
                    Error(UnmatchedImportLineErr, TempEDocumentImportedLine."Line No.");
            until TempEDocumentImportedLine.Next() = 0;

        RecordRef.Get(EDocument."Document Record ID");
        RecordRef.SetTable(PurchaseHeader);
        PurchaseHeader.Validate("Document Date", EDocument."Document Date");
        PurchaseHeader.Validate("Vendor Invoice No.", EDocument."Incoming E-Document No.");
        if PurchaseHeader.IsLinkedToEDoc(EDocument) then
            Error(PurchaseHeaderAlreadyLinkedErr);
        PurchaseHeader.Validate("E-Document Link", EDocument.SystemId);
        PurchaseHeader.Modify();


        EDocOrderMatch.SetRange("E-Document Entry No.", EDocument."Entry No");
        EDocOrderMatch.SetRange("Document Order No.", EDocument."Order No.");
        PurchaseLine.SetRange("Document Type", Enum::"Purchase Document Type"::Order);
        PurchaseLine.SetRange("Document No.", EDocument."Order No.");


        if PurchaseLine.FindSet() then
            repeat
                EDocOrderMatch.SetRange("Document Line No.", PurchaseLine."Line No.");
                // We check that if there is a set, then Direct Cost, UOM and Discount % is all the same, otherwise we cant
                TestFieldsAreTheSameInSet(EDocOrderMatch);

                if EDocOrderMatch.FindFirst() then begin
                    if PurchaseLine."Direct Unit Cost" <> EDocOrderMatch."Direct Unit Cost" then
                        PurchaseLine.Validate("Direct Unit Cost", EDocOrderMatch."Direct Unit Cost");
                    if PurchaseLine."Line Discount %" <> EDocOrderMatch."Line Discount %" then
                        PurchaseLine.Validate("Line Discount %", EDocOrderMatch."Line Discount %");
                    PurchaseLine.Validate("Amount Including VAT");
                    PurchaseLine.Modify();
                end
            until PurchaseLine.Next() = 0;

        EDocService := EDocumentLog.GetLastServiceFromLog(EDocument);
        EDocLogHelper.InsertLog(EDocument, EDocService, Enum::"E-Document Service Status"::"Order Updated");
    end;

    local procedure TestFieldsAreTheSameInSet(var EDocOrderMatch: Record "E-Doc. Order Match")
    var
        EDocOrderMatch2: Record "E-Doc. Order Match";
    begin
        if not EDocOrderMatch.FindFirst() then
            exit;

        EDocOrderMatch2.Copy(EDocOrderMatch);
        if EDocOrderMatch2.FindSet() then
            repeat
                if EDocOrderMatch2."Direct Unit Cost" <> EDocOrderMatch."Direct Unit Cost" then
                    Error(MatchErr, EDocOrderMatch.FieldCaption("Direct Unit Cost"), EDocOrderMatch."Document Line No.", EDocOrderMatch.FieldCaption("Direct Unit Cost"));
                if EDocOrderMatch2."Line Discount %" <> EDocOrderMatch."Line Discount %" then
                    Error(MatchErr, EDocOrderMatch.FieldCaption("Line Discount %"), EDocOrderMatch."Document Line No.", EDocOrderMatch.FieldCaption("Line Discount %"));
            until EDocOrderMatch2.Next() = 0;
    end;

    procedure ResetMatchedQty(var TempEDocumentImportedLine: Record "E-Doc. Imported Line" temporary)
    begin
        UpdateMatchedQty(TempEDocumentImportedLine, -TempEDocumentImportedLine."Matched Quantity");
    end;

    procedure UpdateMatchedQty(var TempEDocumentImportedLine: Record "E-Doc. Imported Line" temporary; Quantity: Integer)
    begin
        TempEDocumentImportedLine.Validate("Matched Quantity", TempEDocumentImportedLine."Matched Quantity" + Quantity);
        TempEDocumentImportedLine.Modify(true);
    end;

    procedure ResetQtyToInvoice(var TempPurchaseLine: Record "Purchase Line" temporary)
    begin
        UpdateQtyToInvoice(TempPurchaseLine, -TempPurchaseLine."Qty. to Invoice");
    end;

    procedure UpdateQtyToInvoice(var TempPurchaseLine: Record "Purchase Line" temporary; Quantity: Integer)
    begin
        TempPurchaseLine.Validate("Qty. to Invoice", TempPurchaseLine."Qty. to Invoice" + Quantity);
        TempPurchaseLine.Modify(true);
    end;

    procedure PersistsUpdates(var TempEDocMatchesThatWasMatched: Record "E-Doc. Order Match" temporary; RemoveMatch: Boolean)
    var
        EDocImportedLine: Record "E-Doc. Imported Line";
        EDocOrderMatch: Record "E-Doc. Order Match";
        PurchaseLine: Record "Purchase Line";
    begin
        TempEDocMatchesThatWasMatched.Reset();
        if TempEDocMatchesThatWasMatched.FindSet() then
            repeat
                EDocOrderMatch.Copy(TempEDocMatchesThatWasMatched);
                PurchaseLine := EDocOrderMatch.GetPurchaseLine();
                PurchaseLine.Validate("Qty. to Invoice", PurchaseLine."Qty. to Invoice" + EDocOrderMatch.Quantity);
                PurchaseLine.Modify(true);

                EDocImportedLine := EDocOrderMatch.GetImportedLine();
                EDocImportedLine.Validate("Matched Quantity", EDocImportedLine."Matched Quantity" + EDocOrderMatch.Quantity);
                EDocImportedLine.Modify(true);

                if RemoveMatch then
                    EDocOrderMatch.Delete()
                else
                    EDocOrderMatch.Insert();

            until TempEDocMatchesThatWasMatched.Next() = 0;
    end;

    procedure ResetQtyToInvoiceBasedOnMatches(var EDocument: Record "E-Document"; var TempPurchaseLine: Record "Purchase Line" temporary)
    var
        EDocOrderMatch: Record "E-Doc. Order Match";
    begin
        EDocOrderMatch.SetRange("E-Document Entry No.", EDocument."Entry No");
        TempPurchaseLine.Reset();
        if TempPurchaseLine.FindSet() then
            repeat
                EDocOrderMatch.SetRange("Document Order No.", TempPurchaseLine."Document No.");
                EDocOrderMatch.SetRange("Document Line No.", TempPurchaseLine."Line No.");
                EDocOrderMatch.CalcSums(Quantity);
                TempPurchaseLine.Validate("Qty. to Invoice", EDocOrderMatch.Quantity);
                TempPurchaseLine.Modify();
            until TempPurchaseLine.Next() = 0;
    end;

    procedure ResetQtyToInvoice(var EDocument: Record "E-Document")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange("Document Type", Enum::"Purchase Document Type"::Order);
        PurchaseLine.SetRange("Document No.", EDocument."Order No.");
        PurchaseLine.ModifyAll("Qty. to Invoice", 0, true);
    end;

    procedure RemoveAllMatches(var EDocument: Record "E-Document")
    var
        EDocOrderMatch: Record "E-Doc. Order Match";
        EDocImportedLine: Record "E-Doc. Imported Line";
        PurchaseLine: Record "Purchase Line";
    begin
        EDocOrderMatch.SetRange("E-Document Entry No.", EDocument."Entry No");
        EDocOrderMatch.DeleteAll();

        EDocImportedLine.SetRange("E-Document Entry No.", EDocument."Entry No");
        EDocImportedLine.ModifyAll("Matched Quantity", 0);
        EDocImportedLine.ModifyAll("Fully Matched", false);

        PurchaseLine.SetRange("Document Type", Enum::"Purchase Document Type"::Order);
        PurchaseLine.SetRange("Document No.", EDocument."Order No.");
        PurchaseLine.ModifyAll("Qty. to Invoice", 0);
    end;

    procedure FindMatchesToRemove(var EDocument: Record "E-Document"; var TempPurchaseLine: Record "Purchase Line" temporary; var TempEDocMatchesThatWasRemoved: Record "E-Doc. Order Match" temporary)
    var
        EDocOrderMatch: Record "E-Doc. Order Match";
    begin
        if TempPurchaseLine.FindSet() then begin
            EDocOrderMatch.SetRange("E-Document Entry No.", EDocument."Entry No");
            EDocOrderMatch.SetRange("Document Order No.", TempPurchaseLine."Document No.");
            repeat
                EDocOrderMatch.SetRange("Document Line No.", TempPurchaseLine."Line No.");
                if EDocOrderMatch.FindSet() then
                    repeat
                        TempEDocMatchesThatWasRemoved := EDocOrderMatch;
                        TempEDocMatchesThatWasRemoved.Quantity *= -1;
                        TempEDocMatchesThatWasRemoved.Insert();
                    until EDocOrderMatch.Next() = 0;
            until TempPurchaseLine.Next() = 0;
        end
    end;


    procedure MatchManually(var TempEDocumentImportedLine: Record "E-Doc. Imported Line" temporary; var TempPurchaseLine: Record "Purchase Line" temporary; var TempEDocMatchesThatWasMatched: Record "E-Doc. Order Match" temporary)
    begin
        if TempEDocumentImportedLine.IsEmpty() or TempPurchaseLine.IsEmpty() then
            Error(EmptyRecordErr);

        VerifyPurchaseOrderLinesHaveSameFieldValuesOrError(TempPurchaseLine);
        VerifyImportedLinesHaveSameFieldValuesOrError(TempEDocumentImportedLine);
        VerifyExistingMatchesHasSameFieldValue(TempEDocumentImportedLine, TempPurchaseLine);
        if TempPurchaseLine.FindSet() then
            repeat
                MatchManyToOne(TempEDocumentImportedLine, TempPurchaseLine, TempEDocMatchesThatWasMatched);
            until TempPurchaseLine.Next() = 0;
    end;


    local procedure VerifyImportedLinesHaveSameFieldValuesOrError(var TempEDocumentImportedLine: Record "E-Doc. Imported Line" temporary)
    var
        UnitCost: Decimal;
        Discount: Decimal;
        UOM: Code[20];
    begin
        TempEDocumentImportedLine.FindFirst();
        UnitCost := TempEDocumentImportedLine."Direct Unit Cost";
        Discount := TempEDocumentImportedLine."Line Discount %";
        UOM := TempEDocumentImportedLine."Unit of Measure Code";
        TempEDocumentImportedLine.FindSet();
        repeat
            if UnitCost <> TempEDocumentImportedLine."Direct Unit Cost" then
                Error(UnitCostErr, TempEDocumentImportedLine.TableCaption());
            if Discount <> TempEDocumentImportedLine."Line Discount %" then
                Error(DiscountErr, TempEDocumentImportedLine.TableCaption());
            if UOM <> TempEDocumentImportedLine."Unit of Measure Code" then
                Error(UOMErr, TempEDocumentImportedLine.TableCaption());
        until TempEDocumentImportedLine.Next() = 0;
    end;

    local procedure VerifyPurchaseOrderLinesHaveSameFieldValuesOrError(var TempPurchaseLine: Record "Purchase Line" temporary)
    var
        UnitCost: Decimal;
        Discount: Decimal;
        UOM: Code[20];
    begin
        TempPurchaseLine.FindFirst();
        UnitCost := TempPurchaseLine."Direct Unit Cost";
        Discount := TempPurchaseLine."Line Discount %";
        UOM := TempPurchaseLine."Unit of Measure Code";
        TempPurchaseLine.FindSet();
        repeat
            if UnitCost <> TempPurchaseLine."Direct Unit Cost" then
                Error(UnitCostErr, TempPurchaseLine.TableCaption());
            if Discount <> TempPurchaseLine."Line Discount %" then
                Error(DiscountErr, TempPurchaseLine.TableCaption());
            if UOM <> TempPurchaseLine."Unit of Measure Code" then
                Error(UOMErr, TempPurchaseLine.TableCaption());
        until TempPurchaseLine.Next() = 0;
    end;

    local procedure VerifyExistingMatchesHasSameFieldValue(var TempEDocImportedLine: Record "E-Doc. Imported Line" temporary; var TempPurchaseLine: Record "Purchase Line" temporary)
    var
        EDocOrderMatch: Record "E-Doc. Order Match";
    begin
        TempPurchaseLine.FindFirst();
        TempEDocImportedLine.FindFirst();

        EDocOrderMatch.SetRange("Document Order No.", TempPurchaseLine."Document No.");
        EDocOrderMatch.SetRange("E-Document Entry No.", TempEDocImportedLine."E-Document Entry No.");
        EDocOrderMatch.SetRange("Document Line No.", TempPurchaseLine."Line No.");
        if EDocOrderMatch.FindFirst() then begin
            if EDocOrderMatch."Direct Unit Cost" <> TempEDocImportedLine."Direct Unit Cost" then
                Error(UnitCostDiffErr, EDocOrderMatch."E-Document Line No.");
            if EDocOrderMatch."Line Discount %" <> TempEDocImportedLine."Line Discount %" then
                Error(DiscountDiffErr, EDocOrderMatch."E-Document Line No.");
        end;
    end;

    procedure AskToOverwrite(EDocument: Record "E-Document"; var TempEDocumentImportedLine: Record "E-Doc. Imported Line" temporary; var TempPurchaseLine: Record "Purchase Line" temporary)
    var
        EDocOrderMatch: Record "E-Doc. Order Match";
        PurchaseLine: Record "Purchase Line";
        EDocImportedLine: Record "E-Doc. Imported Line";
        ConfirmManagement: Codeunit "Confirm Management";
        Overwrite: Boolean;
    begin
        EDocOrderMatch.SetRange("E-Document Entry No.", EDocument."Entry No");
        if not EDocOrderMatch.IsEmpty() then begin
            Overwrite := ConfirmManagement.GetResponseOrDefault(OverwriteExistingMatchesTxt, false);
            if Overwrite then begin
                // Reset filters and qty
                TempEDocumentImportedLine.Reset();
                TempPurchaseLine.Reset();
                if TempPurchaseLine.FindSet() then
                    repeat
                        ResetQtyToInvoice(TempPurchaseLine);
                        PurchaseLine := TempPurchaseLine;
                        PurchaseLine.Modify(true);
                    until TempPurchaseLine.Next() = 0;

                if TempEDocumentImportedLine.FindSet() then
                    repeat
                        ResetMatchedQty(TempEDocumentImportedLine);
                        EDocImportedLine := TempEDocumentImportedLine;
                        EDocImportedLine.Modify(true);
                    until TempEDocumentImportedLine.Next() = 0;

                EDocOrderMatch.DeleteAll();
            end
        end;
    end;

    procedure MatchAutomatically(EDocument: Record "E-Document"; var TempEDocumentImportedLine: Record "E-Doc. Imported Line" temporary; var TempPurchaseLine: Record "Purchase Line" temporary; var TempEDocMatchesThatWasMatched: Record "E-Doc. Order Match" temporary)
    var
        RecordMatchMgt: Codeunit "Record Match Mgt.";
    begin
        if TempEDocumentImportedLine.IsEmpty() or TempPurchaseLine.IsEmpty() then
            Error(EmptyRecordErr);

        // Automatic matching will do the following
        // - For each Import Line, try to get full assignment in 1 or more PO lines
        // - Filter on Type, then Number, Then Text 

        if TempEDocumentImportedLine.FindSet() then
            repeat

                // Match based on Number
                TempPurchaseLine.Reset();
                TempPurchaseLine.SetRange("No.", TempEDocumentImportedLine."No.");
                TempPurchaseLine.SetRange("Unit of Measure Code", TempEDocumentImportedLine."Unit Of Measure Code");
                TempPurchaseLine.SetRange("Direct Unit Cost", TempEDocumentImportedLine."Direct Unit Cost");
                TempPurchaseLine.SetRange("Line Discount %", TempEDocumentImportedLine."Line Discount %");

                MatchOneToMany(TempEDocumentImportedLine, TempPurchaseLine, TempEDocMatchesThatWasMatched);

                if TempEDocumentImportedLine.Quantity > TempEDocumentImportedLine."Matched Quantity" then begin

                    // We still have more to match for imported line
                    TempPurchaseLine.SetRange("No.");
                    TempPurchaseLine.SetFilter("No.", '<>%1', TempEDocumentImportedLine."No.");
                    if TempPurchaseLine.FindSet() then
                        // TO precheck to avoid unessesary Calc String Nearness
                        if TempPurchaseLine.MaxQtyToInvoice() > TempPurchaseLine."Qty. to Invoice" then
                            // If substring is 80% match
                            if RecordMatchMgt.CalculateStringNearness(TempPurchaseLine.Description, TempEDocumentImportedLine.Description, 4, 100) > 80 then
                                MatchOneToOne(TempEDocumentImportedLine, TempPurchaseLine, TempEDocMatchesThatWasMatched);
                end;
            until TempEDocumentImportedLine.Next() = 0;

        // Reset filters before exit
        TempPurchaseLine.Reset();
        TempEDocumentImportedLine.Reset();
    end;

    procedure InsertOrderMatch(var TempEDocumentImportedLine: Record "E-Doc. Imported Line" temporary; var TempPurchaseLine: Record "Purchase Line" temporary; var TempEDocMatchesThatWasMatched: Record "E-Doc. Order Match" temporary; Quantity: Integer; FullMatch: Boolean)
    begin
        TempEDocMatchesThatWasMatched.SetRange("Document Order No.", TempPurchaseLine."Document No.");
        TempEDocMatchesThatWasMatched.SetRange("Document Line No.", TempPurchaseLine."Line No.");
        TempEDocMatchesThatWasMatched.SetRange("E-Document Entry No.", TempEDocumentImportedLine."E-Document Entry No.");
        TempEDocMatchesThatWasMatched.SetRange("E-Document Line No.", TempEDocumentImportedLine."Line No.");
        TempEDocMatchesThatWasMatched.DeleteAll();
        TempEDocMatchesThatWasMatched.Reset();

        TempEDocMatchesThatWasMatched.Init();
        TempEDocMatchesThatWasMatched.Validate("Document Order No.", TempPurchaseLine."Document No.");
        TempEDocMatchesThatWasMatched.Validate("Document Line No.", TempPurchaseLine."Line No.");
        TempEDocMatchesThatWasMatched.Validate("E-Document Entry No.", TempEDocumentImportedLine."E-Document Entry No.");
        TempEDocMatchesThatWasMatched.Validate("E-Document Line No.", TempEDocumentImportedLine."Line No.");
        TempEDocMatchesThatWasMatched.Validate(Quantity, Quantity);
        TempEDocMatchesThatWasMatched.Validate("Direct Unit Cost", TempEDocumentImportedLine."Direct Unit Cost");
        TempEDocMatchesThatWasMatched.Validate("Line Discount %", TempEDocumentImportedLine."Line Discount %");
        TempEDocMatchesThatWasMatched.Validate("Unit of Measure Code", TempEDocumentImportedLine."Unit of Measure Code");
        TempEDocMatchesThatWasMatched.Validate("Fully Matched", FullMatch);
        TempEDocMatchesThatWasMatched.Description := TempEDocumentImportedLine.Description;
        TempEDocMatchesThatWasMatched.Insert();
    end;

    procedure MatchOneToOne(var TempEDocumentImportedLine: Record "E-Doc. Imported Line" temporary; var TempPurchaseLine: Record "Purchase Line" temporary; var TempEDocMatchesThatWasMatched: Record "E-Doc. Order Match" temporary)
    var
        RemaningQuantityToMatch, TotalThatCanBeInvoiced : Integer;
        FullMatch: Boolean;
    begin
        // Calculate the quantity that is available to match for purchase order line
        TotalThatCanBeInvoiced := (TempPurchaseLine."Quantity Received" - TempPurchaseLine."Quantity Invoiced") - TempPurchaseLine."Qty. to Invoice";
        if TotalThatCanBeInvoiced < 1 then
            exit;

        // Calculate the quantity available to match for this imported line. 
        RemaningQuantityToMatch := TempEDocumentImportedLine.Quantity - TempEDocumentImportedLine."Matched Quantity";
        if RemaningQuantityToMatch < TotalThatCanBeInvoiced then begin
            TotalThatCanBeInvoiced := RemaningQuantityToMatch;
            FullMatch := true;
        end;

        if TotalThatCanBeInvoiced < 1 then
            exit;

        TempPurchaseLine.Validate("Qty. to Invoice", TempPurchaseLine."Qty. to Invoice" + TotalThatCanBeInvoiced);
        TempPurchaseLine.Modify(true);
        TempEDocumentImportedLine.Validate("Matched Quantity", TempEDocumentImportedLine."Matched Quantity" + TotalThatCanBeInvoiced);
        TempEDocumentImportedLine.Modify(true);
        InsertOrderMatch(TempEDocumentImportedLine, TempPurchaseLine, TempEDocMatchesThatWasMatched, TotalThatCanBeInvoiced, FullMatch);
    end;

    procedure MatchManyToOne(var TempEDocumentImportedLine: Record "E-Doc. Imported Line" temporary; var TempPurchaseLine: Record "Purchase Line" temporary; var TempEDocMatchesThatWasMatched: Record "E-Doc. Order Match" temporary)
    begin
        if TempEDocumentImportedLine.FindSet() then
            repeat
                MatchOneToOne(TempEDocumentImportedLine, TempPurchaseLine, TempEDocMatchesThatWasMatched)
            until TempEDocumentImportedLine.Next() = 0;
    end;

    procedure MatchOneToMany(var TempEDocumentImportedLine: Record "E-Doc. Imported Line" temporary; var TempPurchaseLine: Record "Purchase Line" temporary; var TempEDocMatchesThatWasMatched: Record "E-Doc. Order Match" temporary)
    begin
        if TempPurchaseLine.FindSet() then
            repeat
                MatchOneToOne(TempEDocumentImportedLine, TempPurchaseLine, TempEDocMatchesThatWasMatched)
            until TempPurchaseLine.Next() = 0;
    end;


    procedure FilterOutFullyMatchedLines(var TempEDocumentImportedLine: Record "E-Doc. Imported Line" temporary; var TempPurchaseLine: Record "Purchase Line" temporary)
    var
        TotalThatCanBeInvoiced: Integer;
    begin
        TempEDocumentImportedLine.SetRange("Fully Matched", false);

        if TempPurchaseLine.FindSet() then
            repeat
                TotalThatCanBeInvoiced := (TempPurchaseLine."Quantity Received" - TempPurchaseLine."Quantity Invoiced") - TempPurchaseLine."Qty. to Invoice";
                if TotalThatCanBeInvoiced > 0 then
                    TempPurchaseLine.Mark(true);
            until TempPurchaseLine.Next() = 0;
        TempPurchaseLine.MarkedOnly(true);
    end;

    procedure SumUnitCostForMatches(EDocument: Record "E-Document") Sum: Decimal
    var
        EDocOrderMatch: Record "E-Doc. Order Match";
    begin
        EDocOrderMatch.SetRange("E-Document Entry No.", EDocument."Entry No");
        EDocOrderMatch.SetRange("Document Order No.", EDocument."Order No.");
        if EDocOrderMatch.FindSet() then
            repeat
                Sum += EDocOrderMatch.Quantity * EDocOrderMatch."Direct Unit Cost";
            until EDocOrderMatch.Next() = 0;
    end;
}