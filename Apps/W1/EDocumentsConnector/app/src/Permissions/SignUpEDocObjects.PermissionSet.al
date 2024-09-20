// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

permissionset 6380 "SignUpEDoc. - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = table ConnectionSetup = X,
                  table ConnectionAuth = X,
                  page ConnectionSetupCard = X,
                  codeunit IntegrationImpl = X,
                  codeunit Processing = X,
                  codeunit Auth = X,
                  codeunit APIRequests = X,
                  codeunit Connection = X,
                  codeunit PatchSent = X,
                  codeunit GetReadyStatus = X;
}