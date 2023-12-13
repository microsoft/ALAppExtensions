// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Setup;

using Microsoft.Inventory.Journal;

tableextension 11712 "Inventory Setup CZL" extends "Inventory Setup"
{
    fields
    {
        field(31062; "Date Order Invt. Change CZL"; Boolean)
        {
            Caption = 'Date Order Inventory Change';
            DataClassification = CustomerContent;
        }
        field(31063; "Def.Tmpl. for Phys.Pos.Adj CZL"; Code[10])
        {
            Caption = 'Default Template for Physical Inventory Positive Adjustment';
            TableRelation = "Invt. Movement Template CZL" where("Entry Type" = const("Positive Adjmt."));
            DataClassification = CustomerContent;
        }
        field(31064; "Def.Tmpl. for Phys.Neg.Adj CZL"; Code[10])
        {
            Caption = 'Default Template for Physical Inventory Negative Adjustment';
            TableRelation = "Invt. Movement Template CZL" where("Entry Type" = const("Negative Adjmt."));
            DataClassification = CustomerContent;
        }
        field(31065; "Post Neg.Transf. As Corr.CZL"; Boolean)
        {
            Caption = 'Post Neg. Transfers as Corr.';
            DataClassification = CustomerContent;
        }
        field(31066; "Post Exp.Cost Conv.As Corr.CZL"; Boolean)
        {
            Caption = 'Post Exp. Cost Conv. as Corr.';
            DataClassification = CustomerContent;
        }
    }
}
