// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This enum has the Run Type of the BCPT Header.
/// </summary>
enum 149003 "BCPT Run Type"
{
    Extensible = false;

    /// <summary>
    /// Specifies that the BCPT Header Run Type is BCPT.
    /// </summary>
    value(0; BCPT)
    {
    }
    /// <summary>
    /// Specifies that the BCPT Header Run Type is PRT.
    /// </summary>
    value(10; PRT)
    {
    }
}