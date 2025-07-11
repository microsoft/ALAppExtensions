// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Warehouse.GateEntry;

using Microsoft.Finance.TaxBase;
using System.Security.User;
using Microsoft.Sales.Document;
using Microsoft.Purchases.Document;
using Microsoft.Inventory.Transfer;
using System.Security.AccessControl;
using Microsoft.Warehouse.Document;

codeunit 18601 "Gate Entry Handler"
{
    var
        PostedGateEntryLine: Record "Posted Gate Entry Line";
        GateEntryAttachment: Record "Gate Entry Attachment";
        PostedGateEntryLineList: Page "Posted Gate Entry Line List";

    procedure LookupUserID(var UserName: Code[50])
    var
        SID: Guid;
    begin
        LookupUser(UserName, SID);
    end;

    procedure LookupUser(var UserName: Code[50]; var SID: Guid): Boolean
    var
        User: Record User;
    begin
        User.Reset();
        User.SetCurrentKey("User Name");
        User."User Name" := UserName;
        if User.Find('=><') then;
        if Page.RunModal(Page::Users, User) = Action::LookupOK then begin
            UserName := User."User Name";
            SID := User."User Security ID";
            exit(true);
        end;
        exit(false);
    end;

    procedure CopyCommentLines(
        FromEntryType: Enum "Gate Entry Type";
        ToEntryType: Enum "Gate Entry Type";
        FromNumber: Code[20];
        ToNumber: Code[20])
    var
        GateEntryCommentLine: Record "Gate Entry Comment Line";
        GECommentLine: Record "Gate Entry Comment Line";
    begin
        GateEntryCommentLine.SetRange("Gate Entry Type", FromEntryType);
        GateEntryCommentLine.SetRange("No.", FromNumber);
        if GateEntryCommentLine.FindSet() then
            repeat
                GECommentLine := GateEntryCommentLine;
                GECommentLine."Gate Entry Type" := ToEntryType;
                GECommentLine."No." := ToNumber;
                GECommentLine.Insert();
            until GateEntryCommentLine.Next() = 0;
    end;

    procedure GetGateEntrySourceType(SourceType: Enum "Gate Entry Source Type"): Enum "Posted Gate Entry Source Type"
    begin
        case SourceType of
            SourceType::"Sales Return Order":
                exit("Posted Gate Entry Source Type"::"Sales Return Order");
            SourceType::"Purchase Order":
                exit("Posted Gate Entry Source Type"::"Purchase Order");
            SourceType::"Transfer Receipt":
                exit("Posted Gate Entry Source Type"::"Transfer Receipt");
        end;
    end;

    procedure GetPurchaseGateEntryLines(PurchaseHeader: Record "Purchase Header")
    begin
        begin
            PostedGateEntryLine.ModifyAll(Mark, false);
            PostedGateEntryLine.Reset();
            PostedGateEntryLine.SetCurrentKey("Entry Type", "Source Type", "Source No.", Status);

            case PurchaseHeader."Document Type" of
                PurchaseHeader."Document Type"::Order:
                    begin
                        PostedGateEntryLine.SetRange("Source Type", PostedGateEntryLine."Source Type"::"Purchase Order");
                        PostedGateEntryLine.SetRange("Entry Type", PostedGateEntryLine."Entry Type"::Inward);
                        PostedGateEntryLine.SetRange("Source No.", PurchaseHeader."No.");
                        PostedGateEntryLine.SetRange(Status, PostedGateEntryLine.Status::Open);
                    end;
                PurchaseHeader."Document Type"::Invoice:
                    begin
                        PostedGateEntryLine.SetRange("Source Type", PostedGateEntryLine."Source Type"::" ");
                        PostedGateEntryLine.SetRange("Entry Type", PostedGateEntryLine."Entry Type"::Inward);
                        PostedGateEntryLine.SetRange(Status, PostedGateEntryLine.Status::Open);
                    end;
            end;

            GateEntryAttachment.SetCurrentKey("Source Type", "Source No.", "Entry Type", "Gate Entry No.", "Line No.");
            if PostedGateEntryLine.FindSet() then
                repeat
                    GateEntryAttachment.SetRange("Source No.", PostedGateEntryLine."Source No.");
                    GateEntryAttachment.SetRange("Gate Entry No.", PostedGateEntryLine."Gate Entry No.");
                    GateEntryAttachment.SetRange("Line No.", PostedGateEntryLine."Line No.");
                    if not GateEntryAttachment.FindFirst() then begin
                        PostedGateEntryLine.Mark := true;
                        PostedGateEntryLine.Modify();
                        Commit();
                    end;
                until PostedGateEntryLine.Next() = 0;

            PostedGateEntryLine.Reset();
            PostedGateEntryLine.SetCurrentKey("Entry Type", "Source Type", "Source No.", Status);
            PostedGateEntryLine.SetRange(Mark, true);
            if PostedGateEntryLine.FindFirst() then begin
                PostedGateEntryLineList.SetTableView(PostedGateEntryLine);
                if Page.RunModal(Page::"Posted Gate Entry Line List", PostedGateEntryLine) = Action::LookupOK then begin
                    GateEntryAttachment.Init();
                    GateEntryAttachment."Source Type" := PostedGateEntryLine."Source Type";
                    GateEntryAttachment."Source No." := PostedGateEntryLine."Source No.";
                    GateEntryAttachment."Entry Type" := PostedGateEntryLine."Entry Type";
                    GateEntryAttachment."Gate Entry No." := PostedGateEntryLine."Gate Entry No.";
                    GateEntryAttachment."Line No." := PostedGateEntryLine."Line No.";
                    GateEntryAttachment."Purchase Invoice No." := PurchaseHeader."No.";
                    GateEntryAttachment.Insert();
                end;
            end;
        end;
    end;

    procedure GetWarehouseGateEntryLines(WarehouseReceiptLine: record "Warehouse Receipt Line")
    var
        WarehouseReceiptHeader: Record "Warehouse Receipt Header";
    begin
        PostedGateEntryLine.ModifyAll(Mark, false);
        PostedGateEntryLine.Reset();
        PostedGateEntryLine.SetCurrentKey("Entry Type", "Source Type", "Source No.", Status);

        WarehouseReceiptHeader.Get(WarehouseReceiptLine."No.");

        case WarehouseReceiptLine."Source Type" of
            Database::"Sales Line":
                if WarehouseReceiptLine."Source Subtype" = 5 then
                    PostedGateEntryLine.SetRange("Source Type", PostedGateEntryLine."Source Type"::"Sales Return Order");
            Database::"Purchase Line":
                if WarehouseReceiptLine."Source Subtype" = 1 then
                    PostedGateEntryLine.SetRange("Source Type", PostedGateEntryLine."Source Type"::"Purchase Order");
            Database::"Transfer Line":
                if WarehouseReceiptLine."Source Subtype" = 1 then
                    PostedGateEntryLine.SetRange("Source Type", PostedGateEntryLine."Source Type"::"Transfer Receipt");
        end;

        PostedGateEntryLine.SetRange("Entry Type", PostedGateEntryLine."Entry Type"::Inward);
        PostedGateEntryLine.SetRange("Source No.", WarehouseReceiptLine."Source No.");
        PostedGateEntryLine.SetRange(Status, PostedGateEntryLine.Status::Open);

        GateEntryAttachment.SetCurrentKey("Source Type", "Source No.", "Entry Type", "Gate Entry No.", "Line No.");
        if PostedGateEntryLine.FindSet() then
            repeat
                GateEntryAttachment.SetRange("Source No.", PostedGateEntryLine."Source No.");
                GateEntryAttachment.SetRange("Gate Entry No.", PostedGateEntryLine."Gate Entry No.");
                GateEntryAttachment.SetRange("Line No.", PostedGateEntryLine."Line No.");
                if not GateEntryAttachment.FindFirst() then begin
                    PostedGateEntryLine.Mark := true;
                    PostedGateEntryLine.Modify();
                    Commit();
                end;
            until PostedGateEntryLine.Next() = 0;

        PostedGateEntryLine.Reset();
        PostedGateEntryLine.SetCurrentKey("Entry Type", "Source Type", "Source No.", Status);
        PostedGateEntryLine.SetRange(Mark, true);
        if PostedGateEntryLine.FindFirst() then begin
            PostedGateEntryLineList.SetTableView(PostedGateEntryLine);
            if Page.RunModal(Page::"Posted Gate Entry Line List", PostedGateEntryLine) = Action::LookupOK then begin
                GateEntryAttachment.Init();
                GateEntryAttachment."Source Type" := PostedGateEntryLine."Source Type";
                GateEntryAttachment."Source No." := PostedGateEntryLine."Source No.";
                GateEntryAttachment."Entry Type" := PostedGateEntryLine."Entry Type";
                GateEntryAttachment."Gate Entry No." := PostedGateEntryLine."Gate Entry No.";
                GateEntryAttachment."Line No." := PostedGateEntryLine."Line No.";
                GateEntryAttachment."Warehouse Recpt. No." := WarehouseReceiptLine."No.";
                GateEntryAttachment.Insert();
            end;
        end;
    end;

    procedure GetTransferGateEntryLines(TransferHeader: Record "Transfer Header")
    begin
        PostedGateEntryLine.ModifyAll(Mark, false);
        PostedGateEntryLine.Reset();
        PostedGateEntryLine.SetCurrentKey("Entry Type", "Source Type", "Source No.", Status);
        PostedGateEntryLine.SetRange("Entry Type", PostedGateEntryLine."Entry Type"::Inward);
        PostedGateEntryLine.SetRange("Source Type", PostedGateEntryLine."Source Type"::"Transfer Receipt");
        PostedGateEntryLine.SetRange("Source No.", TransferHeader."No.");
        PostedGateEntryLine.SetRange(Status, PostedGateEntryLine.Status::Open);
        GateEntryAttachment.SetCurrentKey("Source Type", "Source No.", "Entry Type", "Gate Entry No.", "Line No.");
        if PostedGateEntryLine.FindSet() then
            repeat
                GateEntryAttachment.SetRange("Source No.", PostedGateEntryLine."Source No.");
                GateEntryAttachment.SetRange("Gate Entry No.", PostedGateEntryLine."Gate Entry No.");
                GateEntryAttachment.SetRange("Line No.", PostedGateEntryLine."Line No.");
                if not GateEntryAttachment.FindFirst() then begin
                    PostedGateEntryLine.Mark := true;
                    PostedGateEntryLine.Modify();
                    Commit();
                end;
            until PostedGateEntryLine.Next() = 0;

        PostedGateEntryLine.Reset();
        PostedGateEntryLine.SetCurrentKey("Entry Type", "Source Type", "Source No.", Status);
        PostedGateEntryLine.SetRange(Mark, true);
        if PostedGateEntryLine.FindFirst() then begin
            PostedGateEntryLineList.SetTableView(PostedGateEntryLine);
            if Page.RunModal(Page::"Posted Gate Entry Line List", PostedGateEntryLine) = Action::LookupOK then begin
                GateEntryAttachment.Init();
                GateEntryAttachment."Source Type" := PostedGateEntryLine."Source Type";
                GateEntryAttachment."Source No." := PostedGateEntryLine."Source No.";
                GateEntryAttachment."Entry Type" := PostedGateEntryLine."Entry Type";
                GateEntryAttachment."Gate Entry No." := PostedGateEntryLine."Gate Entry No.";
                GateEntryAttachment."Line No." := PostedGateEntryLine."Line No.";
                GateEntryAttachment.Insert();
            end;
        end;
    end;

    procedure GetSalesGateEntryLines(SalesHeader: Record "Sales Header")
    begin
        PostedGateEntryLine.ModifyAll(Mark, false);
        PostedGateEntryLine.Reset();
        PostedGateEntryLine.SetCurrentKey("Entry Type", "Source Type", "Source No.", Status);
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::"Return Order":
                begin
                    PostedGateEntryLine.SetRange("Entry Type", PostedGateEntryLine."Entry Type"::Inward);
                    PostedGateEntryLine.SetRange("Source Type", PostedGateEntryLine."Source Type"::"Sales Return Order");
                    PostedGateEntryLine.SetRange("Source No.", SalesHeader."No.");
                    PostedGateEntryLine.SetRange(Status, PostedGateEntryLine.Status::Open);
                end;
            SalesHeader."Document Type"::"Credit Memo":
                begin
                    PostedGateEntryLine.SetRange("Entry Type", PostedGateEntryLine."Entry Type"::Inward);
                    PostedGateEntryLine.SetRange("Source Type", PostedGateEntryLine."Source Type"::" ");
                    PostedGateEntryLine.SetRange(Status, PostedGateEntryLine.Status::Open);
                end;
        end;
        GateEntryAttachment.SetCurrentKey("Source Type", "Source No.", "Entry Type", "Gate Entry No.", "Line No.");
        if PostedGateEntryLine.FindSet() then
            repeat
                GateEntryAttachment.SetRange("Source No.", PostedGateEntryLine."Source No.");
                GateEntryAttachment.SetRange("Gate Entry No.", PostedGateEntryLine."Gate Entry No.");
                GateEntryAttachment.SetRange("Line No.", PostedGateEntryLine."Line No.");
                if not GateEntryAttachment.FindFirst() then begin
                    PostedGateEntryLine.Mark := true;
                    PostedGateEntryLine.Modify();
                    Commit();
                end;
            until PostedGateEntryLine.Next() = 0;

        PostedGateEntryLine.Reset();
        PostedGateEntryLine.SetCurrentKey("Entry Type", "Source Type", "Source No.", Status);
        PostedGateEntryLine.SetRange(Mark, true);
        if PostedGateEntryLine.FindFirst() then begin
            PostedGateEntryLineList.SetTableView(PostedGateEntryLine);
            if Page.RunModal(Page::"Posted Gate Entry Line List", PostedGateEntryLine) = Action::LookupOK then begin
                GateEntryAttachment.Init();
                GateEntryAttachment."Source Type" := PostedGateEntryLine."Source Type";
                GateEntryAttachment."Source No." := PostedGateEntryLine."Source No.";
                GateEntryAttachment."Entry Type" := PostedGateEntryLine."Entry Type";
                GateEntryAttachment."Gate Entry No." := PostedGateEntryLine."Gate Entry No.";
                GateEntryAttachment."Line No." := PostedGateEntryLine."Line No.";
                GateEntryAttachment."Sales Credit Memo No." := SalesHeader."No.";
                GateEntryAttachment.Insert();
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posting No. Series", 'OnGetPostingTableID', '', false, false)]
    local procedure OnGetPostingTableID(Type: Enum "Posting Document Type"; var TableID: Integer; var Handled: Boolean)
    begin
        if Type <> Type::"Gate Entry" then
            exit;

        TableID := Database::"Gate Entry Header";
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posting No. Series", 'OnGetPostingNoSeries', '', false, false)]
    local procedure OnGetPostingNoSeries(sender: Record "Posting No. Series"; var Record: Variant; var Handled: Boolean)
    var
        GateEntryHeader: Record "Gate Entry Header";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Record);
        if RecRef.Number <> Database::"Gate Entry Header" then
            exit;

        GateEntryHeader := Record;
        GateEntryHeader."Posting No. Series" := sender.LoopPostingNoSeries(RecRef.Number, sender, GateEntryHeader, sender."Document Type"::"Gate Entry");
        Record := GateEntryHeader;
        Handled := true;
    end;
}
