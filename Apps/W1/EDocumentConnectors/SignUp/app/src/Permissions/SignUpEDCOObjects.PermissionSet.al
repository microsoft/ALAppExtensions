// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using Microsoft.eServices.EDocument;

permissionset 6380 SignUpEDCOObjects
{
    Access = Internal;
    Assignable = false;
    Caption = 'SignUp E-Doc. Connector - Obj.', MaxLength = 30;

    Permissions = table SignUpConnectionSetup = X,
                  table SignUpMetadataProfile = X,
                  table "E-Document Integration Log" = X,
                  page SignUpConnectionSetupCard = X,
                  page SignUpMetadataProfiles = X,
                  codeunit SignUpAPIRequests = X,
                  codeunit SignUpAuthentication = X,
                  codeunit SignUpConnection = X,
                  codeunit SignUpHelpers = X,
                  codeunit SignUpIntegrationImpl = X,
                  codeunit SignUpProcessing = X;
}