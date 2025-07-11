// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT;

enum 14600 "IS VAT Rec. Report Period"
{
    Extensible = false;
    AssignmentCompatibility = true;

    value(0; "Custom") { Caption = 'Custom'; }
    value(1; "January-February") { Caption = 'January-February'; }
    value(2; "March-April") { Caption = 'March-April'; }
    value(3; "May-June") { Caption = 'May-June'; }
    value(4; "July-August") { Caption = 'July-August'; }
    value(5; "September-October") { Caption = 'September-October'; }
    value(6; "November-December") { Caption = 'November-December'; }
}

