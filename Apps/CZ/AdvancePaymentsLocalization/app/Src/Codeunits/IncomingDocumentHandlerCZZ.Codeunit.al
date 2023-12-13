// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.EServices.EDocument;

codeunit 31435 "Incoming Document Handler CZZ"
{
    var
        TwoPlaceholderTok: Label '%1 - %2', Locked = true;

    [EventSubscriber(ObjectType::Table, Database::"Incoming Document", 'OnAfterSetCreatedDocumentType', '', false, false)]
    local procedure AddAdvancesOnAfterSetCreatedDocumentType(var CreatedDocumentType: Dictionary of [Integer, Integer]; var CreatedDocumentStrMenu: Text)
    var
        NumberOfTypes: Integer;
        PurchAdvanceTxt: Label 'Purchase Advance';
        SalesAdvanceTxt: Label 'Sales Advance';
    begin
        NumberOfTypes := CreatedDocumentType.Count();
        CreatedDocumentType.Add(NumberOfTypes + 1, "Incoming Related Document Type"::"Purchase Advance CZZ".AsInteger());
        CreatedDocumentStrMenu += ',' + PurchAdvanceTxt;
        CreatedDocumentType.Add(NumberOfTypes + 2, "Incoming Related Document Type"::"Sales Advance CZZ".AsInteger());
        CreatedDocumentStrMenu += ',' + SalesAdvanceTxt;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Incoming Document", 'OnAfterCreateDocumentType', '', false, false)]
    local procedure CreateAdvanceLetterOnAfterCreateDocumentType(var IncomingDocument: Record "Incoming Document"; DocumentTypeEnum: Integer)
    begin
        case DocumentTypeEnum of
            IncomingDocument."Document Type"::"Purchase Advance CZZ".AsInteger():
                IncomingDocument.CreatePurchAdvLetterCZZ();
            IncomingDocument."Document Type"::"Sales Advance CZZ".AsInteger():
                IncomingDocument.CreateSalesAdvLetterCZZ();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Incoming Document", 'OnTestIfAlreadyExists', '', false, false)]
    local procedure CheckAdvanceLetterOnTestIfAlreadyExists(IncomingRelatedDocumentType: Enum "Incoming Related Document Type"; EntryNo: Integer)
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        AlreadyUsedInPurchaseAdvanceErr: Label 'The incoming document has already been assigned to purchase advance %1.', Comment = '%1 = Document Number';
        AlreadyUsedInSalesAdvanceErr: Label 'The incoming document has already been assigned to sales advance %1.', Comment = '%1 = Document Number';
    begin
        case IncomingRelatedDocumentType of
            IncomingRelatedDocumentType::"Purchase Advance CZZ":
                begin
                    PurchAdvLetterHeaderCZZ.SetRange("Incoming Document Entry No.", EntryNo);
                    if PurchAdvLetterHeaderCZZ.FindFirst() then
                        Error(AlreadyUsedInPurchaseAdvanceErr, PurchAdvLetterHeaderCZZ."No.");
                end;
            IncomingRelatedDocumentType::"Sales Advance CZZ":
                begin
                    SalesAdvLetterHeaderCZZ.SetRange("Incoming Document Entry No.", EntryNo);
                    if SalesAdvLetterHeaderCZZ.FindFirst() then
                        Error(AlreadyUsedInSalesAdvanceErr, SalesAdvLetterHeaderCZZ."No.");
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Incoming Document", 'OnBeforeGetRelatedDocType', '', false, false)]
    local procedure GetAdvanceLetterOnBeforeGetRelatedDocType(PostingDate: Date; DocNo: Code[20]; var IsPosted: Boolean; var IncomingRelatedDocumentType: Enum "Incoming Related Document Type"; var IsHandled: Boolean)
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
    begin
        if IsHandled then
            exit;

        case true of
            PurchAdvLetterHeaderCZZ.Get(DocNo):
                if PurchAdvLetterHeaderCZZ."Posting Date" = PostingDate then begin
                    IncomingRelatedDocumentType := "Incoming Related Document Type"::"Purchase Advance CZZ";
                    IsHandled := true;
                    IsPosted := PurchAdvLetterHeaderCZZ.Status = PurchAdvLetterHeaderCZZ.Status::Closed;
                end;
            SalesAdvLetterHeaderCZZ.Get(DocNo):
                if SalesAdvLetterHeaderCZZ."Posting Date" = PostingDate then begin
                    IncomingRelatedDocumentType := "Incoming Related Document Type"::"Sales Advance CZZ";
                    IsHandled := true;
                    IsPosted := SalesAdvLetterHeaderCZZ.Status = SalesAdvLetterHeaderCZZ.Status::Closed;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Incoming Document", 'OnAfterClearRelatedRecords', '', false, false)]
    local procedure ClearAdvanceLetterOnAfterClearRelatedRecords(IncomingRelatedDocumentType: Enum "Incoming Related Document Type"; EntryNo: Integer)
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
    begin
        case IncomingRelatedDocumentType of
            IncomingRelatedDocumentType::"Purchase Advance CZZ":
                begin
                    PurchAdvLetterHeaderCZZ.SetRange("Incoming Document Entry No.", EntryNo);
                    PurchAdvLetterHeaderCZZ.ModifyAll("Incoming Document Entry No.", 0, true);
                end;
            IncomingRelatedDocumentType::"Sales Advance CZZ":
                begin
                    SalesAdvLetterHeaderCZZ.SetRange("Incoming Document Entry No.", EntryNo);
                    SalesAdvLetterHeaderCZZ.ModifyAll("Incoming Document Entry No.", 0, true);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Incoming Document", 'OnAfterUpdateDocumentFields', '', false, false)]
    local procedure UpdateAdvanceLetterOnAfterUpdateDocumentFields(var IncomingDocument: Record "Incoming Document"; var DocExists: Boolean);
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
    begin
        PurchAdvLetterHeaderCZZ.SetRange("Incoming Document Entry No.", IncomingDocument."Entry No.");
        if PurchAdvLetterHeaderCZZ.FindFirst() then begin
            IncomingDocument."Document Type" := IncomingDocument."Document Type"::"Purchase Advance CZZ";
            IncomingDocument."Document No." := PurchAdvLetterHeaderCZZ."No.";
            DocExists := true;
            exit;
        end;

        SalesAdvLetterHeaderCZZ.SetRange("Incoming Document Entry No.", IncomingDocument."Entry No.");
        if SalesAdvLetterHeaderCZZ.FindFirst() then begin
            IncomingDocument."Document Type" := IncomingDocument."Document Type"::"Sales Advance CZZ";
            IncomingDocument."Document No." := SalesAdvLetterHeaderCZZ."No.";
            DocExists := true;
            exit;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Incoming Document", 'OnAfterFindPostedRecord', '', false, false)]
    local procedure FindAdvanceLetterOnAfterFindPostedRecord(var RelatedRecord: Variant; var RecordFound: Boolean; var IncomingDocument: Record "Incoming Document")
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
    begin
        case IncomingDocument."Document Type" of
            IncomingDocument."Document Type"::"Purchase Advance CZZ":
                if PurchAdvLetterHeaderCZZ.Get(IncomingDocument."Document No.") then begin
                    RelatedRecord := PurchAdvLetterHeaderCZZ;
                    RecordFound := true;
                end;
            IncomingDocument."Document Type"::"Sales Advance CZZ":
                if SalesAdvLetterHeaderCZZ.Get(IncomingDocument."Document No.") then begin
                    RelatedRecord := SalesAdvLetterHeaderCZZ;
                    RecordFound := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Incoming Document", 'OnAfterFindUnPostedRecord', '', false, false)]
    local procedure FindAdvanceLetterOnAfterFindUnPostedRecord(var RelatedRecord: Variant; var RecordFound: Boolean; var IncomingDocument: Record "Incoming Document")
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
    begin
        case IncomingDocument."Document Type" of
            IncomingDocument."Document Type"::"Purchase Advance CZZ":
                if PurchAdvLetterHeaderCZZ.Get(IncomingDocument."Document No.") then begin
                    RelatedRecord := PurchAdvLetterHeaderCZZ;
                    RecordFound := true;
                end;
            IncomingDocument."Document Type"::"Sales Advance CZZ":
                if SalesAdvLetterHeaderCZZ.Get(IncomingDocument."Document No.") then begin
                    RelatedRecord := SalesAdvLetterHeaderCZZ;
                    RecordFound := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Incoming Document", 'OnAfterGetRelatedRecordCaption', '', false, false)]
    local procedure GetRelatedRecordCaption(var RelatedRecordRef: RecordRef; var RecCaption: Text)
    var
        SalesAdvanceTxt: Label 'Sales Advance';
        PurchAdvanceTxt: Label 'Purchase Advance';
    begin
        if RelatedRecordRef.IsEmpty() then
            exit;

        case RelatedRecordRef.Number of
            Database::"Sales Adv. Letter Header CZZ":
                RecCaption := StrSubstNo(TwoPlaceholderTok, SalesAdvanceTxt, GetRecordCaption(RelatedRecordRef));
            Database::"Purch. Adv. Letter Header CZZ":
                RecCaption := StrSubstNo(TwoPlaceholderTok, PurchAdvanceTxt, GetRecordCaption(RelatedRecordRef));
        end;
    end;

    local procedure GetRecordCaption(var RecordRef: RecordRef): Text
    var
        FieldRef: FieldRef;
        KeyRef: KeyRef;
        KeyNo: Integer;
        FieldNo: Integer;
        RecCaption: Text;
    begin
        for KeyNo := 1 to RecordRef.KeyCount do begin
            KeyRef := RecordRef.KeyIndex(KeyNo);
            if KeyRef.Active then begin
                for FieldNo := 1 to KeyRef.FieldCount do begin
                    FieldRef := KeyRef.FieldIndex(FieldNo);
                    if RecCaption <> '' then
                        RecCaption := StrSubstNo(TwoPlaceholderTok, RecCaption, FieldRef.Value)
                    else
                        RecCaption := Format(FieldRef.Value);
                end;
                break;
            end
        end;
        exit(RecCaption);
    end;
}
