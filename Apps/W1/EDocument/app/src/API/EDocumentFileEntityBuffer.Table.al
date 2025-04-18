// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.API;

using Microsoft.eServices.EDocument;

table 6108 "E-Document File Entity Buffer"
{
    Caption = 'E-Document File Entity Buffer';
    TableType = Temporary;
    DataClassification = CustomerContent;

    fields
    {
        field(1; Id; Guid)
        {
            Caption = 'Id';
            DataClassification = SystemMetadata;
        }
        field(2; "Related E-Doc. Entry No."; Integer)
        {
            Caption = 'Related E-Document Entry No.';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                this.UpdateRelatedEDocumentId();
            end;
        }
        field(3; "Related E-Document Id"; Guid)
        {
            Caption = 'Related E-Document Id';
            DataClassification = SystemMetadata;
        }
        field(4; Content; Blob)
        {
            Caption = 'Content';
            DataClassification = SystemMetadata;
            SubType = Bitmap;
        }
        field(5; "Byte Size"; Integer)
        {
            Caption = 'Byte Size';
            DataClassification = SystemMetadata;
        }
        field(6; "File Name"; Text[250])
        {
            Caption = 'File Name';
            DataClassification = SystemMetadata;
        }
        field(7; "File Type"; Text[250])
        {
            Caption = 'File Type';
            DataClassification = SystemMetadata;
        }
        field(8; "Service Id"; Guid)
        {
            Caption = 'Service Id';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }

    internal procedure UpdateRelatedEDocumentId()
    var
        EDocument: Record "E-Document";
    begin
        if Rec."Related E-Doc. Entry No." = 0 then begin
            Clear(Rec."Related E-Document Id");
            exit;
        end;

        if EDocument.Get(Rec."Related E-Doc. Entry No.") then
            Rec."Related E-Document Id" := EDocument.SystemId;
    end;

}
