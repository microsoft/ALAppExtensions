// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using System.Environment;

table 10677 "SAF-T Mapping Source"
{
    DataClassification = CustomerContent;
    Caption = 'SAF-T Mapping Source';

    fields
    {
        field(1; ID; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'ID';
            AutoIncrement = true;
        }
        field(2; "Source Type"; Enum "SAF-T Mapping Source Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Source Type';
        }
        field(3; "Source No."; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Source No.';
            Editable = false;
        }
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }

    var
        SourceExistsErr: Label 'There is a mapping source with this file name already loaded.';

    procedure ImportMappingSource()
    var
        TenantMedia: Record "Tenant Media";
        SAFTMappingSource: Record "SAF-T Mapping Source";
        SAFTXMLImport: Codeunit "SAF-T XML Import";
    begin
        testfield("Source Type");
        SAFTXMLImport.ImportXmlFileIntoTenantMedia(TenantMedia);
        if IsNullGuid(TenantMedia.ID) then
            exit;

        "Source No." := CopyStr(TenantMedia."File Name", 1, MaxStrLen("Source No."));
        SAFTMappingSource.SetFilter(Id, '<>%1', ID);
        SAFTMappingSource.SetRange("Source No.", "Source No.");
        if not SAFTMappingSource.IsEmpty() then
            error(SourceExistsErr);
    end;

}
