// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.FixedAssets.FixedAsset;

tableextension 31237 "FA Allocation CZF" extends "FA Allocation"
{
    fields
    {
        field(31250; "Reason/Maintenance Code CZF"; Code[10])
        {
            Caption = 'Reason/Maintenance Code';
            TableRelation = if ("Allocation Type" = const(Maintenance)) "FA Extended Posting Group CZF".Code where("FA Posting Group Code" = field(Code), "FA Posting Type" = const(Maintenance)) else
            if ("Allocation Type" = const("Book Value (Gain)")) "FA Extended Posting Group CZF".Code where("FA Posting Group Code" = field(Code), "FA Posting Type" = const(Disposal)) else
            if ("Allocation Type" = const("Book Value (Loss)")) "FA Extended Posting Group CZF".Code where("FA Posting Group Code" = field(Code), "FA Posting Type" = const(Disposal));
            DataClassification = CustomerContent;
        }
    }
}
