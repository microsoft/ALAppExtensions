// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

permissionset 10032 "IRS Forms - Objects"
{
    Access = Public;
    Assignable = false;

    Permissions = table "IRS 1099 Calc. Params" = X,
                  table "IRS 1099 Email Queue" = X,
                  table "IRS 1099 Form Statement Line" = X,
                  table "IRS 1099 Form Doc. Line" = X,
                  table "IRS 1099 Form Doc. Line Detail" = X,
                  table "IRS 1099 Form Doc. Header" = X,
                  table "IRS 1099 Form" = X,
                  table "IRS 1099 Form Box" = X,
                  table "IRS 1099 Form Report" = X,
                  table "IRS 1099 Form Instruction" = X,
                  table "IRS 1099 Print Params" = X,
                  table "IRS 1099 Vendor Form Box Adj." = X,
                  table "IRS 1099 Vendor Form Box Setup" = X,
                  table "IRS 1099 Vend. Form Box Buffer" = X,
                  table "IRS Forms Setup" = X,
                  table "IRS Reporting Period" = X,
                  page "IRS 1099 Email Content Setup" = X,
                  page "IRS 1099 Form Boxes" = X,
                  page "IRS 1099 Form Documents" = X,
                  page "IRS 1099 Form Document" = X,
                  page "IRS 1099 Form Doc. Subform" = X,
                  page "IRS 1099 Form Doc Line Details" = X,
                  page "IRS 1099 Form Instructions" = X,
                  page "IRS 1099 Form Reports" = X,
                  page "IRS 1099 Form Statement" = X,
                  page "IRS 1099 Forms" = X,
                  page "IRS 1099 Vendor Form Box Setup" = X,
                  page "IRS 1099 Vend. Form Box Adjmts" = X,
                  page "IRS Forms Guide" = X,
                  page "IRS Forms Setup" = X,
                  page "IRS Reporting Periods" = X,
                  codeunit "IRS 1099 Send Email" = X,
                  codeunit "IRS 1099 Form Document" = X,
                  codeunit "IRS 1099 Vendor Form Box" = X,
                  codeunit "IRS Forms Data" = X,
                  codeunit "IRS Forms Facade" = X,
                  codeunit "IRS Reporting Period" = X,
                  report "IRS 1099 Create Form Docs" = X,
                  report "IRS 1099 Print" = X,
                  report "IRS 1099 Send Email" = X;
}
