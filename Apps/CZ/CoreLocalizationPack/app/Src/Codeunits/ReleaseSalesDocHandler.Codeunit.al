// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using System.Security.User;

codeunit 31310 "Release Sales Doc. Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnCodeOnAfterSalesLineCheck', '', false, false)]
    local procedure UserChecksAllowedOnCodeOnAfterSalesLineCheck(var SalesLine: Record "Sales Line")
    var
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
    begin
        if UserSetupAdvManagementCZL.IsCheckAllowed() then
            if SalesLine.Type = SalesLine.Type::Item then begin
                UserSetupAdvManagementCZL.SetItem(SalesLine."No.");
                case true of
                    SalesLine.Quantity > 0:
                        if not UserSetupAdvManagementCZL.CheckReleasLocQuantityDecrease(SalesLine."Location Code") then
                            SalesLine.FieldError("Location Code");
                    SalesLine.Quantity < 0:
                        if not UserSetupAdvManagementCZL.CheckReleasLocQuantityIncrease(SalesLine."Location Code") then
                            SalesLine.FieldError("Location Code");
                end;
            end;
    end;
}
