// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
interface IHttpResponseMessage
{
    procedure IsBlockedByEnvironment(): Boolean;
    procedure IsSuccessStatusCode(): Boolean;
    procedure HttpStatusCode(): Integer;
    procedure ReasonPhrase(): Text;
    procedure Content(): HttpContent;
    procedure Headers(): HttpHeaders;
}