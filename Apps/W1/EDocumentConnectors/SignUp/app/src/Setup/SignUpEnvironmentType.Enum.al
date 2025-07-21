// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

enum 6440 "SignUp Environment Type"
{
    Access = Internal;
    Caption = 'Environment Type';

    value(0; Production)
    {
        Caption = 'Production';
    }
    value(1; Test)
    {
        Caption = 'Test';
    }
}