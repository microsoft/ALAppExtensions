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

            trigger OnValidate()
            begin
                CheckPeriod();
            end;
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
        FileManagement: Codeunit "File Management";
        EmptyFileNameErr: Label 'Please choose a file to attach.';
        NoContentErr: Label 'The selected file ''%1'' has no content. Please choose another file.', Comment = '%1=FileName';
        NoDocumentAttachedErr: Label 'Please attach a document first.';
        ReplaceQst: Label 'Do you want to replace the existing attachment?';
        SizeErr: Label 'The file size must not exceed 4 Mb.';
        PeriodErr: Label 'The date must be within the period.';

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
        ConfirmManagement: Codeunit "Confirm Management";
        FileInStream: InStream;
        FullFileName: Text;
    begin
        FullFileName := FileManagement.BLOBImport(TempBlob, Rec.TableCaption());
        if FullFileName = '' then
            exit(false);

        if HasAttachmentContent() then
            if not ConfirmManagement.GetResponseOrDefault(ReplaceQst, false) then
                exit(false);

        TempBlob.CreateInStream(FileInStream);
        SaveFile(FileInStream, FullFileName, false);
        exit(true);
    end;

    procedure Import(Files: List of [FileUpload]; VATStatementName: Record "VAT Statement Name")
    begin
        // Default to MS-DOS encoding to keep consistent with existing behavior
        Import(Files, VATStatementName, TextEncoding::MSDos);
    end;

    procedure Import(Files: List of [FileUpload]; VATStatementName: Record "VAT Statement Name"; EncodingType: TextEncoding)
    var
        VATStatementAttachmentCZL: Record "VAT Statement Attachment CZL";
        CurrentFile: FileUpload;
        FileInStream: InStream;
    begin
        foreach CurrentFile in Files do begin
            CurrentFile.CreateInStream(FileInStream, EncodingType);
            VATStatementAttachmentCZL.InitFields(VATStatementName, GetDefaultDate());
            VATStatementAttachmentCZL.Import(FileInStream, CurrentFile.FileName);
            VATStatementAttachmentCZL.Insert();
        end;
    end;

    procedure Import(FileInStream: InStream; FileName: Text)
    begin
        Import(FileInStream, FileName, true);
    end;

    local procedure Import(FileInStream: InStream; FileName: Text; AllowDuplicateFileName: Boolean)
    begin
        if FileName = '' then
            Error(EmptyFileNameErr);

        SaveFile(FileInStream, FileName, AllowDuplicateFileName);
    end;

    procedure Export(ShowFileDialog: Boolean) Result: Text
    var
        TempBlob: Codeunit "Temp Blob";
        FileOutStream: OutStream;
    begin
        // Ensure document has value in DB
        if not HasAttachmentContent() then
            exit;

        TempBlob.CreateOutStream(FileOutStream);
        LoadAttachment(FileOutStream);
        exit(FileManagement.BLOBExport(TempBlob, "File Name", ShowFileDialog));
    end;

    local procedure SaveFile(FileInStream: InStream; FileName: Text; AllowDuplicateFileName: Boolean)
    var
        IncomingFileName: Text;
    begin
        if AllowDuplicateFileName then
            IncomingFileName := FindUniqueFileName(FileManagement.GetFileNameWithoutExtension(FileName), FileManagement.GetExtension(FileName))
        else
            IncomingFileName := FileName;

        "File Name" := CopyStr(FileManagement.GetFileName(IncomingFileName), 1, MaxStrLen("File Name"));
        CheckFileNameDuplicates();
        CheckSizeRestriction(FileInStream.Length);

        if FileInStream.Length = 0 then
            Error(NoContentErr, FileName);

        SaveAttachment(FileInStream);

        if not HasAttachmentContent() then
            Error(NoDocumentAttachedErr);
    end;

    local procedure SaveAttachment(FileInStream: InStream)
    var
        AttachmentOutStream: OutStream;
    begin
        Rec.Attachment.CreateOutStream(AttachmentOutStream);
        CopyStream(AttachmentOutStream, FileInStream);
    end;

    local procedure LoadAttachment(var FileOutStream: OutStream)
    var
        AttachmentInStream: InStream;
    begin
        Rec.CalcFields(Attachment);
        Rec.Attachment.CreateInStream(AttachmentInStream);
        CopyStream(FileOutStream, AttachmentInStream);
    end;

    internal procedure HasAttachmentContent(): Boolean
    begin
        exit(Attachment.HasValue());
    end;

    local procedure FindUniqueFileName(FileName: Text; FileExtension: Text): Text[250]
    var
        FileIndex: Integer;
        SourceFileName: Text[250];
    begin
        SourceFileName := CopyStr(FileName, 1, MaxStrLen(SourceFileName));
        while IsDuplicateFile(GetFullFileName(FileName, FileExtension)) do begin
            FileIndex += 1;
            FileName := GetNextFileName(SourceFileName, FileIndex);
        end;
        exit(GetFullFileName(FileName, FileExtension));
    end;

    local procedure GetFullFileName(FileName: Text; FileExtension: Text) FullFileName: Text[250]
    begin
        exit(CopyStr(StrSubstNo('%1.%2', FileName, FileExtension), 1, MaxStrLen(FullFileName)));
    end;

    local procedure GetNextFileName(FileName: Text[250]; FileIndex: Integer): Text[250]
    begin
        exit(StrSubstNo('%1 (%2)', FileName, FileIndex));
    end;

    procedure GetDefaultDate() DefaultDate: Date
    begin
        DefaultDate := WorkDate();
        FilterGroup(2);
        if GetFilter(Date) <> '' then
            DefaultDate := GetRangeMax(Date);
        FilterGroup(0);
    end;

    internal procedure InitFields(VATStatementName: Record "VAT Statement Name"; DefaultDate: Date)
    begin
        Init();
        "VAT Statement Template Name" := VATStatementName."Statement Template Name";
        "VAT Statement Name" := VATStatementName.Name;
        "Line No." := GetNextLineNo();
        Date := DefaultDate;
    end;

    local procedure GetNextLineNo(): Integer
    var
        VATStatementAttachmentCZL: Record "VAT Statement Attachment CZL";
    begin
        VATStatementAttachmentCZL.SetRange("VAT Statement Template Name", "VAT Statement Template Name");
        VATStatementAttachmentCZL.SetRange("VAT Statement Name", "VAT Statement Name");
        if VATStatementAttachmentCZL.FindLast() then
            exit(VATStatementAttachmentCZL."Line No." + 10000);
        exit(10000);
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
    begin
        if IsDuplicateFile("File Name") then
            FieldError("File Name");
    end;

    local procedure CheckPeriod()
    var
        IsOutsidePeriod: Boolean;
    begin
        IsOutsidePeriod := false;
        FilterGroup(2);
        if GetFilter(Date) <> '' then
            IsOutsidePeriod := (Date < GetRangeMin(Date)) or (Date > GetRangeMax(Date));
        FilterGroup(0);
        if IsOutsidePeriod then
            Error(PeriodErr);
    end;

    local procedure IsDuplicateFile(FileName: Text[250]): Boolean
    var
        VATStatementAttachmentCZL: Record "VAT Statement Attachment CZL";
    begin
        VATStatementAttachmentCZL.SetRange("VAT Statement Template Name", "VAT Statement Template Name");
        VATStatementAttachmentCZL.SetRange("VAT Statement Name", "VAT Statement Name");
        VATStatementAttachmentCZL.SetFilter("Line No.", '<>%1', "Line No.");
        VATStatementAttachmentCZL.SetRange("File Name", FileName);
        exit(not VATStatementAttachmentCZL.IsEmpty);
    end;
}
