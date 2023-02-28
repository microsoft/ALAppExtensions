// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 144759 "BCPT Codeunit With 1 Sql"
{
    trigger OnRun()
    var
        ObjectMetadata: Record "Object Metadata";
    begin
        if ObjectMetadata.IsEmpty() then;
    end;
}