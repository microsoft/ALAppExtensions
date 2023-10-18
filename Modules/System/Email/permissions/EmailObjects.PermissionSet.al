// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

permissionset 8906 "Email - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Email Account" = X,
                  Codeunit "Email Address Lookup" = X,
                  Codeunit "Email Dispatcher" = X,
                  Codeunit "Email Message" = X,
                  Codeunit "Email Scenario" = X,
                  Codeunit "Email Test Mail" = X,
                  Codeunit "Email" = X,
                  Page "Email Account Wizard" = X,
                  Page "Email Accounts" = X,
                  Page "Email Activities" = X,
                  Page "Email Address Lookup" = X,
                  Page "Email Attachments" = X,
                  Page "Email Scenario Attach Setup" = X,
                  Page "Email Choose Scenario Attach" = X,
                  Page "Email Editor" = X,
                  Page "Email Outbox" = X,
                  Page "Email Related Attachments" = X,
                  Page "Email Relation Picker" = X,
                  Page "Email Scenario Setup" = X,
                  Page "Email Scenarios FactBox" = X,
                  Page "Email Scenarios for Account" = X,
                  Page "Email User-Specified Address" = X,
                  Page "Email Viewer" = X,
                  Page "Email View Policy List" = X,
                  Page "Email Rate Limit Wizard" = X,
                  Page "Sent Emails" = X,
                  Page "Sent Emails List Part" = X,
                  Table "Email Attachments" = X,
                  Table "Email Scenario Attachments" = X,
                  Table "Email Account" = X,
                  Table "Email Connector" = X,
                  Table "Email Related Attachment" = X,
                  Table "Email Outbox" = X,
                  Table "Email Scenario" = X,
                  Table "Sent Email" = X,
                  Query "Email Related Record" = X,
                  Query "Sent Emails" = X,
                  Query "Outbox Emails" = X;
}
