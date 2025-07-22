// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEANSCHEMA25
namespace Microsoft.Integration.Shopify;

using System.Environment.Configuration;

tableextension 30200 "Shpfy Feature Data Update" extends "Feature Data Update Status"
{
    fields
    {
        field(30200; "Shpfy Templates Migrate"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Migrate Shopify templates';
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Not used anymore.';
        }
    }
}
#endif