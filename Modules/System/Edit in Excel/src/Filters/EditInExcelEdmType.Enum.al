// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This enum specifies the OData Edm type of the fields added to excel.
/// These should generally reflect those in the $metadata document.
/// </summary>
enum 1490 "Edit in Excel Edm Type"
{
    Access = Public;
    Extensible = false;

    value(0; "Edm.String")
    {
    }
    value(1; "Edm.Int32")
    {
    }
    value(2; "Edm.Int64")
    {
    }
    value(3; "Edm.Decimal")
    {
    }
    value(4; "Edm.DateTimeOffset")
    {
    }
    value(5; "Edm.Boolean")
    {
    }
}