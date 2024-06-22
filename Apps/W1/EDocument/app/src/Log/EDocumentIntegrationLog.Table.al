// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

table 6127 "E-Document Integration Log"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No';
            DataClassification = SystemMetadata;
        }
        field(2; "E-Doc. Entry No"; Integer)
        {
            Caption = 'E-Doc. Entry No';
            TableRelation = "E-Document";
        }
        field(3; "Service Code"; Code[20])
        {
            Caption = 'Service Code';
            TableRelation = "E-Document Service";
        }
        field(4; "Request Blob"; BLOB)
        {
            Caption = 'Request Blob';
        }
        field(5; "Response Blob"; BLOB)
        {
            Caption = 'Response Blob';
        }
        field(6; "Response Status"; Integer)
        {
            Caption = 'Response Status';
        }
        field(7; URL; Text[250])
        {
            Caption = 'URL';
            ObsoleteReason = 'Replaced with Request URL field';
#if not CLEAN25
            ObsoleteState = Pending;
            ObsoleteTag = '25.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '28.0';
#endif
        }
        field(8; Method; Text[10])
        {
            Caption = 'Method';
        }
        field(9; "Request URL"; Text[2048])
        {
            Caption = 'URL';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    var
        EDcoumentRequestBlobTxt: Label 'E-Document_RequestMessage_%1.txt', Locked = true;
        EDcoumentResponseBlobTxt: Label 'E-Document_ResponseMessage_%1.txt', Locked = true;

    internal procedure ExportRequestMessage()
    var
        InStr: InStream;
        FileName: Text;
    begin
        Rec.CalcFields("Request Blob");
        if not Rec."Request Blob".HasValue() then
            exit;

        Rec."Request Blob".CreateInStream(InStr);
        FileName := StrSubstNo(EDcoumentRequestBlobTxt, "E-Doc. Entry No");
        DownloadFromStream(InStr, '', '', '', FileName);
    end;

    internal procedure ExportResponseMessage()
    var
        InStr: InStream;
        FileName: Text;
    begin
        Rec.CalcFields("Response Blob");
        if not Rec."Response Blob".HasValue() then
            exit;

        Rec."Response Blob".CreateInStream(InStr);
        FileName := StrSubstNo(EDcoumentResponseBlobTxt, "E-Doc. Entry No");
        DownloadFromStream(InStr, '', '', '', FileName);
    end;
}
