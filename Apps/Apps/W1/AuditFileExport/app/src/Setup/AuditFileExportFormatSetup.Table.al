// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

table 5268 "Audit File Export Format Setup"
{
    DataClassification = CustomerContent;
    Caption = 'Audit File Export Format Setup';

    fields
    {
        field(1; "Audit File Export Format"; enum "Audit File Export Format")
        {
            DataClassification = CustomerContent;
            Caption = 'Audit File Export Format';
        }
        field(3; "Audit File Name"; Text[1024])
        {
            DataClassification = CustomerContent;
            Caption = 'Audit File Name';
        }
        field(4; "Archive to Zip"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Archive to Zip';
        }
    }

    keys
    {
        key(Key1; "Audit File Export Format")
        {
            Clustered = true;
        }
    }

    procedure InitSetup(AuditFileExportFormat: enum "Audit File Export Format"; AuditFileName: Text[1024]; ArchiveToZip: Boolean)
    begin
        if not Rec.Get(AuditFileExportFormat) then begin
            Rec."Audit File Export Format" := AuditFileExportFormat;
            Rec.Insert();
        end;
        Rec."Audit File Name" := AuditFileName;
        Rec."Archive to Zip" := ArchiveToZip;
        Rec.Modify();
    end;

}
