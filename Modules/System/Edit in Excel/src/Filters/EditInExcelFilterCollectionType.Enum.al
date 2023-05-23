// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This enum specifies whether filters for the given field are connected or disconnected
/// In other words if the filter being added specifies "Field = a&amp;b" (and) or "Field = a|b" (or).
/// </summary>
#pragma warning disable AL0659
enum 1491 "Edit in Excel Filter Collection Type"
#pragma warning restore AL0659
{
    Access = Public;
    Extensible = false;

    value(0; and)
    {
    }
    value(1; or)
    {
    }
}
