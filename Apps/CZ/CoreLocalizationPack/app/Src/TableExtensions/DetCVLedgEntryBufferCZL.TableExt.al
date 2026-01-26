#if not CLEANSCHEMA25
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.ReceivablesPayables;

tableextension 11789 "Det. CV Ledg. Entry Buffer CZL" extends "Detailed CV Ledg. Entry Buffer"
{
    fields
    {
        field(11790; "Appl. Across Post. Groups CZL"; Boolean)
        {
            Caption = 'Application Across Posting Groups';
            Editable = false;
            DataClassification = SystemMetadata;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'The "Alter Posting Groups" feature is replaced by standard "Multiple Posting Groups" feature.';
        }
    }
}
#endif