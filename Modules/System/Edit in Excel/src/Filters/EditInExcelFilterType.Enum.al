// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This enum specifies the type of filter comparison to perform with the given value. Ex. Field &lt; 1000 is "Less Than".
/// </summary>
enum 1481 "Edit in Excel Filter Type"
{
    Extensible = false;

    value(2; "Less Than")
    {
    }
    value(3; "Less or Equal")
    {
    }
    value(4; Equal)
    {
    }
    value(5; "Greater or Equal")
    {
    }
    value(6; "Greater Than")
    {
    }
    value(7; "Not Equal")
    {
    }
}