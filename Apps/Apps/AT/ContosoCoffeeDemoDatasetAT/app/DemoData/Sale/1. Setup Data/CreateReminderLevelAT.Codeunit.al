// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Sales;

using Microsoft.Sales.Reminder;

codeunit 11174 "Create Reminder Level AT"
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
        if Rec."Reminder Terms Code" = CreateReminderTerms.Domestic() then
            case Rec."No." of
                1:
                    Rec.Validate("Additional Fee (LCY)", 7.8);
                2:
                    Rec.Validate("Additional Fee (LCY)", 15.6);
                3:
                    Rec.Validate("Additional Fee (LCY)", 23.2);
            end;
    end;
}
