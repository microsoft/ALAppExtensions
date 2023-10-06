﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.ScriptHandler;

enum 20157 "Action Type"
{
    value(0; DRAFTROW) { }
    value(1; USECASE) { }
    value(3; IFSTATEMENT) { }
    value(4; LOOPNTIMES) { }
    value(5; LOOPWITHCONDITION) { }
    value(6; LOOPTHROUGHRECORDS) { }
    value(8; COMMENT) { }
    value(9; SETVARIABLE) { }
    value(10; ALERTMESSAGE) { }
    value(11; CONCATENATE) { }
    value(12; STRINGEXPRESSION) { }
    value(13; LENGTHOFSTRING) { }
    value(14; CONVERTCASEOFSTRING) { }
    value(15; FINDSUBSTRINGINSTRING) { }
    value(16; REPLACESUBSTRINGINSTRING) { }
    value(17; EXTRACTSUBSTRINGFROMPOSITION) { }
    value(18; EXTRACTSUBSTRINGFROMINDEXOFSTRING) { }
    value(19; NUMBERCALCULATION) { }
    value(20; NUMERICEXPRESSION) { }
    value(21; ROUNDNUMBER) { }
    value(22; DATECALCULATION) { }
    value(23; EXTRACTDATEPART) { }
    value(24; FINDINTERVALBETWEENDATES) { }
    value(46; EXITLOOP) { }
    value(47; CONTINUE) { }
    value(55; EXTRACTDATETIMEPART) { }
    value(56; DATETODATETIME) { }
}
