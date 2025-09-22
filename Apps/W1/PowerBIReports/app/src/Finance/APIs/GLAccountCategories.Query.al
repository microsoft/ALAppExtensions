// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.PowerBIReports;

using Microsoft.Finance.GeneralLedger.Account;

query 36958 "G/L Account Categories"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI G/L Account Categories';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'generalLedgerAccountCategory';
    EntitySetName = 'generalLedgerAccountCategories';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(GLAccountCategory; "G/L Account Category")
        {
            column(entryNo; "Entry No.")
            {
            }
            column(parentEntryNo; "Parent Entry No.")
            {
            }
            column(description; Description)
            {
            }
            column(presentationOrder; "Presentation Order")
            {
            }
            column(siblingSequenceNo; "Sibling Sequence No.")
            {
            }
            column(indentation; Indentation)
            {
            }
            column(accountCategory; "Account Category")
            {
            }
            column(incomeBalance; "Income/Balance")
            {
            }
            column(additionalReportDefinition; "Additional Report Definition")
            {
            }
            column(systemGenerated; "System Generated")
            {
            }
            column(hasChildren; "Has Children")
            {
            }
        }
    }
}