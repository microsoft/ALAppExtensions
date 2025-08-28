#if not CLEAN27
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using System.Environment.Configuration;
using Microsoft.Finance.VAT.GovTalk;

enumextension 10554 "Feature - GovTalk" extends "Feature To Update"
{
    value(10554; GovTalk)
    {
        Implementation = "Feature Data Update" = "Feature - GovTalk";
        ObsoleteState = Pending;
        ObsoleteReason = 'Feature GovTalk will be enabled by default in version 30.0.';
        ObsoleteTag = '27.0';
    }
}
#endif