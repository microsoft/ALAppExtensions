// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool;

enumextension 10550 "GovTalk Contoso Demo Module" extends "Contoso Demo Data Module"
{
    value(10550; "GovTalk Module")
    {
        Implementation = "Contoso Demo Data Module" = "GovTalk Contoso Module";
        Caption = 'GovTalk';
    }
}