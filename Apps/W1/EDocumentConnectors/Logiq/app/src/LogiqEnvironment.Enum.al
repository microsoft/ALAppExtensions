// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Logiq;

enum 6431 "Logiq Environment"
{
    Extensible = false;

    value(0; " ")
    {
        Caption = '', Locked = true;
    }
    value(1; Pilot)
    {
        Caption = 'Pilot';
    }
    value(2; Production)
    {
        Caption = 'Production';
    }
}
