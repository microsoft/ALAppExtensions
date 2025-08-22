// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Setup table for External Storage functionality.
/// Contains configuration settings for automatic upload and deletion policies.
/// </summary>
table 8750 "DA External Storage Setup"
{
    Caption = 'External Storage Setup';
    DataClassification = CustomerContent;
    Access = Internal;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(5; "Delete After"; Enum "DA Ext. Storage - Delete After")
        {
            Caption = 'Delete After';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies when files should be automatically deleted.';
        }
        field(6; "Auto Upload"; Boolean)
        {
            Caption = 'Auto Upload';
            DataClassification = CustomerContent;
            InitValue = true;
            ToolTip = 'Specifies if new attachments should be automatically uploaded to external storage.';
        }
        field(7; "Auto Delete"; Boolean)
        {
            Caption = 'Auto Delete';
            DataClassification = CustomerContent;
            InitValue = false;
            ToolTip = 'Specifies if files should be automatically deleted from external storage.';
        }
        field(25; "Has Uploaded Files"; Boolean)
        {
            Caption = 'Has Uploaded Files';
            FieldClass = FlowField;
            CalcFormula = exist("Document Attachment" where("Uploaded Externally" = const(true)));
            Editable = false;
            ToolTip = 'Indicates if files have been uploaded using this configuration.';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
