// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Reconciliation;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;

codeunit 31074 "Get Inv. Report Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Get Inventory Report", 'OnCalcInvtPostingSetupOnBeforeAssignTempInvtPostingSetup', '', false, false)]
    local procedure InsertConsumptionOnBeforeAssignTempInvtPostingSetup(var InventoryReportEntry: Record "Inventory Report Entry"; var TempInventoryPostingSetup: Record "Inventory Posting Setup" temporary; var InventoryReportHeader: Record "Inventory Report Header"; InventoryPostingSetup: Record "Inventory Posting Setup")
    begin
        TempInventoryPostingSetup.Reset();
        TempInventoryPostingSetup.SetRange("Consumption Account CZL", InventoryPostingSetup."Consumption Account CZL");
        if not TempInventoryPostingSetup.FindFirst() then
            InsertGLInvtReportEntryCZL(InventoryReportEntry, InventoryReportHeader, InventoryPostingSetup."Consumption Account CZL", InventoryReportEntry."Consumption CZL");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Get Inventory Report", 'OnCalcInvtPostingSetupOnBeforeAssignTempInvtPostingSetup', '', false, false)]
    local procedure InsertChangeInInvOfWIPOnBeforeAssignTempInvtPostingSetup(var InventoryReportEntry: Record "Inventory Report Entry"; var TempInventoryPostingSetup: Record "Inventory Posting Setup" temporary; var InventoryReportHeader: Record "Inventory Report Header"; InventoryPostingSetup: Record "Inventory Posting Setup")
    begin
        TempInventoryPostingSetup.Reset();
        TempInventoryPostingSetup.SetRange("Change In Inv.Of WIP Acc. CZL", InventoryPostingSetup."Change In Inv.Of WIP Acc. CZL");
        if not TempInventoryPostingSetup.FindFirst() then
            InsertGLInvtReportEntryCZL(InventoryReportEntry, InventoryReportHeader, InventoryPostingSetup."Change In Inv.Of WIP Acc. CZL", InventoryReportEntry."Change In Inv.Of WIP CZL");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Get Inventory Report", 'OnCalcInvtPostingSetupOnBeforeAssignTempInvtPostingSetup', '', false, false)]
    local procedure InsertChangeInInvOfProductOnBeforeAssignTempInvtPostingSetup(var InventoryReportEntry: Record "Inventory Report Entry"; var TempInventoryPostingSetup: Record "Inventory Posting Setup" temporary; var InventoryReportHeader: Record "Inventory Report Header"; InventoryPostingSetup: Record "Inventory Posting Setup")
    begin
        TempInventoryPostingSetup.Reset();
        TempInventoryPostingSetup.SetRange("Change In Inv.OfProd. Acc. CZL", InventoryPostingSetup."Change In Inv.OfProd. Acc. CZL");
        if not TempInventoryPostingSetup.FindFirst() then
            InsertGLInvtReportEntryCZL(InventoryReportEntry, InventoryReportHeader, InventoryPostingSetup."Change In Inv.OfProd. Acc. CZL", InventoryReportEntry."Change In Inv.Of Product CZL");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Get Inventory Report", 'OnCalcGenPostingSetupOnBeforeAssignTempGenPostingSetup', '', false, false)]
    local procedure InsertInvRoundingAdjOnBeforeAssignTempGenPostingSetup(var InventoryReportEntry: Record "Inventory Report Entry"; var TempGeneralPostingSetup: Record "General Posting Setup" temporary; var InventoryReportHeader: Record "Inventory Report Header"; GeneralPostingSetup: Record "General Posting Setup")
    begin
        TempGeneralPostingSetup.Reset();
        TempGeneralPostingSetup.SetRange("Invt. Rounding Adj. Acc. CZL", GeneralPostingSetup."Invt. Rounding Adj. Acc. CZL");
        if not TempGeneralPostingSetup.FindFirst() then
            InsertGLInvtReportEntryCZL(InventoryReportEntry, InventoryReportHeader, GeneralPostingSetup."Invt. Rounding Adj. Acc. CZL", InventoryReportEntry."Inv. Rounding Adj. CZL");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Get Inventory Report", 'OnAfterCalcValueEntries', '', false, false)]
    local procedure ReconsiliationValuesOnAfterCalcValueEntries(var InventoryReportEntry: Record "Inventory Report Entry"; var ValueEntry: Record "Value Entry")
    begin
        InventoryReportEntry."Inv. Rounding Adj. CZL" += CalcInvRndAdjmtCZL(ValueEntry);
        InventoryReportEntry."Consumption CZL" += CalcConsumptionCZL(ValueEntry);
        InventoryReportEntry."Change In Inv.Of WIP CZL" += CalcChInvWIPCZL(ValueEntry);
        InventoryReportEntry."Change In Inv.Of Product CZL" += CalcChInvProductCZL(ValueEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Get Inventory Report", 'OnCalcDiffOnAfterCalcSumsTypeGLAccount', '', false, false)]
    local procedure ReconsiliationValuesOnAfterCalcSumsTypeGLAccount(var InventoryReportEntry: Record "Inventory Report Entry")
    begin
        InventoryReportEntry.CalcSums("Consumption CZL", "Change In Inv.Of WIP CZL", "Change In Inv.Of Product CZL", "Inv. Rounding Adj. CZL");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Get Inventory Report", 'OnCalcDiffOnAfterCalcSumsTypeItem', '', false, false)]
    local procedure ReconsiliationValuesOnAfterCalcSumsTypeItem(var InventoryReportEntry: Record "Inventory Report Entry")
    begin
        InventoryReportEntry.CalcSums("Consumption CZL", "Change In Inv.Of WIP CZL", "Change In Inv.Of Product CZL", "Inv. Rounding Adj. CZL");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Get Inventory Report", 'OnCalcDiffOnBeforeCopytoInventoryReportEntry', '', false, false)]
    local procedure ReconsiliationValuesOnBeforeCopytoInventoryReportEntry(var CalcInventoryReportEntry: Record "Inventory Report Entry"; var InventoryReportEntry: Record "Inventory Report Entry")
    begin
        CalcInventoryReportEntry."Inv. Rounding Adj. CZL" -= InventoryReportEntry."Inv. Rounding Adj. CZL";
        CalcInventoryReportEntry."Consumption CZL" -= InventoryReportEntry."Consumption CZL";
        CalcInventoryReportEntry."Change In Inv.Of WIP CZL" -= InventoryReportEntry."Change In Inv.Of WIP CZL";
        CalcInventoryReportEntry."Change In Inv.Of Product CZL" -= InventoryReportEntry."Change In Inv.Of Product CZL";
    end;

    procedure DrillDownConsumptionCZL(var InventoryReportEntry: Record "Inventory Report Entry")
    var
        ValueEntry: Record "Value Entry";
    begin
        if InventoryReportEntry.Type = InventoryReportEntry.Type::"G/L Account" then begin
            DrillDownGLCZL(InventoryReportEntry);
            exit;
        end;

        ValueEntry.SetCurrentKey("Item No.", "Posting Date", "Item Ledger Entry Type", "Entry Type");
        ValueEntry.SetRange("Item No.", InventoryReportEntry."No.");
        ValueEntry.SetFilter("Posting Date", InventoryReportEntry.GetFilter("Posting Date Filter"));
        ValueEntry.SetFilter("Location Code", InventoryReportEntry.GetFilter("Location Filter"));
        ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
        ValueEntry.SetFilter("Item Ledger Entry Type", '%1|%2', "Item Ledger Entry Type"::Output, "Item Ledger Entry Type"::Consumption);
        Page.Run(0, ValueEntry, ValueEntry."Cost Amount (Actual)");
    end;

    procedure DrillDownChInvWipCZL(var InventoryReportEntry: Record "Inventory Report Entry")
    var
        ValueEntry: Record "Value Entry";
    begin
        if InventoryReportEntry.Type = InventoryReportEntry.Type::"G/L Account" then begin
            DrillDownGLCZL(InventoryReportEntry);
            exit;
        end;

        ValueEntry.SetCurrentKey("Item No.", "Posting Date", "Item Ledger Entry Type", "Entry Type");
        ValueEntry.SetRange("Item No.", InventoryReportEntry."No.");
        ValueEntry.SetFilter("Posting Date", InventoryReportEntry.GetFilter("Posting Date Filter"));
        ValueEntry.SetFilter("Location Code", InventoryReportEntry.GetFilter("Location Filter"));
        ValueEntry.SetFilter("Entry Type", '%1|%2', ValueEntry."Entry Type"::"Direct Cost", ValueEntry."Entry Type"::Revaluation);
        ValueEntry.SetFilter("Item Ledger Entry Type", '%1|%2', "Item Ledger Entry Type"::Output, "Item Ledger Entry Type"::Consumption);
        Page.Run(0, ValueEntry, ValueEntry."Cost Amount (Actual)");
    end;

    procedure DrillDownChInvProdCZL(var InventoryReportEntry: Record "Inventory Report Entry")
    var
        ValueEntry: Record "Value Entry";
    begin
        if InventoryReportEntry.Type = InventoryReportEntry.Type::"G/L Account" then begin
            DrillDownGLCZL(InventoryReportEntry);
            exit;
        end;

        ValueEntry.SetCurrentKey("Item No.", "Posting Date", "Item Ledger Entry Type", "Entry Type");
        ValueEntry.SetRange("Item No.", InventoryReportEntry."No.");
        ValueEntry.SetFilter("Posting Date", InventoryReportEntry.GetFilter("Posting Date Filter"));
        ValueEntry.SetFilter("Location Code", InventoryReportEntry.GetFilter("Location Filter"));
        ValueEntry.SetFilter("Entry Type", '%1|%2', ValueEntry."Entry Type"::"Direct Cost", ValueEntry."Entry Type"::Revaluation);
        ValueEntry.SetRange("Item Ledger Entry Type", "Item Ledger Entry Type"::Output);
        Page.Run(0, ValueEntry, ValueEntry."Cost Amount (Expected)");
    end;

    procedure DrillDownInvAdjmtRndCZL(var InventoryReportEntry: Record "Inventory Report Entry")
    var
        ValueEntry: Record "Value Entry";
    begin
        if InventoryReportEntry.Type = InventoryReportEntry.Type::"G/L Account" then begin
            DrillDownGLCZL(InventoryReportEntry);
            exit;
        end;

        ValueEntry.SetCurrentKey("Item No.", "Posting Date", "Item Ledger Entry Type", "Entry Type");
        ValueEntry.SetRange("Item No.", InventoryReportEntry."No.");
        ValueEntry.SetFilter("Posting Date", InventoryReportEntry.GetFilter("Posting Date Filter"));
        ValueEntry.SetFilter("Location Code", InventoryReportEntry.GetFilter("Location Filter"));
        ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::Rounding);
        Page.Run(0, ValueEntry, ValueEntry."Cost Amount (Actual)");
    end;

    procedure CalcInvRndAdjmtCZL(var ValueEntry: Record "Value Entry"): Decimal
    begin
        if ValueEntry."Entry Type" = ValueEntry."Entry Type"::Rounding then begin
            ValueEntry.CalcSums("Cost Amount (Actual)");
            exit(-ValueEntry."Cost Amount (Actual)");
        end;
        exit(0);
    end;

    procedure CalcConsumptionCZL(var ValueEntry: Record "Value Entry"): Decimal
    begin
        if (ValueEntry."Entry Type" = ValueEntry."Entry Type"::"Direct Cost") and
           (ValueEntry."Item Ledger Entry Type" = ValueEntry."Item Ledger Entry Type"::Consumption)
        then begin
            ValueEntry.CalcSums("Cost Amount (Actual)");
            exit(ValueEntry."Cost Amount (Actual)");
        end;
        exit(0);
    end;

    procedure CalcChInvWIPCZL(var ValueEntry: Record "Value Entry"): Decimal
    begin
        case ValueEntry."Entry Type" of
            ValueEntry."Entry Type"::"Direct Cost":
                case ValueEntry."Item Ledger Entry Type" of
                    ValueEntry."Item Ledger Entry Type"::Consumption:
                        begin
                            ValueEntry.CalcSums("Cost Amount (Actual)");
                            exit(-ValueEntry."Cost Amount (Actual)");
                        end;
                    ValueEntry."Item Ledger Entry Type"::Output:
                        begin
                            ValueEntry.CalcSums("Cost Amount (Actual)", ValueEntry."Cost Amount (Expected)");
                            exit(-ValueEntry."Cost Amount (Actual)" - ValueEntry."Cost Amount (Expected)");
                        end;
                end;
            ValueEntry."Entry Type"::Revaluation:
                if ValueEntry."Item Ledger Entry Type" = ValueEntry."Item Ledger Entry Type"::Output then begin
                    ValueEntry.CalcSums("Cost Amount (Expected)");
                    exit(-ValueEntry."Cost Amount (Expected)");
                end;
        end;
        exit(0);
    end;

    procedure CalcChInvProductCZL(var ValueEntry: Record "Value Entry"): Decimal
    begin
        case ValueEntry."Entry Type" of
            ValueEntry."Entry Type"::"Direct Cost":
                if ValueEntry."Item Ledger Entry Type" = ValueEntry."Item Ledger Entry Type"::Output then begin
                    ValueEntry.CalcSums("Cost Amount (Actual)", "Cost Amount (Expected)");
                    exit(ValueEntry."Cost Amount (Expected)" + ValueEntry."Cost Amount (Actual)");
                end;
            ValueEntry."Entry Type"::Revaluation:
                if ValueEntry."Item Ledger Entry Type" = ValueEntry."Item Ledger Entry Type"::Output then begin
                    ValueEntry.CalcSums("Cost Amount (Expected)");
                    exit(ValueEntry."Cost Amount (Expected)");
                end;
        end;
        exit(0);
    end;

    local procedure DrillDownGLCZL(var InventoryReportEntry: Record "Inventory Report Entry")
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("G/L Account No.", InventoryReportEntry."No.");
        GLEntry.SetFilter("Posting Date", InventoryReportEntry.GetFilter("Posting Date Filter"));
        Page.Run(0, GLEntry, GLEntry.Amount);
    end;

    local procedure InsertGLInvtReportEntryCZL(var InventoryReportEntry: Record "Inventory Report Entry"; var InventoryReportHeader: Record "Inventory Report Header"; GLAccNo: Code[20]; var CostAmount: Decimal)
    var
        GLAccount: Record "G/L Account";
    begin
        InventoryReportEntry.Init();
        if not GLAccount.Get(GLAccNo) then
            exit;
        GLAccount.SetFilter("Date Filter", InventoryReportHeader.GetFilter("Posting Date Filter"));
        GLAccount.CalcFields("Net Change");
        CostAmount := GLAccount."Net Change";
        if CostAmount = 0 then
            exit;

        InventoryReportEntry.Type := InventoryReportEntry.Type::"G/L Account";
        InventoryReportEntry."No." := GLAccount."No.";
        InventoryReportEntry.Description := GLAccount.Name;
        InventoryReportEntry."Entry No." := InventoryReportEntry."Entry No." + 1;
        InventoryReportEntry.Insert();
    end;
}
