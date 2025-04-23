// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Processing.Import.Purchase;

using Microsoft.Purchases.Vendor;
using Microsoft.Foundation.UOM;
using Microsoft.Finance.Deferral;
using Microsoft.Finance.Dimension;
using Microsoft.Utilities;
using Microsoft.Purchases.Document;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Inventory.Item;
using Microsoft.Finance.AllocationAccount;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Purchases.History;

/// <summary>
/// This table contains the history of field values that were on draft purchase lines, 
/// and their corresponding values on the posted purchase lines.
/// 
/// The Keys section is for identifier values on the draft purchase line.
/// These are mapped to the corresponding values on the posted purchase line in the Values section.
/// </summary>
table 6140 "E-Doc. Purchase Line History"
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
        field(2; "E-Doc. Purchase Line SystemId"; Guid)
        {
            Caption = 'E-Doc. Purchase Line SystemId';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "E-Document Purchase Line".SystemId;
        }
        field(3; "Purch. Inv. Line SystemId"; Guid)
        {
            Caption = 'Purchase Inv. Line SystemId';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "Purch. Inv. Line".SystemId;
        }
        #region Keys
        field(10; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            ToolTip = 'Specifies the vendor number.';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
        }
        field(11; "Product Code"; Text[100])
        {
            Caption = 'Product Code';
            ToolTip = 'Specifies the product code.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(12; "Description"; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the description.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        #endregion Keys

        #region Values
        field(50; "Purchase Line Type"; Enum "Purchase Line Type")
        {
            Caption = 'Type';
            ToolTip = 'Specifies the type of purchase line.';
        }
        field(51; "Purchase Type No."; Code[20])
        {
            Caption = 'No.';
            ToolTip = 'Specifies the number of the purchase type.';
            TableRelation = if ("Purchase Line Type" = const(" ")) "Standard Text"
            else
            if ("Purchase Line Type" = const("G/L Account")) "G/L Account"
            else
            if ("Purchase Line Type" = const("Fixed Asset")) "Fixed Asset"
            else
            if ("Purchase Line Type" = const("Charge (Item)")) "Item Charge"
            else
            if ("Purchase Line Type" = const(Item)) Item
            else
            if ("Purchase Line Type" = const("Allocation Account")) "Allocation Account"
            else
            if ("Purchase Line Type" = const(Resource)) Resource;
        }
        field(52; "Unit of Measure"; Code[20])
        {
            Caption = 'Unit of Measure';
            ToolTip = 'Specifies the unit of measure code.';
            TableRelation = "Unit of Measure";
        }
        field(53; "Deferral Code"; Code[10])
        {
            Caption = 'Deferral Code';
            ToolTip = 'Specifies the deferral code.';
            TableRelation = "Deferral Template";
        }
        field(54; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1),
                                                          Blocked = const(false));


        }
        field(55; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2),
                                                          Blocked = const(false));


        }

        #endregion
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(K1; "Vendor No.", "Product Code", Description)
        {
        }
        key(K2; "Product Code", Description)
        {
        }
        key(K3; "Vendor No.", "Product Code")
        {
        }
        key(K4; "Vendor No.", Description)
        {
        }
    }



}