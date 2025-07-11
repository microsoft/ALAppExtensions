namespace Microsoft.DataMigration;

// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
enum 4009 "Migration Table Type"
{
    value(0; Table)
    {
        Caption = 'Table';
    }
    value(1; "Table Extension")
    {
        Caption = 'Table Extension';
    }
}