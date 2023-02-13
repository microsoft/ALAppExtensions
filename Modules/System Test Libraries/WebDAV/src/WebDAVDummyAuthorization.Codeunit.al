// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135679 "Dummy WebDAV Authorization" implements "WebDAV Authorization"
{
    procedure Authorize(var HttpRequestMessage: HttpRequestMessage);
    begin
        // Does nothing
    end;
}