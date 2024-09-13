namespace Microsoft.eServices.EDocument.OrderMatch;

using Microsoft.Bank.Reconciliation;
using Microsoft.eServices.EDocument;
using Microsoft.Purchases.Document;
using System.Utilities;


codeunit 6164 "E-Doc. Line Matching"
{
    Access = Internal;
    Permissions =
        tabledata "E-Doc. Imported Line" = im,
        tabledata "E-Doc. Order Match" = idm;

    var
        EmptyRecordErr: Label 'Empty selection cannot be matched.';
        DiscountErr: Label 'Varied Discount found among selected %1 entries. Please review and deselect entries with different Discount in order to match selection', Comment = '%1 - Table name for selected entries';
        UnitCostErr: Label 'Varied Unit Costs found among selected %1 entries. Please review and deselect entries with different Unit Costs in order to match selection', Comment = '%1 - Table name for selected entries';
        AmountDiffErr: Label 'Varied amounts found in matching for Import line %1. Please review and undo previous matching in order to match selection', Comment = '%1 - Import line number';
        MatchErr: Label 'Discrepancy detected in line amount for 1 or more matches for Purchase Line %1.', Comment = '%1 - Purchase Line No';
        UOMErr: Label 'Varied Unit Of Measures found among selected %1 entries. Please review and deselect entries with different Unit Of Measures in order to match selection', Comment = '%1 - Table name for selected entries';
        UnmatchedImportLineErr: Label 'Matching of Imported Line %1 is incomplete. It is not fully matched to purchase order lines.', Comment = '%1 - Imported Line No.';
        OverwriteExistingMatchesTxt: Label 'There are lines for this e-document that are already matched with this purchase order.\\ Do you want to overwrite the existing matches?';
        PurchaseHeaderAlreadyLinkedErr: Label 'Cannot apply to purchase order as it is already linked to E-Document';


    procedure RunMatching(var EDocument: Record "E-Document")
    begin
        RunMatching(EDocument, false);
    end;

    procedure RunMatching(var EDocument: Record "E-Document"; WithCopilot: Boolean)
    var
        EDocService: Record "E-Document Service";
        EDocServiceStatus: Record "E-Document Service Status";
        EDocLog: Codeunit "E-Document Log";
        EDocOrderLineMatching: Page "E-Doc. Order Line Matching";
    begin
        EDocument.TestField("Document Type", Enum::"E-Document Type"::"Purchase Order");
        EDocument.TestField(Status, Enum::"E-Document Status"::"In Progress");
        EDocument.TestField(Direction, Enum::"E-Document Direction"::Incoming);
        EDocService := EDocLog.GetLastServiceFromLog(EDocument);
        EDocServiceStatus.Get(EDocument."Entry No", EDocService.Code);
        EDocServiceStatus.TestField(Status, Enum::"E-Document Service Status"::"Order Linked");
        EDocOrderLineMatching.SetTempRecord(EDocument);
        EDocOrderLineMatching.SetAutoRunCopilot(WithCopilot);
        EDocOrderLineMatching.Run();
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
                TestLineTotalAreTheSameInSet(EDocOrderMatch);

                if EDocOrderMatch.FindFirst() then begin
                    if PurchaseLine."Direct Unit Cost" <> EDocOrderMatch."E-Document Direct Unit Cost" then
                        PurchaseLine.Validate("Direct Unit Cost", EDocOrderMatch."E-Document Direct Unit Cost");
                    if PurchaseLine."Line Discount %" <> EDocOrderMatch."Line Discount %" then
                        PurchaseLine.Validate("Line Discount %", EDocOrderMatch."Line Discount %");
                    PurchaseLine.Validate("Amount Including VAT");
                    PurchaseLine.Modify();
                end
            until PurchaseLine.Next() = 0;

        EDocService := EDocumentLog.GetLastServiceFromLog(EDocument);
        EDocLogHelper.InsertLog(EDocument, EDocService, Enum::"E-Document Service Status"::"Order Updated");
    end;

    local procedure TestLineTotalAreTheSameInSet(var EDocOrderMatch: Record "E-Doc. Order Match")
    var
        EDocOrderMatch2: Record "E-Doc. Order Match";
        Total, Total2 : Decimal;
    begin
        if not EDocOrderMatch.FindFirst() then
            exit;

        Total := EDocOrderMatch."E-Document Direct Unit Cost" - (EDocOrderMatch."E-Document Direct Unit Cost" * EDocOrderMatch."Line Discount %" / 100);
        EDocOrderMatch2.Copy(EDocOrderMatch);
        if EDocOrderMatch2.FindSet() then
            repeat
                Total2 := EDocOrderMatch2."E-Document Direct Unit Cost" - (EDocOrderMatch2."E-Document Direct Unit Cost" * EDocOrderMatch2."Line Discount %" / 100);
                if Total <> Total2 then
                    Error(MatchErr, EDocOrderMatch."Document Line No.");
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
        TempTotal, Total : Decimal;
    begin
        TempPurchaseLine.FindFirst();
        TempEDocImportedLine.FindFirst();

        EDocOrderMatch.SetRange("Document Order No.", TempPurchaseLine."Document No.");
        EDocOrderMatch.SetRange("E-Document Entry No.", TempEDocImportedLine."E-Document Entry No.");
        EDocOrderMatch.SetRange("Document Line No.", TempPurchaseLine."Line No.");
        // We only have to check first match as other matches would also have been checked.
        if EDocOrderMatch.FindFirst() then begin
            TempTotal := TempEDocImportedLine."Direct Unit Cost" - (TempEDocImportedLine."Direct Unit Cost" * TempEDocImportedLine."Line Discount %" / 100);
            Total := EDocOrderMatch."E-Document Direct Unit Cost" - (EDocOrderMatch."E-Document Direct Unit Cost" * EDocOrderMatch."Line Discount %" / 100);
            if TempTotal <> Total then
                Error(AmountDiffErr, EDocOrderMatch."E-Document Line No.");
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

        // Automatic matching will do the following:
        // - Filter on items with the same unit of measure, direct unit cost and line discount %
        // - If string nearness is above 80% then match automatically 

        if TempEDocumentImportedLine.FindSet() then
            repeat
                TempPurchaseLine.SetRange("Unit of Measure Code", TempEDocumentImportedLine."Unit Of Measure Code");
                TempPurchaseLine.SetRange("Direct Unit Cost", TempEDocumentImportedLine."Direct Unit Cost");
                TempPurchaseLine.SetRange("Line Discount %", TempEDocumentImportedLine."Line Discount %");
                if TempPurchaseLine.FindSet() then
                    repeat
                        if TempPurchaseLine.MaxQtyToInvoice() > TempPurchaseLine."Qty. to Invoice" then
                            // If substring is 80% match
                            if RecordMatchMgt.CalculateStringNearness(TempPurchaseLine.Description, TempEDocumentImportedLine.Description, 4, 100) > 80 then
                                MatchOneToOne(TempEDocumentImportedLine, TempPurchaseLine, TempEDocMatchesThatWasMatched);
                    until TempPurchaseLine.Next() = 0;
            until TempEDocumentImportedLine.Next() = 0;

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
        TempEDocMatchesThatWasMatched.Validate("E-Document Direct Unit Cost", TempEDocumentImportedLine."Direct Unit Cost");
        TempEDocMatchesThatWasMatched.Validate("PO Direct Unit Cost", TempPurchaseLine."Direct Unit Cost");
        TempEDocMatchesThatWasMatched.Validate("Line Discount %", TempEDocumentImportedLine."Line Discount %");
        TempEDocMatchesThatWasMatched.Validate("Unit of Measure Code", TempEDocumentImportedLine."Unit of Measure Code");
        TempEDocMatchesThatWasMatched.Validate("Fully Matched", FullMatch);
        TempEDocMatchesThatWasMatched."PO Description" := TempPurchaseLine.Description;
        TempEDocMatchesThatWasMatched."E-Document Description" := TempEDocumentImportedLine.Description;
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

}