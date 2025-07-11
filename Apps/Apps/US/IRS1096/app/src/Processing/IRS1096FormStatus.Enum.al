// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

enum 10016 "IRS 1096 Form Status"
{
    Extensible = true;
    value(0; Open) { Caption = 'Open'; }
    value(1; Released) { Caption = 'Released'; }
}
