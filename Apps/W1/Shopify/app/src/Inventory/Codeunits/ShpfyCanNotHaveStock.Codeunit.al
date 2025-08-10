// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

codeunit 30275 "Shpfy Can Not Have Stock" implements "Shpfy IStock Available"
{
    procedure CanHaveStock(): Boolean
    begin
        exit(false);
    end;
}