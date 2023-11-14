// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Transfer;

using System.Security.User;

codeunit 31309 "Rel. Transfer Doc. Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Transfer Document", 'OnRunOnBeforeSetStatusReleased', '', false, false)]
    local procedure UserChecksAllowedOnRunOnBeforeSetStatusReleased(var TransferHeader: Record "Transfer Header")
    var
        TransferLine: Record "Transfer Line";
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
    begin
        if UserSetupAdvManagementCZL.IsCheckAllowed() then begin
            TransferLine.SetRange("Document No.", TransferHeader."No.");
            TransferLine.SetFilter(Quantity, '<>0');
            if TransferLine.FindSet() then
                repeat
                    case true of
                        TransferLine.Quantity > 0:
                            begin
                                UserSetupAdvManagementCZL.SetItem(TransferLine."Item No.");
                                if not UserSetupAdvManagementCZL.CheckReleasLocQuantityDecrease(TransferLine."Transfer-from Code") then
                                    TransferLine.FieldError("Transfer-from Code");
                                if not UserSetupAdvManagementCZL.CheckReleasLocQuantityIncrease(TransferLine."Transfer-to Code") then
                                    TransferLine.FieldError("Transfer-to Code");
                            end;
                        TransferLine.Quantity < 0:
                            begin
                                UserSetupAdvManagementCZL.SetItem(TransferLine."Item No.");
                                if not UserSetupAdvManagementCZL.CheckReleasLocQuantityIncrease(TransferLine."Transfer-from Code") then
                                    TransferLine.FieldError("Transfer-from Code");
                                if not UserSetupAdvManagementCZL.CheckReleasLocQuantityDecrease(TransferLine."Transfer-to Code") then
                                    TransferLine.FieldError("Transfer-to Code");
                            end;
                    end;
                until TransferLine.Next() = 0;
        end;
    end;
}
