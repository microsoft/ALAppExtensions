// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

enum 12215 "Serv. Decl. Report Type IT"
{
    Extensible = true;
    value(0; Purchases) { Caption = 'Purchases'; }
    value(1; Sales) { Caption = 'Sales'; }
}
