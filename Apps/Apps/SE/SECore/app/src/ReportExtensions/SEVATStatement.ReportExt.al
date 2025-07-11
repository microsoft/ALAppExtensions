// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

reportextension 11230 "SE VAT Statement" extends "VAT Statement"
{
    RDLCLayout = './src/ReportExtensions/VATStatement.rdlc';

    dataset
    {
        add("VAT Statement Line")
        {
            column(User_ID; UserId())
            {
            }
            column(VATStatementLine_RowNoCaption; FieldCaption("Row No."))
            {
            }
            column(VATStatementLine_DescriptionCaption; FieldCaption(Description))
            {
            }
        }
    }
}
