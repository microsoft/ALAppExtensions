// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

/// <summary>
/// Enum that holds all of the available email connectors.
/// </summary>
enum 8889 "Email Connector" implements "Email Connector", "Default Email Rate Limit"
{
    Extensible = true;
    DefaultImplementation = "Default Email Rate Limit" = "Default Email Rate Limit";
}