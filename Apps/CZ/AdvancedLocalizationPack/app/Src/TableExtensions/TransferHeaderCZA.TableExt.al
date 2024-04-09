// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Transfer;

using Microsoft.Finance.GeneralLedger.Setup;

tableextension 31239 "Transfer Header CZA" extends "Transfer Header"
{
    fields
    {
        field(31238; "Gen.Bus.Post.Group Ship CZA"; Code[20])
        {
            Caption = 'Gen. Bus. Post. Group Ship';
            TableRelation = "Gen. Business Posting Group";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateTransLines(Rec, FieldNo("Gen.Bus.Post.Group Ship CZA"));
            end;
        }
        field(31239; "Gen.Bus.Post.Group Receive CZA"; Code[20])
        {
            Caption = 'Gen. Bus. Post. Group Receive';
            TableRelation = "Gen. Business Posting Group";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateTransLines(Rec, FieldNo("Gen.Bus.Post.Group Receive CZA"));
            end;
        }
    }

    var
        GenBusPostGroupErr: Label 'The Gen. Business Posting Groups for receive and ship must be the same.';

    internal procedure CheckGenBusPostGroupEqualityCZA()
    begin
        if "Gen.Bus.Post.Group Receive CZA" <> "Gen.Bus.Post.Group Ship CZA" then
            Error(GenBusPostGroupErr);
    end;
}
