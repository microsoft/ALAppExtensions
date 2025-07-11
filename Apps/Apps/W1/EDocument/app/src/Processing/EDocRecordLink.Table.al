// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Processing;

/// <summary>
/// This table is used to link records together.
/// Used by purchase draft historical mapping algorithm:
/// - EDocPurchaseHistMappping.Codeunit.al
/// 
/// To link a draft purchase line to a purchase line. 
/// </summary>
table 6141 "E-Doc. Record Link"
{

    DataClassification = CustomerContent;
    Caption = 'E-Doc. Purchase Line Matches';
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
        field(2; "E-Document Entry No."; Integer)
        {
            Caption = 'E-Document Entry No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(3; "Source Table No."; Integer)
        {
            Caption = 'Source Table No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(4; "Source SystemId"; Guid)
        {
            Caption = 'Source SystemId';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(5; "Target Table No."; Integer)
        {
            Caption = 'Target Table No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(6; "Target SystemId"; Guid)
        {
            Caption = 'Target SystemId';
            DataClassification = SystemMetadata;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(K1; "Target Table No.", "Target SystemId")
        {
        }
        key(K2; "E-Document Entry No.")
        {
        }

    }



}