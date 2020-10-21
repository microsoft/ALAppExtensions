// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

enumextension 4504 "Microsoft 365 Connector" extends "Email Connector"
{
    /// <summary>
    /// The Microsoft 365 connector.
    /// </summary>
    value(1; "Microsoft 365")
    {
        Caption = 'Microsoft 365';
        Implementation = "Email Connector" = "Microsoft 365 Connector";
    }
}