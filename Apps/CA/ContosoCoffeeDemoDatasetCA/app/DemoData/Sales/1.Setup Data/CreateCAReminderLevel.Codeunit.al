// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Sales;

using Microsoft.Sales.Reminder;

codeunit 27064 "Create CA Reminder Level"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Reminder Level", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Reminder Level")
    var
        CreateReminderTerms: Codeunit "Create Reminder Terms";
        CreateReminderLevel: Codeunit "Create Reminder Level";
    begin
        if Rec."Reminder Terms Code" = CreateReminderTerms.Domestic() then
            case Rec."No." of
                CreateReminderLevel.DomesticLevel1():
                    ValidateRecordFields(Rec, 11.6);
                CreateReminderLevel.DomesticLevel2():
                    ValidateRecordFields(Rec, 23.3);
                CreateReminderLevel.DomesticLevel3():
                    ValidateRecordFields(Rec, 34.6);
            end;
    end;

    local procedure ValidateRecordFields(var ReminderLevel: Record "Reminder Level"; AdditionalFeeLCY: Decimal)
    begin
        ReminderLevel.Validate("Additional Fee (LCY)", AdditionalFeeLCY);
    end;
}
