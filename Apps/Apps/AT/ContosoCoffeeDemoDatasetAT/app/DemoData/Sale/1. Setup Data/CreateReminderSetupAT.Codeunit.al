// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Sales;

using Microsoft.Sales.Reminder;

codeunit 11179 "CreateReminder Setup AT"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertReminderSetup(ReminderCode(), ActionGroupCode(), DescriptionLbl);
    end;

    local procedure InsertReminderSetup(Code: Code[50]; ActionGroup: Code[50]; Description: Text[50])
    var
        CreateReminderSetup: Record "Create Reminders Setup";
    begin
        CreateReminderSetup.init();
        CreateReminderSetup.Validate(Code, Code);
        CreateReminderSetup.Validate("Action Group Code", ActionGroup);
        CreateReminderSetup.Validate(Description, Description);
        CreateReminderSetup.Insert(true);
    end;

    procedure ReminderCode(): Code[50]
    begin
        exit(ReminderCodeTok);
    end;

    procedure ActionGroupCode(): Code[50]
    begin
        exit(ActionGroupCodeTok);
    end;

    var
        ReminderCodeTok: Label 'Defualt', MaxLength = 50;
        ActionGroupCodeTok: Label 'CREATE REMINDERS', MaxLength = 50;
        DescriptionLbl: Label 'Default setup', MaxLength = 50;
}
