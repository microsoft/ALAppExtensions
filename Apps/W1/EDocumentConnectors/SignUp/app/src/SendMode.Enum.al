// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

enum 6380 SendMode
{
    Access = Internal;

    value(0; Production)
    {
        Caption = 'Production', Locked = true;
    }
    value(1; Test)
    {
        Caption = 'Test', Locked = true;
    }
}