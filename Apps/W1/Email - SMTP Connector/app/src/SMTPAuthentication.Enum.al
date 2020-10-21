// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The SMTP authentication types
/// </summary>
enum 4511 "SMTP Authentication"
{
    Extensible = false;

    value(1; Anonymous)
    {
    }

    value(3; Basic)
    {
    }
}