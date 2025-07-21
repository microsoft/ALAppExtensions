// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Processing.Import.Purchase;
using Microsoft.Purchases.History;

/// <summary>
/// This table stores historical vendor information from received e-documents and the posted document they ended up in. When new e-documents are received, the information in this table can be leveraged to for example assign the same vendor to the e-document.
/// </summary>
table 6108 "E-Doc. Vendor Assign. History"
{
    Caption = 'E-Document Vendor Assignment History';
    DataClassification = CustomerContent;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
    Access = Internal;
    ReplicateData = false;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            Editable = false;
            AutoIncrement = true;
        }
        field(2; "Vendor Company Name"; Text[250])
        {
            Caption = 'Vendor Company Name';
            DataClassification = CustomerContent;
        }
        field(3; "Vendor Address"; Text[250])
        {
            Caption = 'Vendor Address';
            DataClassification = CustomerContent;
        }
        field(4; "Vendor VAT Id"; Text[100])
        {
            Caption = 'Vendor VAT Id';
            DataClassification = CustomerContent;
        }
        field(5; "Vendor GLN"; Text[13])
        {
            Caption = 'Vendor GLN';
            DataClassification = CustomerContent;
        }
        field(20; "Purch. Inv. Header SystemId"; Guid)
        {
            Caption = 'Purchase Inv. Header SystemId';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "Purch. Inv. Header".SystemId;
        }
    }
    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }
}