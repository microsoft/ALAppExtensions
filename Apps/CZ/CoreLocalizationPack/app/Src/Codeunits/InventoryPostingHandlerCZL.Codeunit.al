// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Costing;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Setup;

codeunit 31073 "Inventory Posting Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting To G/L", 'OnSetAccNoOnBeforeCheckAccNo', '', false, false)]
    local procedure EnhancedPostingAccountsOnSetAccNoOnBeforeCheckAccNo(var InvtPostBuf: Record "Invt. Posting Buffer"; InvtPostingSetup: Record "Inventory Posting Setup"; GenPostingSetup: Record "General Posting Setup"; CalledFromItemPosting: Boolean)
    begin
        case InvtPostBuf."Account Type" of
            InvtPostBuf."Account Type"::"AccConsumption CZL":
                begin
                    if CalledFromItemPosting then
                        InvtPostingSetup.TestField("Consumption Account CZL");
                    InvtPostBuf."Account No." := InvtPostingSetup."Consumption Account CZL";
                end;
            InvtPostBuf."Account Type"::"AccWIPChange CZL":
                begin
                    if CalledFromItemPosting then
                        InvtPostingSetup.TestField("Change In Inv.Of WIP Acc. CZL");
                    InvtPostBuf."Account No." := InvtPostingSetup."Change In Inv.Of WIP Acc. CZL";
                end;
            InvtPostBuf."Account Type"::"AccProdChange CZL":
                begin
                    if CalledFromItemPosting then
                        InvtPostingSetup.TestField("Change In Inv.OfProd. Acc. CZL");
                    InvtPostBuf."Account No." := InvtPostingSetup."Change In Inv.OfProd. Acc. CZL";
                end;
            InvtPostBuf."Account Type"::"InvRoundingAdj CZL":
                begin
                    if CalledFromItemPosting then
                        GenPostingSetup.TestField("Invt. Rounding Adj. Acc. CZL");
                    InvtPostBuf."Account No." := GenPostingSetup."Invt. Rounding Adj. Acc. CZL";
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Post Invt. Cost to G/L - Test", 'OnGetAccountNameInventoryAccountTypeCase', '', false, false)]
    local procedure EnhancedPostingAccountsOnGetAccountNameInventoryAccountTypeCase(InvtPostToGLTestBuf: Record "Invt. Post to G/L Test Buffer"; var AccountName: Text[80]; InvtPostingSetup: Record "Inventory Posting Setup"; GenPostingSetup: Record "General Posting Setup")
    begin
        case InvtPostToGLTestBuf."Inventory Account Type" of
            InvtPostToGLTestBuf."Inventory Account Type"::"AccConsumption CZL":
                AccountName := CopyStr(InvtPostingSetup.FieldCaption("Consumption Account CZL"), 1, MaxStrLen(AccountName));
            InvtPostToGLTestBuf."Inventory Account Type"::"AccWIPChange CZL":
                AccountName := CopyStr(InvtPostingSetup.FieldCaption("Change In Inv.Of WIP Acc. CZL"), 1, MaxStrLen(AccountName));
            InvtPostToGLTestBuf."Inventory Account Type"::"AccProdChange CZL":
                AccountName := CopyStr(InvtPostingSetup.FieldCaption("Change In Inv.OfProd. Acc. CZL"), 1, MaxStrLen(AccountName));
            InvtPostToGLTestBuf."Inventory Account Type"::"InvRoundingAdj CZL":
                AccountName := CopyStr(GenPostingSetup.FieldCaption("Invt. Rounding Adj. Acc. CZL"), 1, MaxStrLen(AccountName));
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Adjustment", 'OnPostItemJnlLineOnAfterSetPostingDate', '', false, false)]
    local procedure RoundingDateOnPostItemJnlLineOnAfterSetPostingDate(var ItemJournalLine: Record "Item Journal Line"; ValueEntry: Record "Value Entry")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.TestField("Closed Per. Entry Pos.Date CZL");

        case true of
            (GeneralLedgerSetup."Rounding Date CZL" <> 0D) and (ItemJournalLine."Value Entry Type" = ItemJournalLine."Value Entry Type"::Rounding):
                if IsPostingAllowedCZL(ValueEntry."Posting Date", GeneralLedgerSetup."Rounding Date CZL") then
                    ItemJournalLine."Posting Date" := ValueEntry."Posting Date"
                else
                    ItemJournalLine."Posting Date" := GeneralLedgerSetup."Rounding Date CZL";
            else
                if IsPostingAllowedCZL(ValueEntry."Posting Date", GeneralLedgerSetup."Closed Per. Entry Pos.Date CZL") then
                    ItemJournalLine."Posting Date" := ValueEntry."Posting Date"
                else
                    ItemJournalLine."Posting Date" := GeneralLedgerSetup."Closed Per. Entry Pos.Date CZL";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting To G/L", 'OnBeforeBufferOutputPosting', '', false, false)]
    local procedure InitInvtPostBufOnBeforeBufferOutputPosting(var Sender: Codeunit "Inventory Posting To G/L"; var ValueEntry: Record "Value Entry"; var GlobalInvtPostBuf: Record "Invt. Posting Buffer"; CostToPost: Decimal; CostToPostACY: Decimal; ExpCostToPost: Decimal; ExpCostToPostACY: Decimal; var IsHandled: Boolean)
    begin
        case ValueEntry."Entry Type" of
            ValueEntry."Entry Type"::Rounding:
                begin
                    Sender.InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"InvRoundingAdj CZL",
                      CostToPost, CostToPostACY, false);
                    IsHandled := true;
                    exit;
                end;
        end;

        InventorySetup.Get();
        if InventorySetup."Post Exp.Cost Conv.As Corr.CZL" then
            exit;
        case ValueEntry."Entry Type" of
            ValueEntry."Entry Type"::"Direct Cost":
                begin
                    if (ExpCostToPost <> 0) or (ExpCostToPostACY <> 0) then begin
                        Sender.InitInvtPostBuf(
                            ValueEntry,
                            GlobalInvtPostBuf."Account Type"::"Inventory (Interim)",
                            GlobalInvtPostBuf."Account Type"::"AccProdChange CZL",
                            ExpCostToPost, ExpCostToPostACY, false);
                        Sender.InitInvtPostBuf(
                            ValueEntry,
                            GlobalInvtPostBuf."Account Type"::"AccWIPChange CZL",
                            GlobalInvtPostBuf."Account Type"::"WIP Inventory",
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
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting To G/L", 'OnBeforeBufferSalesPosting', '', false, false)]
    local procedure InitInvtPostBufOnBeforeBufferSalesPosting(var Sender: Codeunit "Inventory Posting To G/L"; var ValueEntry: Record "Value Entry"; var GlobalInvtPostBuf: Record "Invt. Posting Buffer"; CostToPost: Decimal; CostToPostACY: Decimal; var IsHandled: Boolean)
    begin
        InventorySetup.Get();
        if InventorySetup."Post Exp.Cost Conv.As Corr.CZL" then
            exit;

        case ValueEntry."Entry Type" of
            ValueEntry."Entry Type"::Rounding:
                begin
                    Sender.InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"InvRoundingAdj CZL",
                      CostToPost, CostToPostACY, false);
                    IsHandled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting To G/L", 'OnBeforeBufferConsumpPosting', '', false, false)]
    local procedure InitInvtPostBufOnBeforeBufferConsumpPosting(var Sender: Codeunit "Inventory Posting To G/L"; var ValueEntry: Record "Value Entry"; var GlobalInvtPostBuf: Record "Invt. Posting Buffer" temporary; CostToPost: Decimal; CostToPostACY: Decimal; var IsHandled: Boolean)
    begin
        case ValueEntry."Entry Type" of
            ValueEntry."Entry Type"::"Direct Cost":
                begin
                    Sender.InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                        GlobalInvtPostBuf."Account Type"::"AccConsumption CZL",
                      CostToPost, CostToPostACY, false);
                    Sender.InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::"AccWIPChange CZL",
                      GlobalInvtPostBuf."Account Type"::"WIP Inventory",
                      CostToPost, CostToPostACY, false);
                    IsHandled := true;
                end;
            ValueEntry."Entry Type"::Revaluation,
          ValueEntry."Entry Type"::Rounding:
                begin
                    Sender.InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"InvRoundingAdj CZL",
                      CostToPost, CostToPostACY, false);
                    IsHandled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting To G/L", 'OnBeforeBufferPurchPosting', '', false, false)]
    local procedure InitInvtPostBufOnBeforeBufferPurchPosting(var Sender: Codeunit "Inventory Posting To G/L"; var ValueEntry: Record "Value Entry"; var GlobalInvtPostBuf: Record "Invt. Posting Buffer"; CostToPost: Decimal; CostToPostACY: Decimal; var IsHandled: Boolean)
    begin
        case ValueEntry."Entry Type" of
            ValueEntry."Entry Type"::Rounding:
                begin
                    Sender.InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"InvRoundingAdj CZL",
                      CostToPost, CostToPostACY, false);
                    IsHandled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting To G/L", 'OnBeforeBufferAsmOutputPosting', '', false, false)]
    local procedure InitInvtPostBufOnBeforeBufferAsmOutputPosting(var Sender: Codeunit "Inventory Posting To G/L"; var ValueEntry: Record "Value Entry"; var GlobalInvtPostBuf: Record "Invt. Posting Buffer"; var CostToPost: Decimal; var CostToPostACY: Decimal; var IsHandled: Boolean)
    begin
        case ValueEntry."Entry Type" of
            ValueEntry."Entry Type"::Rounding:
                begin
                    Sender.InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"InvRoundingAdj CZL",
                      CostToPost, CostToPostACY, false);
                    IsHandled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting To G/L", 'OnBeforeBufferAsmConsumpPosting', '', false, false)]
    local procedure InitInvtPostBufOnBeforeBufferAsmConsumpPosting(var Sender: Codeunit "Inventory Posting To G/L"; var ValueEntry: Record "Value Entry"; var GlobalInvtPostBuf: Record "Invt. Posting Buffer"; var CostToPost: Decimal; var CostToPostACY: Decimal; var IsHandled: Boolean)
    begin
        case ValueEntry."Entry Type" of
            ValueEntry."Entry Type"::Rounding:
                begin
                    Sender.InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"InvRoundingAdj CZL",
                      CostToPost, CostToPostACY, false);
                    IsHandled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting To G/L", 'OnBeforeBufferAdjmtPosting', '', false, false)]
    local procedure InitInvtPostBufOnBeforeBufferAdjmtPosting(var Sender: Codeunit "Inventory Posting To G/L"; var ValueEntry: Record "Value Entry"; var GlobalInvtPostBuf: Record "Invt. Posting Buffer"; CostToPost: Decimal; CostToPostACY: Decimal; var IsHandled: Boolean)
    begin
        case ValueEntry."Entry Type" of
            ValueEntry."Entry Type"::Rounding:
                begin
                    Sender.InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"InvRoundingAdj CZL",
                      CostToPost, CostToPostACY, false);
                    IsHandled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting To G/L", 'OnBeforePostInvtPostBuf', '', false, false)]
    local procedure FromAdjustmentCZLOnBeforePostInvtPostBuf(var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine."From Adjustment CZL" := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting To G/L", 'OnBeforeCheckInvtPostBuf', '', false, false)]
    local procedure FromAdjustmentCZLOnBeforeCheckInvtPostBuf(var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine."From Adjustment CZL" := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting To G/L", 'OnAfterInitTempInvtPostBuf', '', false, false)]
    local procedure SetGLCorrectionOnAfterInitTempInvtPostBuf(var TempInvtPostBuf: array[20] of Record "Invt. Posting Buffer"; ValueEntry: Record "Value Entry"; PostBufDimNo: Integer)
    begin
        TempInvtPostBuf[PostBufDimNo]."G/L Correction CZL" := ValueEntry."G/L Correction CZL";

        if ValueEntry."Expected Cost" then
            exit;

        if not TempInvtPostBuf[PostBufDimNo]."Interim Account" then
            exit;

        InventorySetup.Get();
        if not InventorySetup."Post Exp.Cost Conv.As Corr.CZL" then
            exit;

        if (ValueEntry."Item Ledger Entry Type" in [ValueEntry."Item Ledger Entry Type"::Sale, ValueEntry."Item Ledger Entry Type"::Purchase, ValueEntry."Item Ledger Entry Type"::Output]) and
           (ValueEntry."Entry Type" in [ValueEntry."Entry Type"::"Direct Cost", ValueEntry."Entry Type"::Revaluation])
        then
            if ValueEntry."Cost Amount (Expected)" <> 0 then
                TempInvtPostBuf[PostBufDimNo]."G/L Correction CZL" := not TempInvtPostBuf[PostBufDimNo]."G/L Correction CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting To G/L", 'OnPostInvtPostBufProcessGlobalInvtPostBufOnAfterSetDesc', '', false, false)]
    local procedure GetCorrectionOnPostInvtPostBufProcessGlobalInvtPostBufOnAfterSetDesc(var GenJournalLine: Record "Gen. Journal Line"; var GlobalInvtPostBuf: Record "Invt. Posting Buffer")
    begin
        GenJournalLine.Correction := GlobalInvtPostBuf."G/L Correction CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting To G/L", 'OnAfterBufferGLItemLedgRelation', '', false, false)]
    local procedure DeleteRelationOnAfterBufferGLItemLedgRelation(var TempGLItemLedgRelation: Record "G/L - Item Ledger Relation" temporary; GlobalInvtPostBufEntryNo: Integer)
    begin
        if TempGLItemLedgRelation."G/L Entry No." <> GlobalInvtPostBufEntryNo then
            TempGLItemLedgRelation.Delete();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Invt. Posting Buffer", 'OnUseInvtPostSetup', '', false, false)]
    local procedure AccountTypesOnUseInvtPostSetup(var InvtPostingBuffer: Record "Invt. Posting Buffer"; var UseInventoryPostingSetup: Boolean)
    begin
        if InvtPostingBuffer."Account Type" in
          [InvtPostingBuffer."Account Type"::"AccConsumption CZL",
           InvtPostingBuffer."Account Type"::"AccWIPChange CZL",
           InvtPostingBuffer."Account Type"::"AccProdChange CZL"] then
            UseInventoryPostingSetup := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Inventory Posting Setup", 'OnAfterValidateEvent', 'Inventory Account', false, false)]
    local procedure InventoryAccountOnAfterValidate(var Rec: Record "Inventory Posting Setup")
    begin
        Rec.CheckValueEntriesCZL(Rec.FieldCaption("Inventory Account"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Inventory Posting Setup", 'OnAfterValidateEvent', 'Inventory Account (Interim)', false, false)]
    local procedure InventoryAccountInterimOnAfterValidate(var Rec: Record "Inventory Posting Setup")
    begin
        Rec.CheckValueEntriesCZL(Rec.FieldCaption("Inventory Account (Interim)"));
    end;

    local procedure IsPostingAllowedCZL(ValueEntryPostingDate: Date; ClosingDate: Date): Boolean
    begin
        exit(ValueEntryPostingDate >= ClosingDate);
    end;

    var
        InventorySetup: Record "Inventory Setup";
}
