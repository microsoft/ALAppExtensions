// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Transfer;

using Microsoft.Finance.GeneralLedger.Setup;

tableextension 31238 "Transfer Route CZA" extends "Transfer Route"
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

    procedure GetTransferGenPostGroupsCZA(TransferFromCode: Code[10]; TransferToCode: Code[10]; var GenBusPostGroupShip: Code[20]; var GenBusPostGroupReceive: Code[20])
    var
        HasGotRecord: Boolean;
    begin
        if ("Transfer-from Code" <> TransferFromCode) or
           ("Transfer-to Code" <> TransferToCode)
        then begin
            if Get(TransferFromCode, TransferToCode) then
                HasGotRecord := true;
        end else
            HasGotRecord := true;

        if HasGotRecord then begin
            GenBusPostGroupShip := "Gen.Bus.Post.Group Ship CZA";
            GenBusPostGroupReceive := "Gen.Bus.Post.Group Receive CZA";
        end else begin
            Clear(GenBusPostGroupShip);
            Clear(GenBusPostGroupReceive);
        end;
    end;
}
