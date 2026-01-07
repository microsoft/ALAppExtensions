#if not CLEAN27
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using System.Environment.Configuration;


enumextension 10580 "Feature - ReportsGB" extends "Feature To Update"
{
#pragma warning disable AS0072
    value(10580; ReportsGB)
    {
        Implementation = "Feature Data Update" = "Feature - Reports GB";
        ObsoleteState = Pending;
        ObsoleteReason = 'Feature Reports GB will be enabled by default in version 30.0.';
        ObsoleteTag = '27.0';
    }
#pragma warning restore AS0072
}
#endif