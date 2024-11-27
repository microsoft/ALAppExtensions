// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Logiq;

using Microsoft.eServices.EDocument;

enumextension 6430 "E-Doc. Service Status" extends "E-Document Service Status"
{

    value(6380; "In Progress Logiq")
    {
        Caption = 'In Progress';
    }
    value(6381; "Failed Logiq")
    {
        Caption = 'Failed';
    }
}
