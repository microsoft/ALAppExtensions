// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

table 13687 "Imported SAF-T File DK"
{
    DataClassification = CustomerContent;
    Access = Internal;

    fields
    {
        field(1; "File No."; Integer)
        {
            Editable = false;
            AutoIncrement = true;
        }
        field(2; "File Name"; Text[1024])
        {
            Editable = false;
        }
        field(3; "File Content"; Blob)
        {
        }
        field(4; "File Size"; Text[20])
        {
            Editable = false;
        }
        field(5; "Upload Date"; Date)
        {
            Editable = false;
        }
    }

    keys
    {
        key(PK; "File No.")
        {
            Clustered = true;
        }
    }

    var
        UploadFileContentErr: label 'The file cannot be uploaded because it does not have any content.';
        DownloadFileContentErr: label 'The file cannot be downloaded because it does not have any content.';
        SaveFileDialogTxt: label 'Save SAF-T file';
        UploadFileDialogTxt: label 'Upload SAF-T file';
        SAFTFileFilterTxt: Label 'XML File (*.xml)|*.xml|Zip File (*.zip)|*.zip', Locked = true;
        TwoStringsTxt: label '%1%2', Comment = '%1, %2 - two strings to concatenate', Locked = true;

    procedure UploadSAFTFile()
    var
        FileName: Text;
        FileInStream: InStream;
        BlobOutStream: OutStream;
    begin
        if not UploadIntoStream(UploadFileDialogTxt, '', SAFTFileFilterTxt, FileName, FileInStream) then
            exit;
        Rec."File Content".CreateOutStream(BlobOutStream);
        CopyStream(BlobOutStream, FileInStream);
        if not Rec."File Content".HasValue then
            Error(UploadFileContentErr);

        Rec."File No." := 0;
        Rec."File Name" := CopyStr(FileName, 1, MaxStrLen(Rec."File Name"));
        Rec."File Size" := GetAuditFileSizeText();
        Rec."Upload Date" := Today();
        Rec.Insert();
    end;

    procedure DownloadSAFTFile()
    var
        FileInStream: InStream;
    begin
        Rec.CalcFields("File Content");
        if not Rec."File Content".HasValue() then
            Error(DownloadFileContentErr);
        Rec."File Content".CreateInStream(FileInStream);
#pragma warning disable AA0139
        DownloadFromStream(FileInStream, SaveFileDialogTxt, '', '', Rec."File Name");
#pragma warning restore
    end;

    local procedure GetAuditFileSizeText(): Text[20]
    var
        SizeInMbytes: Decimal;
        SizeInGbytes: Decimal;
    begin
        SizeInMbytes := Round(Rec."File Content".Length / (1024 * 1024));
        if SizeInMbytes <= 1024 then
            exit(StrSubstNo(TwoStringsTxt, Format(SizeInMbytes), ' MB'));

        SizeInGbytes := Round(SizeInMbytes / 1024);
        exit(StrSubstNo(TwoStringsTxt, Format(SizeInGbytes), ' GB'));
    end;
}