// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Reporting;

query 10504 "EU VAT Entries GB"
{
    Caption = 'EU VAT Entries';

    elements
    {
        dataitem(VAT_Entry; "VAT Entry")
        {
            DataItemTableFilter = Type = const(Sale);
            column(Entry_No; "Entry No.")
            {
            }
            dataitem(ECSL_VAT_Report_Line_Relation; "ECSL VAT Report Line Relation")
            {
                DataItemLink = "VAT Entry No." = VAT_Entry."Entry No.";
                SqlJoinType = LeftOuterJoin;
                column(VAT_Entry_No; "VAT Entry No.")
                {
                }
                column(ECSL_Line_No; "ECSL Line No.")
                {
                }
                column(ECSL_Report_No; "ECSL Report No.")
                {
                }
                dataitem(ECSL_VAT_Report_Line; "ECSL VAT Report Line")
                {
                    DataItemLink = "Line No." = ECSL_VAT_Report_Line_Relation."ECSL Line No.", "Report No." = ECSL_VAT_Report_Line_Relation."ECSL Report No.";
                    SqlJoinType = LeftOuterJoin;
                    column(Line_Status; "Line Status GB")
                    {
                    }
                    column(XML_Part_Id; "XML Part Id GB")
                    {
                    }
                    column(Line_No; "Line No.")
                    {
                    }
                    column(Report_No; "Report No.")
                    {
                    }
                }
            }
        }
    }
}

