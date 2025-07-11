// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Transfer;

using Microsoft.Finance.GeneralLedger.Setup;

tableextension 31240 "Transfer Line CZA" extends "Transfer Line"
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
    }

    internal procedure CheckGenBusPostGroupEqualityCZA()
    var
        TransferHeader: Record "Transfer Header";
    begin
        TransferHeader."Gen.Bus.Post.Group Receive CZA" := "Gen.Bus.Post.Group Receive CZA";
        TransferHeader."Gen.Bus.Post.Group Ship CZA" := "Gen.Bus.Post.Group Ship CZA";
        TransferHeader.CheckGenBusPostGroupEqualityCZA();
    end;
}
