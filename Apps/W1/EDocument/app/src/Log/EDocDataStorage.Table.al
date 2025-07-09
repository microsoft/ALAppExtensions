// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Utilities;

/// <summary>
/// E-Document Data Storage Table
/// This table stores binary data that is associated with a E-Document Log Entry.
/// </summary>
table 6125 "E-Doc. Data Storage"
{
    DataClassification = CustomerContent;
    ReplicateData = false;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Data Storage"; Blob)
        {
            Caption = 'Data Storage';
            ToolTip = 'Specifies the binary data.';
        }
        field(3; "Data Storage Size"; Integer)
        {
            Caption = 'Data Storage Size';
            ToolTip = 'Specifies the size of the binary data.';
        }
#if not CLEANSCHEMA26
        field(4; "Data Type"; Integer)
        {
            Caption = 'File Format';
            ToolTip = 'Specifies the file format of the binary data.';
            ObsoleteReason = 'Use the File Format field instead.';
            ObsoleteState = Removed;
            ObsoleteTag = '26.0';
        }
#endif
        field(5; "Name"; Text[256])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the name of the binary data.';
        }
#if not CLEANSCHEMA26
        field(6; "Is Structured"; Boolean)
        {
            Caption = 'Is Structured';
            ToolTip = 'Specifies whether the binary data is structured and can be read.';
            ObsoleteReason = 'Unused, specified by the interface implemented by File Format.';
            ObsoleteState = Removed;
            ObsoleteTag = '26.0';
        }
#endif
        field(7; "File Format"; Enum "E-Doc. File Format")
        {
            Caption = 'File Format';
            ToolTip = 'Specifies the file format of the binary data.';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    internal procedure GetTempBlob() TempBlob: Codeunit "Temp Blob"
    begin
        TempBlob.FromRecord(Rec, Rec.FieldNo("Data Storage"));
    end;

}
