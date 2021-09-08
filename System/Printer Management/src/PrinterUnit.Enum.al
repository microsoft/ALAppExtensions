// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Specifies several of the units of measure used for printing.
/// </summary>
enum 2618 "Printer Unit"
{
    Extensible = false;

    /// <summary>
    /// The default unit (0.01 in.)
    /// </summary>
    value(0; Display)
    {
        Caption = 'The default unit (0.01 in.)';
    }

    /// <summary>
    /// One-hundredth of a millimeter (0.01 mm).
    /// </summary>
    value(2; HundredthsOfAMillimeter)
    {
        Caption = 'One-hundredth of a millimeter (0.01 mm).';
    }

    /// <summary>
    /// One-tenth of a millimeter (0.1 mm).
    /// </summary>
    value(3; TenthsOfAMillimeter)
    {
        Caption = 'One-tenth of a millimeter (0.1 mm).';
    }

    /// <summary>
    /// One-thousandth of an inch (0.001 in.).
    /// </summary>
    value(1; ThousandthsOfAnInch)
    {
        Caption = 'One-thousandth of an inch (0.001 in.).';
    }
}
