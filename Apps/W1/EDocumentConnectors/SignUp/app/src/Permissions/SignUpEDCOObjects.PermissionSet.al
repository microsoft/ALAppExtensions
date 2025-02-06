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

    Permissions = table ConnectionSetup = X,
                  table MetadataProfile = X,
                  table "E-Document Integration Log" = X,
                  page ConnectionSetupCard = X,
                  page MetadataProfiles = X,
                  codeunit APIRequests = X,
                  codeunit Authentication = X,
                  codeunit Connection = X,
                  codeunit Helpers = X,
                  codeunit IntegrationImpl = X,
                  codeunit Processing = X;
}