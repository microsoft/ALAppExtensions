// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

enum 4512 "SMTP Connector Sender Type"
{
    Extensible = false;

    value(0; "Specific") { Caption = 'Specific'; }
    value(10; "Current User") { Caption = 'Current User'; }
}