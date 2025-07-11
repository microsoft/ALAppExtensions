// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

permissionset 10024 "IRS 1096 Objects"
{
    Access = Public;
    Assignable = false;

    Permissions =
        table "IRS 1096 Form Header" = X,
        table "IRS 1096 Form Line" = X,
        table "IRS 1096 Form Line Relation" = X,
        page "IRS 1096 Form" = X,
        page "IRS 1096 Forms" = X,
        page "IRS 1096 Form Subform" = X,
        page "IRS 1096 Setup Wizard" = X,
        codeunit "IRS 1096 Form Mgt." = X,
        report "IRS 1096 Form" = X,
        report "IRS 1096 Create Forms" = X;
}
