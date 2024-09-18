// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

permissionset 6380 SignUpEDocObjects
{
    Access = Internal;
    Assignable = false;

    Permissions = table SignUpConnectionSetup = X,
                  table SignUpConnectionAuth = X,
                  page SignUpConnectionSetupCard = X,
                  codeunit SignUpIntegrationImpl = X,
                  codeunit SignUpProcessing = X,
                  codeunit SignUpAuth = X,
                  codeunit SignUpAPIRequests = X,
                  codeunit SignUpConnection = X,
                  codeunit SignUpPatchSent = X,
                  codeunit SignUpGetReadyStatus = X;
}