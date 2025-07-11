// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

enumextension 4501 "Current User Connector" extends "Email Connector"
{
    /// <summary>
    /// The Current User connector.
    /// </summary>
    value(2; "Current User")
    {
        Caption = 'Current User';
        Implementation = "Email Connector" = "Current User Connector",
                         "Default Email Rate Limit" = "Current User Connector";
    }
}