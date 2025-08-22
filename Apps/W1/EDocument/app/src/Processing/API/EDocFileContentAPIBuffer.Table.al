// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.API;

using Microsoft.eServices.EDocument;

/// <summary>
/// Buffer table to present E-Document File Content in API as URI
/// </summary>
table 6130 "E-Doc. File Content API Buffer"
{

    Caption = 'E-Doc. File Content API Buffer';
    Access = Internal;
    DataClassification = CustomerContent;
    TableType = Temporary;
    ReplicateData = false;

    InherentEntitlements = X;
    InherentPermissions = X;

    fields
    {
        field(1; "E-Doc Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'E-Doc Entry No';
            ToolTip = 'Specifies the unique identifier of the E-Document';
            TableRelation = "E-Document";
        }
        field(2; "E-Document Service Code"; Code[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'Service Code';
            ToolTip = 'Specifies the service code of the E-Document';
            TableRelation = "E-Document Service";
        }
        field(3; "E-Document Service Status"; Enum "E-Document Service Status")
        {
            DataClassification = SystemMetadata;
            Caption = 'E-Document Service Status';
            ToolTip = 'Specifies the status of the E-Document Service';
        }
        field(4; Content; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'File Contents';
            ToolTip = 'Specifies the file contents of the E-Document';
        }
    }

    keys
    {
        key(Key1; "E-Doc Entry No.", "E-Document Service Code", "E-Document Service Status")
        {
            Clustered = true;
        }
    }

}