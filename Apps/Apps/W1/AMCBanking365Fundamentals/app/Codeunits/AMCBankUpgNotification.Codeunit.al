﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

codeunit 20109 "AMC Bank Upg. Notification"
{
    trigger OnRun()
    begin
        Message(UpgNotificationLbl);
    end;

    var
        UpgNotificationLbl: Label 'We have updated the AMC Banking 365 Fundamentals extension.\\Before you can use the extension you must provide some information. Go to the AMC Banking Setup page and run the Assisted Setup action.';
}
