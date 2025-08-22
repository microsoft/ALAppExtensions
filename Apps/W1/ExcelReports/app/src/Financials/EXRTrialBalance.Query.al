// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Finance.ExcelReports;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.Dimension;

query 4405 "EXR Trial Balance"
{
    Access = Internal;
    DataAccessIntent = ReadOnly;
    QueryType = Normal;

    elements
    {
        dataitem(GLAccount; "G/L Account")
        {
            column(AccountNumber; "No.")
            {
            }
            dataitem(GLEntry; "G/L Entry")
            {
                DataItemLink = "G/L Account No." = GLAccount."No.";
                SqlJoinType = InnerJoin;
                column(Amount; Amount)
                {
                    Method = sum;
                }
                column(ACYAmount; "Additional-Currency Amount")
                {
                    Method = sum;
                }
                filter(PostingDate; "Posting Date")
                {
                }
                dataitem(DimensionValue1; "Dimension Value")
                {
                    DataItemLink = Code = GLEntry."Global Dimension 1 Code";
                    SqlJoinType = LeftOuterJoin;
                    column(DimensionValue1Code; Code)
                    {
                    }
                    dataitem(DimensionValue2; "Dimension Value")
                    {
                        DataItemLink = Code = GLEntry."Global Dimension 2 Code";
                        SqlJoinType = LeftOuterJoin;
                        column(DimensionValue2Code; Code)
                        {
                        }
                    }
                }
            }
        }
    }
}