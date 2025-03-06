// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

enum 6394 "Continia Registration Status"
{
    Access = Internal;
    Extensible = false;

    value(0; Draft)
    {
        Caption = 'Draft';
    }
    value(1; InProcess)
    {
        Caption = 'Pending approval';
    }
    value(2; Connected)
    {
        Caption = 'Connected';
    }
    value(3; Rejected)
    {
        Caption = 'Rejected';
    }
    value(4; Disabled)
    {
        Caption = 'Disabled';
    }
}