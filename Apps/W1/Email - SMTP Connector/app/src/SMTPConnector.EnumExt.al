// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Enum extension to register the SMTP connector.
/// </summary>
enumextension 4511 "SMTP Connector" extends "Email Connector"
{
    /// <summary>
    /// The SMTP connector.
    /// </summary>
    value(2147483647; SMTP) // Max int value so it appears last
    {
        Caption = 'SMTP';
        Implementation = "Email Connector" = "SMTP Connector Impl.";
    }
}