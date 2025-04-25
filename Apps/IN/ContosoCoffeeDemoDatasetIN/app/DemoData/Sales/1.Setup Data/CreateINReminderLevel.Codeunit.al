// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Sales;

using Microsoft.Sales.Reminder;

codeunit 19032 "Create IN Reminder Level"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Reminder Level", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertReminderLevel(var Rec: Record "Reminder Level")
    var
        CreateReminderTerms: Codeunit "Create Reminder Terms";
    begin
        case Rec."Reminder Terms Code" of
            CreateReminderTerms.Domestic():
                begin
                    if Rec."No." = 1 then
                        ValidateRecordFields(Rec, 350);
                    if Rec."No." = 2 then
                        ValidateRecordFields(Rec, 700);
                    if Rec."No." = 3 then
                        ValidateRecordFields(Rec, 1040);
                end;
        end;
    end;

    procedure ValidateRecordFields(var ReminderLevel: Record "Reminder Level"; AdditionalFee: Decimal)
    begin
        ReminderLevel.Validate("Additional Fee (LCY)", AdditionalFee);
    end;
}
