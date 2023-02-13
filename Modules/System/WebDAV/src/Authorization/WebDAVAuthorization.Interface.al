// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

interface "WebDAV Authorization"
{
    procedure Authorize(var HttpRequestMessage: HttpRequestMessage);
}