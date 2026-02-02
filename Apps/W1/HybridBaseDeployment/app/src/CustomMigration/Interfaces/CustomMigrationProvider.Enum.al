// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration;

/// <summary>
/// Available custom cloud migration providers
/// </summary>
enum 4010 "Custom Migration Provider" implements "Custom Migration Provider", "Custom Migration Table Mapping"
{
    Extensible = true;
    DefaultImplementation = "Custom Migration Provider" = "Custom Migration Provider", "Custom Migration Table Mapping" = "Custom Migration Provider";

    value(4010; "Custom Migration Provider")
    {
        Caption = 'Custom Migration Provider';
    }
}