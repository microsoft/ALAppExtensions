// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Transfer;

using Microsoft.Inventory.Setup;

codeunit 31227 "Transfer Header Handler CZA"
{
    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'OnAfterGetTransferRoute', '', false, false)]
    local procedure SetGenBusPostingGroupsOnAfterGetTransferRoute(var TransferHeader: Record "Transfer Header"; TransferRoute: Record "Transfer Route")
    begin
        TransferRoute.GetTransferGenPostGroupsCZA(
          TransferHeader."Transfer-from Code", TransferHeader."Transfer-to Code",
          TransferHeader."Gen.Bus.Post.Group Ship CZA", TransferHeader."Gen.Bus.Post.Group Receive CZA");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'OnUpdateTransLines', '', false, false)]
    local procedure SetGenBusPostingGroupsOnUpdateTransLines(var TransferLine: Record "Transfer Line"; TransferHeader: Record "Transfer Header"; FieldID: Integer)
    begin
        case FieldID of
            TransferHeader.FieldNo("Transfer-from Code"),
            TransferHeader.FieldNo("Transfer-to Code"):
                begin
                    TransferLine.Validate("Gen.Bus.Post.Group Ship CZA", TransferHeader."Gen.Bus.Post.Group Ship CZA");
                    TransferLine.Validate("Gen.Bus.Post.Group Receive CZA", TransferHeader."Gen.Bus.Post.Group Receive CZA");
                end;
            TransferHeader.FieldNo("Gen.Bus.Post.Group Ship CZA"):
                TransferLine.Validate("Gen.Bus.Post.Group Ship CZA", TransferHeader."Gen.Bus.Post.Group Ship CZA");
            TransferHeader.FieldNo("Gen.Bus.Post.Group Receive CZA"):
                TransferLine.Validate("Gen.Bus.Post.Group Receive CZA", TransferHeader."Gen.Bus.Post.Group Receive CZA");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'OnValidateDirectTransferOnBeforeValidateInTransitCode', '', false, false)]
    local procedure OnValidateDirectTransferOnBeforeValidateInTransitCode(var TransferHeader: Record "Transfer Header")
    var
        InventorySetup: Record "Inventory Setup";
    begin
        InventorySetup.Get();
        if InventorySetup."Def.G.Bus.P.Gr.-Dir.Trans. CZA" = '' then
            exit;
        TransferHeader.Validate("Gen.Bus.Post.Group Ship CZA", InventorySetup."Def.G.Bus.P.Gr.-Dir.Trans. CZA");
        TransferHeader.Validate("Gen.Bus.Post.Group Receive CZA", InventorySetup."Def.G.Bus.P.Gr.-Dir.Trans. CZA");
    end;
}
