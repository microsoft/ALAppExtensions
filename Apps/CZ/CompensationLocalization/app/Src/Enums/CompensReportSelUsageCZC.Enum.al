// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

enum 31270 "Compens. Report Sel. Usage CZC"
{
    Extensible = true;

    value(0; "Compensation")
    {
        Caption = 'Compensation';
    }
    value(1; "Posted Compensation")
    {
        Caption = 'Posted Compensation';
    }
}
