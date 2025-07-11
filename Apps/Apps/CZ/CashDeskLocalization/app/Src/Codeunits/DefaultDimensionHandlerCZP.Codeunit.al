// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Setup;

codeunit 31084 "Default Dimension Handler CZP"
{
    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterUpdateGlobalDimCode', '', false, false)]
    local procedure OnAfterUpdateGlobalDimCode(TableID: Integer; GlobalDimCodeNo: Integer; AccNo: Code[20]; NewDimValue: Code[20])
    begin
        case TableID of
            Database::"Cash Desk CZP":
                UpdateCashDeskCZPGlobalDimCode(GlobalDimCodeNo, AccNo, NewDimValue);
            Database::"Cash Desk Event CZP":
                UpdateCashDeskEventCZPGlobalDimCode(GlobalDimCodeNo, AccNo, NewDimValue);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cash Desk CZP", 'OnAfterInsertEvent', '', false, false)]
    local procedure CashDeskCZPOnAfterInsertEvent(var Rec: Record "Cash Desk CZP")
    begin
        if Rec.IsTemporary then
            exit;

        if UpdateDefaultDimension(Database::"Cash Desk CZP", Rec."No.") then
            Rec.Get(Rec."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cash Desk Event CZP", 'OnAfterInsertEvent', '', false, false)]
    local procedure CashDeskEventCZPOnAfterInsertEvent(var Rec: Record "Cash Desk Event CZP")
    begin
        if Rec.IsTemporary then
            exit;

        if UpdateDefaultDimension(Database::"Cash Desk CZP", Rec.Code) then
            Rec.Get(Rec.Code);
    end;

    local procedure UpdateCashDeskCZPGlobalDimCode(GlobalDimCodeNo: Integer; CashDeskNo: Code[20]; NewDimValue: Code[20])
    var
        CashDeskCZP: Record "Cash Desk CZP";
    begin
        if CashDeskCZP.Get(CashDeskNo) then begin
            case GlobalDimCodeNo of
                1:
                    CashDeskCZP."Global Dimension 1 Code" := NewDimValue;
                2:
                    CashDeskCZP."Global Dimension 2 Code" := NewDimValue;
            end;
            CashDeskCZP.Modify(true);
        end;
    end;

    local procedure UpdateCashDeskEventCZPGlobalDimCode(GlobalDimCodeNo: Integer; CashDeskEventNo: Code[20]; NewDimValue: Code[20])
    var
        CashDeskEventCZP: Record "Cash Desk Event CZP";
    begin
        if CashDeskEventCZP.Get(CashDeskEventNo) then begin
            case GlobalDimCodeNo of
                1:
                    CashDeskEventCZP."Global Dimension 1 Code" := NewDimValue;
                2:
                    CashDeskEventCZP."Global Dimension 2 Code" := NewDimValue;
            end;
            CashDeskEventCZP.Modify(true);
        end;
    end;

    local procedure UpdateDefaultDimension(TableID: Integer; No: Code[20]): Boolean
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        DefaultDimension: Record "Default Dimension";
        UpdateGlobalDimCode: Boolean;
    begin
        UpdateGlobalDimCode := false;
        GeneralLedgerSetup.Get();
        DefaultDimension.SetRange("Table ID", TableID);
        DefaultDimension.SetRange("No.", No);
        if DefaultDimension.FindSet(true) then
            repeat
                if DefaultDimension."Dimension Code" = GeneralLedgerSetup."Global Dimension 1 Code" then begin
                    DefaultDimension.UpdateGlobalDimCode(1, TableID, No, DefaultDimension."Dimension Value Code");
                    UpdateGlobalDimCode := true;
                end;
                if DefaultDimension."Dimension Code" = GeneralLedgerSetup."Global Dimension 2 Code" then begin
                    DefaultDimension.UpdateGlobalDimCode(2, TableID, No, DefaultDimension."Dimension Value Code");
                    UpdateGlobalDimCode := true;
                end;
            until DefaultDimension.Next() = 0;
        exit(UpdateGlobalDimCode);
    end;
}
