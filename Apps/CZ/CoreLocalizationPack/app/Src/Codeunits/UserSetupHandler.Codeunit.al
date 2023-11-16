// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Security.User;

using Microsoft.Finance.Dimension;
using Microsoft.Inventory.Ledger;
using System.Utilities;

codeunit 31325 "User Setup Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"User Setup", 'OnAfterDeleteEvent', '', false, false)]
    local procedure UserSetupLineCZLOnAfterDeleteEvent(var Rec: Record "User Setup")
    var
        UserSetupLineCZL: Record "User Setup Line CZL";
    begin
        UserSetupLineCZL.Reset();
        UserSetupLineCZL.SetRange("User ID", Rec."User ID");
        UserSetupLineCZL.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Error Message", 'OnDrillDownSource', '', false, false)]
    local procedure OnErrorMessageDrillDown(ErrorMessage: Record "Error Message"; SourceFieldNo: Integer; var IsHandled: Boolean)
    var
        CheckDimensions: Codeunit "Check Dimensions";
    begin
        if not IsHandled then
            if (ErrorMessage."Table Number" = DATABASE::"User Setup") and
               (ErrorMessage."Field Number" = UserSetup.FieldNo("Check Dimension Values CZL"))
            then
                case SourceFieldNo of
                    ErrorMessage.FieldNo("Context Record ID"):
                        IsHandled := CheckDimensions.ShowContextDimensions(ErrorMessage."Context Record ID");
                    ErrorMessage.FieldNo("Record ID"):
                        begin
                            GetUserSetup();
                            UserSetupAdvManagementCZL.SelectDimensionsToCheck(UserSetup);
                            IsHandled := true;
                        end;
                end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Application Worksheet", 'OnOpenPageEvent', '', false, false)]
    local procedure CheckItemUnapplyOnOpenPage()
    begin
        if UserSetupAdvManagementCZL.IsCheckAllowed() then
            UserSetupAdvManagementCZL.CheckItemUnapply();
    end;

    [TryFunction]
    procedure GetUserSetup()
    begin
        UserSetup.Get(GetUserID());
    end;

    procedure GetUserID() TempUserID: Code[50]
    begin
        TempUserID := CopyStr(UserId, 1, MaxStrLen(TempUserID));
    end;

    var
        UserSetup: Record "User Setup";
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
}
