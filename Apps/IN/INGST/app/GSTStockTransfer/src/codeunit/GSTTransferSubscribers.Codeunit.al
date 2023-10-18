// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.StockTransfer;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GST.Base;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Transfer;

codeunit 18392 "GST Transfer Subscribers"
{
    var
        GSTCustomDutyErr: Label 'Custom Duty Amount must be 0 if GST Group Type is Service while transferring from Bonded Warehouse location.';
        GSTAssessableErr: Label 'GST Assessable Value must be 0 if GST Group Type is Service while transferring from Bonded Warehouse location.';

    local procedure GSTAssessableValue(var Transferline: Record "Transfer Line")
    var
        TransHeader: Record "Transfer Header";
        Location: Record Location;
        GSTGroup: Record "GST Group";
    begin
        TransHeader.Get(Transferline."Document No.");
        Location.Get(Transferline."Transfer-from Code");
        if not Location."Bonded warehouse" then
            Transferline.TestField(Transferline."GST Assessable Value", 0);

        if GSTGroup.Get(Transferline."GST Group Code") and
            (GSTGroup."GST Group Type" <> GSTGroup."GST Group Type"::Goods)
        then
            if (Transferline."GST Assessable Value" <> 0) then
                Error(GSTAssessableErr);

        Transferline.Validate(Quantity);
    end;

    local procedure CustomDutyAmount(var Transferline: Record "Transfer Line")
    var
        TransHeader: Record "Transfer Header";
        Location: Record Location;
        GSTGroup: Record "GST Group";
    begin
        TransHeader.Get(Transferline."Document No.");
        Location.Get(Transferline."Transfer-from Code");
        if not Location."Bonded warehouse" then
            Transferline.TestField("Custom Duty Amount", 0);

        if GSTGroup.Get(Transferline."GST Group Code") and
            (GSTGroup."GST Group Type" <> GSTGroup."GST Group Type"::Goods)
        then
            if (Transferline."Custom Duty Amount" <> 0) then
                Error(GSTCustomDutyErr);

        Transferline.Validate(Quantity);
    end;

    //Transfer Header - Subscribers    
    [EventSubscriber(ObjectType::Table, database::"Transfer Header", 'OnBeforeValidateEvent', 'Transfer-from Code', false, false)]
    local procedure CheckTransferfromCode(var Rec: Record "Transfer Header")
    var
        Location: Record Location;
    begin
        if Location.Get(Rec."Transfer-from Code") then begin
            Location.TestField("GST Input Service Distributor", false);
            if Location."Bonded warehouse" then
                Rec.TestField("Load Unreal Prof Amt on Invt.", false);
        end;
    end;

    [EventSubscriber(ObjectType::Table, database::"Transfer Header", 'OnBeforeValidateEvent', 'Transfer-to Code', false, false)]
    local procedure CheckTransfertoCode(var Rec: Record "Transfer Header")
    var
        Location: Record Location;
    begin
        if Location.Get(Rec."Transfer-to Code") then
            Location.TestField("GST Input Service Distributor", false);
    end;

    [EventSubscriber(ObjectType::Table, database::"Transfer Header", 'OnAfterValidateEvent', 'Load Unreal Prof Amt on Invt.', false, false)]
    local procedure ValidateLoadUnrealProfAmtoninvt(var Rec: Record "Transfer Header")
    var
        Location: Record Location;
    begin
        if Location.Get(Rec."Transfer-from Code") then
            Location.TestField("Bonded warehouse", false);
    end;

    //Transfer Line - Subscribers
    [EventSubscriber(ObjectType::Table, DATABASE::"Transfer Line", 'OnAfterValidateEvent', 'Item No.', false, false)]
    local procedure validateItemNo(var Rec: Record "Transfer Line")
    var
        Item: Record Item;
    begin
        if not Item.Get(Rec."Item No.") then
            exit;

        Rec."GST Credit" := Item."GST Credit";
        Rec."GST Group Code" := Item."GST Group Code";
        Rec."HSN/SAC Code" := Item."HSN/SAC Code";
        Rec.Exempted := Item.Exempted;
        Rec.Validate("Transfer Price");
    end;

    [EventSubscriber(ObjectType::Table, DATABASE::"Transfer Line", 'OnBeforeValidateEvent', 'Quantity', false, false)]
    local procedure ValidateQuantity(var Rec: Record "Transfer Line")
    begin
        Rec.Amount := Round(Rec.Quantity * Rec."Transfer Price");
    end;

    [EventSubscriber(ObjectType::Table, DATABASE::"Transfer Line", 'OnAfterValidateEvent', 'Transfer price', false, false)]
    local procedure ValidateTransferPrice(var Rec: Record "Transfer Line")
    begin
        Rec.TestField("Quantity Shipped", 0);
        Rec.Amount := Round(Rec.Quantity * Rec."Transfer Price");
    end;

    [EventSubscriber(ObjectType::table, DATABASE::"Transfer Line", 'OnAfterValidateEvent', 'Exempted', false, false)]
    local procedure ValidateExempted(var Rec: Record "Transfer Line")
    begin
        Rec.TestField("Quantity Shipped", 0);
        Rec.TestField("Quantity Received", 0);
    end;

    [EventSubscriber(ObjectType::Table, DATABASE::"Transfer Line", 'OnAfterValidateEvent', 'GST Assessable Value', false, false)]
    local procedure ValidateGSTAssessableValue(var Rec: Record "Transfer Line")
    begin
        GSTAssessableValue(rec);
    end;

    [EventSubscriber(ObjectType::Table, DATABASE::"Transfer Line", 'OnAfterValidateEvent', 'Custom Duty Amount', false, false)]
    local procedure ValidateCustomDutyAmount(var Rec: Record "Transfer Line")
    begin
        CustomDutyAmount(rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnBeforeCheckAccountNo', '', false, false)]
    local procedure OnBeforeCheckAccountNo(var GenJnlLine: Record "Gen. Journal Line"; var CheckDone: Boolean)
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.Get();
        if GenJnlLine."Source Code" = SourceCodeSetup.Transfer then
            CheckDone := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", 'OnAfterValidateEvent', 'Unit of Measure Code', false, false)]
    local procedure UPdateTransferPrie(var Rec: Record "Transfer Line")
    var
        Item: Record "Item";
    begin
        Item.Get(Rec."Item No.");
        Rec.Validate("Transfer Price", Item."Unit Cost" * Rec."Qty. per Unit of Measure");
    end;
}
