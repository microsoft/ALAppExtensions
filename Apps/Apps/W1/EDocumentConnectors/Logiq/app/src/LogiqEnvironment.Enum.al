// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Logiq;

enum 6431 "Logiq Environment"
{
    Extensible = false;

    value(0; Pilot)
    {
        Caption = 'Pilot';
    }
    value(1; Production)
    {
        Caption = 'Production';
    }
}