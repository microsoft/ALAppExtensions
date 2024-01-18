// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Transfer;

using Microsoft.Finance.GeneralLedger.Setup;

tableextension 31242 "Transfer Shipment Line CZA" extends "Transfer Shipment Line"
{
    fields
    {
        field(31238; "Gen.Bus.Post.Group Ship CZA"; Code[20])
        {
            Caption = 'Gen. Bus. Post. Group Ship';
            TableRelation = "Gen. Business Posting Group";
            DataClassification = CustomerContent;
        }
        field(31239; "Gen.Bus.Post.Group Receive CZA"; Code[20])
        {
            Caption = 'Gen. Bus. Post. Group Receive';
            TableRelation = "Gen. Business Posting Group";
            DataClassification = CustomerContent;
        }
        field(31040; "Correction CZA"; Boolean)
        {
            Caption = 'Correction';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(31041; "Transfer Order Line No. CZA"; Integer)
        {
            Caption = 'Transfer Order Line No.';
            DataClassification = CustomerContent;
        }
    }
}
