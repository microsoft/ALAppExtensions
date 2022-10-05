// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132972 "Dummy SharePoint Authorization" implements "SharePoint Authorization"
{
    procedure Authorize(var HttpRequestMessage: HttpRequestMessage);
    begin
        // Does nothing
    end;
}