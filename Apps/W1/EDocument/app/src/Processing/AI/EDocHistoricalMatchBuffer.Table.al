// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.AI;

using Microsoft.Purchases.Document;
using Microsoft.Finance.Deferral;
using Microsoft.Foundation.UOM;
using Microsoft.Finance.Dimension;
table 6129 "EDoc Historical Match Buffer"
{
    Access = Internal;
    TableType = Temporary;
    DataClassification = SystemMetadata;
    InherentEntitlements = X;
    InherentPermissions = RIMDX;

    fields
    {
        field(1; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(2; "Historical Line SystemId"; Guid)
        {
            Caption = 'Historical Line SystemId';
        }
        field(3; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(10; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
        }
        field(11; "Purchase Type"; Enum "Purchase Line Type")
        {
            Caption = 'Purchase Type';
        }
        field(12; "Purchase Type No."; Code[20])
        {
            Caption = 'Purchase Type No.';
        }
        field(20; "Product Code"; Text[100])
        {
            Caption = 'Product Code';
        }
        field(21; "Description"; Text[100])
        {
            Caption = 'Description';
        }
        field(30; "Match Reason"; Text[250])
        {
            Caption = 'Match Reason';
        }
        field(40; "Confidence Score"; Decimal)
        {
            Caption = 'Confidence Score';
            DecimalPlaces = 0 : 2;
            MinValue = 0;
            MaxValue = 1;
        }
        field(50; "Is E-Document History"; Boolean)
        {
            Caption = 'Is E-Document History';
            InitValue = true;
        }
        field(51; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(52; "Unit of Measure"; Code[10])
        {
            Caption = 'Unit of Measure';
            TableRelation = "Unit of Measure";
        }
        field(53; "Shortcut Dimension 1 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
        }
        field(54; "Shortcut Dimension 2 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
        }
        field(55; "Deferral Code"; Code[10])
        {
            Caption = 'Deferral Code';
            TableRelation = "Deferral Template"."Deferral Code";
        }
    }

    keys
    {
        key(Key1; "Line No.", "Historical Line SystemId")
        {
            Clustered = true;
        }
        key(Key2; "Confidence Score")
        {
        }
    }
}