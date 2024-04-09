// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

enum 11723 "Intrastat Detail Source CZL"
{
    Extensible = true;
#if not CLEAN22
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
    ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions. This enum is not used any more.';
#else
    Access = Internal;
#endif
    value(0; "Posted Entries")
    {
        Caption = 'Posted Entries';
    }
    value(1; "Item Card")
    {
        Caption = 'Item Card';
    }
}
