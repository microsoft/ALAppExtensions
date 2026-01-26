// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document.Attachment;
table 7278 "Mapping Cache"
{
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
    Access = Internal;

    fields
    {
        field(1; "File Identity Hash"; Text[1024])
        {
            Caption = 'File Identity Hash';
            DataClassification = SystemMetadata;
        }
        field(2; Mapping; Blob)
        {
            Caption = 'Mapping';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "File Identity Hash")
        {
            Clustered = true;
        }
    }
}