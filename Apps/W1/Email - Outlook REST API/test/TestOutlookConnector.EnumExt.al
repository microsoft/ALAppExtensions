// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

enumextension 139760 "Test Outlook Connector" extends "Email Connector"
{
    value(139760; "Test Outlook REST API")
    {
        Caption = 'Test Outlook REST API';
        Implementation = "Email Connector" = "Test Outlook Email Connector";
    }
}
