// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using Microsoft.Utilities;

codeunit 30203 "Company Details Checklist Item"
{
    Access = Internal;

    trigger OnRun()
    begin
        Page.Run(Page::"Assisted Company Setup Wizard");
    end;
}