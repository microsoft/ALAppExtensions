// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Environment.Configuration;

enumextension 11704 "Manual Setup Category CZL" extends "Manual Setup Category"
{
    value(11700; "EET CZL")
    {
        Caption = 'EET';
    }
#if not CLEAN22
    value(11701; "Intrastat CZL")
    {
        Caption = 'Intrastat (Obsolete)';
        ObsoleteState = Pending;
        ObsoleteTag = '22.0';
        ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
    }
#endif
}
