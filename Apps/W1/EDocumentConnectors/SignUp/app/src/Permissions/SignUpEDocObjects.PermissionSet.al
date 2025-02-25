// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using Microsoft.eServices.EDocument;

permissionset 6440 "SignUp E-Doc Objects"
{
    Access = Internal;
    Assignable = false;
    Caption = 'SignUp E-Doc. Connector - Obj.', MaxLength = 30;

    Permissions = table "SignUp Connection Setup" = X,
                  table "SignUp Metadata Profile" = X,
                  table "E-Document Integration Log" = X,
                  page "SignUp Connection Setup Card" = X,
                  page "SignUp Metadata Profiles" = X,
                  codeunit "SignUp API Requests" = X,
                  codeunit "SignUp Authentication" = X,
                  codeunit "SignUp Connection" = X,
                  codeunit "SignUp Helpers" = X,
                  codeunit "SignUp Integration Impl." = X,
                  codeunit "SignUp Processing" = X;
}