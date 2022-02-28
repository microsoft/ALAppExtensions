// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Contains the possible data types that business chart can show.
/// </summary>
enum 479 "Business Chart Data Type"
{
    Extensible = false;

    /// <summary>
    /// String type, corresponds to 'System.String'
    /// </summary>
    value(0; "String")
    {
        Caption = 'String';
    }

    /// <summary>
    /// Integer type, corresponds to 'System.Int32'
    /// </summary>
    value(2; "Integer")
    {
        Caption = 'Integer';
    }

    /// <summary>
    /// Decimal type, corresponds to 'System.Decimal'
    /// </summary>
    value(3; "Decimal")
    {
        Caption = 'Decimal';
    }

    /// <summary>
    /// DateTime type, corresponds to 'System.DateTime'
    /// </summary>
    value(5; "DateTime")
    {
        Caption = 'DateTime';
    }
}