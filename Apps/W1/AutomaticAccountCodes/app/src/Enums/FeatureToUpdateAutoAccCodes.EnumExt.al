#if not CLEAN22
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AutomaticAccounts;

using System.Environment.Configuration;

enumextension 4852 "Feature To Update - Auto Acc. Codes" extends "Feature To Update"
{
    value(4850; AutomaticAccountCodes)
    {
        Implementation = "Feature Data Update" = "Feature Auto. Acc. Codes";
    }
}
#endif