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
        }
        field(6; "Auto Upload"; Boolean)
        {
            Caption = 'Auto Upload';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(25; "Has Uploaded Files"; Boolean)
        {
            Caption = 'Has Uploaded Files';
            FieldClass = FlowField;
            CalcFormula = exist("Document Attachment" where("Uploaded Externally" = const(true)));
            Editable = false;
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
