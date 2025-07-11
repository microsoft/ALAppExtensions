// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

/// <summary>
/// Types of senders available for the SMTP Connector.
/// </summary>
enum 4512 "SMTP Connector Sender Type"
{
    Access = Internal;
    Extensible = false;

    value(0; "Specific User") { Caption = 'Specific User'; }
    value(10; "Current User") { Caption = 'Current User'; }
}