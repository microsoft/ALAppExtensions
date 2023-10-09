// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Group;

// This file should have been labeled with CLEAN22
// But it can't be deleted because it's referenced in one field in VATReportSetupExtension.TableExt.al
// Delete this when we supported deleting tables/fields
#pragma warning disable AL0659
enum 4700 "VAT Group Authentication Type OnPrem"
#pragma warning restore
{
    ObsoleteReason = 'Replaced by "VAT Group Auth Type OnPrem" as the name exceeds 30 characters.';
    ObsoleteTag = '22.0';
    ObsoleteState = Pending;

    value(0; WebServiceAccessKey)
    {
        Caption = 'Web Service Access Key';
    }
    value(1; OAuth2)
    {
        Caption = 'OAuth2';
    }
    value(2; WindowsAuthentication)
    {
        Caption = 'Windows Authentication';
    }
}
