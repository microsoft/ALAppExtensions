// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

using Microsoft.EServices.EDocument;

codeunit 31436 "Incoming Document Handler CZC"
{
    [EventSubscriber(ObjectType::Table, Database::"Incoming Document", 'OnAfterSetCreatedDocumentType', '', false, false)]
    local procedure AddCompensationOnAfterSetCreatedDocumentType(var CreatedDocumentType: Dictionary of [Integer, Integer]; var CreatedDocumentStrMenu: Text)
    var
        NumberOfTypes: Integer;
        CompensationTxt: Label 'Compensation';
    begin
        NumberOfTypes := CreatedDocumentType.Count();
        CreatedDocumentType.Add(NumberOfTypes + 1, "Incoming Related Document Type"::"Compensation CZC".AsInteger());
        CreatedDocumentStrMenu += ',' + CompensationTxt;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Incoming Document", 'OnAfterCreateDocumentType', '', false, false)]
    local procedure CreateCompensationOnAfterCreateDocumentType(var IncomingDocument: Record "Incoming Document"; DocumentTypeEnum: Integer)
    begin
        case DocumentTypeEnum of
            IncomingDocument."Document Type"::"Compensation CZC".AsInteger():
                IncomingDocument.CreateCompensationCZC();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Incoming Document", 'OnTestIfAlreadyExists', '', false, false)]
    local procedure CheckCompensationOnTestIfAlreadyExists(IncomingRelatedDocumentType: Enum "Incoming Related Document Type"; EntryNo: Integer)
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
        AlreadyUsedInCompensationErr: Label 'The incoming document has already been assigned to compensation %1.', Comment = '%1 = Document Number';
    begin
        case IncomingRelatedDocumentType of
            IncomingRelatedDocumentType::"Compensation CZC":
                begin
                    CompensationHeaderCZC.SetRange("Incoming Document Entry No.", EntryNo);
                    if CompensationHeaderCZC.FindFirst() then
                        Error(AlreadyUsedInCompensationErr, CompensationHeaderCZC."No.");
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Incoming Document", 'OnBeforeGetRelatedDocType', '', false, false)]
    local procedure GetCompensationLetterOnBeforeGetRelatedDocType(PostingDate: Date; DocNo: Code[20]; var IsPosted: Boolean; var IncomingRelatedDocumentType: Enum "Incoming Related Document Type"; var IsHandled: Boolean)
    var
        PostedCompensationHeaderCZC: Record "Posted Compensation Header CZC";
    begin
        if IsHandled then
            exit;

        case true of
            PostedCompensationHeaderCZC.Get(DocNo):
                if PostedCompensationHeaderCZC."Posting Date" = PostingDate then begin
                    IncomingRelatedDocumentType := "Incoming Related Document Type"::"Compensation CZC";
                    IsHandled := true;
                    IsPosted := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Incoming Document", 'OnAfterClearRelatedRecords', '', false, false)]
    local procedure ClearCompensationOnAfterClearRelatedRecords(IncomingRelatedDocumentType: Enum "Incoming Related Document Type"; EntryNo: Integer)
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
    begin
        case IncomingRelatedDocumentType of
            IncomingRelatedDocumentType::"Compensation CZC":
                begin
                    CompensationHeaderCZC.SetRange("Incoming Document Entry No.", EntryNo);
                    CompensationHeaderCZC.ModifyAll("Incoming Document Entry No.", 0, true);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Incoming Document", 'OnAfterUpdateDocumentFields', '', false, false)]
    local procedure UpdateCompensationOnAfterUpdateDocumentFields(var IncomingDocument: Record "Incoming Document"; var DocExists: Boolean);
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
    begin
        CompensationHeaderCZC.SetRange("Incoming Document Entry No.", IncomingDocument."Entry No.");
        if CompensationHeaderCZC.FindFirst() then begin
            IncomingDocument."Document Type" := IncomingDocument."Document Type"::"Compensation CZC";
            IncomingDocument."Document No." := CompensationHeaderCZC."No.";
            DocExists := true;
            exit;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Incoming Document", 'OnAfterFindPostedRecord', '', false, false)]
    local procedure FindCompensationOnAfterFindPostedRecord(var RelatedRecord: Variant; var RecordFound: Boolean; var IncomingDocument: Record "Incoming Document")
    var
        PostedCompensationHeaderCZC: Record "Posted Compensation Header CZC";
    begin
        case IncomingDocument."Document Type" of
            IncomingDocument."Document Type"::"Compensation CZC":
                if PostedCompensationHeaderCZC.Get(IncomingDocument."Document No.") then begin
                    RelatedRecord := PostedCompensationHeaderCZC;
                    RecordFound := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Incoming Document", 'OnAfterFindUnPostedRecord', '', false, false)]
    local procedure FindCompensationOnAfterFindUnPostedRecord(var RelatedRecord: Variant; var RecordFound: Boolean; var IncomingDocument: Record "Incoming Document")
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
    begin
        case IncomingDocument."Document Type" of
            IncomingDocument."Document Type"::"Compensation CZC":
                if CompensationHeaderCZC.Get(IncomingDocument."Document No.") then begin
                    RelatedRecord := CompensationHeaderCZC;
                    RecordFound := true;
                end;
        end;
    end;
}
