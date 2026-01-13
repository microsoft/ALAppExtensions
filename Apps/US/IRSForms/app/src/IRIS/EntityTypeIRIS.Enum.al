// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

enum 10043 "Entity Type IRIS"
{
    Extensible = true;

    value(1; "Transmission") { Caption = 'Transmission'; }
    value(2; "Submission") { Caption = 'Submission'; }
    value(3; "RecordType") { Caption = 'Record'; }
}