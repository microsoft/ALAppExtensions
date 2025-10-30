// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;


table 13910 "OIOUBL E-Doc. Export Session"
{
    DataClassification = ToBeClassified;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;

    fields
    {
        field(1; "E-Document Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'E-Document Entry No.';
            ToolTip = 'Specifies the entry number of the e-document.';
            TableRelation = "E-Document";
        }
        field(2; "E-Document Service Code"; Code[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'E-Document Service Code';
            ToolTip = 'Specifies the code of the e-document service.';
            TableRelation = "E-Document Service";
        }
    }

    keys
    {
        key(Key1; "E-Document Entry No.", "E-Document Service Code")
        {
            Clustered = true;
        }
    }

}