// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Apps;

using System.Apps;

codeunit 133102 "Sample Setup For Test"
{
    trigger OnRun()
    begin
        Page.RunModal(Page::"Extension Settings");
    end;

}