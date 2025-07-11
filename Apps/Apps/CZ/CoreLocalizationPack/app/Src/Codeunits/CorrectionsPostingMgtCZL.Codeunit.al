// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Posting;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.Journal;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Inventory.Costing;
using Microsoft.Inventory.Document;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Posting;
using Microsoft.Inventory.Setup;
using Microsoft.Projects.Project.Journal;
using Microsoft.Purchases.Document;
using Microsoft.Sales.Document;
using Microsoft.Service.Document;
using Microsoft.Service.Posting;

codeunit 11796 "Corrections Posting Mgt. CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertGLEntryBuffer', '', false, false)]
    local procedure CheckDebitCreditOnBeforeInsertGLEntryBuffer(var TempGLEntryBuf: Record "G/L Entry" temporary; var GenJournalLine: Record "Gen. Journal Line"; var BalanceCheckAmount: Decimal; var BalanceCheckAmount2: Decimal; var BalanceCheckAddCurrAmount: Decimal; var BalanceCheckAddCurrAmount2: Decimal; var NextEntryNo: Integer; var TotalAmount: Decimal; var TotalAddCurrAmount: Decimal)
    begin
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Check Posting Debit/Credit CZL" then
            CheckDebitCreditGLAccPosting(TempGLEntryBuf);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnBeforeUpdateRecurringAmt', '', false, false)]
    local procedure SetDebitCreditAmtOnBeforeUpdateRecurringAmt(var GenJnlLine2: Record "Gen. Journal Line"; var Updated: Boolean; var IsHandled: Boolean);
    var
        GLEntry: Record "G/L Entry";
        GLAccount: Record "G/L Account";
        GenJnlAlloc: Record "Gen. Jnl. Allocation";
    begin
        GeneralLedgerSetup.Get();
        if not GeneralLedgerSetup."Check Posting Debit/Credit CZL" then
            exit;

        if (GenJnlLine2."Account No." <> '') and
            (GenJnlLine2."Recurring Method" in
            [GenJnlLine2."Recurring Method"::"B  Balance", GenJnlLine2."Recurring Method"::"RB Reversing Balance"])
        then begin
            GLEntry.LockTable();
            if GenJnlLine2."Account Type" = GenJnlLine2."Account Type"::"G/L Account" then begin
                GLAccount.Get(GenJnlLine2."Account No.");
                GLAccount.SetRange("Date Filter", 0D, GenJnlLine2."Posting Date");
                if GeneralLedgerSetup."Additional Reporting Currency" <> '' then begin
                    GenJnlLine2."Source Currency Code" := GeneralLedgerSetup."Additional Reporting Currency";
                    GLAccount.CalcFields("Additional-Currency Net Change");
                    GenJnlLine2."Source Currency Amount" := -GLAccount."Additional-Currency Net Change";
                    GenJnlAlloc.UpdateAllocationsAddCurr(GenJnlLine2, GenJnlLine2."Source Currency Amount");
                end;
                GLAccount.CalcFields("Net Change");
                case GLAccount."Debit/Credit" of
                    GLAccount."Debit/Credit"::Debit:
                        GenJnlLine2.Validate("Debit Amount", -GLAccount."Net Change");
                    GLAccount."Debit/Credit"::Credit:
                        GenJnlLine2.Validate("Credit Amount", GLAccount."Net Change");
                    GLAccount."Debit/Credit"::Both:
                        GenJnlLine2.Validate(Amount, -GLAccount."Net Change");
                end;
                Updated := true;
                IsHandled := true;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeInsertValueEntry', '', false, false)]
    local procedure SetGLCorrectionOnBeforeInsertValueEntry(var ValueEntry: Record "Value Entry"; ItemJournalLine: Record "Item Journal Line"; var ItemLedgerEntry: Record "Item Ledger Entry"; var ValueEntryNo: Integer; var InventoryPostingToGL: Codeunit "Inventory Posting To G/L"; CalledFromAdjustment: Boolean)
    var
        FirstValueEntry: Record "Value Entry";
        IsFirstValueEntry: Boolean;
    begin
        FirstValueEntry.SetCurrentKey("Item Ledger Entry No.");
        FirstValueEntry.SetRange("Item Ledger Entry No.", ValueEntry."Item Ledger Entry No.");
        IsFirstValueEntry := not FirstValueEntry.FindFirst();
        if not IsFirstValueEntry then
            ValueEntry."G/L Correction CZL" := CalcGLCorrection(FirstValueEntry, ValueEntry)
        else
            ValueEntry."G/L Correction CZL" := ItemJournalLine."G/L Correction CZL";

        if ValueEntry."Item Ledger Entry Type" = ValueEntry."Item Ledger Entry Type"::Transfer then begin
            InventorySetup.Get();
            if InventorySetup."Post Neg.Transf. As Corr.CZL" then
                ValueEntry."G/L Correction CZL" := ValueEntry."Valued Quantity" < 0;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeInsertCorrValueEntry', '', false, false)]
    local procedure SetGLCorrectionOnBeforeInsertCorrValueEntry(var NewValueEntry: Record "Value Entry"; OldValueEntry: Record "Value Entry"; var ItemJournalLine: Record "Item Journal Line"; Sign: Integer; CalledFromAdjustment: Boolean; var ItemLedgerEntry: Record "Item Ledger Entry"; var ValueEntryNo: Integer; var InventoryPostingToGL: Codeunit "Inventory Posting To G/L")
    begin
        if Sign < 0 then
            NewValueEntry."G/L Correction CZL" := not OldValueEntry."G/L Correction CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeInsertCapValueEntry', '', false, false)]
    local procedure SetGLCorrectionOnBeforeInsertCapValueEntry(var ValueEntry: Record "Value Entry"; ItemJnlLine: Record "Item Journal Line")
    begin
        ValueEntry."G/L Correction CZL" := ItemJnlLine."G/L Correction CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Reclass. Transfer Line", 'OnBeforeFAJnlLineInsert', '', false, false)]
    local procedure SetCorrectionOnBeforeFAJnlLineInsert(var FAJournalLine: Record "FA Journal Line"; var FAReclassJournalLine: Record "FA Reclass. Journal Line"; Sign: Integer)
    var
        DepreciationBook: Record "Depreciation Book";
    begin
        // when posting old FA No.
        if FAJournalLine."FA No." = FAReclassJournalLine."FA No." then begin
            DepreciationBook.Get(FAReclassJournalLine."Depreciation Book Code");
            if DepreciationBook."Mark Reclass. as Correct. CZL" then
                FAJournalLine.Validate(Correction, true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Reclass. Transfer Line", 'OnBeforeGenJnlLineInsert', '', false, false)]
    local procedure SetCorrectionOnBeforeGenJnlLineInsert(var GenJournalLine: Record "Gen. Journal Line"; var FAReclassJournalLine: Record "FA Reclass. Journal Line"; Sign: Integer)
    var
        DepreciationBook: Record "Depreciation Book";
    begin
        // when posting old FA No.
        if GenJournalLine."Account No." = FAReclassJournalLine."FA No." then begin
            DepreciationBook.Get(FAReclassJournalLine."Depreciation Book Code");
            if DepreciationBook."Mark Reclass. as Correct. CZL" then
                GenJournalLine.Validate(Correction, true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting To G/L", 'OnBeforeBufferPurchPosting', '', false, false)]
    local procedure InitInvtPostBufOnBeforeBufferPurchPosting(var Sender: Codeunit "Inventory Posting To G/L"; var ValueEntry: Record "Value Entry"; var GlobalInvtPostBuf: Record "Invt. Posting Buffer"; CostToPost: Decimal; CostToPostACY: Decimal; ExpCostToPost: Decimal; ExpCostToPostACY: Decimal; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;
        InventorySetup.Get();
        if not InventorySetup."Post Exp.Cost Conv.As Corr.CZL" then
            exit;
        case ValueEntry."Entry Type" of
            ValueEntry."Entry Type"::"Direct Cost":
                begin
                    if (ExpCostToPost <> 0) or (ExpCostToPostACY <> 0) then
                        Sender.InitInvtPostBuf(
                          ValueEntry,
                          GlobalInvtPostBuf."Account Type"::"Inventory (Interim)",
                          GetInvtPostBufferAccTypeForGLCorrection(ValueEntry, GlobalInvtPostBuf."Account Type"::"Invt. Accrual (Interim)"),
                          ExpCostToPost, ExpCostToPostACY, true);
                    if (CostToPost <> 0) or (CostToPostACY <> 0) then
                        Sender.InitInvtPostBuf(
                          ValueEntry,
                          GlobalInvtPostBuf."Account Type"::Inventory,
                          GlobalInvtPostBuf."Account Type"::"Direct Cost Applied",
                          CostToPost, CostToPostACY, false);
                    IsHandled := true;
                end;
            ValueEntry."Entry Type"::Revaluation:
                begin
                    if (ExpCostToPost <> 0) or (ExpCostToPostACY <> 0) then
                        Sender.InitInvtPostBuf(
                            ValueEntry,
                            GlobalInvtPostBuf."Account Type"::"Inventory (Interim)",
                            GetInvtPostBufferAccTypeForGLCorrection(ValueEntry, GlobalInvtPostBuf."Account Type"::"Invt. Accrual (Interim)"),
                            ExpCostToPost, ExpCostToPostACY, true);
                    if (CostToPost <> 0) or (CostToPostACY <> 0) then
                        Sender.InitInvtPostBuf(
                            ValueEntry,
                            GlobalInvtPostBuf."Account Type"::Inventory,
                            GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                            CostToPost, CostToPostACY, false);
                    IsHandled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting To G/L", 'OnBeforeBufferSalesPosting', '', false, false)]
    local procedure InitInvtPostBufOnBeforeBufferSalesPosting(var Sender: Codeunit "Inventory Posting To G/L"; var ValueEntry: Record "Value Entry"; var GlobalInvtPostBuf: Record "Invt. Posting Buffer"; CostToPost: Decimal; CostToPostACY: Decimal; ExpCostToPost: Decimal; ExpCostToPostACY: Decimal; var IsHandled: Boolean)
    begin
        InventorySetup.Get();
        if not InventorySetup."Post Exp.Cost Conv.As Corr.CZL" then
            exit;
        case ValueEntry."Entry Type" of
            ValueEntry."Entry Type"::"Direct Cost":
                begin
                    if (ExpCostToPost <> 0) or (ExpCostToPostACY <> 0) then
                        Sender.InitInvtPostBuf(
                            ValueEntry,
                            GlobalInvtPostBuf."Account Type"::"Inventory (Interim)",
                            GetInvtPostBufferAccTypeForGLCorrection(ValueEntry, GlobalInvtPostBuf."Account Type"::"COGS (Interim)"),
                            ExpCostToPost, ExpCostToPostACY, true);
                    if (CostToPost <> 0) or (CostToPostACY <> 0) then
                        Sender.InitInvtPostBuf(
                            ValueEntry,
                            GlobalInvtPostBuf."Account Type"::Inventory,
                            GlobalInvtPostBuf."Account Type"::COGS,
                            CostToPost, CostToPostACY, false);
                    IsHandled := true;
                end;
            ValueEntry."Entry Type"::Revaluation:
                begin
                    if (ExpCostToPost <> 0) or (ExpCostToPostACY <> 0) then
                        Sender.InitInvtPostBuf(
                            ValueEntry,
                            GlobalInvtPostBuf."Account Type"::"Inventory (Interim)",
                            GetInvtPostBufferAccTypeForGLCorrection(ValueEntry, GlobalInvtPostBuf."Account Type"::"COGS (Interim)"),
                            ExpCostToPost, ExpCostToPostACY, true);
                    if (CostToPost <> 0) or (CostToPostACY <> 0) then
                        Sender.InitInvtPostBuf(
                            ValueEntry,
                            GlobalInvtPostBuf."Account Type"::Inventory,
                            GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                            CostToPost, CostToPostACY, false);
                    IsHandled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting To G/L", 'OnBeforeBufferOutputPosting', '', false, false)]
    local procedure InitInvtPostBufOnBeforeBufferOutputPosting(var Sender: Codeunit "Inventory Posting To G/L"; var ValueEntry: Record "Value Entry"; var GlobalInvtPostBuf: Record "Invt. Posting Buffer"; CostToPost: Decimal; CostToPostACY: Decimal; ExpCostToPost: Decimal; ExpCostToPostACY: Decimal; var IsHandled: Boolean)
    begin
        InventorySetup.Get();
        if not InventorySetup."Post Exp.Cost Conv.As Corr.CZL" then
            exit;
        case ValueEntry."Entry Type" of
            ValueEntry."Entry Type"::"Direct Cost":
                begin
                    if (ExpCostToPost <> 0) or (ExpCostToPostACY <> 0) then begin
                        Sender.InitInvtPostBuf(
                            ValueEntry,
                            GlobalInvtPostBuf."Account Type"::"Inventory (Interim)",
                            GetInvtPostBufferAccTypeForGLCorrection(ValueEntry, GlobalInvtPostBuf."Account Type"::"AccProdChange CZL"),
                            ExpCostToPost, ExpCostToPostACY, false);
                        Sender.InitInvtPostBuf(
                            ValueEntry,
                            GlobalInvtPostBuf."Account Type"::"AccWIPChange CZL",
                            GetInvtPostBufferAccTypeForGLCorrection(ValueEntry, GlobalInvtPostBuf."Account Type"::"WIP Inventory"),
                            ExpCostToPost, ExpCostToPostACY, true);
                    end;
                    if (CostToPost <> 0) or (CostToPostACY <> 0) then begin
                        Sender.InitInvtPostBuf(
                            ValueEntry,
                            GlobalInvtPostBuf."Account Type"::Inventory,
                            GlobalInvtPostBuf."Account Type"::"AccProdChange CZL",
                            CostToPost, CostToPostACY, false);
                        Sender.InitInvtPostBuf(
                            ValueEntry,
                            GlobalInvtPostBuf."Account Type"::"AccWIPChange CZL",
                            GlobalInvtPostBuf."Account Type"::"WIP Inventory",
                            CostToPost, CostToPostACY, false);
                    end;
                    IsHandled := true;
                end;
            ValueEntry."Entry Type"::Revaluation:
                begin
                    if (ExpCostToPost <> 0) or (ExpCostToPostACY <> 0) then
                        Sender.InitInvtPostBuf(
                            ValueEntry,
                            GlobalInvtPostBuf."Account Type"::"Inventory (Interim)",
                            GetInvtPostBufferAccTypeForGLCorrection(ValueEntry, GlobalInvtPostBuf."Account Type"::"WIP Inventory"),
                            ExpCostToPost, ExpCostToPostACY, true);
                    if (CostToPost <> 0) or (CostToPostACY <> 0) then
                        Sender.InitInvtPostBuf(
                            ValueEntry,
                            GlobalInvtPostBuf."Account Type"::Inventory,
                            GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                            CostToPost, CostToPostACY, false);
                    IsHandled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Invt. Posting Buffer", 'OnUseInvtPostSetup', '', false, false)]
    local procedure SetValueOnUseInvtPostSetup(var InvtPostingBuffer: Record "Invt. Posting Buffer"; var UseInventoryPostingSetup: Boolean)
    begin
        if InvtPostingBuffer."Account Type" in
            [InvtPostingBuffer."Account Type"::"WIP Inventory Corr.CZL",
            InvtPostingBuffer."Account Type"::"AccProdChange Corr.CZL"]
        then
            UseInventoryPostingSetup := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting To G/L", 'OnSetAccNoOnBeforeCheckAccNo', '', false, false)]
    local procedure SetAccountOnSetAccNoOnBeforeCheckAccNo(var InvtPostBuf: Record "Invt. Posting Buffer"; InvtPostingSetup: Record "Inventory Posting Setup"; GenPostingSetup: Record "General Posting Setup"; CalledFromItemPosting: Boolean)
    begin
        if InvtPostBuf."Account No." <> '' then
            exit;
        case InvtPostBuf."Account Type" of
            InvtPostBuf."Account Type"::"WIP Inventory Corr.CZL":
                if CalledFromItemPosting then
                    InvtPostBuf."Account No." := InvtPostingSetup.GetWIPAccount()
                else
                    InvtPostBuf."Account No." := InvtPostingSetup."WIP Account";
            InvtPostBuf."Account Type"::"COGS (Interim) Corr.CZL":
                if CalledFromItemPosting then
                    InvtPostBuf."Account No." := GenPostingSetup.GetCOGSInterimAccount()
                else
                    InvtPostBuf."Account No." := GenPostingSetup."COGS Account (Interim)";
            InvtPostBuf."Account Type"::"Invt. Accrual (Interim) Corr.CZL":
                if CalledFromItemPosting then
                    InvtPostBuf."Account No." := GenPostingSetup.GetInventoryAccrualAccount()
                else
                    InvtPostBuf."Account No." := GenPostingSetup."Invt. Accrual Acc. (Interim)";
            // NAVCZ
            InvtPostBuf."Account Type"::"AccProdChange Corr.CZL":
                begin
                    if CalledFromItemPosting then
                        InvtPostingSetup.TestField("Change In Inv.OfProd. Acc. CZL");
                    InvtPostBuf."Account No." := InvtPostingSetup."Change In Inv.OfProd. Acc. CZL";
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting To G/L", 'OnPostInvtPostBufOnBeforeSetAmt', '', false, false)]
    local procedure SetCorrectionOnPostInvtPostBufOnBeforeSetAmt(var GenJournalLine: Record "Gen. Journal Line"; var ValueEntry: Record "Value Entry"; var GlobalInvtPostingBuffer: Record "Invt. Posting Buffer")
    begin
        // has amount to post
        if (GlobalInvtPostingBuffer.Amount <> 0) or (GlobalInvtPostingBuffer."Amount (ACY)" <> 0) then
            GenJournalLine.Correction := IsCorrectionInvtPostBufferAccType(GlobalInvtPostingBuffer."Bal. Account Type");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterValidateEvent', 'Quantity', false, false)]
    local procedure ItemJnlLineSetCorrectionOnAfterValidateQuantity(var Rec: Record "Item Journal Line"; var xRec: Record "Item Journal Line"; CurrFieldNo: Integer)
    begin
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Mark Neg. Qty as Correct. CZL" then
            Rec."G/L Correction CZL" := (Rec.Quantity < 0) or (Rec."Invoiced Quantity" < 0);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Invt. Doc.-Post Shipment", 'OnAfterFillItemJournalLineQtyFromInvtShipmentLine', '', false, false)]
    local procedure ItemJnlLineSetCorrectionOnAfterFillItemJournalLineQtyFromInvtShipmentLine(var ItemJournalLine: Record "Item Journal Line")
    begin
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Mark Neg. Qty as Correct. CZL" then
            ItemJournalLine."G/L Correction CZL" := (ItemJournalLine.Quantity < 0) or (ItemJournalLine."Invoiced Quantity" < 0);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Invt. Doc.-Post Receipt", 'OnAfterFillItemJournalLineQtyFromInvtShipmentLine', '', false, false)]
    local procedure ItemJnlLineSetCorrectionOnAfterFillItemJournalLineQtyFromInvtShipmentLine2(var ItemJournalLine: Record "Item Journal Line")
    begin
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Mark Neg. Qty as Correct. CZL" then
            ItemJournalLine."G/L Correction CZL" := (ItemJournalLine.Quantity < 0) or (ItemJournalLine."Invoiced Quantity" < 0);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Journal Line", 'OnAfterValidateEvent', 'Quantity', false, false)]
    local procedure JobJnlLineSetCorrectionOnAfterValidateQuantity(var Rec: Record "Job Journal Line"; var xRec: Record "Job Journal Line"; CurrFieldNo: Integer)
    begin
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Mark Neg. Qty as Correct. CZL" then
            Rec."Correction CZL" := (Rec.Quantity < 0);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterInitOutstanding', '', false, false)]
    local procedure SalesLineSetNegativeOnAfterInitOutstanding(var SalesLine: Record "Sales Line")
    begin
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Mark Neg. Qty as Correct. CZL" then
            SalesLine."Negative CZL" := (SalesLine.Quantity < 0);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterInitOutstandingQty', '', false, false)]
    local procedure PurchLineSetNegativeOnAfterInitOutstandingQty(var PurchaseLine: Record "Purchase Line")
    begin
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Mark Neg. Qty as Correct. CZL" then
            PurchaseLine."Negative CZL" := (PurchaseLine.Quantity < 0);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Line", 'OnAfterInitOutstanding', '', false, false)]
    local procedure ServiceLineSetNegativeOnAfterInitOutstanding(var ServiceLine: Record "Service Line")
    begin
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Mark Neg. Qty as Correct. CZL" then
            ServiceLine."Negative CZL" := (ServiceLine.Quantity < 0);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::Microsoft.Sales.Posting."Sales Post Invoice Events", 'OnAfterPrepareInvoicePostingBuffer', '', false, false)]
    local procedure SetCorrectionOnAfterPrepareSales(var SalesLine: Record "Sales Line"; var InvoicePostingBuffer: Record "Invoice Posting Buffer")
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        InvoicePostingBuffer."Correction CZL" := SalesHeader.Correction xor SalesLine."Negative CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::Microsoft.Purchases.Posting."Purch. Post Invoice Events", 'OnAfterPrepareInvoicePostingBuffer', '', false, false)]
    local procedure SetCorrectionOnAfterPreparePurchase(var PurchaseLine: Record "Purchase Line"; var InvoicePostingBuffer: Record "Invoice Posting Buffer")
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        InvoicePostingBuffer."Correction CZL" := PurchaseHeader.Correction xor PurchaseLine."Negative CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service Post Invoice Events", 'OnAfterPrepareInvoicePostingBuffer', '', false, false)]
    local procedure SetCorrectionOnAfterPrepareService(ServiceLine: Record "Service Line"; var InvoicePostingBuffer: Record "Invoice Posting Buffer")
    var
        ServiceHeader: Record "Service Header";
    begin
        ServiceHeader.Get(ServiceLine."Document Type", ServiceLine."Document No.");
        InvoicePostingBuffer."Correction CZL" := ServiceHeader.Correction xor ServiceLine."Negative CZL";
    end;

    local procedure GetInvtPostBufferAccTypeForGLCorrection(ForValueEntry: Record "Value Entry"; BalAccType: Enum "Invt. Posting Buffer Account Type") BalAccTypeForGLCorr: Enum "Invt. Posting Buffer Account Type"
    begin
        BalAccTypeForGLCorr := BalAccType;
        if ForValueEntry."Expected Cost" then
            exit;
        if InventorySetup."Post Exp.Cost Conv.As Corr.CZL" xor ForValueEntry."G/L Correction CZL" then
            case BalAccType of
                BalAccType::"Invt. Accrual (Interim)":
                    BalAccTypeForGLCorr := BalAccType::"Invt. Accrual (Interim) Corr.CZL";
                BalAccType::"WIP Inventory":
                    BalAccTypeForGLCorr := BalAccType::"WIP Inventory Corr.CZL";
                BalAccType::"COGS (Interim)":
                    BalAccTypeForGLCorr := BalAccType::"COGS (Interim) Corr.CZL";
                BalAccType::"AccProdChange CZL":
                    BalAccTypeForGLCorr := BalAccType::"AccProdChange Corr.CZL";
            end;
    end;

    local procedure IsCorrectionInvtPostBufferAccType(BalAccType: Enum "Invt. Posting Buffer Account Type"): Boolean
    begin
        exit(BalAccType in [
            BalAccType::"Invt. Accrual (Interim) Corr.CZL",
            BalAccType::"WIP Inventory Corr.CZL",
            BalAccType::"COGS (Interim) Corr.CZL",
            BalAccType::"AccProdChange Corr.CZL"]);
    end;

    local procedure CalcGLCorrection(FirstValueEntry: Record "Value Entry"; NewValueEntry: Record "Value Entry"): Boolean
    var
        NewGetCostAmt: Decimal;
        GetCostAmt: Decimal;
    begin
        if NewValueEntry."Cost Amount (Actual)" = 0 then
            NewGetCostAmt := NewValueEntry."Cost Amount (Expected)"
        else
            NewGetCostAmt := NewValueEntry."Cost Amount (Actual)";

        if FirstValueEntry."Cost Amount (Actual)" = 0 then
            GetCostAmt := FirstValueEntry."Cost Amount (Expected)"
        else
            GetCostAmt := FirstValueEntry."Cost Amount (Actual)";

        exit(FirstValueEntry."G/L Correction CZL" xor (GetCostAmt * NewGetCostAmt < 0));
    end;

    local procedure CheckDebitCreditGLAccPosting(var GLEntry: Record "G/L Entry")
    var
        GLAccount: Record "G/L Account";
        SourceCodeSetup: Record "Source Code Setup";
        CloseIncomeStatement: Boolean;
        CloseEntry: Boolean;
        IsCorrection: Boolean;
    begin
        GLAccount.Get(GLEntry."G/L Account No.");
        if GLAccount."Debit/Credit" = GLAccount."Debit/Credit"::Both then
            exit;

        SourceCodeSetup.Get();
        CloseIncomeStatement := GLEntry."Source Code" = SourceCodeSetup."Close Income Statement";
        CloseEntry := CloseIncomeStatement or (GLEntry."Source Code" = SourceCodeSetup."Close Balance Sheet CZL");
        CloseEntry := (GLEntry."Source Code" <> '') and CloseEntry;

        IsCorrection := (GLEntry."Credit Amount" < 0) or (GLEntry."Debit Amount" < 0);

        if (GLAccount."Debit/Credit" = GLAccount."Debit/Credit"::Debit) and not CloseEntry or
           (GLAccount."Debit/Credit" = GLAccount."Debit/Credit"::Credit) and CloseEntry
        then begin
            if GLEntry."Credit Amount" <> 0 then begin
                if GLAccount."Direct Posting" and not IsCorrection then
                    Error(DebitCreditPostingErr, GLEntry.FieldCaption("Credit Amount"), GLEntry.FieldCaption("G/L Account No."), GLAccount."No.");
                GLEntry."Debit Amount" := -GLEntry."Credit Amount";
                GLEntry."Credit Amount" := 0;
                if GLEntry."Add.-Currency Credit Amount" <> 0 then begin
                    GLEntry."Add.-Currency Debit Amount" := -GLEntry."Add.-Currency Credit Amount";
                    GLEntry."Add.-Currency Credit Amount" := 0;
                end;
            end;
        end else
            if GLEntry."Debit Amount" <> 0 then begin
                if GLAccount."Direct Posting" and not IsCorrection then
                    Error(DebitCreditPostingErr, GLEntry.FieldCaption("Debit Amount"), GLEntry.FieldCaption("G/L Account No."), GLAccount."No.");
                GLEntry."Credit Amount" := -GLEntry."Debit Amount";
                GLEntry."Debit Amount" := 0;
                if GLEntry."Add.-Currency Debit Amount" <> 0 then begin
                    GLEntry."Add.-Currency Credit Amount" := -GLEntry."Add.-Currency Debit Amount";
                    GLEntry."Add.-Currency Debit Amount" := 0;
                end;
            end;
    end;

    procedure SetCorrectionIfNegQty(var JobJournalLine: Record "Job Journal Line")
    begin
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Mark Neg. Qty as Correct. CZL" then
            JobJournalLine."Correction CZL" := JobJournalLine.Quantity < 0;
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        InventorySetup: Record "Inventory Setup";
        DebitCreditPostingErr: Label '%1 must be 0 at posting on %2 %3.', Comment = '%1 = Debit/Credit Amount, %2 = G/L Account No. Caption, %3 = G/L Account No.';
}
