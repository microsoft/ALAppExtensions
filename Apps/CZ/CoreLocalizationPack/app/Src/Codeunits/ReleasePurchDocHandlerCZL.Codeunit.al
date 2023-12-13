// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

using System.Security.User;

codeunit 31311 "Release Purch.Doc. Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Purchase Document", 'OnCodeOnAfterCheck', '', false, false)]
    local procedure UserChecksAllowedOnCodeOnAfterCheck(var PurchaseLine: Record "Purchase Line")
    var
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
    begin
        if UserSetupAdvManagementCZL.IsCheckAllowed() then
            if PurchaseLine.FindSet() then
                repeat
                    if PurchaseLine.Type = PurchaseLine.Type::Item then begin
                        UserSetupAdvManagementCZL.SetItem(PurchaseLine."No.");
                        case true of
                            PurchaseLine.Quantity < 0:
                                UserSetupAdvManagementCZL.CheckReleasLocQuantityDecrease(PurchaseLine."Location Code");
                            PurchaseLine.Quantity > 0:
                                UserSetupAdvManagementCZL.CheckReleasLocQuantityIncrease(PurchaseLine."Location Code");
                        end;
                    end;
                until PurchaseLine.Next() = 0;
    end;
}
