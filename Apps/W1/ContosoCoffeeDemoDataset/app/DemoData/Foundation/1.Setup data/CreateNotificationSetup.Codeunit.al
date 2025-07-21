// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.DemoTool.Helpers;
using System.Environment.Configuration;

codeunit 5322 "Create Notification Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoNotification: Codeunit "Contoso Notification";
        DummyUserID: Code[50];
    begin
        DummyUserID := '';

        ContosoNotification.InsertNotification(DummyUserID, Enum::"Notification Entry Type"::"New Record", Enum::"Notification Method Type"::Email);
        ContosoNotification.InsertNotification(DummyUserID, Enum::"Notification Entry Type"::Approval, Enum::"Notification Method Type"::Email);
        ContosoNotification.InsertNotification(DummyUserID, Enum::"Notification Entry Type"::Overdue, Enum::"Notification Method Type"::Email);
    end;


}
