// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.IO;
using System.Utilities;

table 11776 "VAT Statement Attachment CZL"
{
    Caption = 'VAT Statement Attachment';
    DrillDownPageId = "VAT Statement Attachments CZL";
    LookupPageId = "VAT Statement Attachments CZL";

    fields
    {
        field(1; "VAT Statement Template Name"; Code[10])
        {
            Caption = 'VAT Statement Template Name';
            NotBlank = true;
            TableRelation = "VAT Statement Template";
            DataClassification = CustomerContent;
        }
        field(2; "VAT Statement Name"; Code[10])
        {
            Caption = 'VAT Statement Name';
            NotBlank = true;
            TableRelation = "VAT Statement Name".Name;
            DataClassification = CustomerContent;
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(4; Date; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }
        field(5; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(6; Attachment; Blob)
        {
            Caption = 'Attachment';
            DataClassification = CustomerContent;
        }
        field(7; "File Name"; Text[250])
        {
            Caption = 'File Name';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; "VAT Statement Template Name", "VAT Statement Name", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        CheckAttachmentsAllowed();
    end;

    var
        ReplaceQst: Label 'Do you want to replace the existing attachment?';
        SizeErr: Label 'The file size must not exceed 4 Mb.';

    procedure CheckAttachmentsAllowed()
    var
        VATStatementTemplate: Record "VAT Statement Template";
    begin
        VATStatementTemplate.Get("VAT Statement Template Name");
        VATStatementTemplate.TestField("Allow Comments/Attachments CZL");
    end;

    procedure Import(): Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        ConfirmManagement: Codeunit "Confirm Management";
        RecordRef: RecordRef;
        FullFileName: Text;
    begin
        FullFileName := FileManagement.BLOBImport(TempBlob, Rec.TableCaption());
        if FullFileName = '' then
            exit(false);

        "File Name" := CopyStr(FileManagement.GetFileName(FullFileName), 1, MaxStrLen("File Name"));
        CheckFileNameDuplicates();
        CheckSizeRestriction(TempBlob.Length());

        if Attachment.HasValue then
            if not ConfirmManagement.GetResponseOrDefault(ReplaceQst, false) then
                exit(false);

        RecordRef.GetTable(Rec);
        TempBlob.ToRecordRef(RecordRef, FieldNo(Attachment));
        RecordRef.SetTable(Rec);
        exit(true);
    end;

    local procedure CheckSizeRestriction(StreamLength: Integer)
    var
        MaxSize: Integer;
    begin
        MaxSize := 4194304;

        if MaxSize < StreamLength then
            Error(SizeErr);
    end;

    local procedure CheckFileNameDuplicates()
    var
        VATStatementAttachmentCZL: Record "VAT Statement Attachment CZL";
    begin
        VATStatementAttachmentCZL.SetRange("VAT Statement Template Name", "VAT Statement Template Name");
        VATStatementAttachmentCZL.SetRange("VAT Statement Name", "VAT Statement Name");
        VATStatementAttachmentCZL.SetFilter("Line No.", '<>%1', "Line No.");
        VATStatementAttachmentCZL.SetRange("File Name", "File Name");
        if not VATStatementAttachmentCZL.IsEmpty then
            FieldError("File Name");
    end;
}
