// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

permissionset 6380 Objects
{
    Access = Internal;
    Assignable = false;
    Caption = 'SignUp E-Doc. Connector - Obj.', MaxLength = 30;

    Permissions = table ConnectionSetup = X,
                  page ConnectionSetupCard = X,
                  codeunit IntegrationImpl = X,
                  codeunit PatchSentJob = X,
                  codeunit JobHelperImpl = X,
                  codeunit GetReadyStatusJob = X,
                  codeunit APIRequests = X,
                  codeunit APIRequestsImpl = X,
                  codeunit Authentication = X,
                  codeunit AuthenticationImpl = X,
                  codeunit Connection = X,
                  codeunit ConnectionImpl = X,
                  codeunit HelpersImpl = X,
                  codeunit Processing = X,
                  codeunit ProcessingImpl = X;

}